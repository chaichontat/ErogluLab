dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length;i++) {
	if (startsWith(list[i], "Count")) {
		open(dir + list[i]);
		if (roiManager("count") > 0) {
			roiManager("Deselect");
			roiManager("Delete");
		}
		
		run("Remove Overlay");
		run("Select None");
		
		name = getTitle();
		
		roiManager("Open", dir + "ROI_" + substring(name,6,lengthOf(name)-4) + ".zip");
		
		// Modifications to fit U-Net
		roiManager("Select", 0);
		run("Make Inverse");
		roiManager("Add");
		roiManager("Delete");
		
		roiManager("Select", roiManager("count")-1);
		roiManager("Remove Channel Info");
		roiManager("Remove Slice Info");
		roiManager("Remove Frame Info");
		roiManager("Rename", "ignore");

		counts = roiManager("count");

		xarray = newArray(counts-1);
		yarray = newArray(counts-1);
		lists = newArray(counts-1);

		
		for (j = 0; j < counts-1; j++) {
			roiManager("Select", j);
			Roi.getBounds(x, y, width, height)
		
			x = round(x + (width / 2));
			y = round(y + (height / 2));
			
			xarray[j] = x;
			yarray[j] = y;
			lists[j] = j;
		}
		
		makeSelection("point", xarray, yarray);
		
		roiManager("Add");
		roiManager("Select", counts);
		roiManager("Remove Channel Info");
		roiManager("Remove Slice Info");
		roiManager("Remove Frame Info");
		roiManager("Rename", "cell");
		
		roiManager("Select", lists);
		roiManager("delete");

		rename("temp");
		run("Split Channels");
		run("Merge Channels...", "c1=C1-temp c2=C2-temp c3=C3-temp c4=C4-temp create");
		run("From ROI Manager");
		
		
		saveAs("tiff", dir + "UNet_" + name);
		run("Close All");
	}
}