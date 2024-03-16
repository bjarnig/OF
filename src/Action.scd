
/*

  ---- ---- ---- ---- OF 'Actions' ---- ---- ---- ----

		direct influences of NFs through actions

*/

(

var actions = ();

actions.interrupt = {|ev, name, freq=10, output=0|
	var local = ("interrupt_" ++ name).asSymbol;
	var f1 = rrand(2.3, 7.5), f2 = rrand(3.2, 8.5);

	{
		NF(local, {
			var lpf=150, hpf=8000, gaina=1000, gainb=200, son = NF(name).ar;

			BPeakEQ.ar( HPF.ar(SoftClipAmp8.ar(son, pregain:gaina)
			* EnvGen.ar(Env([0.2,0.1,0.0], [3,4,15])), Lag.ar(LFNoise0.ar(f1).range(hpf, hpf*2))) +
			BBandStop.ar(LPF.ar(SoftClipAmp8.ar(son, pregain:gainb)
				* EnvGen.ar(Env([0.2,0.1,0.0], [2,5,15])), Lag.ar(LFNoise0.ar(f2).range(lpf*0.25, lpf))),80, 0.1), 100, 1, -3) * 0.7;

		}).play(output);

		0.1.wait;
		NF(name).stop;
		25.wait;
		NF(local).stop;

	}.fork;

    NF(local)
};

actions.drop = {|ev, name, freq=1000, delay=0.2, decay=0.4,output=0|
	var local = ("drop_" ++ name).asSymbol, dur = rrand(12, 14);

	{
		NF(local, {
			var son = NF(name).ar;
			var modTo = EnvGen.ar(Env(Array.geom(4, rrand(6,10), rrand(2,4)), [dur/2,dur/4,dur/6]));
			var filter = EnvGen.ar(Env(Array.series(4, rrand(freq,freq*5), rrand(freq *1.5,freq*4.5)), [dur/2,dur/4,dur/6]));
			var hpfSound = HPF.ar(son.tanh.distort, LFPar.ar( LFNoise1.ar(rrand(1,10)).range(modTo/4,modTo)).range(filter/4,filter));
			CombC.ar(hpfSound, 0.8, delay, decay) * EnvGen.ar(Env([1,0.75,0.5,0.0], [dur/6,dur/4,dur/2]));
		}).play(output);

		0.5.wait;
	    NF(name).stop;
		dur.wait;
		NF(local).stop;

 	}.fork;

	^NF(local)
};

actions.disturb = {|ev, name, freq=1000, mod=28, delay=0.2, feedback = 0.9,output=0|
	var local = ("disturb_" ++ name).asSymbol;
	var dur = rrand(20, 25);

	{
		NF(local, {
			var son = NF(name).ar;
			var bpf = LFNoise1.kr(XLine.kr(3,40,dur)).range(freq,(freq*8).min(15000));
			var q = XLine.kr(4,1,dur);
			var sig = Fb({|fbSig| BPF.ar(fbSig * feedback + son, bpf, q).tanh; }, 1.0, delay.min(1.0));
			// Feedback Quark is required, Quarks.install("Feedback")
			sig = LPF.ar(son, 80) + sig;
			sig = sig * EnvGen.ar(Env([1,0.8,0.5,0.0], [dur/2,dur/3,dur/4]));
			sig = XFade2.ar(sig, sig * LFNoise0.ar(mod).range(0.2,1.2), XLine.kr(-1, 1, dur/3));
			sig * EnvGen.ar(Env([1,0.75,0.5,0.0], [dur/2,dur/2,dur/2])) * 0.4;
		}).play(output);

		0.1.wait;
		NF(name).stop;
		(dur).wait;
		NF(local).stop;

	}.fork;

	^NF(local)
};

actions.hinder = {|ev, name,freq=2000,output=0|
	var local = ("hinder_" ++ name).asSymbol;
	var dur = rrand(11, 13);

	{
		NF(local, {
			var son = NF(name).ar;
			var inFreq = Mix.ar(Tartini.kr(son));
			var signal = LeastChange.ar(son, BBandStop.ar(Gendy1.ar(minfreq:inFreq/2,maxfreq:inFreq/3), freq, 0.01));
			HPF.ar(signal * 0.1, XLine.ar(40, 2000, dur)) * EnvGen.ar(Env([1,0.75,0.5,0.0], [dur/2,dur/2,dur/4]));
		}).play(output);

		0.1.wait;
		NF(local).play;
		NF(name).stop;
		(dur).wait;
		NF(local).stop;

	}.fork;

	^NF(local)
};

actions.cut = {|ev, name, inFreq=100,output=0|
	var local = ("cut_" ++ name).asSymbol;
	var dur = rrand(9, 14);

	{
		NF(local, {
			var son = \in.ar([0,0]);
			var side = Limiter.ar((son.squared + (50*son))/(son.squared + ((50-1)*son) + 1), 0.7);
			var side2 = MoogFF.ar(side, LFNoise2.ar(inFreq/Line.kr(1, 40, dur)).range(inFreq,inFreq*4));
			var signal = Compander.ar(son, side2, 0.1, 1, 0.1, 0.01, 0.1);
			var hpfSound = HPF.ar(signal.fold2(SinOsc.ar(inFreq/rrand(20,40))) + side2, XLine.ar(40, 8000, dur));
			hpfSound * EnvGen.ar(Env([1,0.75,0.5,0.0], [dur/2,dur/2,dur/4]));
		}).play(output);

		0.1.wait;
		NF(name).stop;
		NF(local).stop;
	}.fork;

	^NF(local)
};

actions

)