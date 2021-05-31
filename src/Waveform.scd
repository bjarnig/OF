
/*

  ---- ---- ---- ---- Pipeline 'Waveform' ---- ---- ---- ----

	an Event() that containts Ns responsible for waveforms

*/

(

var waveform = ();

waveform.specs = Dictionary();

waveform.andin = {|ev, name=\andin|
	NF(name)[0] = {|mod=0.005, from=9, to=12, sdm=1, min=0.1, max=0.3, amp=1|
		var sd = SampleDur.ir * sdm, hpf=40, mf=1.0;

		HPF.ar(
			DemandEnvGen.ar(
				Dseq([min, min.neg, [max.neg, max]], inf),
				sd * Dseq([Lag.kr(from), Lag.kr(to), Dbrown(from,to,to,from.neg,from)], inf)
			).fold2(SinOsc.ar(mod)) * mf * amp,
		hpf)
	}
};

waveform.specs[\andin] = Dictionary();
waveform.specs[\andin][\sdm] = ControlSpec(0.01,10,'lin');
waveform.specs[\andin][\mod] = ControlSpec(0.001,80,'lin');
waveform.specs[\andin][\from] = ControlSpec(1,20,'lin');
waveform.specs[\andin][\to] = ControlSpec(1,20,'lin');

waveform.traum = {|ev, name=\traum|
	NF(name)[0] = {|sdm=1, repeats=32, from=8, to=30, min=0.1, max=0.9, amp=1.0|
		var sd = SampleDur.ir * sdm, mf=0.2;

		DemandEnvGen.ar(
			Dseq([
				Dseq([0, 0.5], repeats),
				Dseq([-0.2, 0.8], repeats/2),
				Dseq([-1.0, 1.0], Dwhite(repeats/32, repeats)),
				Dseq([-0.8, 0.1], repeats/16)
			], inf),
			Dseq([
				Dwhite(from, to, [repeats, repeats*0.5]),
				Dwhite(from/1.5, to/1.5, [repeats, repeats*2]),
				Dbrown(from/10, to/10, from/20, [repeats, repeats*0.25])
			], inf) * sd
		) * mf * amp;
	}
};

waveform.specs[\traum] = Dictionary();
waveform.specs[\traum][\sdm] = ControlSpec(0.001,10,'lin');
waveform.specs[\traum][\repeats] = ControlSpec(1,64,'lin');
waveform.specs[\traum][\from] = ControlSpec(1,20,'lin');
waveform.specs[\traum][\to] = ControlSpec(1,20,'lin');

waveform.serin = {|ev, name=\serin, iter=2|
	NF(name)[0] = {|step=2, start=1, from=2, to=5, sdm=0.2, min=0.1, max=0.9, amp=1.0, brownStep=0.01|
		var sd = SampleDur.ir * [sdm,sdm*1.1], mf=0.08;
		var levels = ({ Dseries(rrand(min.neg,max.neg), rrand(min,max), from*rrand(from,to)) } ! iter) ++
		({ Dbrown(rrand(min.neg,max.neg), rrand(min,max), brownStep, to*2) } ! iter);
		var times = { Dseries(rrand(start,start*2), rrand(step,step*2), rrand(from*5,to*4)) } ! (iter*2);

		DemandEnvGen.ar(
			Dseq(levels, inf),
			Dseq(times, inf) * sd
		) * mf * amp
	}
};

waveform.specs[\serin] = Dictionary();
waveform.specs[\serin][\sdm] = ControlSpec(0.001,10,'lin');
waveform.specs[\serin][\brownStep] = ControlSpec(0.001,1.0,'lin');
waveform.specs[\serin][\step] = ControlSpec(1,64,'lin');
waveform.specs[\serin][\start] = ControlSpec(1,64,'lin');
waveform.specs[\serin][\from] = ControlSpec(1,20,'lin');
waveform.specs[\serin][\to] = ControlSpec(1,20,'lin');

waveform.leaf = {|ev, name=\greet, length=30|
	NF(name)[0] = {|sdm=1, repeats=4, from=5, to=18, mod=60, amp=1.0|
		var sd = SampleDur.ir * sdm, mf=0.3;

		DemandEnvGen.ar(
			Dseq([Dseries(-1.0, [0.04,0.09], 30)], inf),
			Dseq([
				Dwhite(from, to, repeats),
				Dwhite(from/1.5, to*3, repeats)
			], inf) * sd
		).clip(SinOsc.ar(mod)) * mf * amp;
	}
};

waveform.foral = {|ev, name=\foral|
	NF(name)[0] = {|ser=500,step=2.5,amp=1.0,sdm=0.5|
		var sd = SampleDur.ir * sdm, mf = 0.008;

		Limiter.ar(DemandEnvGen.ar(
			Dseq([Dseries(-0.5, [0.1,-0.1], ser)], inf),
			sd * Dbrown(1,7,2.5)) * mf
		) * amp
	}
};

waveform.opca = {|ev, name=\opca, size=5, from=1, to=25|
	NF(name)[0] = {|sdm=0.15,modFreq=10, modFrom=5, modTo=25, amp=1.0|
		var sd = SampleDur.ir * sdm, mf =0.4;

		HPF.ar(DemandEnvGen.ar(
			Dseq([1, [-1, 0.5]], inf),
			Dseq(Array.rand(size,from,to), inf) * sd
		).atan(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))),40) * mf * amp;
	};
};

