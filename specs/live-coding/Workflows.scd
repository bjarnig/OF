////////////////////////////////////////////////////////////////
//
//                    Live Coding - Workflows
//
////////////////////////////////////////////////////////////////


// 01. Tdef driving Ndef parameters (sound: \depfm)

(
Ndef(\pad, {|freqMin=5, freqMax=10, mul=20, add=80, rate=0.5, modFreq=2100, index=0.3, amp=0.4|
	var trig = Impulse.kr(rate);
	var seq  = Diwhite(freqMin, freqMax, inf).midicps;
	var freq = Demand.kr(trig, 0, seq);
	HPF.ar(PMOsc.ar(LFCub.kr([freq, freq/2], 0, mul, add), modFreq, index) * 0.4 * amp, 30)
}).play;
)

(
Tdef(\evolve, {
	loop {
		Ndef(\pad).set(
			\freqMin, rrand(3, 8),
			\freqMax, rrand(8, 14),
			\modFreq, rrand(800, 4000),
			\index,   rrand(0.1, 1.2)
		);
		rrand(3.0, 8.0).wait;
	}
}).play;
)

(
Tdef(\evolve, {
	loop {
		Ndef(\pad).set(\freqMin, rrand(1, 4), \freqMax, rrand(4, 6), \mul, rrand(10, 60));
		rrand(0.5, 2.0).wait;
	}
});
)

Tdef(\evolve).stop;
Ndef(\pad).stop;
Ndef.clear;


// 02. Routine-based parameter evolution (sound: \varsaw)

(
Ndef(\morph, {|freq=100, amp=0.4|
	var sig = VarSaw.ar(
		LFPar.ar([freq/10, freq/20], 0, 10, LFPar.kr(5, 0, 5, freq)),
		0, LFNoise2.kr(freq/3, 0.5, 1.5)
	) * 0.15;
	BBandStop.ar(sig, LFNoise1.kr(freq/10, 300, 700), 4) * amp
}).play;
)

// Morph from state A to state B over 20 seconds
(
~morphParams = { |ndef, from, to, dur=20|
	var steps = 100;
	var wait  = dur / steps;
	Routine({
		steps.do { |i|
			var t = i / steps;
			from.keysValuesDo { |key, valA|
				var valB = to[key];
				ndef.set(key, valA.blend(valB, t));
			};
			wait.wait;
		};
		"morph done".postln;
	}).play;
};

~morphParams.(
	Ndef(\morph),
	(\freq: 60,  \amp: 0.3),
	(\freq: 300, \amp: 0.6),
	20
);
)

Ndef(\morph).stop;
Ndef.clear;


// 03. Multi-source mixer Ndef

(
// Folding sine plane
Ndef(\s1, {|amp=0.4|
	var sd = SampleDur.ir;
	var trig = Impulse.kr(0.5);
	var seq  = Dseq([Dbrown(10, 30, 2, 16), Dwhite(10, 20, 8)], inf);
	var freq = Demand.kr(trig, 0, seq);
	DemandEnvGen.ar(
		Dseq([0.1, -0.1, [-0.2, 0.2]], inf),
		Dseq([sd * 9, sd * 5], inf)
	).fold2(SinOsc.ar([freq, freq*0.5])) * 0.23 * amp;
});

// Brownian Blip drone
Ndef(\s2, {|amp=0.3|
	var brown = Dbrown(60, 70, 100, inf);
	var trig  = Impulse.kr(LFNoise1.kr(0.3, 4000, 15));
	var freqd = Demand.kr(trig, 0, brown);
	var sig   = Blip.ar(freqd, 15, 4);
	sig = HPF.ar(sig.fold2(SinOsc.ar(20)), freqd * 1.2, amp);
	BBandStop.ar(sig, LFNoise1.kr(0.4).range(600, 6000), 6)
});

// Crackle noise with bandstop modulation
Ndef(\s3, {|amp=0.3|
	BBandStop.ar(
		LPF.ar(Crackle.ar(LFNoise2.ar(12).range(1.01, 1.5), 0.5), 12000),
		StandardL.ar(5.4).range(100, 300), 6
	) * amp
});

// Simple bass FM
Ndef(\s4, {|amp=0.3|
	var trig = Impulse.kr(2);
	var seq  = Diwhite(4, 14, inf).midicps;
	var freq = Demand.kr(trig, 0, seq);
	SinOsc.ar(LFCub.kr([freq, freq/2], 0, 40, 60), 0, 0.055) * 2 * amp
});

Ndef(\mixer, { |l1=0, l2=0, l3=0, l4=0|
	var sources = [Ndef(\s1).ar, Ndef(\s2).ar, Ndef(\s3).ar, Ndef(\s4).ar];
	Mix(sources * [l1, l2, l3, l4]);
}).play;
)

