////////////////////////////////////////////////////////////////
//
//              JITLib - Systems
//
////////////////////////////////////////////////////////////////


/* - 1. Circular Buffer Granular System - */

(

fork {
	// Buffers and Busses
	~circularBuf = Buffer.alloc(s, s.sampleRate * 3);
	~sourceBus = Bus.audio(s, 1);
	~writerBus = Bus.audio(s, 1);

	s.sync;

	// Groups for proper node ordering
	~sourceGroup = Group.new;
	~writerGroup = Group.after(~sourceGroup);
	~readerGroup = Group.after(~writerGroup);

	"Granular system setup complete".postln;
};

)


(

// Source
Ndef(\source, { Gendy3.ar * 0.1 }).play(~sourceBus, group: ~sourceGroup);

// Writer
Ndef(\writer, {
	var pos = Phasor.ar(0, 1, 0, BufFrames.kr(~circularBuf));
	var sig = In.ar(~sourceBus, 1);
	BufWr.ar(sig, ~circularBuf, pos);
	pos;
}).play(~writerBus, group: ~writerGroup);

// Create 8 grains
8.do { |i|
	var proxy = ("grain" ++ i).asSymbol;
	Ndef(proxy, { |rate = 1, dur = 0.1, delay = 0.1, amp = 0.4|
		var sig, pos;
		pos = In.ar(~writerBus);
		pos = pos / BufFrames.kr(~circularBuf);
		pos = pos - delay;
		pos = pos.wrap(0, 1);
		pos = pos * LFNoise1.ar(10).range(0.9, 1.1);
		rate = LFDNoise3.ar(10).range(rate * 0.5, rate * 2);
		sig = GrainBuf.ar(1, Impulse.ar(40), dur, ~circularBuf, rate, pos) * amp;
	}).play(i.wrap(0, 1), group: ~readerGroup);

	// Set unique parameters
	Ndef(proxy).set(
		\rate, rrand(0.01, 4.0),
		\dur, (i + 1) * 0.02,
		\delay, i * 0.05,
		\amp, 0.15
	);
};
)


// LIVE: Modify individual granulators
Ndef(\grain0).set(\rate, 0.1, \dur, 0.5, \delay, 0.2);

Ndef(\grain1).set(\rate, 20.5, \dur, 0.01, \delay, 0.5);

Ndef(\grain2).set(\rate, -1.0, \dur, 0.1);  // Reverse!


// LIVE: Modify all grains at once
8.do { |i| Ndef(("grain" ++ i).asSymbol).set(\rate, rrand(0.5, 2.0)) };

8.do { |i| Ndef(("grain" ++ i).asSymbol).set(\dur, rrand(0.01, 0.2)) };


// LIVE: Change source
Ndef(\source, { Gendy3.ar * 0.1 });

Ndef(\source, { SinOsc.ar(LFNoise1.ar(1).exprange(200, 800)) * 0.2 });

Ndef(\source, { Pulse.ar(LFNoise0.ar(10).exprange(80, 800)) * 0.1 });


( // Automate grain changes

Tdef(\grainMod, {
	inf.do {
		8.do { |i|
			Ndef(("grain" ++ i).asSymbol).set(
				\rate, rrand(0.01, 4.0),
				\dur, rrand(0.001, 0.2),
				\delay, rrand(0.05, 0.8)
			);
		};
		rrand(0.5, 2.0).wait;
	}
}).play;

)

Tdef(\grainMod).stop;

( // Cleanup

8.do { |i| Ndef(("grain" ++ i).asSymbol).clear };
Ndef(\source).clear;
Ndef(\writer).clear;
~circularBuf.free;
~sourceBus.free;
~writerBus.free;

)



/* - 2. ProxySubmix Routing - */

/*
Route multiple Ndefs through a submix with individual level control.
*/

// Create source Ndefs
(
Ndef(\a, {
	PanAz.ar(4,
		Ringz.ar(PinkNoise.ar(0.03), 3000, 0.1),
		LFSaw.kr(0.5)
	)
});

Ndef(\b, {
	PanAz.ar(4,
		Ringz.ar(PinkNoise.ar(0.03), 500, 0.1),
		LFSaw.kr(-0.3)
	)
});

Ndef(\c, {
	PanAz.ar(4,
		Ringz.ar(Dust.ar(10, 0.03), 1200, 0.1),
		LFNoise1.kr(0.2)
	)
});
)



