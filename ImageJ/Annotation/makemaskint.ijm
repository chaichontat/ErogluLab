' Create mask based on intensity

dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);
minsize = getNumber("Minimum cell area? ", 50);
starts = getString("Name starts with?", "Cut");
thr = getNumber("Threshold? ", 30000);

for (i=0; i< list.length;i++) {
	if (startsWith(list[i], starts) && endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		run("Remove Overlay");
		getDimensions(width, height, channels, slices, frames);
		Stack.setDisplayMode("color");
		Stack.setChannel(channels);
		
		run("Duplicate...", " ");
		setThreshold(thr, 65535);
		//run("Threshold...");
		//waitForUser("Adjust threshold and click OK");
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=" + minsize + "-Infinity display add clear");
		close();
	
		run("Remove Overlay");
		run("From ROI Manager");
		saveAs("tiff", dir + list[i]);
	}
}