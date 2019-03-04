' Convert mask in the last channel to ROIs

name = getTitle();
getDimensions(width, height, channels, slices, frames);

rename("temp");
Stack.setDisplayMode("color");
Stack.setChannel(3);
run("Make Inverse");

setAutoThreshold("Li dark");
getThreshold(lower, upper);

run("Split Channels");
setThreshold(lower, upper);
run("Convert to Mask");
run("Watershed");
roiManager("Deselect");
run("Analyze Particles...", "size=50-Infinity display clear add");

close();

arg = "";
for (i=1; i<=channels - 1; i++) {
	arg = arg + " c" + i + "=" + "C" + i + "-temp";
}

arg = arg + " create";
run("Merge Channels...", arg);
rename(name);
roiManager("Show All");
