// Annotation toolkit
macro "Switch Color [c]" {
	getDimensions(width, height, channels, slices, frames);
	Stack.setDisplayMode("color");
	Stack.getActiveChannels(ch);
	current = lastIndexOf(ch,1) + 1;
	if (current == channels) {
		newchan = 1;
	} else {
		newchan = current+1;
	}

	if (current == channels-1) { // Avoid mask
		if (is_mask(newchan)) {
				newchan = 1;
		}
	}
	
	Stack.setChannel(newchan);

	function is_mask(chan) {
		Stack.setChannel(chan);
		if (getPixel(0,0) == 251 && getPixel(1,0) == 148 && getPixel(0,1) == 249) {
			return true;
		} else {
			return false;
		}
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

macro "Enhance [e]" {
	run("Select None");
	run("mpl-inferno");
	run("Enhance Contrast...", "saturated=0.3");
}

// UNet toolkit
macro "Overlay to ROI [i]" {
	if (getBoolean("Overlay to ROI? Will clear ROI Manager.")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}
		run("To ROI Manager");	
	}
}

macro "ROI to Overlay [p]" {
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
		path =  getInfo("image.directory"); 
		rename("temp");
		if (channels == 1) {
			lastmask = false;
		} else {
			lastmask = is_mask(channels);
			run("Split Channels");
			run("Merge Channels...", gen_arg(channels,lastmask));
		}
		
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

macro "Mask to ROI [m]" {
	minsize = getNumber("Minimum cell area? ", 50);
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
	close();
	close();

	run("Remove Overlay");
	roiManager("Show All");
	Stack.setChannel(1);
}


// Rotation kit
macro "Smart Rotate [r]" {
	setTool("line");
	waitForUser("Hold", "Drag Line and Click OK");
	getSelectionCoordinates(x, y);
	slope = -(y[1] - y[0])/ (x[1] - x[0]);
	angle = atan2(-(y[1] - y[0]), (x[1] - x[0]));

	// For some reason, enlarge doesn't work. Fall back to manual linear algebra.
	aangle = angle;
	if (aangle < 0) {
		aangle += PI;
	}
	if (aangle > PI / 2) {
		aangle -= PI / 2;
	}
	getDimensions(width, height, channels, slices, frames);
	x_ori = width / 2;
	y_ori = height / 2;
	// Upper right corner
	newheight = abs(x_ori * sin(aangle) + y_ori * cos(aangle)) * 2;
	// Lower right corner
	newwidth  = abs(x_ori * cos(aangle) + y_ori * sin(aangle)) * 2;
	
	run("Canvas Size...", "width=" + newwidth + " height=" + newheight + " position=Center zero");
	run("Rotate... ", "angle=" + aangle * 180 / PI + " grid=1 interpolation=Bilinear stack");
	setTool("rectangle");
}

macro "Horizontal Flip [h]" {
	run("Flip Horizontally", "stack");
}

macro "Vertical Flip [v]" {
	run("Flip Vertically", "stack");
}