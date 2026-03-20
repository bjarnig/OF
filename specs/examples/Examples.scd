////////////////////////////////////////////////////////////////
//
//                    Live Coding - Examples
//
////////////////////////////////////////////////////////////////


// 01. FadeTime, smooth crossfades between definitions

Ndef(\fader).play(fadeTime: 1);
Ndef(\fader, { SinOsc.ar(400, 0, 0.2) ! 2 });
Ndef(\fader).fadeTime = 3;

Ndef(\fader, { Saw.ar(300, 0.15) ! 2 });
Ndef(\fader, { LFTri.ar(500, 0, 0.2) ! 2 });
Ndef(\fader, { Pulse.ar(200, 0.4, 0.15) ! 2 });

Ndef(\fader).stop(4);


// 02. Nested Ndefs, source to filter routing

Ndef(\src, { WhiteNoise.ar(0.3) });
Ndef(\filt, { LPF.ar(Ndef.ar(\src), 800) }).play;

Ndef(\filt).fadeTime = 2;
Ndef(\filt, { BPF.ar(Ndef.ar(\src), 1200, 0.15) });
Ndef(\filt, { HPF.ar(Ndef.ar(\src), 2000) });

Ndef(\src, { PinkNoise.ar(0.3) });
Ndef(\src, { Saw.ar(100, 0.3) });
Ndef(\src, { Pulse.ar([100, 101], 0.5, 0.3) });

Ndef(\filt).stop;
Ndef.clear;


// 03. FM with modulator/carrier pair

(
Ndef(\mod, { SinOsc.ar(5) });
Ndef(\car, {
	SinOsc.ar(Ndef.ar(\mod) * 200 + 400, 0, 0.2) ! 2
}).play;
)

Ndef(\mod).fadeTime = 3;
Ndef(\mod, { SinOsc.ar(10.5) });
Ndef(\mod, { LFNoise2.ar(3) });
Ndef(\mod, { LFSaw.ar(2) });

Ndef(\car).stop;
Ndef.clear;


// 04. Arguments and GUI sliders

(
Ndef(\synth, { |freq=100, detune=4, cutoff=3000, amp=0.2|
	var sig = Saw.ar([freq, freq + detune]);
	RLPF.ar(sig, cutoff, 0.3) * amp;
}).play;
)

Ndef(\synth).set(\freq, 200);
Ndef(\synth).set(\cutoff, 800, \detune, 20);

Ndef(\synth).fadeTime = 2;
Ndef(\synth).xset(\freq, 600);

Ndef(\synth).gui;
Ndef(\synth).stop;


// 05. LFO mapping to parameters

(
Ndef(\tgt, { |freq=50, filt=3000|
	RLPF.ar(Saw.ar(freq, 0.2), filt, 0.3) ! 2
}).play;
)

Ndef(\lfoFreq,  { SinOsc.kr(0.5).range(20, 200) });
Ndef(\lfoFilt,  { LFNoise1.kr(2).range(500, 6000) });

Ndef(\tgt).map(\freq, Ndef(\lfoFreq));
Ndef(\tgt).map(\filt, Ndef(\lfoFilt));

Ndef(\lfoFreq).fadeTime = 3;
Ndef(\lfoFreq, { LFNoise2.kr(0.3).range(100, 1200) });

Ndef(\tgt).unmap(\freq);
Ndef(\tgt).set(\freq, 440);

Ndef(\tgt).stop;
Ndef.clear;


// 06. Effect chains with .filter

Ndef(\chain, { PinkNoise.ar(0.2) ! 2 }).play;

Ndef(\chain).filter(1, { |in| in * LFPulse.ar(4).lag(0.01) });
Ndef(\chain).filter(2, { |in| in + CombN.ar(in, 0.2, 0.15, 2) });
Ndef(\chain).filter(3, { |in| RLPF.ar(in, LFNoise1.kr(0.5).range(400, 5000), 0.3) });
Ndef(\chain).filter(4, { |in| Decimator.ar(in.distort, 1000) });

Ndef(\chain).filter(1, { |in| in * SinOsc.ar(3).range(0.2, 1.0) });
Ndef(\chain)[4] = nil;

Ndef(\chain).stop;
Ndef.clear;


// 07. Node proxy roles, \set and \filter slots

Ndef(\roles).play;
Ndef(\roles).fadeTime = 2;

Ndef(\roles)[0] = { |freq=80| Saw.ar(freq ! 2, 0.1) };
Ndef(\roles)[2] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(50, 100));
Ndef(\roles)[3] = \filter -> { |in| LPF.ar(in, LFNoise1.ar(4).range(200, 3000))};
Ndef(\roles)[0] = { |freq=80| Pulse.ar(freq ! 2, 0.3, 0.08) };

Ndef(\roles).stop;
Ndef.clear;


// 08. Internal rhythms, Impulse + TRand

(
Ndef(\beat, { |rate=10|
	var trig = Impulse.kr(rate);
	var env  = EnvGen.ar(Env.perc(0.005, 0.15), trig);
	var freq = TRand.kr(200, 1200, trig);
	SinOsc.ar(freq, 0, 0.25) * env ! 2;
}).play;
)

Ndef(\beat).set(\rate, 8);
Ndef(\beat).set(\rate, 2);
Ndef(\beat).set(\rate, 16);

(
Ndef(\beat, { |rate=4|
	var trig = Impulse.kr(rate * 0.5);
	var env  = EnvGen.ar(Env.perc(0.1, 0.5, 1, -4), trig);
	var freq = TRand.kr(60, 400, trig);
	Gendy3.ar(mul:0.3,freq:freq) * env ! 2;
});
)

Ndef(\beat).stop;
Ndef.clear;


// 09. Pdef, redefine patterns live

