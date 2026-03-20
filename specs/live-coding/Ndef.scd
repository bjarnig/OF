////////////////////////////////////////////////////////////////
//
//                         More Ndefs
//
////////////////////////////////////////////////////////////////

{ Dust.ar([10,20]) }.play

Ndef.clear

Quarks.install("JITLibExtensions")

// 01 - Node Proxy roles

(
// -> \set
Ndef(\a);
Ndef(\a)[0] = {|freq=80| Saw.ar(freq!2,0.1) };
Ndef(\a)[2] = {|freq=80| SinOsc.ar(freq!2 * 0.5,0,0.1) };
Ndef(\a)[1] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(40,400));
Ndef(\a).play
)

(
~freq = 1000;
// -> \setsrc
Ndef(\b).play;
Ndef(\b)[0] = {|freq=90| Saw.ar(freq!2,0.1) };
Ndef(\b)[0] = \setsrc -> Pbind(\dur, 0.5, \source,
	Prand ([ {Gendy3.ar(~freq!2) }, {Gendy1.ar(~freq!2) }], inf));
Ndef(\b)[1] = \set -> Pbind(\dur, 0.01, \freq, Pwhite(40,400));
)

(
// -> \filter
Ndef(\c).play;
Ndef(\c).fadeTime = 2;
Ndef(\c)[0] = {|freq=90| Saw.ar(freq!2,0.1) };
Ndef(\c)[2] = \filter -> {|in| LPF.ar(in, LFNoise1.ar(8).range(100,800)) };
Ndef(\c)[3] = {|freq=900| Saw.ar(freq!2,0.1) };
)

// or .filter
Ndef(\saw, { Saw.ar(100!2) }).play
Ndef(\saw).filter(1, {arg in; LPF.ar(in, 900)})
Ndef(\saw).filter(2, {arg in; GVerb.ar(in)})
Ndef(\saw).filter(3, {arg in; CombC.ar(in, 2, LFNoise1.ar(3).range(0.1,0.2), 4) })




// 02 - Proxychain
(
ProxyChain(\first).clear;
ProxyChain.add(\dust, \mix -> { Dust.ar(180 ! 2) });
ProxyChain.add(\dist, \filter -> { |in| in.fold2(SinOsc.ar(20))});
ProxyChain.add(\comb, \filter -> { |in| CombC.ar(in,0.1,0.1,4) });
ProxyChain(\first, [\dust, \dist, \comb]);
)

// Tell the proxy to play
(
ProxyChain(\first).play;
ProxyChain(\first).proxy.fadeTime = 3;
)

// Add the dust and the effects
ProxyChain(\first).add(\dust, 0.5)
ProxyChain(\first).add(\dist, 0.5)
ProxyChain(\first).add(\comb, 0.25)

ProxyChain(\first).remove(\dist)
ProxyChain(\test).gui;



// 03 - Connecting Ndefs using .asMap
Ndef(\click, { Dust.kr(1!2); });
Ndef(\envelope, {|trig=1| SinOsc.ar(800!2) * EnvGen.ar(Env.sine(0.1),trig) }).play;
Ndef(\envelope).set(\trig, Ndef(\click).asMap);


Ndef.clear

// 04 - Use \in.ar for audio signals
Ndef(\filter, {|freq=15| BLowPass.ar(\in.ar, LFNoise1.ar(freq!2).range(100,4000)) });
Ndef(\osc1, {Saw.ar(10!2,0.1) });
Ndef(\filter).play;
Ndef(\filter).set(\in, Ndef(\osc1).asMap, \freq, Ndef(\osc2, {LFNoise1.ar(1!2).range(10,20)}).asMap);

// Not updating?
Ndef(\osc2, {LFNoise1.ar(100!2).range(10,20)})

// 05 - Ndef feedback
a = Ndef(\ep, { Impulse.ar(6) ! 2}).play
a[1] = \filter-> {|in| in + (Ndef.ar(\ep_fb) * 0.98)}
Ndef(\ep_fb, { DelayC.ar(LPF.ar(Ndef.ar(\ep), LFNoise1.ar(1).range(100,8000)), 0.5, LFNoise1.ar(10).range(0.1,0.2)) })

