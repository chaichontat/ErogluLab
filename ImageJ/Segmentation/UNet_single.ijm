waitForUser("This script merges U-Net mask with input image.\nSelect input image and click OK.");
name = getTitle();

// Catch user error
if (!endsWith(name, ".tif")) {
	exit("Please select the input image, not the output image.");
}

getDimensions(width, height, channels, slices, frames);
run("32-bit");
setBatchMode(true);

// Get rid of extraneous things
close(name + " - normalized");
close(name + " - normalized - score (segmentation)");
selectWindow(name + " - normalized - score (softmax)");
run("Split Channels");
rename("mask"); // channel 2
close("C1-" + name + " - normalized - score (softmax)"); // close channel 1

// Split
selectImage(name);
if (channels > 1) {
	rename("temp");
	run("Split Channels");
} else {
	rename("C1-temp");
}

// Merge
arg = "";
for (j=1; j<=channels; j++) {
	arg = arg + " c" + j + "=" + "C" + j + "-temp";
}
arg = arg + " c" + j + "=mask create";
run("Merge Channels...", arg);

set_mask(channels+1);
rename(name);
setBatchMode("show");

function set_mask(chan) { // Mark that channel is a mask.
	Stack.setChannel(chan);
	setPixel(0,0,251);
	setPixel(1,0,148);
	setPixel(0,1,249);
}