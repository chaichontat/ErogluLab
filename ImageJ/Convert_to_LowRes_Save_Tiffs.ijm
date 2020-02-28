dir = getDirectory("Choose");
list = getFileList(dir);
setBatchMode(false);

File.makeDirectory(dir + "LowRes1");
File.makeDirectory(dir + "LowRes2");
File.makeDirectory(dir + "LowRes3");
File.makeDirectory(dir + "HighRes");
File.makeDirectory(dir + "Tiffs");

for (i = 0; i < list.length; i++) {
	if (endsWith(list[i], ".tif") | endsWith(list[i], ".oir")) {
		run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		// saveAs("tiff", dir + "HighRes/" + list[i]);
		
		getDimensions(width, height, channels, slices, frames);
		img = getTitle();
		saveAs("tiff", dir + "/Tiffs/" + substring(img, 0, lengthOf(img)-4));
		name = getTitle();
		//run("Size...", "width=683 height=683 depth=83 constrain average interpolation=Bilinear");
		//run("Divide...", "value=4.000 stack");
		run("Duplicate...", "duplicate");
		run("Duplicate...", "duplicate");

		selectWindow(name);
		num = 40 + 20 * random("gaussian");
		run("Add Specified Noise...", "stack standard=" + num);
		saveAs("tiff", dir + "LowRes1/" + name);
		close();

		selectWindow(substring(name,0,(lengthOf(name)-4))+"-1.tif");
		num = 40 + 20 * random("gaussian");
		run("Add Specified Noise...", "stack standard=" + num);
		saveAs("tiff", dir + "LowRes2/" + name);
		close();
		
		selectWindow(substring(name,0,(lengthOf(name)-4))+"-2.tif");
		num = 40 + 20 * random("gaussian");
		run("Add Specified Noise...", "stack standard=" + num);
		saveAs("tiff", dir + "LowRes3/" + name);
		close();
	}
}