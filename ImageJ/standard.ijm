function init() {
	dir = getDirectory("[Choose Source Directory]");
	list  = getFileList(dir);
	for (i=0; i<list.length; i++) {
		
	}
}

function mergechannel() {
	arg = "";
	for (i=1; i<=channels - 1; i++) {
		arg = arg + " c" + i + "=" + "C" + i + "-temp";
	}
	
	arg = arg + " create";
	run("Merge Channels...", arg);
}
