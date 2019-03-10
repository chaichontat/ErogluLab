dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);
setname = getString("Name", "Sox9")
File.makeDirectory(dir + setname + "/");

setchan = getString("Channels", "12");
numchan = lengthOf(setchan);

setarray = newArray(numchan);
for (i=0; i<numchan; i++) {
	setarray[i] = substring(setchan,i,i+1);
}

arg = "";
for (i=1; i<=numchan; i++) {
	arg = arg + " c" + i + "=" + "C" + setarray[i-1] + "-temp";
}
arg = arg + " create";

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		rename("temp");
		run("Split Channels");
		run("Merge Channels...", arg);
		saveAs(dir + setname + "/" + setname + "_" + list[i]);
		run("Close All");
	}
}
