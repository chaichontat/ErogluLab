' Remove spaces outside of ROI

dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);

//downscale = getBoolean("Has this set been upscaled by 2x?");

roipath = File.openDialog("Choose ROI file");
if (!endsWith(roipath, ".roi")) {
	exit("Invalid ROI file.");
}

if (roiManager("count") != 0) {
	roiManager("deselect");
	roiManager("delete");
}

roiManager("open", roipath);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	if (startsWith(list[i], "Seg_")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);

		//if (downscale) {
		//	run("Size...", "width=" + width/2 + " height=" + height/2 + " constrain average interpolation=Bilinear");
		//}
		roiManager("Select", 0);
		run("Make Inverse");
		
		for (j=1; j<=channels; j++) {
			setSlice(j);
			run("Clear", "slice");
		}
		
		run("Make Inverse");
		saveAs("tiff", dir + "Cut_" + list[i]);
		close();
	}
}