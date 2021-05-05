
/*

  ---- ---- ---- ---- OF 'Behaviour' ---- ---- ---- ----

*/

(

var behaviour = ();

behaviour.run = {|ev, ndef|
	ndef.play
};

behaviour.mfb = {|ev, nin|

var name = ("mfb_" ++ name).asSymbol;

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

behaviour.stack = {|ev,nin,effects,pipeline|

	// Clear slots
	10.do{|i|
		NF(nin)[10+i] = nil;
	};

	// Add effects
	effects.do{|eff,count|
		eff.postln;
		NF(nin)[10+count] = \filter -> pipeline.processing[eff].value();
	};

	Ndef(nin)
};


behaviour.stackd = {|ev,nin,effects,pipeline,delFrom,delTo|

	// Clear slots
	10.do{|i|
		NF(nin)[10+i] = nil;
	};

	// Add effects
	{
	effects.do{|eff,count|
		(" ## stackdel:" + eff).postln;
		// with delay
		rrand(delFrom, delTo).wait;
		// NF(\thestacks, { Gendy4.ar(minfreq:100.rand, maxfreq:1000.rand) * 0.2 }).play;
		NF(nin)[10+count] = \filter -> pipeline.processing[eff].value();
	};
	}.fork;

	Ndef(nin)
};


behaviour.stackp = {|ev,nin,effects,pipeline|

	// Clear slots
	10.do{|i|
		NF(nin)[10+i] = nil;
	};

	// Add effects
	{ effects.do{|eff,count|
		var effect = eff[0], params = eff[1];

		NF(nin)[10+count] = \filter -> pipeline.processing[effect].value();

		0.05.wait;

		params.keys.do{|key|
			NF(nin).xset(key, params[key]);
		};

		0.01.wait;

	}}.fork;

	NF(nin)
};

behaviour.stackprand = {|ev,nin,effects,pipeline,times=10,delay=3|

	// Clear slots, TODO : Why is the slot businesss hardcoded?
	10.do{|i|
		NF(nin)[10+i] = nil;
	};
    {
		    times.do{|i|

			10.do{|i| NF(nin)[10+i] = nil };

			effects.do{|eff,count|
				var effect = eff[0], params = eff[1];

				NF(nin)[10+count] = \filter -> pipeline.processing[effect].value();

				0.05.wait;

				params.keys.do{|key|
					NF(nin).xset(key, params[key]);
				};

				0.01.wait;
			};


			effects = effects.scramble;
			delay.wait;

			};

		}.fork;


	NF(nin)
};


behaviour.stackpd = {|ev,nin,effects,pipeline|

	// Clear slots
	10.do{|i|
		NF(nin)[10+i] = nil;
	};

	// Add effects
	{ effects.do{|eff,count|
		var effect = eff[0], delay = eff[1], params = eff[2];

		NF(nin)[10+count] = \filter -> pipeline.processing[effect].value();

		0.05.wait;

		params.keys.do{|key|
			NF(nin).xset(key, params[key]);
		};

		delay.wait;

	}}.fork;

	NF(nin)
};

behaviour

)
