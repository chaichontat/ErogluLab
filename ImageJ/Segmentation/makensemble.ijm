dir = getDirectory("Choose a Directory");
setBatchMode(true);
list = getFileList(dir);
ovl = getBoolean("Create from overlap ROI?");
chan = getNumber("Channel?", 1);
starts = getString("Name starts with?", "Cut");
path = dir + "Flat/";
lut = "Green";
File.makeDirectory(path)

for (i=0; i<list.length;i++) {
	if (startsWith(list[i], starts) && endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		setSlice(chan);
		run("Enhance Contrast...", "saturated=0.3");
		run(lut);
		if (roiManager("count") != 0) {
			roiManager("Deselect");
			roiManager("Delete");
		}
		
		if (ovl) {
			run("Remove Overlay");
			open(dir + list[i] + "_overlapROI.zip");
			run("From ROI Manager");
		}

		run("Duplicate...", "use");
		run("Remove Overlay");
		run(lut);
		saveAs("tiff", path + list[i] + "old");
		close();

		run("Duplicate...", "use");
		run("Labels...", "color=white font=12 draw");
		run(lut);
		run("Flatten", "slice");
		saveAs("tiff", path + list[i]);
		close();
		close();
	}
}
