
/*

  ---- ---- ---- ---- OF 'Processing' ---- ---- ---- ----

	an Event() that containts NFs responsible for processing.

*/

(

var processing = ();

processing.verb = {|ev|
	{|in, vroom=5|
		var freq = Tartini.kr(in)[0][0], amp = Lag.ar(Amplitude.ar(in), 0.5);
		GVerb.ar(in, vroom, amp.linlin(0.0,1.0,5,0.1),freq.linlin(20,20000, 0.6, 0.9))
	};
};

processing.decimator = {|ev|
	{ |in, dratef=5000, dratet=15000, dbitsf=16, dbitst=2|
		var freq = Tartini.kr(in)[0][0];
		Decimator.ar(in,freq.linlin(0,20000,5000,15000),freq.linlin(20,20000, dbitst, dbitsf))
	};
};

processing.fold = {|ev|
	{ |in, ffreq=20|
		HPF.ar(in.fold2(SinOsc.ar(ffreq)), 40)
	};
};

processing.chopper = {|ev|
	{ |in, cmod=5, cfrom=0.0, cto=1.0|
		var freq = Tartini.kr(in)[0][0];
		in * SinOsc.ar(freq.linlin(20,20000, cmod, cmod * 10) * SinOsc.ar(0.25).range(0.5,2) ).range(cfrom, cto)
	};
};

processing.fshift = {|ev, envHi = 1.2, envLo = 0.3|
	{ |in, fmod=20,ffrom=60,fto=100|
		var dst = (in * SinOsc.ar( LFNoise1.ar(0.2).range(10,50).max(10).min(50)).range(0.1, 0.9)) +
		FreqShift.ar(in, LFNoise1.ar(fmod).range(ffrom,fto).max(ffrom).min(fto));
		var env = Env([envLo,envLo*1.1,envHi,envHi*0.8,envHi*0.9,envLo,envLo*1.1,envHi,envHi* 0.8,envHi*0.9],
		{ rrand(0.1, 1.2) } ! 9);
		dst * EnvGen.ar(env.circle) * 1.1
	};
};

processing.foldorm = {|ev|
	{ |in, fdmod=1, fdlag=8, fdfreq=50|
		var la, lb;
		la = in.fold2(SinOsc.ar( Lag.ar(GbmanL.ar(8 * fdmod, 0.6).range(fdfreq*0.2,fdfreq*0.3), fdlag)));
		la = la	* OFLFDorm.ar(fdmod* 0.01, min:0.3, max:1.1);
		lb = in.thresh(SinOsc.ar(GbmanL.ar(3*fdmod).range(fdfreq,fdfreq*4)));
		la + lb
	};
};

processing.minsaw = {|ev|
	{|in, mfreq=10, mbw=12|
		BBandStop.ar(in < LFSaw.ar([mfreq, mfreq*1.3]), [mfreq*6,mfreq*8], mbw) * 0.7;
	}
};

processing.modsaw = {|ev|
	{|in, mbw=12|
		var freq = Tartini.kr(in)[0][0];
		BBandStop.ar(in.mod(LFSaw.ar([freq*0.125, freq*0.3])), [freq*6,freq*8], mbw) * 0.7;
	}
};

processing.clip = {|ev|
	{|in, cfreq=60, mbw=2|
		BBandStop.ar(in.clip(SinOsc.ar(cfreq)), [cfreq*4,cfreq*7], mbw) * 0.7;
	}
};

processing.drift = {|ev|
	{|in, drfreqh=0.25, drfreql=0.15, drlopf=200, drlopt=800, drhpf=7000, drhpt=12000|
		var sig, osc, thres, freq=1000, la, lb, lc, verb, effect;
		var envLo = 0.8, envHi = 0.99;
		var times = { rrand(0.5, 1.8) } ! 8;
		var mix = EnvGen.ar(Env([0, envLo, envHi, envHi/2, envLo, envLo/2, envHi, envLo, 0], times).circle);
		sig = in; verb = sig;
		8.do{verb=AllpassL.ar(verb,0.3,{0.1.rand+0.1}!2,5)}; verb = verb.tanh;
		effect = BLowPass4.ar(verb * 0.5, LFNoise2.ar(drfreql).range(drlopf, drlopt), 0.2) +
		BHiPass4.ar(verb * 0.5, LFNoise2.ar(drfreqh).range(drhpf, drhpt), 0.2);
		(effect * mix) + (sig * (1-mix));
	}
};

processing.dualdist = {|ev|
	{|in, ddlpf=100, ddhpf=8000, ddgaina=800, ddgainb=200|
		var son = in;
		var f1 = rrand(0.3, 2.5);
		var f2 = rrand(1.2, 3.5);
		HPF.ar(SoftClipAmp8.ar(son, pregain:ddgaina), Lag.ar(LFNoise0.ar(f1).range(ddhpf, ddhpf * 2))) +
		LPF.ar(SoftClipAmp8.ar(son, pregain:ddgainb), Lag.ar(LFNoise0.ar(f2).range(ddlpf * 0.25, ddlpf)))
	}
};

processing.amclip = {|ev|
	{|in,amfreq=100|
		in.amclip(Saw.ar(amfreq))
	}
};

processing.wloss = {|ev|
	{|in,wldrop=30, wloutoff=40, wlmode=2|
		WaveLoss.ar(in, wldrop, wloutoff, wlmode)
	}
};

processing.bfold = {|ev|
	{|in, bffreq=24, bfstop=500, bfbw=6|
		HPF.ar(
			BBandStop.ar(
				in.fold2(SinOsc.ar([bffreq*1.05,bffreq])),bfstop,bfbw
			),
		rrand(40,60)) * 4;
	}
};

processing.xloss = {|ev|
	{|in, xlfrom=10, xlto=18, xlfreq=0.1, xlfreqf=2, xlfreqt=4|
		var sh = Amplitude.ar(in*2, 0.001).linlin(0,1,xlfrom,xlto);
		WaveLoss.ar(in, LFDNoise3.ar( SinOsc.ar(xlfreq).range(xlfreqf,xlfreqt) ).range(sh*0.5,sh), 25)
	}
};

processing.diffuse = {|ev|
	{|in, diffreq=3, diffrom=500, difto=2000, difroom=25|
		var verb = GVerb.ar( BBandStop.ar(in, LFDNoise1.ar(diffreq).range(diffrom,difto)), difroom, 5, damping:0.5 );
		XFade2.ar(in, verb, -0.75);
	}
};

processing.lfdnamp = {|ev|
	{|in, lfafrom=4, lfato=10, lfamod=0.1, lfashift=0.8|
		var amp = Amplitude.ar(in).range(lfafrom, SinOsc.ar(lfamod).range(lfato,lfato*2));
		var sig = in * LFDNoise3.ar(amp).range(0.1,1.2);
		sig.distort + PitchShift.ar(sig, 0.02, lfashift)
	}
};

processing.filtfold = {|ev|
	{|in,ffofrom=100, ffotto=8000|
		var freq = Tartini.kr(in)[0][0].linlin(20,20000,1,10);
		var sig = DFM1.ar(in,
		LFDNoise3.ar(freq/64).range(ffofrom, ffotto),
		SinOsc.kr(freq/32).range(0.92,1.0135),1,0,0.005,0.7);
		sig = XFade2.ar(sig, Fold.ar(sig, SinOsc.ar(freq*10), SinOsc.ar(freq*5)), LFDNoise0.ar(freq* 0.1).range(-1.0,1.0), 0.75);
		HPF.ar(sig,40)
	}
};

processing.rmsfold = {|ev|
	{|in, rmfreq=3, rmfrom=1, rmtto=12, rmbw=8|
		var rms = RMS.ar(in * SinOsc.ar(rmfreq) * 2).range(rmfrom,rmtto);
		var freq = Lag.kr(Tartini.kr(in)[0][0], 2.0);
		HPF.ar(BBandStop.ar( in.fold2(SinOsc.ar( [rms,rms+1])), freq * 5, rmbw), 60) * 3;
	}
};

processing.ampdrift = {|ev,addur=5|
	{|in, admin = 0.0, admax = 1.3|
		var freq = Tartini.kr(in)[0][0].linlin(0,20000, 1,15);
		in * EnvGen.ar( Env([admin, admax * 0.5, admax, admax, admin], [0.1,2,2,1].normalizeSum * addur, [5,4,-4,-5] ).circle )
		* LFDNoise3.ar(freq).range(admin,admax)
	}
};

processing.pulsecross = {|ev,base=200|
	{|in|
		var freq = Tartini.kr(in)[0][0].linlin(0,20000, 1, 10);
		var osc, verb, thres, sig;
		thres = Lag.kr(Amplitude.kr(in), 0.1);
		sig = Splay.ar(Pulse.ar(Array.series(10, base, 20) * Lag.kr(freq, 2.0) )) * thres;
		XFade2.ar(in,sig, 0.5)
}
};

processing.mostchanged = {|ev|
	{|in|
		MostChange.ar(in, SinOsc.ar(ZeroCrossing.ar(in) * 0.5) ) * 0.5
	}
};

processing.feedfold = {|ev|
	{|in, ffdfreq=0.1, ffdfold=10, ffdfeedback=0.6, ffddelay=0.2|
		var effect = in + LocalIn.ar(2);
		effect = effect.fold2(SinOsc.ar( LFNoise2.ar(ffdfreq).range(ffdfold,ffdfold*2) ));
		effect = DelayC.ar(effect, ffddelay, SinOsc.ar(ffdfreq * 0.01).range(0.1,0.202));
		LocalOut.ar(effect * ffdfeedback);
		effect
	}
};

processing.gravch = {|ev|
	{|in, grfrom=100, grto=1500|
		var freq = Tartini.kr(in)[0][0].linlin(0,20000, grfrom, grto);
		LPF.ar(LeastChange.ar(GravityGrid.ar(0, [freq * 0.25, freq* 0.5] ), in), (freq * 50).min(15000), 0.4);
	}
};

processing.vesica = {|ev|
	{|in, vefreq=0.01, vefrom=0.5, veto=2|
		var mod = LFNoise1.kr(vefreq);
		Fold.ar(in, OFVesica.ar(mod.range(vefrom,veto)), OFVesica.ar(mod.range(vefrom*10,veto*8)) * 3)
	}
};

processing.ghole = {|ev|
	{|in, ghmod=0.1, ghfreqf=100, ghfreqt=1000|
		var mod = LFNoise1.kr(ghmod);
		Greyhole.ar(FreqShift.ar(in, 0.1, Lag.kr(mod.range(ghfreqf, ghfreqt), 4)), 0.8, 0.6, mod.range(5,10), 0.1, 0.8, 0.4, 0.5)
	}
};

processing.bbstop = {|ev|
	{|in, bbsfreq=0.3, bbsfiltf=100, bbsfiltt=8000, bbsfiltbw=6|
		BBandStop.ar(in.round(0.1), LFNoise1.ar(bbsfreq).exprange(bbsfiltf, bbsfiltt), bbsfiltbw) * 1.5;
	}
};

processing.dfmf = {|ev, dffreq=0.5, dffiltf=50, dffiltt=8000|
	{|in|
		var chain = FFT(LocalBuf(2048), in);
		var centroid = SpecCentroid.kr(chain) * LFNoise1.kr(dffreq).exprange(0.001,0.2);
		in = in.thresh(SinOsc.ar(centroid * 0.08));
		DFM1.ar(in,LFDNoise1.ar(centroid * 0.05).range(dffiltf,dffiltt),SinOsc.kr(centroid * 0.05).range(0.82,0.9),1,0,0.005,0.7);
	}
};

processing.bcomb = {|ev, bcmult=3, bcfilt=100, bcbw=2, bcdellag=3, bcdelf=0.2, bcdelt=0.8, bcdeldec=2|
	{|in|
		var mod = LFNoise1.ar([1, 1.1, 1.2, 1.3] * bcmult);
		var snd = BBandStop.ar(in, mod.exprange(bcfilt, bcfilt*10), mod.exprange(bcbw, bcbw*2));
		Splay.ar( CombC.ar(snd, 0.2, Lag.kr(Amplitude.kr(in), bcdellag).range(bcdelf,bcdelt), bcdeldec))
	}
};

processing.cubmod = {|ev|
	{|in, ctrig=5, ctfrom=1, ctto=10, ctampm=0.5, ctampa=0.9|
		var trig, seq, freq;
		trig = Impulse.kr(ctrig);
	    seq = Diwhite(Rand(ctfrom*0.1, ctfrom*2), Rand(ctto,ctto*3), inf).midicps;
		freq = Demand.kr(trig, 0, seq);
		LFCub.kr([freq, freq/4], 0, ctampm, ctampa) * in
	}
};

processing.lfddel = {|ev|
	{|in, lfdfeedback=0.5, lfddelay=0.2, lfdfreq=0.1|
		var mod = LFNoise2.ar(lfdfreq);
		var effect = in + LocalIn.ar(2);
		effect = effect * LFDNoise1.ar(mod.range(1,10)).range(0.5,1.0);
		effect = DelayC.ar(effect, lfddelay, mod.range(0.1, 0.302));
		LocalOut.ar(effect * lfdfeedback);
		effect
	}
};

// Utilities //

processing.append = {|ev, nf, name|
	var local = ("append_" ++ name).asSymbol;
	local.postln;
	nf.postln;
	NF(local, { nf.ar });
	NF(local)[10] = \filter -> ev[name].value;
	NF(local);
};

)
