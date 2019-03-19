minsize = getNumber("Minimum cell area? ", 50);
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i< list.length;i++) {
	if (startsWith(list[i],"Seg") && endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);
		Stack.setDisplayMode("color");
		Stack.setChannel(channels);
		
		run("Duplicate...", " ");
		setAutoThreshold("Minimum dark");
		//run("Threshold...");
		//waitForUser("Adjust threshold and click OK");
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=" + minsize + "-Infinity display clear add");
		close();
	
		run("Remove Overlay");
		run("From ROI Manager");
		saveAs("tiff", dir + list[i]);
	}
}