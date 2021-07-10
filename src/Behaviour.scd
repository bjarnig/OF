/*

---- ---- ---- ---- OF 'Behaviour' ---- ---- ---- ----

*/

(

var behaviour = ();

behaviour.run = {|ev, nf|
	nf.play
};

behaviour.mfb = {|ev, nin|

	var name = ("mfb\_" ++ name).asSymbol;

	NF(name,
	{|feedback=0.998, delay=0.08, shiftFreq=10, shiftMod=20, shiftLpf=18000, amp=1.0|
		var sig, input, first, second, shiftSnd, combined;

		// NF to process
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

behaviour.switchx = {|ev,pool,dur=6|

    {
		pool.do {|pl|

			pl.play;
			rrand(dur,dur*2).wait;
			o.action.iinterrupt(pl.key);
			rrand(0.5,1.5).wait;
		}
    }.fork
};

behaviour.overlap = {|ev,nodes,dur=8,overlap=2,next=7,amp=0.75, output=0, emit, cb|

    var envDur = [dur*overlap,dur,dur*overlap];

    {
    	nodes.do{|node|

			var name = OF.key(node, "overlap");

    		NF(name, {
    			HPF.ar(node.ar, 40, amp) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur))
			}).play(output);

			if(emit.notNil, { emit.(name) }); next.wait;
    	};

		if(cb.notNil, { cb.() })

    }.fork

};

behaviour.shadow = {|ev,nodes,dur=8,overlap=2,next=6,amp=1.0,factor=0.5, output=0, emit, cb|

    var envDur = [dur*overlap,dur,dur*overlap];

    {
		nodes.do{|node,i|

			if(i % 2 == 0, {
    			NF(OF.key(node, "shadowhi"), {
    				HPF.ar(node.ar, 40, amp) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur))
				}).play(output);

				if(emit.notNil, { emit.(node.key) }); next.wait;
    		}, {
    			NF(OF.key(node, "shadowlow"), {
    				HPF.ar(node.ar, 40, amp * 0.3) * EnvGen.ar(Env( [0.0,1.0,1.0,0.0], envDur * 0.5))
				}).play(output);

    			if(emit.notNil, { emit.(node.key) }); (next * factor).wait;
			})
    	};

		if(cb.notNil, { cb.() })

    }.fork
};

behaviour.brpb = {|ev, nodes, durFrom=2, durTo=4, filtFrom=100, filtTo=4000, bw=6, res=0.1, bramp=1.0, bpamp=1.0, output=0, emit, cb|

	var result = List();

	{
    	nodes.do {|node|

			var nbr = OF.key(node, "brjct1");
			var nbp = OF.key(node, "brjct2");

			NF(nbr, { BBandStop.ar(node.ar, rrand(filtFrom,filtTo), bw, bramp ) }).play(output);
			NF(nbp, { BBandPass.ar(node.ar, rrand(filtFrom,filtTo), res, bpamp ) }).play(output);
			result.add(nbr); result.add(nbp);

			if(emit.notNil, { emit.(node.key) });
    		rrand(durFrom, durTo).wait;
    	};

		result.do{|node| node.stop };
		if(cb.notNil, { cb.() })

    }.fork;

    output
};

behaviour.lfswitch = {|ev, nodes, modFreq, freqfrom, freqTo, output=0, emit|

	var name = '/lfswitch' ++ 100000.rand;
	var path = name.asSymbol;
	var nf = name.replace("/","").asSymbol;
	var func = OSCFunc(emit, path, s.addr);

	NF(nf, {
		var trig = LFNoise0.ar(SinOsc.ar(modFreq).range(freqfrom,freqTo));
		var selection = trig.range(0,nodes.size);
		var reply = Changed.ar(selection);
		SendReply.ar(reply, path);
		Select.ar(selection, nodes.collect{|node| node.ar});
	}).play(output)
};

behaviour.lfswitchx = {|ev, nodes, freq=5, focus=2, wrap=true, output=0, emit|

	var name = '/switcherx' ++ 100000.rand;
	var path = name.asSymbol;
	var nf = name.replace("/","").asSymbol;
	var osc = (name.replace("/","") ++ osc).asSymbol;
	var func = OSCdef(osc, emit, path, s.addr);

	NF(nf, {
		var trig = LFNoise0.ar(freq);
		var selection = trig.range(0,nodes.size);
		var reply = Changed.ar(selection);
		SendReply.ar(reply, path);
		SelectXFocus.ar(selection, nodes.collect{|node| node.ar}, focus, wrap);
	}).play(output)
};

behaviour.fspread = {|ev, nodes, range=10000, base=100, mult=10, bw=0.5, delFrom=1, delTo=2, output=0, emit, cb|

	var amount = range / nodes.size;

	{
		nodes.do {|node,i|
			NF(OF.key(node, "fspread"), {
				var snd = BBandPass.ar(node.ar, base + ( amount * i ), bw);
				snd * (mult / nodes.size)
			}).play(output);

			if(emit.notNil, { emit.(node.key) });
			rrand(delFrom,delTo).wait
		};

		if(cb.notNil, { cb.() })

	}.fork
};

behaviour.interp = {|ev,node, param, from, to, env, dur=10, step=0.1, times=inf, output=0, emit, cb|

	var n = dur / step;
	var m = to - from;

	node.play(output);

	{
		times.do{
			n.do{|i|
				var index = i.linlin(0,n-1,0.0,1.0);
				var value = (from + (m * env[index]));
				node.set(param, value);
				step.wait;
			};
			if(emit.notNil, { emit.(node.key) });
		};

		sif(cb.notNil, { cb.() })

	}.fork
};

behaviour

)
