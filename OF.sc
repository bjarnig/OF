OF {

	var <>basePath = "/Users/bjarni/Library/Application Support/SuperCollider/Extensions/Dev/OF/src/";
	var <>synthesis, <>processing, <>control, <>behaviour, <>action, <>waveform, <>st, <>pr, <>cn, <>bh, <>ac, <>wf;

	*new {|interpreter|
		^super.newCopyArgs().init(interpreter);
	}

	init {|interpreter|

		synthesis = interpreter.compileFile(basePath ++ "Synthesis.scd").value;
		processing = interpreter.compileFile(basePath ++ "Processing.scd").value;
		control = interpreter.compileFile(basePath ++ "Control.scd").value;
		behaviour = interpreter.compileFile(basePath ++ "Behaviour.scd").value;
		action = interpreter.compileFile(basePath ++ "Action.scd").value;
		waveform = interpreter.compileFile(basePath ++ "Waveform.scd").value;

		st = interpreter.compileFile(basePath ++ "Synthesis.scd").value;
		pr = interpreter.compileFile(basePath ++ "Processing.scd").value;
		cn = interpreter.compileFile(basePath ++ "Control.scd").value;
		bh = interpreter.compileFile(basePath ++ "Behaviour.scd").value;
		ac = interpreter.compileFile(basePath ++ "Action.scd").value;
		wf = interpreter.compileFile(basePath ++ "Waveform.scd").value;

		^this
	}

	synthesisNames {
		^this.synthesis.keys.asArray
	}

	actionNames {
		^this.synthesis.keys.asArray
	}

	waveformNames {
		^this.waveform.keys.asArray
	}
}

NF : Ndef {

	var <>pindex, <>cindex;

	initialize {
		if(pindex.isNil, { pindex = 1000 });
		if(cindex.isNil, { cindex = 2000 });
	}

	transform {|process, index|
		var i = index;

		if(i.isNil, {
			this.initialize();
			pindex = pindex + 1;
			i = pindex;
		});

		this[i] = \filter -> process;
	}

	control {|process, index|
		var i = index;

		if(i.isNil, {
			this.initialize();
			cindex = cindex + 1;
			i = cindex;
		});

		this[i] = \pset -> process;
	}

	modulate {|param, process|
		var local = ("modulate_" ++ this.key ++ "_" ++ param).asSymbol; local.postln;
		^this.map(param, NF(local , process));
	}
}

TF : Tdef {}