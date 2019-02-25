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
		counts = roiManager("count");
		for (j = 0; j < counts; j++){ 
		    roiManager("Select", j);
		    roiManager("Rename", "cell");
		    roiManager("Remove Channel Info");
			roiManager("Remove Slice Info");
			roiManager("Remove Frame Info");
		}
		run("From ROI Manager");
		
		path =  getInfo("image.directory"); 
		call("ij.io.OpenDialog.setDefaultDirectory", path); 
		run("Tiff...");
		setBatchMode(false);
	}
}
