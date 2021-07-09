OF {

	var <>basePath, <>synthesis, <>processing, <>control, <>behaviour, <>action, <>observe, <>waveform, <>st, <>pr, <>cn, <>bh, <>ac, <>ob, <>wf;

	*new {|interpreter|
		^super.newCopyArgs().init(interpreter);
	}

	init {|interpreter|

		basePath = (Platform.userExtensionDir ++ "/downloaded-quarks/OF/src/").replace("Extensions/", "");

		synthesis = interpreter.compileFile(basePath ++ "Synthesis.scd").value;
		processing = interpreter.compileFile(basePath ++ "Processing.scd").value;
		control = interpreter.compileFile(basePath ++ "Control.scd").value;
		behaviour = interpreter.compileFile(basePath ++ "Behaviour.scd").value;
		action = interpreter.compileFile(basePath ++ "Action.scd").value;
		observe = interpreter.compileFile(basePath ++ "Observe.scd").value;
		waveform = interpreter.compileFile(basePath ++ "Waveform.scd").value;

		st = interpreter.compileFile(basePath ++ "Synthesis.scd").value;
		pr = interpreter.compileFile(basePath ++ "Processing.scd").value;
		cn = interpreter.compileFile(basePath ++ "Control.scd").value;
		bh = interpreter.compileFile(basePath ++ "Behaviour.scd").value;
		ac = interpreter.compileFile(basePath ++ "Action.scd").value;
		ob = interpreter.compileFile(basePath ++ "Observe.scd").value;
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
		^this.waveform.keys.asArray.reject{|name| name == "append" }
	}

	processingNames {
		^this.processing.keys.asArray
	}
}