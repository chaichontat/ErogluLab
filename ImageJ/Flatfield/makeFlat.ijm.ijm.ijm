' Median project across z and images to generate a flatfield image(s)

chan = getNumber("Number of channels? ", 2);
dirtiff = newArray(chan);

dir = getDirectory("Choose a Directory");
list = getFileList(dir);

for (i = 0; i < chan; i++) {
	dirtiff[i] = dir + "MedProj_C" + i+1 + "/";
	File.makeDirectory(dirtiff[i]);
}

setBatchMode(true);

// Median projection of Z
for (i = 0; i < list.length; i++) {
	if ((endsWith(list[i], ".oir") || endsWith(list[i], ".tif")) && !startsWith(list[i], "Flat")) {
		run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("Z Project...", "projection=Median");

		if (chan == 2) {
			run("Split Channels");
			saveAs("tiff", dirtiff[1] + getTitle());
			close();
		}
		
		saveAs("tiff", dirtiff[0] + getTitle());
		run("Close All");
	}
}

// Median projection across all images
for (i = 0; i < chan; i++) {
	listmed = getFileList(dirtiff[i]);
	run("Image Sequence...", "open=" + dirtiff[i] + listmed[0] + " sort");
	run("Z Project...", "projection=Median");
	run("Gaussian Blur...", "sigma=1");
	saveAs("tiff", dirtiff[i] + "../" + "Flat_C" + i+1);
	run("Close All");
	deletedir(dirtiff[i]);
}

function deletedir(dirdel) {
	listdel = getFileList(dirdel);
	for (i = 0; i < listdel.length; i++) {
		x = File.delete(dirdel + listdel[i]);
	}
	x = File.delete(dirdel);
}
