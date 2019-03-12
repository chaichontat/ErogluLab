' Scale flatfield image for zoomed configurations

zoom = getNumber("Zoom factor?" , 1.5);

dir = getDirectory("Choose a Directory");
list = getFileList(dir);

dirtiff = dir + "Flat_" + zoom + "x/";
File.makeDirectory(dirtiff);

setBatchMode(true);
for (i = 0; i < list.length; i++) {
	if (startsWith(list[i], "Flat")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);
		newwidth = width / zoom;
		newheight = height / zoom;
		makeRectangle(floor((width-newwidth)/2), floor((height-newheight)/2), newwidth, newheight);
		run("Crop");
		run("Size...", "width=" + width + " height=" + height + " constrain average interpolation=Bicubic");
		saveAs("tiff", dirtiff + list[i]);
	}
}