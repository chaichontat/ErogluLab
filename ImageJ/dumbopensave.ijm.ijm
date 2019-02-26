dir = getDirectory("Choose a Directory");
tiff = dir + "/Tiffs/";
File.makeDirectory(tiff);

list = getFileList(dir);
setBatchMode(true);

for (i=0; i<list.length;i++) {
	if(endsWith(list[i], ".oir") || endsWith(list[i], ".tif")) {
	run("Bio-Formats Importer", "open=["+dir+list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
//	run("Z Project...", "projection=[Max Intensity]");
	saveAs("tiff",tiff + list[i]);
//	close();
	close();
	}
}
