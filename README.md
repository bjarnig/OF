# OF
A small SuperCollider framework that consists of four main process categories: 
* Synthesis processes with dynamic waveform generation
* Atomic sound transformations that adapt to incoming signals
* Operation pipelines and algorithms to control and generate them
* Direct access, observers and reactions for content-based triggers and actions 

```javascript

/* Install OF */

Quarks.install("https://github.com/bjarnig/OF")

/*

01 - Dynamic waveform generation and transformations.

*/

(

// Initialize OF
o = OF(this);

// Parameters for waveform duration size and minimum and maximum duration
a = o.waveform.opca(\op, 100); a.play;

// Runtime parameters for cycle duration and modulation
a.set(\sdm, rrand(0.1,0.5),\mod, rrand(1,10));

// Modulate a parameter
a.modulate(\sdm, { LFNoise1.kr(10, 0.1, 0.2) } );

// Append a transformation operation 
a.transform( o.processing.wloss() );

// Another transformation
a.transform( o.processing.foldorm() );

// Parameter movement for amplitude
a.control( o.control.brownian(\amp, 0.2, 0.01, 1.2 ));

// Another transformation
a.transform( o.processing.dualdist() );

// Interrump through an action
o.action.interrupt(\op);

)

/*

02 - Transformation sequences and pipelines

*/

( /* Stacking transformations */

o = OF(this); a = o.waveform.hectn(\pl);
a.stack([\clip, \minsaw, \bfold, \minsaw].scramble, o).play;

)

( /* Transformations and intervals */

o = OF(this); a = o.waveform.hectn(\ti);
a.stackd([\clip, \clip, \minsaw, \minsaw, \minsaw, \bfold], o, 3, 5).play;

)

( /* Parameters, processing and random order */

o = OF(this);
a = o.waveform.hectn(\encore);
a.stackprand([
	[\drift, (\drfreqh: 2, \drfreql:8)],
	[\wloss, (\wldrop: 25)],
	[\bfold, (\bffreq: 20, \bfstop: 100)]
], o, 20, 2);

a.transform(o.pr.diffuse).play

)

( /* Nested pipelines with parameters and duration */

o = OF(this);

a = o.waveform.costa(\co);
a.stackpd([
	[\bfold, 3, (\bffreq: 20, \bfstop: 100)],
	[\lfdnamp, 14, (\lfamod: 0.8)],
	[\gravch, 21, (\grto: 2000)]
], o);

b = o.waveform.hectn(\pl);
b.stack([\clip, \minsaw, \bfold, \minsaw].scramble, o);

c = o.waveform.dramp(\dramp);
c.stackd([\clip, \clip, \minsaw, \gravch, \bfold], o, 3, 5);

// Submit the three pipelines to a switching algorithm
o.behaviour.switchx( OFPool[a,b,c] ).play

)