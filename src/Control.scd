
/*

  ---- ---- ---- ---- OF 'Control' ---- ---- ---- ----

	an Event() that containts patterns for control.

*/

(

var control = ();

control.triangle = {|ev, param=\amp, dur=0.01, length=2, min=0.001, max=1.0|
	Pbind(\dur, dur, param, Pn(Penv([max,min,max], [length,length*2])));
};

control.brownian = {|ev, param=\amp, dur=0.1, min=0.001, max=1.0, step=0.1|
	Pbind(\dur, dur, param, Pbrown(min,max,step));
};

control.pfsm = {|ev, param=\amp, dur=0.01, length=2, min=0.01, max=1.0|
	var brown = Pbrown(min,max, (max - min) * 0.2);
	Pbind(\dur, dur, param, Pfsm([ [0], max, [0, 1], brown, [2,3], min, [0, 2], max - min, [0] ], length));
};

control.ramp = {|ev, param=\amp, dur=0.01, from=0.0, to=1.0, length=10|
	Pbind(\dur, dur, param, Pn(Penv([from, to], [length])));
};

control.random = {|ev, param=\amp, dur=0.1, min=0.001, max=1.0|
	Pbind(\dur, dur, param, Pwhite(min, max));
};

control.stepper = {|ev, param=\amp, dur=0.1, min=0.0, max=1.0, steps=8|
	var vals = Array.series(steps, min, (max - min) / (steps - 1));
	Pbind(\dur, dur, param, Pseq(vals ++ vals.reverse, inf));
};

control

)
