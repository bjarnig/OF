////////////////////////////////////////////////////////////////
//
//                 More/Misc JITLib things
//
////////////////////////////////////////////////////////////////


//////// Routing/Modulation of a playing pattern ///////////////

( // SynthDef that will be used below

SynthDef(\jsnd, { arg freq=100, gate=1, out=0, lop=800, amp=0.1;
	var env = EnvGen.kr(Env.asr(0.1, amp, 0.5), gate, doneAction:2);
	var signal = RLPF.ar(Blip.ar(freq, 150).fold2(SinOsc.ar(freq/10)), lop);
    Out.ar(out, Pan2.ar(signal * env));
}).add;

)

( // Use source and destination proxies

a = NodeProxy.audio(s, 2);
a.fadeTime = 2;
b = NodeProxy.audio(s,2);
b.fadeTime = 3;
a.play;
b.play

)

// Play b as pattern
b.source = Pbind(\instrument, \jsnd, \freq, 500, \ffreq, 700, \amp, 0.2, \dur, 0.75, \legato, 0.1);
b.stop;

// Play a as and multiply with b
a.source = { b.ar * SinOsc.ar(SinOsc.kr(10, 250, 500)) };




//////// Control node proxy used within a pattern /////////////

d = NodeProxy.audio(s, 2);
d.source = { SinOsc.kr(100, 0, 500, 2000) };
d.fadeTime = 1;

c = NodeProxy.audio(s, 2);
c.play
c.source = Pbind(\instrument, \jsnd, \freq, 500, \lop, d, \amp, 0.4, \dur, 2);




///// Updating events with a \set message and event pattern //////////

a = NodeProxy(s);
a[0] = { |freq = 340, lop=2000|  RLPF.ar(Blip.ar(freq, 150!2).fold2(SinOsc.ar(freq/10)), lop) ! 2 * 0.05 };
a.fadeTime = 2;
a.play;

(

a[1] = \set -> Pbind(
    \dur, Prand([0.2, 0.5, 0.25, 0.125], inf),
    \freq, Pwhite(50, 1500, inf),
    \lop, Pwhite(300, 4000, inf)
)

);

// modify the source while it plays
a[0] = { |freq = 340, lop=2000| RLPF.ar(Saw.ar(freq/2 !2).fold2(SinOsc.ar(freq * 10)), lop) ! 2 * 0.01 };

// set another source that recieves changes from the pattern
a[2] = {|freq=100| LFNoise1.kr(1) * Impulse.ar(freq!2, 0.5) }; // to check

// filter the combined sound
a[3] = \filter -> {|in| RLPF.ar(in, LFNoise1.ar(5).range(100,2000), 0.2) };




//////// Sequencing proxies instances with \setsrc /////////////

(

Ndef(\x,
    \setsrc -> Pbind(\source,
        Pseq([
			{ Blip.ar(5000, 150).fold2(SinOsc.ar(10)) ! 2 * 0.2 },
			{ Blip.ar(50, 5).fold2(SinOsc.ar(0.1)) ! 2 * 0.5  },
			{ Blip.ar(500, 100).fold2(SinOsc.ar(20)) ! 2 * 0.2  },
        ], inf),
        \dur, Prand([3, 2, 4], inf)
    )
).play;

)