( // Create submix and add sources

~mix = ProxySubmix(\mix);
~mix.ar(4);  // 4 channels

// Add sources (prefader)
~mix.addMix(Ndef(\a), postVol: false);
~mix.addMix(Ndef(\b), postVol: false);
~mix.addMix(Ndef(\c), postVol: false);

)


// Play
~mix.play;

// Control individual levels
~mix.setAt(\a, 0.5);
~mix.setAt(\b, 1.0);
~mix.setAt(\c, 0.3);


( // Add effects to submix

~mix.filter(10, { |in|
	FreeVerb.ar(in, 0.5, 0.9, 0.1) * 2
});

)


( // Cleanup

~mix.clear;
Ndef(\a).clear;
Ndef(\b).clear;
Ndef(\c).clear;

)



/* - 3. Multi-Source Mixing - */


( // Multiple sources with crossfader

// Create 4 different sources
Ndef(\s1, { SinOsc.ar(200) * 0.2 });
Ndef(\s2, { Saw.ar(300) * 0.2 });
Ndef(\s3, { Pulse.ar(150) * 0.2 });
Ndef(\s4, { WhiteNoise.ar(0.1) });

// Mixer with crossfader
Ndef(\mixer, { |mix1=0, mix2=0, mix3=0, mix4=0|
	var sources = [
		Ndef(\s1).ar,
		Ndef(\s2).ar,
		Ndef(\s3).ar,
		Ndef(\s4).ar
	];
	var levels = [mix1, mix2, mix3, mix4];
	Mix(sources * levels) ! 2;
}).play;

)


// Control mix levels
Ndef(\mixer).set(\mix1, 1.0, \mix2, 0.0, \mix3, 0.0, \mix4, 0.0);

Ndef(\mixer).set(\mix1, 0.5, \mix2, 0.5, \mix3, 0.0, \mix4, 0.0);

Ndef(\mixer).set(\mix1, 0.0, \mix2, 0.0, \mix3, 1.0, \mix4, 0.0);


// Automate mixing
(

Tdef(\autoMix, {
	inf.do {
		Ndef(\mixer).set(
			\mix1, 1.0.rand,
			\mix2, 1.0.rand,
			\mix3, 1.0.rand,
			\mix4, 1.0.rand
		);
		2.wait;
	}
}).play;

)

Tdef(\autoMix).stop;

Ndef(\mixer).stop;



/* - 4. GUI Launchers - */


( // Simple launcher for Ndef variations

var w, sounds;

// Prepare sounds
sounds = Dictionary();
sounds["Low"] = Ndef(\low, { SinOsc.ar(200) * 0.2 ! 2 });
sounds["Mid"] = Ndef(\mid, { SinOsc.ar(400) * 0.2 ! 2 });
sounds["High"] = Ndef(\high, { SinOsc.ar(800) * 0.2 ! 2 });

// Create window
w = Window("Sound Launcher", Rect(100, 100, 300, 200)).front;
w.layout = VLayout();

// Buttons
sounds.keys.do { |name|
	var button = Button()
		.states_([
			[name, Color.black, Color.gray],
			[name, Color.white, Color.green]
		])
		.action_({ |btn|
			if(btn.value == 1, {
				sounds[name].play;
			}, {
				sounds[name].stop;
			});
		});
	w.layout.add(button);
};

// Stop all
w.layout.add(
	Button()
		.states_([["Stop All", Color.white, Color.red]])
		.action_({ sounds.do(_.stop) })
);

)


/* - 5. Performance Setup - */

