// Get statistics from U-Net

run("Set Measurements...");
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	if ((startsWith(list[i], "Cut") || startsWith(list[i], "Seg")) && endsWith(list[i], ".tif")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}
		
		open(dir + list[i]);
		run("To ROI Manager");
		//mask_to_roi();
		roiManager("Measure");
		saveAs("Results", dir + list[i] + ".csv");
		run("Close All");
		close("Results");
		
		/*roiManager("Combine");
		run("Create Mask");
		run("Select None");
		run("Analyze Particles...", "size=20-Infinity display clear add");
		saveAs("Results", dir + list[i] + ".csv");
		run("Close All");*/
	}
}

function mask_to_roi() {
	name = getTitle();
	getDimensions(width, height, channels, slices, frames);
	Stack.setDisplayMode("color");
	Stack.setChannel(channels);

	run("Duplicate...", " ");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	//waitForUser("Adjust threshold and click OK");
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size=" + minsize + "-Infinity display clear add");
	close();

	run("Remove Overlay");
	roiManager("Show All");
	Stack.setChannel(1);
}