
////////////////////////////////////////////////////////////////
//
//                     Bandpass filtering
//
////////////////////////////////////////////////////////////////


(    // - Sound Inputs -

    s.options.numOutputBusChannels = 16;

    s.waitForBoot({

    	~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
    	~fp = ~path ++ "sounds/";

    	// stereo
    	~s1 = Buffer.read(s, ~fp ++ "dolico.wav");
    	~s2 = Buffer.read(s, ~fp ++ "chanslim.wav");
    	~s3 = Buffer.read(s, ~fp ++ "charesoi.wav");
    	~s4 = Buffer.read(s, ~fp ++ "screpen.wav");
    	~s5 = Buffer.read(s, ~fp ++ "freeze.wav");

    	// mono
    	~s1m = Buffer.readChannel(s, ~fp ++ "dolico.wav", channels:[0]);
    	~s2m = Buffer.readChannel(s, ~fp ++ "chanslim.wav", channels:[0]);
    	~s3m = Buffer.readChannel(s, ~fp ++ "charesoi.wav", channels:[0]);
    	~s4m = Buffer.readChannel(s, ~fp ++ "screpen.wav", channels:[0]);
    	~s5m = Buffer.readChannel(s, ~fp ++ "freeze.wav", channels:[0]);

    })
)



( // #1, Different filters for different outputs

{
	var speed = 1.0; // try changing this;
	var bw = 0.2; // and this
	var snd = PlayBuf.ar(1, ~s1m);
	var amp = 8;
	var bp1 = BBandPass.ar(snd, 100, bw, SinOsc.ar(0.01*speed).range(0.0,1.0));
	var bp2 = BBandPass.ar(snd, 500, bw, SinOsc.ar(0.05*speed).range(0.0,1.0));
	var bp3 = BBandPass.ar(snd, 1500, bw, SinOsc.ar(0.1*speed).range(0.0,1.0));
	var bp4 = BBandPass.ar(snd, 4000, bw, SinOsc.ar(0.2*speed).range(0.0,1.0));

	Out.ar(snd, [bp1,bp2,bp3,bp4] * amp)

}.play

)


( // #2, Combining filters for different outputs

{
	var speed = 0.5; // try changing this;
	var bw = 0.2; // and this
	var amp = 4;
	var snd = PlayBuf.ar(1, ~s1m);
	var bp1 = BBandPass.ar(snd, Array.rand(4,10,100), bw, LFNoise1.ar(0.2*speed).range(0.0,1.0)).sum;
	var bp2 = BBandPass.ar(snd, Array.rand(4,100,500), bw, LFNoise1.ar(0.1*speed).range(0.0,1.0)).sum;
	var bp3 = BBandPass.ar(snd, Array.rand(4,1500,5000), bw, LFNoise1.ar(0.05*speed).range(0.0,1.0)).sum;
	var bp4 = BBandPass.ar(snd, Array.rand(4,500,1000), bw, LFNoise1.ar(0.01*speed).range(0.0,1.0)).sum;

	Out.ar(snd, [bp1,bp2,bp3,bp4] * amp)

}.play

)


( // #3, 8 filters

{
	var speed = 1.0; // try changing this;
	var bw = 0.1; // and this
	var amp = 14;
	var snd = PlayBuf.ar(1, ~s1m);
	var bp1 = BBandPass.ar(snd, 100, bw, SinOsc.ar(0.01*speed).range(0.0,1.0));
	var bp2 = BBandPass.ar(snd, 200, bw, SinOsc.ar(0.05*speed).range(0.0,1.0));
	var bp3 = BBandPass.ar(snd, 400, bw, SinOsc.ar(0.1*speed).range(0.0,1.0));
	var bp4 = BBandPass.ar(snd, 1000, bw, SinOsc.ar(0.2*speed).range(0.0,1.0));
	var bp5 = BBandPass.ar(snd, 2000, bw, SinOsc.ar(0.01*speed).range(0.0,1.0));
	var bp6 = BBandPass.ar(snd, 4000, bw, SinOsc.ar(0.05*speed).range(0.0,1.0));
	var bp7 = BBandPass.ar(snd, 8000, bw, SinOsc.ar(0.1*speed).range(0.0,1.0));
	var bp8 = BBandPass.ar(snd, 12000, bw, SinOsc.ar(0.2*speed).range(0.0,1.0));

	Out.ar(snd, [bp1,bp2,bp3,bp4] + [bp5,bp6,bp7,bp8] * amp )

}.play

)
