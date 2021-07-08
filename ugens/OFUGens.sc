
OFNanite : UGen {
	*ar { arg freq=9, ch=0.3, hip=50, lop=6000, surface=0.0001, freqShift=0, modFreq=1, mul=1.0, add=0.0;
		var signal, out;
		signal = FitzHughNagumo.ar(Impulse.kr(LFNoise1.kr([modFreq,modFreq*2],freq/5,freq)), surface.linlin(0.0, 1.0,0.0001,0.4), ch.linlin(0.0,1.0,0.0001,0.4), ch.linlin(0.0, 1.0, 0.01, 3),surface.linlin(0.0, 1.0, 0.01, 4),SinOsc.kr(20*modFreq,0,0.7), SinOsc.kr(21*modFreq,0,0.8)) * 0.2;
		signal = FreqShift.ar(signal, [freqShift, freqShift*2]);
		out = LPF.ar(BHiPass4.ar(signal * 0.3, hip), lop);
		out = BPeakEQ.ar(out, 8470, 1, -12);
		^out.madd(mul, add)
	}
}

OFLoFM : UGen {
	*ar { arg freq=30, mul=1.0, add=0.0;
	var out = PMOsc.ar(freq, LFDClipNoise.ar().range(50,100), 1);
	^out.madd(mul, add)
	}
}

OFDemWhite : UGen {
	*ar { arg scale=1.1, amp=0.08, mul=1.0, add=0.0;
		var out = DemandEnvGen.ar(
		Dseq([-1, 0.1,  Dwhite(-0.1, 0.1, 5), Dwhite(-0.2, 0.2, 5)], inf),
		SampleDur.ir * scale, 1, 0,  1, Impulse.ar([10, 40])) * amp;
		^out.madd(mul, add)
	}
}

OFBromate : UGen {
	*ar { arg freq=100, modFreq=2.1, mul=1.0, add=0.0;
		var saw = LeastChange.ar(GbmanL.ar(freq, freq * 1.3).clip(LFNoise2.ar([modFreq, modFreq*1.1])), GbmanL.ar(freq*1.3));
		var band = BBandStop.ar(saw, LFNoise2.kr(freq/100, freq, freq * 4), 10);
		var out = Splay.ar(LPF.ar(HPF.ar(band, 110), 15000)) * 0.25;
		^out.madd(mul, add)
	}
}

OFDinocap : UGen {
	*ar { arg freq = 90, modFreq=0.1, modFrom=0.5, modTo=2.5, mul=1.0, add=0.0;
		var diff = freq + (freq * 0.5);
		var relb = GbmanL.ar(modFreq).range(modFrom, modTo);
		var diffb = relb + (relb * 1.75);
		var modulator = LFPar.ar(0.02);
		var out = SinOsc.ar(LFCub.kr([freq + (freq * 0.5), freq], 0, diff * 3, freq *
		(freq*modulator.range(0.4,0.44))), 0, modulator.range(0.02, 0.0) ) +
		SinOsc.ar(LFCub.kr([relb + (relb * 0.5), relb], 0, diffb * 10, relb * relb), 0, 0.03) * 0.8;
		out = HPF.ar(out, 25);
		^out.madd(mul, add)
	}
}

OFDagal : UGen {
	*ar { arg freq=50, trig=0.5, rate=10, modFreq=0.05, resFrom=0.82, resTo=1.001, lpf=600, hpfFrom=100, hpfTo=200, mul=1.0, add=0.0;
		var seq = Dseq([ Dbrown(rate*0.1, rate, rate*0.2, rate*1.6), Dwhite(rate*0.1, rate, 8)], inf);
		var freqRate = Demand.kr(Impulse.kr(trig), 0, seq);
		var snd = DFM1.ar(SinOsc.ar([freq*0.8,freq],0,0.1),lpf,SinOsc.kr(modFreq).range(resFrom,resTo),1,0,0.002,0.8);
		var out = HPF.ar(snd, SinOsc.ar(freqRate).range(hpfFrom,hpfTo)) * 1.4;
		^out.madd(mul, add)
	}
}

OFLFDorm : UGen {
	*ar { arg freq=0.2, from=0.5, to=5, min=0.05, max=1.3, mul=1.0, add=0.0;
		var out = LFNoise2.ar(LFPulse.ar(freq).range(from, to)).exprange(min, max).min(max*1.5);
		^out.madd(mul, add)
	}
}


OFVesica : UGen {
	*ar { arg freq=50, ch=0.2, lop=18000, hip=20, lopVol=0.5, hipVol=0.5, surface=0.2,
	envTime=1, envShape=1, entropy=14, mul=1.0, add=0.0;
	var signal, out;
	signal = FitzHughNagumo.ar(Impulse.kr(LFNoise1.kr([1,2],freq/5,freq)), surface.linlin(0.0, 1.0,0.0001,0.4), ch.linlin(0.0,1.0,0.0001,0.4),
	ch.linlin(0.0, 1.0, 0.01, 3),surface.linlin(0.0, 1.0, 0.01, 4),SinOsc.kr(20,0,0.7), SinOsc.kr(21,0,0.8)) * 0.1;
	signal = BLowPass4.ar(signal, lop, 0.25, mul:lopVol) + BHiPass4.ar(signal, hip, 0.25, mul:hipVol);
	out = LPF.ar(BHiPass4.ar(signal * 0.2, hip), 16000);
	^out.madd(mul, add)
	}
}
