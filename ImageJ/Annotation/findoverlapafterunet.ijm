' Get 2 folders, find the overlap between ROIs, and save CSV statistics.

dir1 = getDirectory("Choose a Directory");
dir2 = getDirectory("Choose a Directory");
setBatchMode(true);

list1 = getFileList(dir1);
list2 = getFileList(dir2);

for (i=0; i<list1.length;i++) {
	if (endsWith(list1[i], ".tif")) {
		open(dir1 + list1[i]);
		if (roiManager("count") != 0) {
				roiManager("Deselect");
				roiManager("Delete");
		}
		run("To ROI Manager");
		roiManager("Combine");
		run("Create Mask");
		run("Invert LUT");
		rename("mask1");
		run("Select None");
	
		open(dir2 + list2[i]);
		if (roiManager("count") != 0) {
				roiManager("Deselect");
				roiManager("Delete");
		}
		run("To ROI Manager");
		roiManager("Combine");
		run("Create Mask");
		run("Invert LUT");
		rename("mask2");
	
		imageCalculator("AND create", "mask1","mask2");
		run("Invert");
		run("Analyze Particles...", "size=20-Infinity display clear add");
		roiManager("Save", dir1 + list1[i] + "_overlapROI.zip");
		saveAs("Results", dir1 + list1[i] + "_overlap.csv");
	
		close("Results");
		run("Close All");
	}
}