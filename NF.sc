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

	clearProcessSlots {
		var n = 0;

		this.initialize();
		this.pindex - 1000;

		n.do{|i|
			this[1000+i] = nil;
		}
	}

	modulate {|param, process|
		var local = ("modulate_" ++ this.key ++ "_" ++ param).asSymbol; local.postln;
		^this.map(param, NF(local , process));
	}

	stack {|processes, pipeline|

		this.clearProcessSlots();

		processes.do{|eff,i|
			this[pindex + i] = \filter -> pipeline.processing[eff].value();
		}
	}

	stackd {|processes, pipeline, delFrom, delTo|

		this.clearProcessSlots();

		{
			processes.do{|eff,i|
				rrand(delFrom, delTo).wait;
				this[pindex + i] = \filter -> pipeline.processing[eff].value();
			}

		}.fork
	}

	stackp {|processes,pipeline|

		this.clearProcessSlots();

		{
			processes.do{|eff,i|
				var effect = eff[0], params = eff[1];

				this[pindex + i] = \filter -> pipeline.processing[effect].value();

				0.05.wait;

				params.keys.do{|key|
					this.xset(key, params[key]);
				};

				0.01.wait
			}
		}.fork
	}

	stackpd {|processes,pipeline|

		this.clearProcessSlots();

		{
			processes.do{|eff,i|
				var effect = eff[0], delay = eff[1], params = eff[2];

				this[pindex + i] = \filter -> pipeline.processing[effect].value();

				0.05.wait;

				params.keys.do{|key|
					this.xset(key, params[key]);
				};

				delay.wait
			}
		}.fork
	}

	stackprand {|processes,pipeline,times=10,delay=3|
		{
			times.do{|i|

				this.clearProcessSlots();

				processes.do{|eff,i|
					var effect = eff[0], params = eff[1];

					this[pindex + i] = \filter -> pipeline.processing[effect].value();

					0.05.wait;

					params.keys.do{|key|
						this.xset(key, params[key]);
					};

					0.01.wait;
				};

				processes = processes.scramble;
				delay.wait;
			}

		}.fork
	}
}

Pool {

	var <>items;

	*new {|input|
		^super.newCopyArgs(input).init(input);
    }

	init {|in|
		this.items = in;
	}
}

TF : Tdef {}

Pipeline : NF {}