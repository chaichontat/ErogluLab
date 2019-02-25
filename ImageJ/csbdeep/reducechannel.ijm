dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	open(dir + list[i]);
	rename("temp");
	run("Split Channels");
	run("Merge Channels...", "c1=C1-temp c2=C3-temp create");
	saveAs(dir + "Olig2_" + list[i]);
	run("Close All");
}
