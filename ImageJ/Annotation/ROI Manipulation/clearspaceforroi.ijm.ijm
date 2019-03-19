roipath = File.openDialog("Choose ROI file");
if (!endsWith(roipath, ".roi")) {
	exit("Invalid ROI file.");
}

dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);

if (roiManager("count") != 0) {
	roiManager("deselect");
	roiManager("delete");
}

roiManager("open", roipath);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	open(dir + list[i]);
	getDimensions(width, height, channels, slices, frames);
	roiManager("Select", 0);
	run("Make Inverse");
	
	for (j=1; j<=channels; j++) {
		setSlice(j);
		run("Clear", "slice");
	}
	
	run("Make Inverse");
	saveAs("tiff", dir + list[i]);
	close();
}