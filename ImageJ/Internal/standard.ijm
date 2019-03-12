function init() {
	dir = getDirectory("[Choose Source Directory]");
	list  = getFileList(dir);
	setBatchMode(true);
	
	for (i=0; i<list.length; i++) {
		open(dir + list[i]);
		
		saveAs("tiff", dir + list[i]);
		close();
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
