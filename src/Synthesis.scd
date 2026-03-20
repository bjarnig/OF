
/*

  ---- ---- ---- ---- OF 'Synthesis' ---- ---- ---- ----

	an Event() that containts NFs responsible for synthesis

*/

(

var synthesis = ();

synthesis.specs = Dictionary();

// 01. [ silk ]

synthesis.silk = {|ev, name=\silk|

	NF(name, {|freq=1090, amp=1.0, harms=170, modFreq=9, modFreq2=1, modFreq3=3.1|
		var mod = SinOsc.ar(LFNoise2.kr(modFreq2).range(modFreq * 5, 0.5), 0, LFNoise1.kr(modFreq/10).range(5, 20));
		var sig = Splay.ar(Blip.ar(Array.series(5, freq, freq/24) + mod, harms));
		sig = BPeakEQ.ar(BBandStop.ar(sig, harms * 10, 2.5), LFNoise1.kr(modFreq, 3500, 8000), 1, -10) * 2;
		Splay.ar(sig * LFNoise1.ar(modFreq3).range(0.3,1.1) * amp)
	})
};

synthesis.specs[\silk] = Dictionary();
synthesis.specs[\silk][\freq] = ControlSpec(545.0,2180,'lin');
synthesis.specs[\silk][\harms] = ControlSpec(85.0,340,'lin');
synthesis.specs[\silk][\modFreq] = ControlSpec(4.5,18,'lin');
synthesis.specs[\silk][\modFreq2] = ControlSpec(0.5,2,'lin');
synthesis.specs[\silk][\modFreq3] = ControlSpec(1.55,6.2,'lin');


// 02. [ vsaw ]

synthesis.vsaw = {|ev, name=\vsaw|

	NF(name, {|freq=90, amp=1.0, modFreq=0.5, ampMod=0.8, bsMul=600, bsAdd=800, bsBw=8|
		var sig = VarSaw.ar(LFPar.ar(freq/[10,8], 0, 10, LFPar.kr(5, 0, 5, freq)), 0, LFNoise2.kr(freq/3, 0.5, 1.5)) * 0.6;
		var thres = Lag.kr(Amplitude.kr(sig), 0.1);
		var osc = Splay.ar(Pulse.ar(Array.series(10, freq, 5))) * thres;
		sig = osc + BPeakEQ.ar(BBandStop.ar(sig, LFNoise1.kr(modFreq, bsMul, bsAdd), bsBw), 80, 3, -2);
 		HPF.ar(Splay.ar(sig),60,amp) * LFNoise1.ar(ampMod).range(0.3,1.1)
	})
};

synthesis.specs[\vsaw] = Dictionary();
synthesis.specs[\vsaw][\freq] = ControlSpec(45.0,180,'lin');
synthesis.specs[\vsaw][\amp] = ControlSpec(0.5,2.0,'lin');
synthesis.specs[\vsaw][\modFreq] = ControlSpec(0.25,1.0,'lin');
synthesis.specs[\vsaw][\ampMod] = ControlSpec(0.4,1.6,'lin');
synthesis.specs[\vsaw][\bsMul] = ControlSpec(300.0,1200,'lin');
synthesis.specs[\vsaw][\bsAdd] = ControlSpec(400.0,1600,'lin');
synthesis.specs[\vsaw][\bsBw] = ControlSpec(4.0,16,'lin');


// 03. [ depfm ]

synthesis.depfm = {|ev, name=\depfm|

	NF(name, {|freqMin=1, freqMax=10, mul=20, add=100, rate=1, modFreq=4100, index=0.2, amp=1|
		var trig, seq, freq;
		trig = Impulse.kr(rate);
		seq = Diwhite(freqMin, freqMax, inf).midicps;
		freq = Demand.kr(trig, 0, seq);
		PMOsc.ar(LFCub.kr([freq, freq/2], 0, mul, add), modFreq, index) * 0.3 * amp * 0.7
	})
};

synthesis.specs[\depfm] = Dictionary();
synthesis.specs[\depfm][\freqMin] = ControlSpec(0.5,2,'lin');
synthesis.specs[\depfm][\freqMax] = ControlSpec(5.0,20,'lin');
synthesis.specs[\depfm][\mul] = ControlSpec(10.0,40,'lin');
synthesis.specs[\depfm][\add] = ControlSpec(50.0,200,'lin');
synthesis.specs[\depfm][\rate] = ControlSpec(0.5,2,'lin');
synthesis.specs[\depfm][\modFreq] = ControlSpec(2050.0,8200,'lin');
synthesis.specs[\depfm][\index] = ControlSpec(0.1,0.4,'lin');
synthesis.specs[\depfm][\amp] = ControlSpec(0.5,2,'lin');


// 04. [ osom ]

synthesis.osom = {|ev, name=\osom|

	NF(name, {|rate=2, trigMin=0.01, trigMax=10, shift=0.02, decay=0.1, initx=0.3, inity=0.1, initz=0.2, freq=600, bw=8, amp=1|
		var trigx = Impulse.kr(rate);
		var seqx = Diwhite(trigMin, trigMax, inf).midicps;
		var trig = Demand.kr(trigx, 0, seqx);
		var signal = Splay.ar(BBandStop.ar( Oregonator.ar(
			Impulse.kr(trig), shift, decay, 0.1, 0.2,initx:initx, inity:inity.neg, initz:initz),
		freq, bw, amp * 1.4));
		signal = HPF.ar(signal, 40);
	})
};

synthesis.specs[\osom] = Dictionary();
synthesis.specs[\osom][\rate] = ControlSpec(1.0,4,'lin');
synthesis.specs[\osom][\trigMin] = ControlSpec(0.005,0.02,'lin');
synthesis.specs[\osom][\trigMax] = ControlSpec(5.0,20,'lin');
synthesis.specs[\osom][\shift] = ControlSpec(0.01,0.04,'lin');
synthesis.specs[\osom][\decay] = ControlSpec(0.05,0.2,'lin');
synthesis.specs[\osom][\initx] = ControlSpec(0.15,0.6,'lin');
synthesis.specs[\osom][\inity] = ControlSpec(0.05,0.2,'lin');
synthesis.specs[\osom][\initz] = ControlSpec(0.1,0.4,'lin');
synthesis.specs[\osom][\freq] = ControlSpec(300.0,1200,'lin');
synthesis.specs[\osom][\bw] = ControlSpec(4.0,16,'lin');
synthesis.specs[\osom][\amp] = ControlSpec(0.5,2,'lin');


// 05. [ gravit ]

synthesis.gravit = {|ev, name=\gravit|

	NF(name, {|rate=12, trigMin=400, trigMax=1000, amp=1.0, freq=10|
		var trigx = Impulse.kr(rate);
		var seqx = Diwhite(trigMin, trigMax, inf);
		var trig = Demand.kr(trigx, 0, seqx);
		HPF.ar(BBandStop.ar(LeastChange.ar(GravityGrid.ar(0, [freq/2, freq]), OFLoFM.ar(freq)), Lag.kr(trig), 12), 40) * amp
	})
};

synthesis.specs[\gravit] = Dictionary();
synthesis.specs[\gravit][\rate] = ControlSpec(6.0,24,'lin');
synthesis.specs[\gravit][\trigMin] = ControlSpec(200.0,800,'lin');
synthesis.specs[\gravit][\trigMax] = ControlSpec(500.0,2000,'lin');
synthesis.specs[\gravit][\freq] = ControlSpec(5.0,20,'lin');


// 06. [ demwi ]

synthesis.demwi = {|ev, name=\demwi|

	NF(name, {|rate=3, trigMin=18, trigMax=20, times=10, delay=0.05, decay=0.5, amp=1.0|
		var trigx = Impulse.kr(rate);
		var seqx = Diwhite(trigMin, trigMax, inf).midicps;
		var trig = Demand.kr(trigx, 0, seqx);
		var snd = HPF.ar(BPeakEQ.ar(
			OFDemWhite.ar(1).tanh(
			SinOsc.ar(trig)),
			LFNoise1.ar(2).range(80,6000ss),
			LFNoise1.ar(3).range(2,8),
			LFNoise1.ar(32).range(-4,-12)), 40);

		Mix.fill(10, { CombC.ar(snd.tanh * amp, delay, rrand(delay/1, delay), decay) * 1/times});
	})
};

synthesis.specs[\demwi] = Dictionary();
synthesis.specs[\demwi][\rate] = ControlSpec(1.5,6,'lin');
synthesis.specs[\demwi][\trigMin] = ControlSpec(9.0,36,'lin');
synthesis.specs[\demwi][\trigMax] = ControlSpec(10.0,40,'lin');
synthesis.specs[\demwi][\times] = ControlSpec(5.0,20,'lin');
synthesis.specs[\demwi][\delay] = ControlSpec(0.025,0.1,'lin');
synthesis.specs[\demwi][\decay] = ControlSpec(0.25,1.0,'lin');

// 07. [ shimr ]

synthesis.shimr = {|ev, name=\shimr|
	NF(name, { |modFreq=8, feedb=0.01, amp=1.0, freqFrom=2140, freqTo=2165|
		SinOscFB.ar(LFNoise1.ar(0.001).range(freqFrom, freqTo)*2, feedb).fold2(SinOsc.ar( modFreq / [1,1.2])) * 0.1 * amp
	})
};

synthesis.specs[\shimr] = Dictionary();
synthesis.specs[\shimr][\modFreq] = ControlSpec(4.0,16,'lin');
synthesis.specs[\shimr][\feedb] = ControlSpec(0.005,0.02,'lin');
synthesis.specs[\shimr][\freqFrom] = ControlSpec(1070.0,4280,'lin');
synthesis.specs[\shimr][\freqTo] = ControlSpec(1082.5,4330,'lin');

// 08. [ drol ]

synthesis.drol = {|ev, name=\pmrol|
	NF(name, { arg freq=60, clipfreq=12, clipfrom=2, clipto=16, lffreq=6, lffrom=100, lfto=3000, amp=1.0 ;
		HPF.ar(PMOsc.ar(freq,
			Lag.ar(
				LFDClipNoise.ar(clipfreq).range(clipfrom,clipto), 0.01), [1000, 2000]).fold2(SinOsc.ar(freq)),
				LFNoise1.ar(lffreq).range(lffrom,lfto), 0.3) * amp
	})
};

synthesis.specs[\pmrol] = Dictionary();
synthesis.specs[\pmrol][\freq] = ControlSpec(30.0,120,'lin');
synthesis.specs[\pmrol][\clipfreq] = ControlSpec(6.0,24,'lin');
synthesis.specs[\pmrol][\clipfrom] = ControlSpec(1.0,4,'lin');
synthesis.specs[\pmrol][\clipto] = ControlSpec(8.0,32,'lin');
synthesis.specs[\pmrol][\lffreq] = ControlSpec(3.0,12,'lin');
synthesis.specs[\pmrol][\lffrom] = ControlSpec(50.0,200,'lin');
synthesis.specs[\pmrol][\lfto] = ControlSpec(1500.0,6000,'lin');

// 09. [ calib ]

synthesis.calib = {|ev, name=\calib|
	NF(name,{ arg freq=10, ch=0.3, hip=500, lop=6000, surface=0.0001, envTime=1, envShape=1, entropy=1, amp = 1.0;
		var signal = FitzHughNagumo.ar(Impulse.kr(LFNoise1.kr([1,2],freq/5,freq)), surface.linlin(0.0, 1.0,0.0001,0.4), ch.linlin(0.0,1.0,0.0001,0.4),
		ch.linlin(0.0, 1.0, 0.01, 3),surface.linlin(0.0, 1.0, 0.01, 4),SinOsc.kr(20,0,0.7), SinOsc.kr(21,0,0.8)) * 0.4;
		LPF.ar(BHiPass4.ar(signal * 0.3, hip), lop) * amp;
	})
};

synthesis.specs[\calib] = Dictionary();
synthesis.specs[\calib][\freq] = ControlSpec(5.0,20,'lin');
synthesis.specs[\calib][\ch] = ControlSpec(0.15,0.6,'lin');
synthesis.specs[\calib][\hip] = ControlSpec(250.0,1000,'lin');
synthesis.specs[\calib][\lop] = ControlSpec(3000.0,12000,'lin');
synthesis.specs[\calib][\surface] = ControlSpec(5e-05,0.0002,'lin');
synthesis.specs[\calib][\envTime] = ControlSpec(0.5,2,'lin');
synthesis.specs[\calib][\envShape] = ControlSpec(0.5,2,'lin');
synthesis.specs[\calib][\entropy] = ControlSpec(0.5,2,'lin');



// 10. [ sofbas ]

synthesis.sofbas = {|ev, name=\sofbas|
	NF(name, {|freq=66, amp=1.0, lffreq=12, resfreq=10.1, resfrom=0.92, resto=1.0135, lpf=50, lpfrq=4|
		BPeakEQ.ar(DFM1.ar(SinOsc.ar([freq,freq*1.09] *
			LFNoise0.ar(lffreq).range(0.98,1.02),0,0.1),300,
			SinOsc.kr(resfreq).range(resfrom,resto),1,0,0.003,0.5), lpf,lpfrq,-9) * 1.7 * amp
	})
};

synthesis.specs[\sofbas] = Dictionary();
synthesis.specs[\sofbas][\freq] = ControlSpec(33.0,132,'lin');
synthesis.specs[\sofbas][\lffreq] = ControlSpec(6.0,24,'lin');
synthesis.specs[\sofbas][\resfreq] = ControlSpec(5.05,20.2,'lin');
synthesis.specs[\sofbas][\resfrom] = ControlSpec(0.46,1.84,'lin');
synthesis.specs[\sofbas][\resto] = ControlSpec(0.50675,2.027,'lin');
synthesis.specs[\sofbas][\lpf] = ControlSpec(25.0,100,'lin');
synthesis.specs[\sofbas][\lpfrq] = ControlSpec(2.0,8,'lin');



// 11. [ brom ]

synthesis.brom = {|ev, name=\brom|
	NF(name, {|freq=66, amp=1.0|
		OFBromate.ar(freq, 4, 6) * amp
	})
};

synthesis.specs[\brom] = Dictionary();
synthesis.specs[\brom][\freq] = ControlSpec(33.0,132,'lin');


// 12. [ fmdin ]

synthesis.fmdin = {|ev, name=\fmdin|
	NF(name, {|freq=66, mod=8, amp=1.0|
		PMOsc.ar(freq, OFDinocap.ar(mod).range(10,100), 1.1) * 0.25 * amp
	})
};

synthesis.specs[\fmdin] = Dictionary();
synthesis.specs[\fmdin][\freq] = ControlSpec(33.0,132,'lin');
synthesis.specs[\fmdin][\mod] = ControlSpec(4.0,16,'lin');

// 13. [ nanite ]

synthesis.nanite = {|ev, name=\nanite|
	NF(name, {|freq=40, mod=14.1, amp=1.0, lpf=8000|
		LPF.ar(OFNanite.ar(mod, surface:0.001, freqShift:freq), lpf) * 1.2
	})
};

synthesis.specs[\nanite] = Dictionary();
synthesis.specs[\nanite][\freq] = ControlSpec(20.0,80,'lin');
synthesis.specs[\nanite][\mod] = ControlSpec(7.05,28.2,'lin');
synthesis.specs[\nanite][\lpf] = ControlSpec(4000.0,16000,'lin');


// 14. [ dagal ]

synthesis.dagal = {|ev, name=\dagal|
	NF(name, {|freq=57, amp=1.0|
		OFDagal.ar(57, rate:2, resTo:1, lpf:800, mul:2) * amp
	})
};

synthesis.specs[\dagal] = Dictionary();
synthesis.specs[\dagal][\freq] = ControlSpec(28.5,114,'lin');
synthesis.specs[\dagal][\amp] = ControlSpec(0.5,2);


// 15. [ evdrone ]

synthesis.evdrone = {|ev, name=\evdrone|
	NF(name, {|mod=150, amp=0.12, fa=3, fb=6, fc=9, fd=12|
		Splay.ar([fa, fb, fc, fd].collect{|rate|
			HPF.ar(
				SinOsc.ar(LFCub.kr(rate, 0, mod * 0.5, mod), 0, amp),
				50
			) * SinOsc.ar(0.01 + 0.5.rand).range(0, 0.8)
		}) * 1.2
	})
};

synthesis.specs[\evdrone] = Dictionary();
synthesis.specs[\evdrone][\mod] = ControlSpec(75.0,300,'lin');
synthesis.specs[\evdrone][\fa] = ControlSpec(1.5,6,'lin');
synthesis.specs[\evdrone][\fb] = ControlSpec(3.0,12,'lin');
synthesis.specs[\evdrone][\fc] = ControlSpec(4.5,18,'lin');
synthesis.specs[\evdrone][\fd] = ControlSpec(6.0,24,'lin');


// 16. [ texture ]

synthesis.texture = {|ev, name=\texture|
	NF(name, {|density=120, timeUp=6, timeDown=8, amp=0.5|
		var sig = Dust.ar(density) + Crackle.ar(0.9);
		var holder = EnvGen.ar(Env([0,1,0], [timeUp,timeDown]).circle);
		var sinFrom = EnvGen.ar(Env([0,1,0], [timeUp*2,timeDown/2]).circle);
		var mod = LFNoise2.ar([4,8]).range(sinFrom, 1.0);
		sig = sig * Line.kr(0, 1, timeUp);
		sig * (mod * holder) ! 2 * amp
	})
};

synthesis.specs[\texture] = Dictionary();
synthesis.specs[\texture][\density] = ControlSpec(60.0,240,'lin');
synthesis.specs[\texture][\timeUp] = ControlSpec(3.0,12,'lin');
synthesis.specs[\texture][\timeDown] = ControlSpec(4.0,16,'lin');


// 17. [ clicks ]

synthesis.clicks = {|ev, name=\clicks|
	NF(name, {|freq=2000, rate=5.5, amp=0.3|
		var freqx = freq + 5;
		var snd = RLPF.ar(Saw.ar(LFNoise2.ar([0.1, 0.15])
			.range(freqx, freqx*Array.rand(8, 0.9, 1.5))), Array.series(4, 600, 200))
			* EnvGen.ar(Env.perc(0.004, 0.02), Impulse.ar(rate));
		Splay.ar(snd) * amp
	})
};

synthesis.specs[\clicks] = Dictionary();
synthesis.specs[\clicks][\freq] = ControlSpec(1000.0,4000,'lin');
synthesis.specs[\clicks][\rate] = ControlSpec(2.75,11,'lin');


// 18. [ dfmbass ]

synthesis.dfmbass = {|ev, name=\dfmbass|
	NF(name, {|freq=66, amp=0.4|
		BPeakEQ.ar(
			DFM1.ar(
				SinOsc.ar([freq, freq*1.13] * LFNoise0.ar([2, 4, 8, 16]).range(0.98, 1.02), 0, 0.1),
				400, SinOsc.kr(10.1).range(0.92, 1.0185), 1, 0, 0.003, 0.5
			), 50, 4, -9
		) * 2.5 * amp
	})
};

synthesis.specs[\dfmbass] = Dictionary();
synthesis.specs[\dfmbass][\freq] = ControlSpec(33.0,132,'lin');


// 19. [ blipfold ]

synthesis.blipfold = {|ev, name=\blipfold|
	NF(name, {|freq=65, amp=0.3|
		var brown = Dbrown(freq-5, freq+5, 100, inf);
		var trig = Impulse.kr(LFNoise1.kr(0.3, 4000, 15));
		var freqd = Demand.kr(trig, 0, brown);
		var sig = Blip.ar(freqd, 15, 4);
		sig = HPF.ar(sig.fold2(SinOsc.ar(20)), freqd * 1.2, amp);
		BBandStop.ar(sig, LFNoise1.kr(0.4).range(600, 6000), 6)
	})
};

synthesis.specs[\blipfold] = Dictionary();
synthesis.specs[\blipfold][\freq] = ControlSpec(32.5,130,'lin');


// 20. [ crackstop ]

synthesis.crackstop = {|ev, name=\crackstop|
	NF(name, {|crmod=12, crfrom=1.01, crto=1.5, amp=0.5|
		BBandStop.ar(
			LPF.ar(Crackle.ar(LFNoise2.ar(crmod).range(crfrom, crto), 0.5), 12000),
			StandardL.ar(5.4).range(100, 300), 6
		) * amp
	})
};

synthesis.specs[\crackstop] = Dictionary();
synthesis.specs[\crackstop][\crmod] = ControlSpec(6.0,24,'lin');
synthesis.specs[\crackstop][\crfrom] = ControlSpec(1.005,1.02,'lin');
synthesis.specs[\crackstop][\crto] = ControlSpec(1.25,2.0,'lin');


// 21. [ gbdrone ]

synthesis.gbdrone = {|ev, name=\gbdrone|
	NF(name, {|freq=60, index=10, modMult=15, amp=0.4|
		var mod = Lag.ar(GbmanL.ar(
			LFNoise1.kr(0.1, 0.5, 3.5), LFNoise1.kr(0.2, 500, 1000), 0.25, 0.5
		).range(freq, freq * modMult), 0.1);
		BPeakEQ.ar(
			PMOsc.ar([LFNoise2.kr(0.05, freq/5, freq), LFNoise2.kr(0.01, freq/10, freq/2)],
				mod, index, 0, 0.2),
			3000, 2, -12, 0.5
		) * amp
	})
};

synthesis.specs[\gbdrone] = Dictionary();
synthesis.specs[\gbdrone][\freq] = ControlSpec(30.0,120,'lin');
synthesis.specs[\gbdrone][\index] = ControlSpec(5.0,20,'lin');
synthesis.specs[\gbdrone][\modMult] = ControlSpec(7.5,30,'lin');


// 22. [ fmpulse ]

synthesis.fmpulse = {|ev, name=\fmpulse|
	NF(name, {|freq=101, amp=0.4|
		var p = Pulse.ar(LFPulse.ar(120, 0, 0.55, freq/8, freq), Saw.ar(freq/3));
		var bass = MoogFF.ar(p, LFNoise1.ar(10, 10, freq), 3) ! 2 * 0.3;
		var highs = RHPF.ar(p, LFNoise0.ar(1, 20, freq * 60), 3) ! 2 * 0.3;
		(bass + highs) * amp
	})
};

synthesis.specs[\fmpulse] = Dictionary();
synthesis.specs[\fmpulse][\freq] = ControlSpec(50.5,202,'lin');


// 23. [ grain ]

synthesis.grain = {|ev, name=\grain|
	NF(name, {|rate=20, grAtk=0.88, grRel=0.2, amp=0.6|
		var trigger = (Impulse.ar(rate) * 0.8) + (Dust.ar(rate) * 0.2);
		var env = EnvGen.ar(Env.perc(grAtk, grRel, 1, 4), trigger, 1, 0, (1/rate));
		Mix.ar(HPF.ar(
			SinOsc.ar([rate/3, rate], 0, env * 0.5) +
			BPF.ar(PinkNoise.ar(mul: env), rate * Array.series(8, 4, 4), 0.2),
		40)) * amp
	})
};

synthesis.specs[\grain] = Dictionary();
synthesis.specs[\grain][\rate] = ControlSpec(10.0,40,'lin');
synthesis.specs[\grain][\grAtk] = ControlSpec(0.44,1.76,'lin');
synthesis.specs[\grain][\grRel] = ControlSpec(0.1,0.4,'lin');


// 24. [ foldplane ]

synthesis.foldplane = {|ev, name=\foldplane|
	NF(name, {|amp=0.4|
		var sd = SampleDur.ir;
		var trig = Impulse.kr(0.5);
		var seq = Dseq([Dbrown(10, 30, 2, 16), Dwhite(10, 20, 8)], inf);
		var freq = Demand.kr(trig, 0, seq);
		DemandEnvGen.ar(
			Dseq([0.1, -0.1, [-0.2, 0.2]], inf),
			Dseq([sd * 9, sd * 5], inf)
		).fold2(SinOsc.ar([freq, freq*0.5])) * 0.23 * amp
	})
};

synthesis.specs[\foldplane] = Dictionary();


// 25. [ midtex ]

synthesis.midtex = {|ev, name=\midtex|
	NF(name, {|amp=0.3|
		var signal = DemandEnvGen.ar(
			Dseq([-1, 0.1, Dwhite(-0.1, 0.1, 5), Dwhite(-0.2, 0.2, 5)], inf),
			SampleDur.ir * Array.rand(8, 0.8, 8.2), 1, 0, 1, Impulse.ar([10, 40])
		) * XLine.ar(0.0015, 0.15, 12);
		BPeakEQ.ar(signal, Array.rand(8, 4000, 10000), 4,
			EnvGen.ar(Env([0, -1, -7], [4, 12]))) * 2 * amp
	})
};

synthesis.specs[\midtex] = Dictionary();


// 26. [ sparks ]

synthesis.sparks = {|ev, name=\sparks|
	NF(name, {|freq=4200, amp=0.5|
		var freqx = freq - 5;
		Splay.ar(
			RLPF.ar(
				Saw.ar(LFNoise2.ar([0.1, 0.15], 2).range(freqx, freqx * Array.rand(8, 0.5, 2.0))),
				1200
			) * EnvGen.ar(Env.perc(0.004, 0.08, 3.0), Impulse.ar(Array.rand(8, 0.5, 1.2)))
		) * amp
	})
};

synthesis.specs[\sparks] = Dictionary();
synthesis.specs[\sparks][\freq] = ControlSpec(2100.0,8400,'lin');

synthesis

)
