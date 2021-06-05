
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

)