// Complete performance setup - textural/experimental
(

// === SOURCES ===
Ndef(\pulse, {
	var rate = 12, freq = 60;
	var trigx = Impulse.kr(rate);
	var seqx = Diwhite(400, 1000, inf);
	var trig = Demand.kr(trigx, 0, seqx);
	HPF.ar(BBandStop.ar(LeastChange.ar(
		GravityGrid.ar(0, [freq/2, freq/4, freq, freq/16]),
		Saw.ar(freq)), Lag.kr(trig), 12), 40) * 0.15
});

Ndef(\drone, {
	var diff = 90 + (90 * 0.5);
	var relb = GbmanL.ar(10).range(2.5, 3.5);
	var diffb = relb + (relb * 1.75);
	(SinOsc.ar(LFCub.kr([90 + (90 * 0.5), 90], 0, diff * 10, 90 * 90), 0, 0.05) +
		SinOsc.ar(LFCub.kr([relb + (relb * 0.5), relb], 0, diffb * 10, relb * relb), 0, 0.1) * 0.6) * 0.5
});

Ndef(\texture, {
	var sig = Dust.ar(120) + Crackle.ar(0.9);
	var timeUp= 6, timeDown= 8;
	var holder = EnvGen.ar(Env([0,1,0], [timeUp,timeDown]).circle);
	var sinFrom = EnvGen.ar(Env([0,1,0], [timeUp*2,timeDown/2]).circle);
	var mod = LFNoise2.ar([4,8]).range(sinFrom, 1.0);
	sig = sig * Line.kr(0, 1, timeUp);
	sig = sig * (mod * holder) ! 2 * 0.5;
	sig
});

Ndef(\clicks, {
	var freq = 2000, freqx = freq + 5;
	var snd = RLPF.ar(Saw.ar(LFNoise2.ar([0.1, 0.15])
		.range(freqx, freqx*Array.rand(8, 0.9,1.5))), Array.series(4,600,200))
		* EnvGen.ar(Env.perc(0.004, 0.02), Impulse.ar(5.5));
	Splay.ar(snd) * 0.3
});


Ndef(\master, {
	var pulse = Ndef(\pulse).ar;
	var drone = Ndef(\drone).ar;
	var texture = Ndef(\texture).ar;
	var clicks = Ndef(\clicks).ar;

	Mix([pulse * 0.8, drone * 0.4, texture * 0.3, clicks * 0.5]);
}).play;


Ndef(\master).filter(1, { |in|
	Compander.ar(in, in,
		thresh: 0.5,
		slopeBelow: 1,
		slopeAbove: 0.5,
		clampTime: 0.01,
		relaxTime: 0.1
	)
});

Ndef(\master).filter(2, { |in|
	in + FreeVerb.ar(in, 0.3, 0.8, 0.5)
});

Ndef(\master).filter(3, { |in|
	Limiter.ar(in, 0.95)
});

)

(

Ndef(\pulse, {
	var rate = 8, freq = 40;
	var trigx = Impulse.kr(rate);
	var seqx = Diwhite(600, 1200, inf);
	var trig = Demand.kr(trigx, 0, seqx);
	HPF.ar(BBandStop.ar(LeastChange.ar(
		GravityGrid.ar(0, [freq/2, freq/4, freq, freq/16]),
		Saw.ar(freq)), Lag.kr(trig), 8), 60) * 0.15
});

Ndef(\drone, {
	BBandStop.ar(LPF.ar(Crackle.ar(LFNoise2.ar(12).range(1.01, 1.5), 0.5), 12000),
		StandardL.ar(5.4).range(100,300), 6) * 0.5
});

)

// Cleanup
(
[\pulse, \drone, \texture, \clicks, \master].do { |name|
	Ndef(name).stop;
	Ndef(name).clear;
};

)


/* - 6. Synchronized System - */

// Clock-synced Ndefs with ProxySpace
(
p = ProxySpace.push(s);
p.clock = TempoClock.default;
p.quant = 1.0;
)

// Create synced sources
(
~a.play;
~b.play;

~a = { Ringz.ar(Impulse.ar(2), [400, 800], 0.8) * 0.1};
~b = { Ringz.ar(Impulse.ar(2), [200, 1000], 0.8) * 0.1};
)

// Update in sync
~a = { Ringz.ar(Impulse.ar(4), [1000, 2000], 0.8) * 0.1};

~b = { Ringz.ar(Impulse.ar(0.5), [100, 500], 0.8) * 0.1};

// Faster together
(
~a = { Ringz.ar(Impulse.ar(10), [300, 500], 0.8) ! 2 * 0.1};
~b = { Ringz.ar(Impulse.ar(5), [100, 200], 0.8) ! 2 * 0.1};
)

p.clear;
p.pop;


