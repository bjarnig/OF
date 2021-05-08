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