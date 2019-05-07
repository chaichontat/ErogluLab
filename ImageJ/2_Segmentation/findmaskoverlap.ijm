' Get 2 folders, find the overlap between ROIs, and save CSV statistics.

ovl = getNumber("Overlap area?", 50);
dir1 = getDirectory("Choose a Directory");
dir2 = getDirectory("Choose a Directory");

if (indexOf(dir1, "\\") == -1) {
	delim = "/";
} else {
	delim = "\\";
}

dir1a = split(dir1, delim);
dir2a = split(dir2, delim);
dirout = dir1 + "../" + dir1a[dir1a.length-1] + dir2a[dir2a.length-1] + "/";
File.makeDirectory(dirout)


run("Set Measurements...", "area mean centroid redirect=None decimal=3");
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
		run("Analyze Particles...", "size=" + ovl + "-Infinity display clear add");

		selectWindow(list1[i]);
		run("From ROI Manager");
		saveAs("tiff", dirout + substring(list1[i],0,lengthOf(list1[i])-4) + "_overlapROI.zip");
		saveAs("Results", dirout + list1[i] + "_overlap.csv");
	
		close("Results");
		run("Close All");
	}
}