Ndef.help
NodeProxy.helpp


// 06 - Change Ndef num of channels

Ndef(\znd, { Saw.ar * 0.2 }).play

//Set to elastic to reshape automatically, so it can adapt to different number of output channels..
Ndef(\znd).reshaping = \elastic;

Ndef(\znd, { Saw.ar ! 2 * 0.2}).play

// Or even do it globally:
NodeProxy.defaultReshaping = \elastic;

Ndef.clear

// Play as mono
Ndef(\ind, { Saw.ar }).play

// Still mono
Ndef(\ind, { Saw.ar ! 2 })

// Mold to stereo
Ndef(\ind, { Saw.ar ! 2 }).mold(2)



// 07 - GUis
Ndef(\ttest, {|freq= 400, detune= 4, amp= 0.3, pmod= 0, pamp= 3| SinOsc.ar([freq, freq+detune], SinOsc.ar(pmod, 0, pamp), amp)});
Ndef(\ttest).gui;




// 08 - Workflow example

(

SynthDef(\jsnd, { arg freq=100, gate=1, out=0, lop=800, amp=0.1;
	var env = EnvGen.kr(Env.asr(0.1, amp, 0.5), gate, doneAction:2);
	var signal = RLPF.ar(Blip.ar(freq, 150).fold2(SinOsc.ar(freq/10)), lop);
    Out.ar(out, Pan2.ar(signal * env));
}).add;

)

Ndef.clear;

// Set the pattern freq mod
Ndef(\mod)[0] = { LFNoise2.kr(0.1).exprange(20, 800) };

// Create the pattern
Ndef(\pattern)[0] = Pbind(\instrument, \jsnd, \dur, 1, \legato, 0.01, \freq, Ndef(\mod), \amp, 0.5);

// Route the pattern to effect 1
Ndef(\effect)[0] = { LPF.ar(Ndef(\pattern).ar * SinOsc.ar(SinOsc.kr(1.5, 250, 500)), 10000) };

Ndef(\effect).play

// Chain effect 1 to effect 2
Ndef(\effect2)[0] = { LPF.ar(CombC.ar(Ndef(\effect).ar, 0.2, 0.2, 2.6), 5000) * 0.8 };

// Add a layer to the pattern
Ndef(\pattern)[1] = {|freq2=120| Saw.ar(freq2, 0.01) };

// Change effect 2
Ndef(\effect2)[0] = { Decimator.ar(Ndef(\effect).ar, LFNoise1.ar(100).exprange(500, 10000), 8) };

// Add sequencing to the pattern layer with \set
Ndef(\pattern)[2] = \set -> Pbind(\dur, Prand([0.02, 0.05], inf), \freq2, Pwhite(50, 1500, inf));

// Modify items
Ndef(\mod)[0] = { LFNoise2.kr(0.1).range(20, 800) };

// Modify items
Ndef(\mod)[0] = { LFNoise2.kr(0.1).range(20, 80) };

// Modify items
Ndef(\pattern)[0] = Pbind(\instrument, \saw, \dur, 0.05, \legato, 0.01, \freq, Ndef(\mod), \amp, 0.1);



// 10 Use <<> for routing

(
Ndef(\dst, {
	var son = \in.ar([0,0]);
	var inFreq = Tartini.kr(son)[0];
	var freq = inFreq[0] / 4;
	var thres = Lag.kr(Amplitude.kr(son), 0.1);
	var osc = Splay.ar(Pulse.ar(Array.series(10, freq, 5))) * thres;
	var verb = Mix.ar(Array.fill(10,{ CombL.ar(osc, 0.05, rrand(0.02, 0.04), 10.rand) }));
	XFade2.ar(son, verb, 0.75)
}).play;

)

Ndef(\src, { Blip.ar(LFNoise2.ar(7).range(40,100))  }) <>> Ndef(\dst); Ndef(\src).play