waveform.amplin = {|ev, name=\amplin, size=4, from=2, to=5|
	NF(name)[0] = {|sdm=0.15,modFreq=3, modFrom=1, modTo=25, amp=1.0|
		var sd = SampleDur.ir * sdm, mf =0.4;

		HPF.ar(DemandEnvGen.ar(
			Dseq([Dseq([1.0,-1.0],32), Dseries(-0.1,0.1,20), Dseries(-0.1,0.025,80), Drand([-0.5,0.5,1.0,-1.0],18) ], inf),
			Drand(Array.geom(size,from,to), inf) * sd
		),400).mod(SinOsc.ar(LFNoise0.ar([modFreq,modFreq*0.75]).range(modFrom, modTo))) * mf * amp;
	};
};

waveform.moch = {|ev, name=\moch, size=13, from=10, to=35|
	NF(name)[0] = {|filtSpeed=20, filtCenter=1000, sdm=1, filtBw=3, repeats=150, amp=1.0, modFreq = 1, modFrom = 1, modTo = 8|
		var sd = SampleDur.ir * sdm;
		var mf = 0.6;
		var snd = DemandEnvGen.ar(
			Dseq([
				Dseq([0, 0.5], repeats),
				Dseq([-0.2, 0.8], repeats/2),
				Dseq([-1.0, 1.0], Dwhite(repeats/32, repeats)),
				Dseq([-0.8, 0.1], repeats/16)
			], inf),
			Dseq([
				Dwhite(from, to, repeats),
				Dwhite(from/1.5, to/1.5, repeats),
				Dbrown(from/10, to/10, from/20, repeats)
			], inf) * sd
		);

		snd = snd.wrap2(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))) * amp * mf;
		HPF.ar(BBandStop.ar(snd, LFNoise1.ar( [filtSpeed,filtSpeed*2]).range(filtCenter * 0.2, filtCenter * 2), filtBw));
	}
};

waveform.dramp = {|ev, name=\dramp, size=3, from=1, to=25, a = 9, b = 5, min=0.1, max=0.3|
	NF(name)[0] = {|filtSpeed=10, filtCenter=200, sdm=1, modFreq=0.01, filtBw=3, amp=1.0, lpf=2500|
		var sd = SampleDur.ir * sdm;
		var snd = DemandEnvGen.ar(
			Dseq([min, min.neg, [max.neg, max]], inf),
			Dwhite(sd * a, sd * b),
		).wrap2(SinOsc.ar([modFreq, modFreq * 1.1])) * 0.2;
		snd = SoftClipAmp8.ar(snd,10) * amp;
		HPF.ar(BBandStop.ar(snd, Lag.ar(LFNoise1.ar( [filtSpeed,filtSpeed*2] ).range(filtCenter * 0.2, filtCenter * 2), 0.05), filtBw));
	}
};

waveform.costa = {|ev, name=\costa|
	NF(name)[0] = {|amp=1.0,mod=20,freq=20,lop=200| LeastChange.ar(SinOsc.ar(mod), Nanite.ar([freq,freq*0.5], lop:lop)) * amp };
};

waveform.specs[\costa] = Dictionary();
waveform.specs[\costa][\freq] = ControlSpec(0.01,100,'lin');
waveform.specs[\costa][\lop] = ControlSpec(20,15000,'lin');

waveform.hectn = {|ev, name=\hectn, size=5, from= 20, to=25|
	NF(name)[0] = {|sdm=0.15,modFreq=10, modFrom=5, modTo=25, fmfreq=100, fmhi=4000, amp=1.0, mf = 0.25|
	var sd = SampleDur.ir * sdm;
	var first = [1, [-1, 1.0]];
	var second = Array.rand(size,from,to);
	var seq = Dseq(second, inf);
	var snd = DemandEnvGen.ar(Dseq(first, inf), seq * sd
	).atan(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))) * 0.5;

	var trig = Impulse.kr(10);
	var freq = Demand.kr(trig, 0, seq);
	var buena = Stepper.kr(trig, 0, 0, 10, 1);

	snd = snd + PMOsc.ar(LFCub.kr([freq, freq/2], 0, fmfreq * 0.2, fmfreq), fmhi, 0.5) * mf;
	snd = snd + (DemandEnvGen.ar(Dwhite(-0.9,0.9,1),seq * sd * 10 * 0.1));
	HPF.ar(snd, 40, amp)
}};

waveform.specs[\hectn] = Dictionary();
waveform.specs[\hectn][\sdm] = ControlSpec(0.01,10,'lin');
waveform.specs[\hectn][\modFreq] = ControlSpec(0.001,50,'lin');
waveform.specs[\hectn][\fmfreq] = ControlSpec(50,1000,'lin');

waveform

)