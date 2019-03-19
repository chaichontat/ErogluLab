dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (i=0; i< list.length;i++) {
	if (startsWith(list[i],"Seg")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);
		run("Size...", "width=" + width/2 + " height=" + height/2 + " constrain average interpolation=Bilinear");
		saveAs("tiff", dir + list[i]);
		close();
		
	}
}