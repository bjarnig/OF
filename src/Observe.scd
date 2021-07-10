
/*

  ---- ---- ---- ---- OF 'Observers' ---- ---- ---- ----

		an Event() that containts attached observers.

*/

(

var observers = ();

observers.zeronan = {|ev, name=\encore, out=0|

	var brombuf = Buffer.alloc(s, 512);
	var key = OF.key(nil, "observe-zeronan-" ++ name);

	NF(key, {
		var snd, analysed;
		snd = NF(name).ar;
		analysed = ZeroCrossing.ar(snd);
		BBandStop.ar( OFNanite.ar(analysed * 0.08, 2, freqShift:100, modFreq:0.1, surface:0.0000001, mul: 4))
	}).play(out)
};

observers.vesipeak = {|ev, name=\encore, out=0|

	var brombuf = Buffer.alloc(s, 512);
	var key = OF.key(nil, "observe-vesipeak-" ++ name);

	NF(key, {
		var snd, peak, peakFollow, runningMax;
		snd = NF(name).ar;
		peak = Peak.ar(snd);
		peakFollow = PeakFollower.ar(snd);
		runningMax = RunningMax.ar(snd);
		Vesica.ar(runningMax.linlin(0, 1, 20, 100), surface:0.5, entropy:13, lop:4000, mul:  peakFollow)
		* LFDNoise1.ar(runningMax.linlin(0, 1, 0.5, 6)).exprange(0.5, 3.0) * 2;
	}).play(out)
};

observers.bromtrack = {|ev, name=\encore, out=0|

	var brombuf = Buffer.alloc(s, 512);
	var key = OF.key(nil, "observe-bromtrack-" ++ name);

	NF(key, {
		var chain, onsets, snd, verb;
		chain = FFT(brombuf, NF(name).ar);
		onsets = Onsets.kr(chain, 0.3);
		snd = OFBromate.ar( Pitch.kr(NF(name).ar)[0][0] * 0.1, mul:EnvGen.kr(Env.perc(0.3, 1.5, 0.2), onsets));
		verb = Splay.ar(BBandStop.ar(GVerb.ar(snd, 4, 5), 1000, 5));
		XFade2.ar(snd, verb, -0.5);
	}).play(out)
};

observers.graytick = {|ev, name=\encore, out=0|

	var gtbuf = Buffer.alloc(s, 512);
	var key = OF.key(nil, "observe-graytick-" ++ name);

	NF(key, {|thresf=0.1, threst=0.4, thresfreq=0.1|
		var chain, onsets, snd, verb;
		chain = FFT(gtbuf, NF(name).ar);
		onsets = Onsets.kr(chain, LFNoise1.ar(thresfreq).range(thresf, threst));
		snd = GrayNoise.ar(EnvGen.kr(Env.perc(0.001, 0.01, 0.2), onsets));
		verb = BBandStop.ar(GVerb.ar(snd, 7, 15, 0.6).fold2(SinOsc.ar(LFNoise2.ar(0.8).range(10,20))), 800, 7);
		XFade2.ar(snd, verb, -0.25);
	}).play(out)
};

observers.adapt = {|ev, name=\nf, out=0|

	var key = OF.key(nil, "observe-adapt-" ++ name);
	var adapt = true;

	TF(key, {

		" ** adapt to : [" ++ name ++ "]".postln;

		NF(\logic, { |freq = 60, index = 5, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/3, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.1);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,8,15,6]).circle) * (Gendy3.ar(freq:XLine.ar(10, 1000, 20)));
		});

		0.1.wait;

		NF(\logichpf, { HPF.ar( NF(\logic).ar, 2000) * Amplitude.ar(NF(\fo).ar,0.1).range(2.0, 0.0)  }).play(out);

		rrand(10,15).wait;

		NF(\modyfreq, { LFNoise1.ar(0.001).range(2000, 2200) });
		NF(\modyfreq).fadeTime = 0.1;

		1.1.wait;

		NF(\dusttrig, { Impulse.ar(20) });
		NF(\dust, {
			var sig = Saw.ar(LFNoise2.ar([0.1, 0.15]).range(NF(\modyfreq), NF(\modyfreq)*1.01));
			sig = RLPF.ar(sig, 800) * 1.4 * EnvGen.ar(Env.perc(0.01, 0.01), NF(\dusttrig));
			HPF.ar(sig * EnvGen.ar(Env([0,1,0.2,1,0], [1,2,4,6]).circle), 20) * XLine.ar(0.0001, 1, 5) *
			Amplitude.ar(NF(\fo).ar,0.1).range(2.0, 0.0)
		}).play(out);

		rrand(4,12).wait;

		NF(\logic, { |freq = 90, index = 5, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/3, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.5);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,8,15,6]).circle) * (Gendy3.ar(freq:XLine.ar(10, 1000, 20)));
		});

		rrand(6,12).wait;

		while({adapt == true}, {
			NF(\logichpf, { HPF.ar( NF(\logic).ar, LFNoise1.ar(1/3).range(rrand(600,1200), rrand(3000, 6000)) ) });
			rrand(3,7).wait;
			NF(\dusttrig, { Impulse.ar(rrand(12,25)) });
			rrand(2,4).wait;
		});

		NF(\dust, {
			var sig = Saw.ar(LFNoise2.ar([0.1, 0.15]).range(NF(\modyfreq), NF(\modyfreq)*1.01));
			sig = RLPF.ar(sig, 800) * 1.15 * EnvGen.ar(Env.perc(0.01, 0.01), Impulse.ar(Line.kr(19, 5, 10)));
			HPF.ar(sig * EnvGen.ar(Env([0,1,0.2,1,0], [1,2,6,4]).circle), 20) * EnvGen.ar(Env([1,0.8,0.3,0.0], [4,8,16]))
		});

		3.wait;

		NF(\logic, { |freq = 80, index = 1, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/4, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.2);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,2,1,2]).circle) * (Gendy3.ar(freq:10) * 1.5) * EnvGen.ar(Env([1,0.8,0.3,0.0], [2,4,8]))
		});

}).play;

};

observers;

)
