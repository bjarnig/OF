
/*

  ---- ---- ---- ---- Pipeline 'Observers' ---- ---- ---- ----

*/

(

var observers = ();

observers.adapt = {|ev, name=\adapt|

	~adapt = true;

	Tdef(\simal, {

		Ndef(\logic, { |freq = 60, index = 5, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/3, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.1);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,8,15,6]).circle) * (Gendy3.ar(freq:XLine.ar(10, 1000, 20)));
		});

		0.1.wait;

		Ndef(\logichpf, { HPF.ar( Ndef(\logic).ar, 2000 ) }).play;

		2.wait;

		" ** adapt to : [current]".postln;

		Ndef(\modyfreq, { LFNoise1.ar(0.001).range(2000, 2200) });
		Ndef(\modyfreq).fadeTime = 0.1;

		1.1.wait;

		Ndef(\dusttrig, { Impulse.ar(20) });
		Ndef(\dust, {
			var sig = Saw.ar(LFNoise2.ar([0.1, 0.15]).range(Ndef(\modyfreq), Ndef(\modyfreq)*1.01));
			sig = RLPF.ar(sig, 800) * 1.4 * EnvGen.ar(Env.perc(0.01, 0.01), Ndef(\dusttrig));
			HPF.ar(sig * EnvGen.ar(Env([0,1,0.2,1,0], [1,2,4,6]).circle), 20) * XLine.ar(0.0001, 1, 5)
		}).play;

		6.wait;

		Ndef(\logic, { |freq = 90, index = 5, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/3, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.5);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,8,15,6]).circle) * (Gendy3.ar(freq:XLine.ar(10, 1000, 20)));
		});

		3.wait;

		// // l o o p // //

		while({~adapt == true}, {
			Ndef(\logichpf, { HPF.ar( Ndef(\logic).ar, LFNoise1.ar(1/3).range(rrand(600,1200), rrand(3000, 6000)) ) });
			rrand(3,7).wait;
			Ndef(\dusttrig, { Impulse.ar(rrand(12,25)) });
			rrand(2,4).wait;

		});

		// e n d ///

		Ndef(\dust, {
			var sig = Saw.ar(LFNoise2.ar([0.1, 0.15]).range(Ndef(\modyfreq), Ndef(\modyfreq)*1.01));
			sig = RLPF.ar(sig, 800) * 1.15 * EnvGen.ar(Env.perc(0.01, 0.01), Impulse.ar(Line.kr(19, 5, 10)));
			HPF.ar(sig * EnvGen.ar(Env([0,1,0.2,1,0], [1,2,6,4]).circle), 20) * EnvGen.ar(Env([1,0.8,0.3,0.0], [4,8,16]))
		});

		3.wait;

		Ndef(\logic, { |freq = 80, index = 1, modMult = 25|
			var mod = Lag.ar(Logistic.ar(LFNoise1.kr(0.001,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5).range(freq, freq * modMult));
			var signal = Splay.ar(PMOsc.ar(Array.rand(8, freq/4, freq), mod, rrand(index, index * 2) ! 8,0, 0.02), 0.2);
			signal * EnvGen.ar(Env([0,1,0,1,0], [1,2,1,2]).circle) * (Gendy3.ar(freq:10) * 1.5) * EnvGen.ar(Env([1,0.8,0.3,0.0], [2,4,8]))
		});

}).play;

};

observers;

)