(
SynthDef(\blip, { |freq=440, amp=0.2, pan=0, gate=1|
	var env = EnvGen.ar(Env.perc(0.01, 0.18), gate, doneAction: 2);
	Out.ar(0, Pan2.ar(SinOsc.ar(freq) * amp * env, pan));
}).add;
)

(
Pdef(\mel).play;
Pdef(\mel, Pbind(
	\instrument, \blip,
	\dur,        Pseq([0.15, 0.3, 0.1, 0.45], inf),
	\midinote,   Pseq([61, 68, 54, 73, 59, 66], inf),
	\amp,        0.18
));
)

(
Pdef(\mel, Pbind(
	\instrument, \blip,
	\dur,        Prand([0.1, 0.07, 0.35, 0.5, 0.12], inf),
	\midinote,   Prand([37, 61, 42, 70, 49, 74, 53, 68], inf),
	\amp,        Pwhite(0.06, 0.22, inf),
	\pan,        Pbrown(-0.9, 0.9, 0.3, inf)
));
)

Pdef(\mel).stop;


// 10. Pbindef, change individual pattern keys

(
Pbindef(\grv,
	\instrument, \blip,
	\dur,        0.2,
	\midinote,   49,
	\amp,        0.18,
	\pan,        0
).play;
)

Pbindef(\grv, \midinote, Prand([37, 54, 68], inf));
Pbindef(\grv, \midinote, Prand([42, 61, 49, 73, 66], inf));
Pbindef(\grv, \dur,      Prand([0.07, 0.15, 0.4, 0.1], inf));
Pbindef(\grv, \amp,      Pwhite(0.05, 0.24, inf));
Pbindef(\grv, \pan,      Pbrown(-0.9, 0.9, 0.4, inf));

Pbindef(\grv).stop;
Pbindef(\grv).clear;


// 11. Duty-based audio-rate sequencing

(
Ndef(\seq).play;
Ndef(\seq, { SinOsc.ar(Duty.kr(0.15, 0, Dseq([400, 500, 600, 700], inf))) ! 2 * 0.2 });
)

Ndef(\seq).fadeTime = 2;
Ndef(\seq, { SinOsc.ar(Duty.kr(0.1, 0, Drand([300, 400, 500, 600, 800], inf))) ! 2 * 0.2 });
Ndef(\seq, { SinOsc.ar(Duty.kr(0.1, 0, Dshuf([300, 500, 700, 900], inf))) ! 2 * 0.2 });

(
Ndef(\seq, {
	var notes = (Scale.minor.degrees + 60).midicps;
	SinOsc.ar(Duty.kr(0.12, 0, Dseq(notes, inf))) ! 2 * 0.2;
});
)

Ndef(\seq).stop;
Ndef.clear;


// 12. Evolving drone texture

(

Ndef(\drone, { |mod=150, amp=0.12, fa=3, fb=6, fc=9, fd=12|
	Splay.ar([fa, fb, fc, fd].collect { |rate|
		HPF.ar(
			SinOsc.ar(LFCub.kr(rate, 0, mod * 0.5, mod), 0, amp),
			50
		) * SinOsc.ar(0.01 + 0.5.rand).range(0, 0.8)
	}) * 1.2;
}).play;

)

Ndef(\drone).set(\mod, 40);
Ndef(\drone).set(\mod, 200);

Ndef(\drone).filter(1, { |in| in + FreeVerb.ar(in, 0.5, 0.9, 0.3) });
Ndef(\drone)[1] = nil;
Ndef(\drone).stop(6);
Ndef.clear;


// 13. Layered noise texture + effects

(
Ndef(\tex).play;
Ndef(\tex, {
	Splay.ar(PinkNoise.ar * Decay.ar(Dust.ar(3 ! 8), 0.1))
});
)

Ndef(\tex).filter(1, { |in|
	RLPF.ar(in, LFNoise1.kr(0.5).range(400, 5000), 0.4)
});

Ndef(\tex).filter(2, { |in|
	in + CombN.ar(in, 0.3, [0.15, 0.2], 3, 0.35)
});

Ndef(\tex).fadeTime = 5;
Ndef(\tex, {
	Splay.ar(PinkNoise.ar * Decay.ar(
		Dust.ar(SinOsc.kr(0.08).range(1, 10) ! 8), 0.15
	))
});

Ndef(\tex).stop(6);
Ndef.clear;


// 14. FFT spectral processing

(

Ndef(\pvsrc, { Saw.ar(60 ! 1, 0.3) + PinkNoise.ar(0.1) });
Ndef(\pv, {
	var sig   = Ndef.ar(\pvsrc);
	var chain = FFT(LocalBuf(2048), sig);
	IFFT(PV_MagSmear(chain, 4)).dup;
}).play;

)


(

Ndef(\pv, {
	var sig   = Ndef.ar(\pvsrc);
	var chain = FFT(LocalBuf(2048), sig);
	IFFT(PV_Freeze(chain, LFPulse.kr(2))).dup;
});

)


// 15. Feedback loop

(
Ndef(\ep, { Impulse.ar(6) ! 2 }).play;
Ndef(\ep)[1] = \filter -> { |in|
	in + (Ndef.ar(\ep_fb) * 0.97)
};
Ndef(\ep_fb, {
	DelayC.ar(
		LPF.ar(Ndef.ar(\ep), LFNoise1.ar(0.5).range(400, 8000)),
		0.5,
		LFNoise1.ar(8).range(0.1, 0.4)
	)
});
)

// Modify trigger rate
Ndef(\ep, { Impulse.ar(12) ! 2 });
Ndef(\ep, { Impulse.ar(3) ! 2 });

Ndef(\ep).stop;
Ndef.clear;

