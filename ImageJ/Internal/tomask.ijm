getDimensions(width, height, channels, slices, frames);
name = getTitle();
rename("temp");
if (roiManager("count") != 0) {
		roiManager("Deselect");
		roiManager("Delete");
}
run("To ROI Manager");
roiManager("Combine");
run("Create Mask");
run("Invert LUT");
rename("mask");
run("16-bit");

if (channels == 1) {
	run("Merge Channels...", "c1=[temp] c2=[mask] create");
	rename(name);
} else {
	selectWindow("temp");
	run("Split Channels");
	arg = "";
	for (i=1; i<=channels; i++) {
		arg = arg + " c" + i + "=" + "C" + i + "-temp";
	}
	arg = arg + " c" + channels+1 + "=mask create";
	run("Merge Channels...", arg);
	rename(name);
}
