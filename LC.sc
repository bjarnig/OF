LC {

	var <>scenes, <>activeTdefs;

	*new {
		^super.new.init;
	}

	init {
		scenes = Dictionary();
		activeTdefs = List();
		^this
	}

	// morph smoothly between two parameter states over time
	morph {|nf, from, to, dur=20, steps=100|
		var wait = dur / steps;
		var key = ("lc_morph_" ++ nf.key ++ "_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			steps.do{|i|
				var t = i / steps;
				from.keysValuesDo{|k, valA|
					var valB = to[k];
					nf.set(k, valA.blend(valB, t));
				};
				wait.wait;
			};
			"morph done".postln;
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// evolve parameters randomly within given ranges
	evolve {|nf, params, interval=5|
		var key = ("lc_evolve_" ++ nf.key ++ "_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			loop {
				params.keysValuesDo{|k, range|
					nf.set(k, rrand(range[0], range[1]));
				};
				rrand(interval * 0.5, interval * 1.5).wait;
			}
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// pilot two interacting Ndefs, modulator + carrier
	pilot {|modNf, carNf, modParams, carParams, interval=6|
		var key = ("lc_pilot_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			loop {
				modParams.keysValuesDo{|k, range|
					modNf.set(k, rrand(range[0], range[1]));
				};
				carParams.keysValuesDo{|k, range|
					carNf.set(k, rrand(range[0], range[1]));
				};
				rrand(interval * 0.5, interval * 1.5).wait;
			}
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// register a scene
	scene {|name, func|
		scenes[name] = func;
	}

	// transition to a scene with crossfade
	goScene {|name, dur=6|
		var key = ("lc_scene_" ++ name).asSymbol;

		TF(key, {
			NF.getPlaying.do{|n| NF(n).fadeTime = dur; NF(n).stop(dur) };
			(dur * 0.5).wait;
			scenes[name].value;
			">> scene: %".format(name).postln;
		}).play;
	}

	// gradually layer Ndefs in over time
	buildUp {|ndefs, interval=8, fadeTime=5, cb|
		var key = ("lc_buildup_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			ndefs.do{|nf|
				nf.fadeTime = fadeTime;
				nf.play;
				("+ " ++ nf.key).postln;
				interval.wait;
			};
			if(cb.notNil, { cb.() });
			"-- build-up complete --".postln;
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// create a mixer NF for a collection of NFs
	mixer {|ndefs, name=\lcmixer|
		NF(name, {
			var sources = ndefs.collect{|nf| nf.ar };
			var levels = ndefs.collect{|nf, i| NamedControl.kr(("l" ++ i).asSymbol, 0) };
			Mix(sources * levels);
		}).play;
		^NF(name)
	}

	// auto-mix: randomize mixer levels over time
	autoMix {|mixerNf, count=4, interval=4|
		var key = ("lc_automix_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			loop {
				count.do{|i|
					mixerNf.set(("l" ++ i).asSymbol, rrand(0.0, 1.0));
				};
				rrand(interval * 0.5, interval * 1.5).wait;
			}
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// set up a feedback network around an NF
	feedback {|nf, delFrom=0.05, delTo=0.4, lpfFrom=300, lpfTo=6000, amount=0.85|
		var fbKey = (nf.key ++ "_fb").asSymbol;

		NF(fbKey, {
			var sig = nf.ar;
			sig = DelayC.ar(sig, 1.0, LFNoise1.ar(0.3).range(delFrom, delTo));
			LPF.ar(sig, LFNoise1.ar(0.5).range(lpfFrom, lpfTo))
		});

		nf[999] = \filter -> {|in| in + (NF(fbKey).ar * amount) };
	}

	// set up node proxy roles on an NF: source + \set pattern + \filter
	roles {|nf, source, set, filter, output=0|
		if(source.notNil, { nf[0] = source });
		if(set.notNil, { nf[1] = \set -> set });
		if(filter.notNil, { nf[2] = \filter -> filter });
		nf.play(output);
	}

	// set up source sequencing with \setsrc
	setsrc {|nf, sources, durs, output=0|
		nf[0] = \setsrc -> Pbind(
			\source, Pseq(sources, inf),
			\dur, if(durs.isKindOf(Pattern), { durs }, { Pseq(durs, inf) })
		);
		nf.play(output);
	}

	// route src into dst via <<>
	route {|src, dst|
		src <>> dst;
		src.play;
	}

	// sequence with Duty-based demand patterns
	sequence {|nf, notes, dur=0.15|
		nf[0] = {
			SinOsc.ar(Duty.kr(dur, 0, Dseq(notes, inf))) ! 2 * 0.2
		};
		nf.play;
	}

	// incremental Pbindef building
	pbindef {|name, instrument, dur=0.25, midinote=60, amp=0.15|
		^Pbindef(name,
			\instrument, instrument,
			\dur, dur,
			\midinote, midinote,
			\amp, amp
		).play;
	}

	// automate Pbindef changes with a Tdef
	pbinBot {|name, pitchSets, durSets, interval=6|
		var key = ("lc_pbinbot_" ++ name ++ "_" ++ Date.getDate.secStamp).asSymbol;

		TF(key, {
			loop {
				Pbindef(name, \midinote, pitchSets.choose);
				rrand(interval * 0.5, interval * 1.5).wait;
				Pbindef(name, \dur, durSets.choose);
				rrand(interval * 0.5, interval * 1.5).wait;
			}
		}).play;

		activeTdefs.add(key);
		^TF(key)
	}

	// set up a master chain with compressor + reverb + limiter
	master {|ndefs, levels, name=\lcmaster|
		NF(name, {
			var sources = ndefs.collect{|nf, i| nf.ar * (levels[i] ? 0.5) };
			Mix(sources)
		}).play;

		NF(name).filter(10, {|in|
			Compander.ar(in, in, thresh:0.5, slopeBelow:1, slopeAbove:0.5, clampTime:0.01, relaxTime:0.1)
		});

		NF(name).filter(11, {|in|
			in + FreeVerb.ar(in, 0.3, 0.8, 0.5)
		});

		NF(name).filter(12, {|in|
			Limiter.ar(in, 0.95)
		});

		^NF(name)
	}

	// stop all active Tdefs managed by LC
	stopAll {
		activeTdefs.do{|key| TF(key).stop };
		activeTdefs = List();
	}

	// clear everything: stop Tdefs and clear all playing NFs
	clearAll {
		this.stopAll;
		NF.getPlaying.do{|n| NF(n).stop; NF(n).clear };
	}
}
