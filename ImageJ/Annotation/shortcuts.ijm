macro "Switch Color [c]" {
	Stack.getDisplayMode(displaymode);
	if (displaymode == "color") {
		Stack.setDisplayMode("composite");
	}
	Stack.getActiveChannels(ch);
	if (ch == "0100000") {
		Stack.setActiveChannels("10");
	} else {
		Stack.setActiveChannels("01");
	}
}

macro "No Show [a]" {
	roiManager("Show None");
}

macro "Show [s]" {
	roiManager("Show All without labels");
}

macro "Label [S]" {
	roiManager("Show All with labels");
}

macro "Enhance [r]" {
	run("mpl-inferno");
	run("Enhance Contrast...", "saturated=0.3");
}

macro "Init [i]" {
	if (getBoolean("Init? Will clear ROI Manager.")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}
		run("To ROI Manager");	
	}
}

macro "Save ROI [p]" {
	if (getBoolean("Save? Will clear overlay.")) {
		setBatchMode(true);
		getDimensions(width, height, channels, slices, frames);
		name = getTitle();
		counts = roiManager("count");
		for (j = 0; j < counts; j++){ 
		    roiManager("Select", j);
		    roiManager("Rename", "cell");
		    roiManager("Remove Channel Info");
			roiManager("Remove Slice Info");
			roiManager("Remove Frame Info");
		}
		
		path =  getInfo("image.directory"); 
		arg = "";
		for (i=1; i<=channels - 1; i++) {
			arg = arg + " c" + i + "=" + "C" + i + "-temp";
		}
		
		rename("temp");
		run("Split Channels");
		arg = arg + " create";
		run("Merge Channels...", arg);
		rename(name);
		close("C" + channels + "-temp");
		run("From ROI Manager");
		
		call("ij.io.OpenDialog.setDefaultDirectory", path); 
		run("Tiff...");
		close();
		setBatchMode(false);
	}
}

macro "From mask [m]" {
	if (getBoolean("Get ROI from last channel?")) {
		name = getTitle();
		//setBatchMode(true);
		getDimensions(width, height, channels, slices, frames);
		Stack.setDisplayMode("color");
		Stack.setChannel(channels);

		run("Duplicate...", " ");
		run("Make Inverse");
		setAutoThreshold("Li dark");
		run("Convert to Mask");
		run("Watershed");
		roiManager("Deselect");
		run("Analyze Particles...", "size=50-Infinity display clear add");
		close();

		run("Remove Overlay");
		
		setBatchMode(false);
		roiManager("Show All");
		Stack.setChannel(1);
	}
}
