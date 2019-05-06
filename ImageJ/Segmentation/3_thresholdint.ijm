' Create mask based on intensity

dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);
minsize = getNumber("Minimum cell area? ", 50);
starts = getString("Name starts with?", "Cut");
thr = getNumber("Threshold? ", 30000);
remove = getBoolean("Remove mask?");

for (i=0; i< list.length;i++) {
	if (startsWith(list[i], starts) && endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);
		
		if (!is_mask(channels)) exit("Last channel from file " + list[i] + " is not mask.");
		
		run("Remove Overlay");
		name = getTitle();
		rename("temp");
		run("Split Channels");
		
		setThreshold(thr, 65535);
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=" + minsize + "-Infinity display add clear");
		close();
		
		arg = "";
		for (j=1; j<channels; j++) {
			arg = arg + " c" + j + "=" + "C" + j + "-temp";
		}
		arg = arg + "create";
		run("Merge Channels...", arg);

		roiManager("deselect");
		roiManager("Measure");
		saveAs("Results", dir + list[i] + ".csv");
		close("Results");
	
		run("Remove Overlay");
		run("From ROI Manager");
		saveAs("tiff", dir + "Seg_ROI_" + substring(list[i],3, lengthOf(list[i])));
		close();
	}
}

function is_mask(chan) {
	Stack.setChannel(chan);
	if (getPixel(0,0) == 251 && getPixel(1,0) == 148 && getPixel(0,1) == 249) {
		return true;
	} else {
		return false;
	}
}