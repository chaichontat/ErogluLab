dir = getDirectory("Choose a Directory");
setBatchMode(true);
list = getFileList(dir);
ovl = getBoolean("Create from overlap ROI?");
chan = getNumber("Channel?", 1);
path = dir + "Flat/";
File.makeDirectory(path)

for (i=0; i<list.length;i++) {
	if (endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		setSlice(chan);
		run("Enhance Contrast...", "saturated=0.3");
		run("Green");
		if (roiManager("count") != 0) {
			roiManager("Deselect");
			roiManager("Delete");
		}
		
		if (ovl) {
			run("Remove Overlay");
			open(dir + list[i] + "_overlapROI.zip");
			run("From ROI Manager");
		}
		
		
		run("Labels...", "color=white font=12 draw");
		run("Flatten", "slice");
		saveAs("tiff", path + list[i]);
		close();
		close();
	}
}
