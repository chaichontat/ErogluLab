var list1;
var dir1;
var firstimage;

dirp1 = getDirectory("Choose");
dirp2 = getDirectory("Choose");

list1 = getFileList(dirp1);
list2 = getFileList(dirp2);

getChannels();
dirtiff = dirp1 + "../MergedCorrected/" + substring(list1[firstimage], 0, lengthOf(list1[firstimage])-18) + "-corrected/";
File.makeDirectory(dirtiff); 
dirdark = "C:\\Users\\User\\Desktop\\New folder (2)\\DarkFlat\\";

setBatchMode(true);

for (i=0; i<list1.length; i++) {
	if (endsWith(list1[i], ".oir")) {
		run("Bio-Formats Importer", "open=[" + dirp1 + list1[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		name = getTitle();
		
		run("Split Channels");

		selectWindow("C1-" + name);
		rename("C1");
		selectWindow("C2-" + name);
		rename("C2");
		name = substring(name, 0, lengthOf(name)-4);

		run("Bio-Formats Importer", "open=[" + dirp2 + list2[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		name2 = getTitle();
		
		run("Split Channels");
		selectWindow("C1-" + name2);
		rename("C3");
		selectWindow("C2-" + name2);
		rename("C4");

		for (j = 1; j <= 4; j++) {
			open(dirdark + "Flat_C" + j + ".tif");
			open(dirdark + "Dark_C" + j + ".tif");
			selectWindow("C" + j);
			run("BaSiC ", "processing_stack=C" + j +" flat-field=[Flat_C" + j + ".tif] dark-field=None shading_estimation=[Skip estimation and use predefined shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
		}
		run("Merge Channels...", "c1=[Corrected:C1] c2=[Corrected:C2] c3=[Corrected:C3] c4=[Corrected:C4] create");
		saveAs("tiff", dirtiff + name);
		run("Close All");
	}
}

function getChannels() {
	n = 0;
	while (!(endsWith(list1[n], ".oir") || endsWith(list1[n], ".tif")) || (startsWith(list1[n], "Stitch"))) {
		n++;
	}
	print(n);
	firstimage = n;
	/*run("Bio-Formats Importer", "open=[" + dir1 + list1[n] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	getDimensions(w, h, chan, slice, framenum);
	close();
	print("Number of channels: " + chan);
	channels = chan;
	frame = framenum;*/
}