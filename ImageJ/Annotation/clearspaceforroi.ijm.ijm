dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	open(dir + list[i]);
	getDimensions(width, height, channels, slices, frames);
	roiManager("Select", 0);
	run("Make Inverse");
	
	for (j=1; j<=channels; j++) {
		run("Clear", "slice");
	}
	saveAs("tiff", dir + list[i]);
	close();
}