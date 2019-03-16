// Get statistics from U-Net

var minsize;
minsize = getNumber("Minimum cell area? ", 50);
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		mask_to_roi();
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
	setAutoThreshold("Moments dark");
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