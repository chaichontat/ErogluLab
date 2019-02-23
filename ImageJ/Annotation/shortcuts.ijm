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

macro "Save ROI [p]" {
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
