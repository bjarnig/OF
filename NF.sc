NF : Ndef {

	var <>pindex, <>cindex;

	initialize {
		if(pindex.isNil, { pindex = 1000 });
		if(cindex.isNil, { cindex = 2000 });
	}

	clearProcessSlots {
		pindex = 1000;
		(this.pindex - 1000).do{|i| this[this.pindex+i] = nil; }
	}

	clearOrInit {|clear=true|
		if(clear == true, { this.clearProcessSlots() }, { this.initialize() });
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

	stack {|processes, lib, clear=true|

		this.clearOrInit(clear);

		processes.do{|eff,i|
			pindex = pindex + i;
			this[pindex] = \filter -> lib.processing[eff].value();
		}
	}

	stackd {|processes, lib, delFrom=0.0, delTo=1.0, clear=true|

		this.clearOrInit(clear);

		{
			processes.do{|eff,i|
				rrand(delFrom, delTo).wait;
				pindex = pindex + i;
				this[pindex] = \filter -> lib.processing[eff].value();
			}

		}.fork
	}

	stackp {|processes, lib, clear=true|

		this.clearOrInit(clear);

		{
			processes.do{|eff,i|
				var effect = eff[0], params = eff[1];

				pindex = pindex + i;
				this[pindex] = \filter -> lib.processing[effect].value();
				0.05.wait;

				params.keys.do{|key|
					this.xset(key, params[key]);
				};

				0.01.wait
			}
		}.fork
	}

	stackpd {|processes, lib, clear=true|

		this.clearOrInit(clear);

		{
			processes.do{|eff,i|
				var effect = eff[0], delay = eff[1], params = eff[2];
				pindex = pindex + i;
				this[pindex] = \filter -> lib.processing[effect].value();
				0.05.wait;

				params.keys.do{|key|
					this.xset(key, params[key]);
				};

				delay.wait
			}
		}.fork
	}

	stackprand {|processes,lib,times=10,delay=3,clear=true|

		this.clearOrInit(clear);

		{
			times.do{|i|

				processes.do{|eff,i|
					var effect = eff[0], params = eff[1];
					pindex = pindex + 1;
					this[pindex + i] = \filter -> lib.processing[effect].value();
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