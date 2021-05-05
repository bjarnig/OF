
/*

  ---- ---- ---- ---- Pipeline 'Processing' ---- ---- ---- ----

   an Event() that containts Ndefs responsible for processing.

*/

(

var processing = ();

processing.verb = {|ev|
	{|in, vroom=5| GVerb.ar(in,vroom) };
};

processing.decimator = {|ev|
	{ |in, drate=8000, dbits=8|
		Decimator.ar(in,drate,dbits)
	};
};

processing.fold = {|ev|
	{ |in, ffreq=20|
		in.fold2(SinOsc.ar(ffreq))
	};
};

processing.chopper = {|ev|
	{ |in, cmod=1, cfrom=0.0, cto=1.0|
		in * SinOsc.ar(cmod).range(cfrom, cto)
	};
};

processing.fshift = {|ev, envHi = 1.2, envLo = 0.3|
	{ |in, fmod=20,ffrom=60,fto=100|
		var dst = (in * SinOsc.ar( LFNoise1.ar(0.2).range(10,50).max(10).min(50)).range(0.1, 0.9)) +
		FreqShift.ar(in, LFNoise1.ar(fmod).range(ffrom,fto).max(ffrom).min(fto).poll);
		var env = Env([envLo,envLo*1.1,envHi,envHi*0.8,envHi*0.9,envLo,envLo*1.1,envHi,envHi* 0.8,envHi*0.9],
		{ rrand(0.1, 1.2) } ! 9);
		dst * EnvGen.ar(env.circle)
	};
};

processing.foldorm = {|ev|
	{ |in, fdmod=1, fdlag=8, fdfreq=50|
		var la, lb;
		la = in.fold2(SinOsc.ar( Lag.ar(GbmanL.ar(8 * fdmod, 0.6).range(fdfreq*0.2,fdfreq*0.3), fdlag)));
		la = la	* LFDorm.ar(fdmod* 0.01, min:0.3, max:1.1);
		lb = in.thresh(SinOsc.ar(GbmanL.ar(3*fdmod).range(fdfreq,fdfreq*4)));
		la + lb
	};
};

processing.minsaw = {|ev|
	{|in, mfreq=10, mbw=12|
		BBandStop.ar(in < LFSaw.ar([mfreq, mfreq*1.3]), [mfreq*6,mfreq*8], mbw) * 0.7;
	}
};

processing.clip = {|ev|
	{|in, cfreq=60, mbw=2|
		BBandStop.ar(in.clip(SinOsc.ar(cfreq)), [cfreq*4,cfreq*7], mbw) * 0.7;
	}
};

processing.drift = {|ev|
	{|in|
		var sig, osc, thres, freq=1000, la, lb, lc, verb, effect;
		var envLo = 0.8, envHi = 0.99;
		var times = { rrand(0.5, 1.8) } ! 8;
		var mix = EnvGen.ar(Env([0, envLo, envHi, envHi/2, envLo, envLo/2, envHi, envLo, 0], times).circle);
		sig = in;
		verb = sig;
		8.do{verb=AllpassL.ar(verb,0.3,{0.1.rand+0.1}!2,5)};
		verb = verb.tanh;
		effect = BLowPass4.ar(verb * 0.5, LFNoise2.ar(0.15).range(200, 800), 0.2) +
		BHiPass4.ar(verb * 0.5, LFNoise2.ar(0.25).range(7000, 12000),0.2);
		(effect * mix) + (sig * (1-mix));
	}
};

processing.dualdist = {|ev|
	{|in,lpf=100, hpf=8000, gaina=1000, gainb=200|
		var son = in;
		var f1 = rrand(0.3, 2.5);
		var f2 = rrand(1.2, 3.5);
		HPF.ar(SoftClipAmp8.ar(son, pregain:gaina), Lag.ar(LFNoise0.ar(f1).range(hpf, hpf*2))) +
		LPF.ar(SoftClipAmp8.ar(son, pregain:gainb), Lag.ar(LFNoise0.ar(f2).range(lpf*0.25, lpf)))
	}
};

processing.nmod = {|ev|
	{|in,nfreq=10|
		in.mod(LFNoise1.ar([nfreq,nfreq*1.3]))
	}
};

processing.amclip = {|ev|
	{|in,afreq=100|
		in.amclip(Saw.ar(afreq))
	}
};

processing.wloss = {|ev|
	{|in,drop=30,outoff=40,mode=3| WaveLoss.ar(in,drop,outoff,mode) }
};

processing.bfold = {|ev|
	{|in,bffreq=24,bfstop=500,bfbw=6| HPF.ar(BBandStop.ar( in.fold2(SinOsc.ar( [bffreq*1.05,bffreq])),bfstop,bfbw),rrand(40,60)) * 4;  }
};

processing.waveloss = {|ev|
	{|in|
	var sh = Amplitude.ar(in*2, 0.001).linlin(0,1,10,18);
	WaveLoss.ar(in, LFDNoise3.ar( SinOsc.ar(0.1).range(2,4) ).range(sh*0.5,sh), 25)
	}
};

processing.diffuse = {|ev|
	{|in|
		var verb = GVerb.ar( BBandStop.ar(x.ar, LFDNoise1.ar(3).range(500,2000)), 25, 5, damping:0.9 );
		XFade2.ar(in, verb, -0.75);
	}
};

processing.append = {|ev, nf, name|
	var local = ("append_" ++ name).asSymbol;
	NF(local, { nf.ar });
	NF(local)[10] = \filter -> ev[name].value;
	NF(local);
};

)
