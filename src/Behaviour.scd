/*

---- ---- ---- ---- OF 'Behaviour' ---- ---- ---- ----

*/

(

var behaviour = ();

behaviour.run = {|ev, ndef|
	ndef.play
};

behaviour.mfb = {|ev, nin|

var name = ("mfb\_" ++ name).asSymbol;

NF(name,
{| feedback=0.998, delay=0.08, shiftFreq=10, shiftMod=20, shiftLpf=18000, amp=1.0|
var sig, input, first, second, shiftSnd, combined;

    // Ndef to process
    sig = nin.ar;

    // local in, 4 channels
    input = sig + LocalIn.ar(4);

    // 1 - 2
    first = input.clump(2)[0];
    first = FreqShift.ar(first, LFNoise1.ar(shiftMod*0.5).range(shiftFreq,shiftFreq*3));

    shiftSnd = LPF.ar(FreqShift.ar(first, LFNoise1.ar(shiftMod).range(shiftFreq,shiftFreq*4)),shiftLpf);

    // 3 -4
    second = input.clump(2)[1];
    second = MostChange.ar(first, shiftSnd);

    // delay it
    first = DelayC.ar(first, 1, LFNoise1.ar(0.1).range(delay*0.5,delay*1.3));
    second = DelayC.ar(second, 1, LFNoise1.ar(0.1).range(delay,delay*1.4));

    combined = (first ++ second) * 0.6;

    // local out
    LocalOut.ar(combined * feedback);

    CombC.ar( Limiter.ar( Splay.ar( combined ), 0.9 * amp), 0.1, 0.1, 0.2)

}).play

};

behaviour.mcloud = {|ev,nin,dur=2,times=4|

    TF(\mcloud, {
    	var recorder = (nin ++ "_mcrecord").asSymbol;
    	var ripa = (nin ++ "_mripa").asSymbol;
    	var ripb = (nin ++ "_mripb").asSymbol;
    	var ampf = (nin ++ "_mampf").asSymbol;

    	// Allocate a buffer for a 2 second stereo signal
    	var buf = Buffer.alloc(Server.local, 44100 * 2.0, 2); s.sync;

    	times.do {

    		" ## MC plays ".postln;

    		Ndef(nin).play;

    		Ndef(recorder, {
    			RecordBuf.ar(Ndef(nin).ar, buf, doneAction: Done.freeSelf, loop: 0);
    		}).play;

    		dur.wait;

    		" ## Done recording ".postln;

    		NF(ripa, {
    			var input = PlayBuf.ar(2, buf, 1, loop: 1);
    			var dens = LFDNoise3.kr(2).range(0.018, 0.045);
    			var pos = LFDNoise3.kr(4).range(0.5, 1.0);
    			MiClouds.ar(input, 0, pos, 0.1, dens, 0.5, drywet: 1, mode: 0, mul:2);
    		}).play;

    		0.5.wait; Ndef(nin).stop;

    		" ## Rip A ".postln;

    		dur.wait;

    		NF(ripb, {
    			var input = PlayBuf.ar(2, buf, 1, loop: 1);
    			var dens = LFDNoise3.kr(2).range(0.018, 0.45);
    			var pos = LFDNoise3.kr(4).range(0.5, 1.0);
    			var grains = MiClouds.ar(input, 0, pos, 0.2, dens, 0.5, drywet: 1, mode: 0, mul:4);
    			BPF.ar(grains, 100, 2);
    		}).play;

    		" ## Rip B ".postln;

    		dur.wait;

    		" ## Ampf ".postln;

    		NF(ampf, {
    			var sd = SampleDur.ir * 0.5;
    			var size = 5, from = 1, to = 25;
    			var modFreq = 10, modFrom = 15, modTo = 25;
    			var ampFollow = Amplitude.ar(PlayBuf.ar(2,buf,1,1,0,1),0.05,0.05);

    			DemandEnvGen.ar(
    				Dseq([1, [-1, 0.5], rrand(0.0,1.0), rrand(-0.9,0.9)], inf),
    				Dseq(Array.rand(size,from,to), inf) * sd
    			).atan(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))) * ampFollow * 4;
    		}).play;

    		(dur*2).wait;

    		" ## mc, loop ends ".postln;
    	};

    	NF(ampf).stop;
    	NF(ripa).stop;
    	NF(ripb).stop;

    })

};

