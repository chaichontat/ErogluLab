dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".tif")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}

		open(dir + list[i]);
		run("To ROI Manager");
		setSlice(2);
		run("Enhance Contrast...", "saturated=0.3");
		run("mpl-inferno");
		roiManager("Show All without labels");
		run("Flatten", "slice");
		saveAs("tiff", dir + "Flat_" + list[i]);
		close();
		close();
	}
}
