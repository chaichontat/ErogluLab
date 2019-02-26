dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0;i<list.length;i++) {
	if (startsWith(list[i], "C1-P1")) {
		open(list[i]);
		rename("C1");
		open(dir + "C2-P1_" + substring(list[i],6,lengthOf(list[i])));
		rename("C2");
		open(dir + "C1-P2_" + substring(list[i],6,lengthOf(list[i])));
		rename("C3");
		open(dir + "C2-P2_" + substring(list[i],6,lengthOf(list[i])));
		rename("C4");
		run("Merge Channels...", "c1=C1 c2=C2 c3=C3 c4=C4 create");
		saveAs("tiff", dir + substring(list[i],6,lengthOf(list[i])));
		close();
	}
}