// Bring sources in one by one
Ndef(\mixer).set(\l1, 1);
Ndef(\mixer).set(\l2, 0.5);
Ndef(\mixer).set(\l3, 0.4);
Ndef(\mixer).set(\l4, 0.7);

(
Tdef(\autoMix, {
	loop {
		Ndef(\mixer).set(
			\l1, rrand(0.2, 1.0), \l2, rrand(0.0, 0.8),
			\l3, rrand(0.0, 0.6), \l4, rrand(0.2, 0.9)
		);
		rrand(4.0, 8.0).wait;
	}
}).play;
)

Tdef(\autoMix).stop;
Ndef(\mixer).stop;
Ndef.clear;


// 04. Pbindef incremental

(
SynthDef(\fmPerc, { |freq=440, mod=200, amp=0.2, pan=0, gate=1|
	var env = EnvGen.ar(Env.perc(0.005, 0.3, 1, -4), gate, doneAction: 2);
	var sig = SinOsc.ar(freq, SinOsc.ar(mod, 0, 2pi)) * amp * env;
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
Pbindef(\build,
	\instrument, \fmPerc,
	\dur,        0.25,
	\midinote,   60,
	\mod,        200,
	\amp,        0.15
).play;
)

Pbindef(\build, \midinote, Pseq([60, 63, 67, 72], inf));
Pbindef(\build, \dur, Pseq([0.25, 0.125, 0.125, 0.5], inf));
Pbindef(\build, \mod, Pwhite(50, 800, inf));
Pbindef(\build, \amp, Pwhite(0.06, 0.2, inf));
Pbindef(\build, \pan, Pwhite(-0.8, 0.8, inf));
Pbindef(\build, \midinote, Prand([48, 55, 60, 63, 67, 72, 79], inf));

(
Tdef(\buildBot, {
	var pitches = [
		Pseq([60, 63, 67, 72], inf),
		Prand([48, 55, 60, 67], inf),
		Pbrown(55, 79, 3, inf)
	];
	var durs = [
		0.05,
		Pseq([0.125, 0.125, 0.25], inf),
		Prand([0.125, 0.25, 0.5], inf)
	];
	loop {
		Pbindef(\build, \midinote, pitches.choose, \mod, Pwhite(50, 1500, inf));
		rrand(4, 8).wait;
		Pbindef(\build, \dur, durs.choose);
		rrand(4, 8).wait;
	}
}).play;
)

Tdef(\buildBot).stop;
Pbindef(\build).stop;
Pbindef(\build).clear;


// 05. Node proxy roles: \set, \filter, \setsrc in one Ndef (sound: \swsc)

(
Ndef(\multi).play;
Ndef(\multi).fadeTime = 2;

Ndef(\multi)[0] = { |freq=80, mfreq=12|
	HPF.ar(
		BBandStop.ar(
			Saw.ar(LFNoise1.ar([mfreq, mfreq*0.6]).range(freq, freq*2), 0.2)
			.excess(SinOsc.ar([freq+6, freq+4, freq+2, freq+8])),
			LFNoise1.ar(10).range(100, 900),
			SinOsc.ar(20).range(7, 20)
		), 80
	) * 0.5
};

Ndef(\multi)[1] = \set -> Pbind(
	\dur,   Prand([0.1, 0.2, 0.5], inf),
	\freq,  Pwhite(40, 200),
	\mfreq, Pwhite(5, 25)
);

Ndef(\multi)[2] = \filter -> { |in|
	LPF.ar(in, LFNoise1.ar(2).range(300, 5000))
};
)

(
Ndef(\multi)[0] = { |freq=80, mfreq=6|
	var freqArr = [freq, freq+5, freq+10, freq+15];
	var modArr  = [mfreq, mfreq/2, mfreq/3, mfreq/4];
	Splay.ar(HPF.ar(Blip.ar(freqArr, 150).fold2(SinOsc.ar(modArr)), 30)) * 0.3
};
)

(
Ndef(\multi)[2] = \filter -> { |in|
	RLPF.ar(in, SinOsc.kr(0.3).range(200, 6000), 0.2)
};
)

Ndef(\multi).stop;
Ndef.clear;


// 06. Two Ndefs interacting

(
Ndef(\mod, { |rate=3, lo=60, hi=900|
	Lag.ar(GbmanL.ar(
		LFNoise1.kr(0.1, 0.5, rate),
		LFNoise1.kr(0.2, 500, 1000), 0.25, 0.5
	).range(lo, hi), 0.1)
});

Ndef(\synth, { |freq=60, index=10, amp=0.3|
	var mod = Ndef.ar(\mod);
	BPeakEQ.ar(
		PMOsc.ar(
			[LFNoise2.kr(0.05, freq/5, freq), LFNoise2.kr(0.01, freq/10, freq/2)],
			mod, index, 0, 0.2
		),
		3000, 2, -12, 0.5
	) * amp
}).play;
)

(
Tdef(\pilot, {
	loop {
		var rate  = rrand(1.0, 8.0);
		var lo    = rrand(30, 200);
		var hi    = rrand(400, 2000);
		var freq  = rrand(40, 120);
		var index = rrand(2, 15);

		Ndef(\mod).set(\rate, rate, \lo, lo, \hi, hi);
		Ndef(\synth).set(\freq, freq, \index, index);

		"rate: % | lo: % | hi: % | freq: % | index: %".format(
			rate.round(0.1), lo.round(1), hi.round(1), freq.round(1), index.round(0.1)
		).postln;

		rrand(4.0, 10.0).wait;
	}
}).play;
)

Tdef(\pilot).stop;
Ndef(\synth).stop;
Ndef.clear;


// 07. Gradual build-up with Tdef

(

Ndef(\bass, {|amp=0.4|
	BPeakEQ.ar(
		DFM1.ar(
			SinOsc.ar([62, 70] * LFNoise0.ar([2, 4, 8, 16]).range(0.98, 1.02), 0, 0.1),
			400, SinOsc.kr(10.1).range(0.92, 1.0185), 1, 0, 0.003, 0.5
		), 50, 4, -9
	) * 2.5 * amp
});

Ndef(\mid, {|amp=0.3|
	var signal = DemandEnvGen.ar(
		Dseq([-1, 0.1, Dwhite(-0.1, 0.1, 5), Dwhite(-0.2, 0.2, 5)], inf),
		SampleDur.ir * Array.rand(8, 0.8, 8.2), 1, 0, 1, Impulse.ar([10, 40])
	) * XLine.ar(0.0015, 0.15, 12);
	BPeakEQ.ar(signal, Array.rand(8, 4000, 10000), 4,
		EnvGen.ar(Env([0, -1, -7], [4, 12]))) * 2 * amp
});

Ndef(\high, {|amp=0.5|
	var freq = 4200, freqx = freq - 5;
	Splay.ar(
		RLPF.ar(
			Saw.ar(LFNoise2.ar([0.1, 0.15], 2).range(freqx, freqx * Array.rand(8, 0.5, 2.0))),
			1200
		) * EnvGen.ar(Env.perc(0.004, 0.08, 3.0), Impulse.ar(Array.rand(8, 0.5, 1.2)))
	) * amp
});

Ndef(\noise, {|amp=0.4|
	var sig = Dust.ar(120) + Crackle.ar(0.9);
	var timeUp = 6, timeDown = 8;
	var holder = EnvGen.ar(Env([0, 1, 0], [timeUp, timeDown]).circle);
	var sinFrom = EnvGen.ar(Env([0, 1, 0], [timeUp*2, timeDown/2]).circle);
	var mod = LFNoise2.ar([4, 8]).range(sinFrom, 1.0);
	sig = sig * Line.kr(0, 1, timeUp);
	sig * (mod * holder) ! 2 * amp
});

[\bass, \mid, \high, \noise].do { |name| Ndef(name).fadeTime = 5 };
)

(
Tdef(\buildUp, {
	"-- build-up start --".postln;

	Ndef(\bass).play;
	"+ bass (DFM1 filtered sine)".postln;
	8.wait;

	Ndef(\mid).play;
	"+ mid (DemandEnvGen waveshaping)".postln;
	8.wait;

	Ndef(\high).play;
	"+ high (sparkling saws)".postln;
	8.wait;

	Ndef(\noise).play;
	"+ noise (dust + crackle)".postln;
	6.wait;

	[\bass, \mid, \high, \noise].do { |name|
		Ndef(name).filter(10, { |in| in + FreeVerb.ar(in, 0.4, 0.9, 0.3) });
	};

	"-- build-up complete --".postln;
}).play;
)

Ndef.clear;


// 08. Scene system, switching between configurations

(
~scenes = Dictionary();

~scenes[\drone] = {
	Ndef(\drone, {|freq=60, index=10, modMult=15, amp=0.4|
		var mod = Lag.ar(GbmanL.ar(
			LFNoise1.kr(0.1, 0.5, 3.5), LFNoise1.kr(0.2, 500, 1000), 0.25, 0.5
		).range(freq, freq * modMult), 0.1);
		BPeakEQ.ar(
			PMOsc.ar([LFNoise2.kr(0.05, freq/5, freq), LFNoise2.kr(0.01, freq/10, freq/2)],
				mod, index, 0, 0.2),
			3000, 2, -12, 0.5
		) * amp
	}).play;
};

~scenes[\grain] = {
	Ndef(\grain, {|rate=20, grAtk=0.88, grRel=0.2, amp=0.6|
		var trigger = (Impulse.ar(rate) * 0.8) + (Dust.ar(rate) * 0.2);
		var env = EnvGen.ar(Env.perc(grAtk, grRel, 1, 4), trigger, 1, 0, (1/rate));
		Mix.ar(HPF.ar(
			SinOsc.ar([rate/3, rate], 0, env * 0.5) +
			BPF.ar(PinkNoise.ar(mul: env), rate * Array.series(8, 4, 4), 0.2),
		40)) * amp
	}).play;
};

~scenes[\pulse] = {
	Ndef(\pulse, {|freq=101, amp=0.4|
		var p = Pulse.ar(LFPulse.ar(120, 0, 0.55, freq/8, freq), Saw.ar(freq/3));
		var bass  = MoogFF.ar(p, LFNoise1.ar(10, 10, freq), 3) ! 2 * 0.3;
		var highs = RHPF.ar(p, LFNoise0.ar(1, 20, freq * 60), 3) ! 2 * 0.3;
		(bass + highs) * amp
	}).play;
};
)

~scenes[\drone].value;

(
~transition = { |sceneName, dur=6|
	Tdef(\trans, {
		Ndef.all.do { |n| n.fadeTime = dur; n.stop(dur) };
		(dur * 0.5).wait;
		~scenes[sceneName].value;
		Ndef.all.do { |n| n.fadeTime = dur };
		">> scene: %".format(sceneName).postln;
	}).play;
};
)

~transition.(\grain, 5);
~transition.(\pulse, 6);
~transition.(\drone, 8);

Ndef.clear;


// 09. Feedback network with an Ndefs

(
Ndef(\src, {|freq=60, clipfreq=12|
	HPF.ar(
		PMOsc.ar(freq,
			Lag.ar(LFDClipNoise.ar(clipfreq).range(2, 16), 0.01),
			[1000, 2000]
		).fold2(SinOsc.ar(freq)),
		LFNoise1.ar(6).range(100, 3000), 0.3
	) * 0.3
}).play;

Ndef(\fb, {
	var sig = Ndef.ar(\src);
	sig = DelayC.ar(sig, 1.0, LFNoise1.ar(0.3).range(0.05, 0.4));
	LPF.ar(sig, LFNoise1.ar(0.5).range(300, 6000))
});

Ndef(\src)[1] = \filter -> { |in| in + (Ndef.ar(\fb) * 0.85) };
)

(
Tdef(\fbCtrl, {
	loop {
		var freq = rrand(30, 120);
		var clip = rrand(4, 30);
		Ndef(\src).set(\freq, freq, \clipfreq, clip);
		"fb freq: % | clip: %".format(freq.round(1), clip.round(1)).postln;
		rrand(4.0, 8.0).wait;
	}
}).play;
)

Tdef(\fbCtrl).stop;
Ndef(\src).stop;
Ndef.clear;