behaviour.switchx = {|ev,pool,dur=6|

    {

		pool.items.do {|pl|

			pl.play;
			rrand(dur,dur*2).wait;
			o.action.iinterrupt(pl.key);
			rrand(0.5,1.5).wait;
		}

    }.fork;

};

behaviour.overlap = {|ev,nodes,dur=8,overlap=2,next=7,amp=0.75|

    var envDur = [dur*overlap,dur,dur*overlap];

    {
    	nodes.do{|node|

    		Ndef(("overlap" + node.key).asSymbol, {
    			HPF.ar(node.ar, 40, amp) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur))
    		}).play;

    		node.key.postln; // emit event!
    		next.wait;
    	}

    }.fork

};

behaviour.shadow = {|ev,nodes,dur=8,overlap=2,next=6,amp=1.0,factor=0.5|

    var envDur = [dur*overlap,dur,dur*overlap];

    {
    	nodes.do{|node,i|

			if(i % 2 == 0, {
    			Ndef(("shadowhi" + node.key).asSymbol, {
    				HPF.ar(node.ar, 40, amp) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur))
    			}).play;

    			node.key.postln; next.wait;

    		}, {
    			Ndef(("shadowlow" + node.key).asSymbol, {
    				HPF.ar(node.ar, 40, amp * 0.3) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur * 0.5))
    			}).play;

    			node.key.postln; (next * factor).wait;
			})
    	}

    }.fork

};

behaviour.brpb = {|ev, node, durFrom=2, durTo=4, filtFrom=100, filtTo=4000, bw=6, res=0.1, bramp=1.0, bpamp=1.0, cb|

    var nbr = ("brjct1"+node.key).asSymbol;
    var nbp = ("brjct2"+node.key).asSymbol;

    {
    	inf.do {
    		Ndef(nbr, { BBandStop.ar(node.ar, rrand(filtFrom,filtTo), bw, bramp ) }).play;
    		Ndef(nbp, { BBandPass.ar(node.ar, rrand(filtFrom,filtTo), res, bpamp ) }).play;
    		rrand(durFrom,durTo).wait;
    	};

    	Ndef(nbr).stop;
    	Ndef(nbp).stop;
    	cb.();

    }.fork;

    [ Ndef(nbp), Ndef(nbp) ]
};

behaviour.lfswitch = {|ev,nodes, freq, from, to, emitter|
	Ndef(\switcher, {
		var trig = LFNoise0.ar(SinOsc.ar(freq).range(from,to));
		SendTrig.ar(trig);
		Lag.ar(Select.ar(trig.range(0,nodes.size), nodes.collect{|node| node.ar}),0.01);
	}).play
};

behaviour.fspread = {|ev, nodes, range=10000, base=100, mult=10, bw=0.5, delFrom=1, delTo=2|

var amount = range / nodes.size;

{

nodes.do {|node,i|
	Ndef(("fspread" ++ node.key).asSymbol, {
		var snd = BBandPass.ar(node.ar, base + ( amount * i ), bw);
		snd * (mult / nodes.size)
	}).play;

	rrand(delFrom,delTo).wait;

};

}.fork;

};

behaviour.selectx = {|ev, nodes, freq, from, to, emitter|
	Ndef(\switcherx, {
		var trig = SinOsc.ar(0.1).range(0.0,nodes.size);
		SelectXFocus.ar(trig, nodes.collect{|node| node.ar},2,true);
	}).play
};

behaviour.interp = {|ev,node, param, from, to, env, dur=10, step=0.1, times=inf|
    var n = dur / step;
    var m = to - from;

    node.play;

    {
    	times.do{
    		n.do{|i|
    			var index = i.linlin(0,n-1,0.0,1.0);
    			var value = (from + (m * env[index]));
    			node.set(param, value);
    			step.wait;
    		}
    	}
    }.fork
};

behaviour

)
