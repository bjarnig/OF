
/*

  ---- ---- ---- ---- OF 'Synthesis' ---- ---- ---- ----

	an Event() that containts NFs responsible for synthesis

*/

(

var synthesis = ();

// 01. [ silk ]

synthesis.silk = {|ev, name=\silk|

	NF(name, {|freq=1090, amp=1.0, harms=170, modFreq=9, modFreq2=1, modFreq3=3.1|
		var mod = SinOsc.ar(LFNoise2.kr(modFreq2).range(modFreq * 5, 0.5), 0, LFNoise1.kr(modFreq/10).range(5, 20));
		var sig = Splay.ar(Blip.ar(Array.series(5, freq, freq/24) + mod, harms));
		sig = BPeakEQ.ar(BBandStop.ar(sig, harms * 10, 2.5), LFNoise1.kr(modFreq, 3500, 8000), 1, -10) * 2;
		Splay.ar(sig * LFNoise1.ar(modFreq3).range(0.3,1.1) * amp)
	})
};

// 02. [ vsaw ]

synthesis.vsaw = {|ev, name=\vsaw|

	NF(name, {|freq=90, amp=1.0, modFreq=0.5, ampMod=0.8, bsMul=600, bsAdd=800, bsBw=8|
		var sig = VarSaw.ar(LFPar.ar(freq/[10,8], 0, 10, LFPar.kr(5, 0, 5, freq)), 0, LFNoise2.kr(freq/3, 0.5, 1.5)) * 0.6;
		var thres = Lag.kr(Amplitude.kr(sig), 0.1);
		var osc = Splay.ar(Pulse.ar(Array.series(10, freq, 5))) * thres;
		sig = osc + BPeakEQ.ar(BBandStop.ar(sig, LFNoise1.kr(modFreq, bsMul, bsAdd), bsBw), 80, 3, -2);
 		HPF.ar(Splay.ar(sig),60,amp.poll) * LFNoise1.ar(ampMod).range(0.3,1.1)
	})
};


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

// 05. [ gravit ]

synthesis.gravit = {|ev, name=\gravit|

	NF(name, {|rate=12, trigMin=400, trigMax=1000, amp=1.0, freq=10|
		var trigx = Impulse.kr(rate);
		var seqx = Diwhite(trigMin, trigMax, inf);
		var trig = Demand.kr(trigx, 0, seqx);
		HPF.ar(BBandStop.ar(LeastChange.ar(GravityGrid.ar(0, [freq/2, freq]), LoFM.ar(freq)), Lag.kr(trig), 12), 40) * amp
	})
};

// 06. [ demwi ]

synthesis.demwi = {|ev, name=\demwi|

	NF(name, {|rate=3, trigMin=18, trigMax=20, times=10, delay=0.05, decay=0.5, amp=1.0|
		var trigx = Impulse.kr(rate);
		var seqx = Diwhite(trigMin, trigMax, inf).midicps;
		var trig = Demand.kr(trigx, 0, seqx);
		var snd = HPF.ar(BPeakEQ.ar(
			DemWhite.ar(1).tanh(
			SinOsc.ar(trig)),
			LFNoise1.ar(2).range(80,6000ss),
			LFNoise1.ar(3).range(2,8),
			LFNoise1.ar(32).range(-4,-12)), 40);

		Mix.fill(10, { CombC.ar(snd.tanh * amp, delay, rrand(delay/1, delay), decay) * 1/times});
	})
};

// 07. [ shimr ]

synthesis.shimr = {|ev, name=\shimr|
	NF(name, { |modFreq=8, feedb=0.01, amp=1.0, freqFrom=2140, freqTo=2165|
		SinOscFB.ar(LFNoise1.ar(0.001).range(freqFrom, freqTo)*2, feedb).fold2(SinOsc.ar( modFreq / [1,1.2])) * 0.1 * amp
	})
};

// 08. [ drol ]

synthesis.drol = {|ev, name=\pmrol|
	NF(name, { arg freq=60, amp=1.0 ;
		HPF.ar(PMOsc.ar(freq,
			Lag.ar(
				LFDClipNoise.ar(12).range(2,16), 0.01), [1000, 2000]).fold2(SinOsc.ar(freq)),
				LFNoise1.ar(6).range(100,3000), 0.3) * amp
	})
};

// 09. [ calib ]

synthesis.calib = {|ev, name=\calib|
	NF(name,{ arg freq=10, ch=0.3, hip=500, lop=6000, surface=0.0001, envTime=1, envShape=1, entropy=1, amp = 1.0;
		var signal = FitzHughNagumo.ar(Impulse.kr(LFNoise1.kr([1,2],freq/5,freq)), surface.linlin(0.0, 1.0,0.0001,0.4), ch.linlin(0.0,1.0,0.0001,0.4),
		ch.linlin(0.0, 1.0, 0.01, 3),surface.linlin(0.0, 1.0, 0.01, 4),SinOsc.kr(20,0,0.7), SinOsc.kr(21,0,0.8)) * 0.4;
		LPF.ar(BHiPass4.ar(signal * 0.3, hip), lop) * amp;
	})
};

// 10. [ sofbas ]

synthesis.sofbas = {|ev, name=\sofbas|
	NF(name, {|freq=66, amp=1.0|
		BPeakEQ.ar(DFM1.ar(SinOsc.ar([freq,freq*1.09] *
			LFNoise0.ar(12).range(0.98,1.02),0,0.1),300,
			SinOsc.kr(10.1).range(0.92,1.0135),1,0,0.003,0.5), 50,4,-9) * 1.7 * amp
	})
};

// 11. [ brom ]

synthesis.brom = {|ev, name=\brom|
	NF(name, {|freq=66, amp=1.0|
		Bromate.ar(freq, 4, 6) * amp
	})
};

// 12. [ fmdin ]

synthesis.fmdin = {|ev, name=\fmdin|
	NF(name, {|freq=66, mod=8, amp=1.0|
		PMOsc.ar(freq, Dinocap.ar(mod).range(10,100), 1.1) * 0.25 * amp
	})
};

// 13. [ nanite ]

synthesis.nanite = {|ev, name=\nanite|
	NF(name, {|freq=40, mod=14.1, amp=1.0, lpf=8000|
		LPF.ar(Nanite.ar(mod, surface:0.001, freqShift:freq), lpf) * 1.2
	})
};

// 14. [ dagal ]

synthesis.dagal = {|ev, name=\dagal|
	NF(name, {|freq=57, amp=1.0|
		Dagal.ar(57, rate:2, resTo:1, lpf:800, mul:2) * amp
	})
};

)
