macro "Switch Color [c]" {
	getDimensions(width, height, channels, slices, frames);
	Stack.setDisplayMode("color");
	Stack.getActiveChannels(ch);
	print("old:" + ch);
	current = lastIndexOf(ch,1) + 1;
	if (current == channels) {
		newchan = 1;
	} else {
		newchan = current+1;
	}
	Stack.setChannel(newchan);
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
	run("Select None");
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
		if (roiManager("count") == 0) {
			exit("Stop. ROI Manager is empty.");
		}
		
		setBatchMode(true);
		run("Remove Overlay");
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
		
		lastmask = is_mask(channels);
		path =  getInfo("image.directory"); 
		rename("temp");
		run("Split Channels");
		run("Merge Channels...", gen_arg(channels,lastmask));
		if (lastmask) {
			close("C" + channels + "-temp");
		}
		
		rename(name);
		run("From ROI Manager");
		
		call("ij.io.OpenDialog.setDefaultDirectory", path); 
		run("Tiff...");
		close();
		setBatchMode(false);
	}

	function is_mask(chan) {
		Stack.setChannel(chan);
		if (getPixel(0,0) == 251 && getPixel(1,0) == 148 && getPixel(0,1) == 249) {
			return true;
		} else {
			return false;
		}
	}

	function gen_arg(channels, lastmask) {
		arg = "";
		if (lastmask) {
			channels--;
		}
		for (i=1; i<=channels; i++) {
			arg = arg + " c" + i + "=" + "C" + i + "-temp";
		}
		arg = arg + " create";
		return arg;
	}
}

macro "From mask [m]" {
	minsize = getNumber("Minimum cell area? ", 50);
	name = getTitle();
	setBatchMode(true);
	getDimensions(width, height, channels, slices, frames);
	Stack.setDisplayMode("color");
	Stack.setChannel(channels);

	run("Duplicate...", " ");
	setAutoThreshold("Li dark");
	run("Threshold...");
	waitForUser("Adjust threshold and click OK");
	run("Convert to Mask");
	run("Watershed");
	roiManager("Deselect");
	run("Analyze Particles...", "size=" + minsize + "-Infinity display clear add");
	close();

	run("Remove Overlay");
	setBatchMode(false);
	roiManager("Show All");
	Stack.setChannel(1);
}
