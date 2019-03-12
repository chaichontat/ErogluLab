' Make a substack of channels with optional 2x scale.

var setname;
var setchan;
var scale;
var zstart;
var zend;
var maxproj;
dialoggen();

dir = getDirectory("Choose a Directory");
list = getFileList(dir);

setBatchMode(true);
File.makeDirectory(dir + setname + "/");
numchan = lengthOf(setchan);
setarray = newArray(numchan);

for (i=0; i<numchan; i++) {
	setarray[i] = substring(setchan,i,i+1);
}

arg = "";
for (i=1; i<=numchan; i++) {
	arg = arg + " c" + i + "=" + "C" + setarray[i-1] + "-temp";
}
arg = arg + " create";

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);

		if (slices != 1 && maxproj == true) {
			run("Z Project...", "start=" + zstart + " stop=" + zend + " projection=[Max Intensity]");
		}

		rename("temp");
		run("Split Channels");
		
		if (numchan > 1) {
			run("Merge Channels...", arg);
		} else {
			selectWindow("C" + setchan + "-temp");
		}
		if (scale) {
			run("Size...", "width=" + width*2 + " height=" + height*2 + " constrain average interpolation=Bilinear");
		}
		
		saveAs(dir + setname + "/" + setname + "_" + list[i]);
		run("Close All");
	}
}

function dialoggen() {
	Dialog.create("Channel Reduction");
	Dialog.addString("Name", "Sox9");
	Dialog.addMessage("Name of the output channel(s).\nBy default, files will be saved in [current folder]/Sox9/Sox9_[original name.tif].");
	
	Dialog.addString("Channels", "12");
	Dialog.addMessage("Channel(s) to extract. By default, channels 1 and 2 will be extracted.");
	
	Dialog.addRadioButtonGroup("2x scale", newArray("Yes", "No"), 1, 2, "Yes");
	Dialog.addMessage("Scale width and height up by 2x. Helps with segmentation.");

	Dialog.addMessage("Max Z Projection Configuration\nFor no projection, put 0 in both boxes.")
	Dialog.addNumber("Start: ", 0);
	Dialog.addToSameRow();
	Dialog.addNumber("End: ", 0);

	Dialog.show();

	setname = Dialog.getString();
	setchan = Dialog.getString();

	if (Dialog.getRadioButton() == "Yes") {
		scale = true;
	} else {
		scale = false;
	}

	zstart = Dialog.getNumber();
	zend   = Dialog.getNumber();

	if (zstart == 0 || zend == 0) {
		maxproj = false;
	} else {
		maxproj = true;
	}
}