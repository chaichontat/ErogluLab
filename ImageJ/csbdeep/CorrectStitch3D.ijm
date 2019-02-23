' Correct n Stitch (3D)
' Infer vignetting / multichannel
' Prior to CSBDeep
' Chaichontat "Richard" Sriworarat
' February 11, 2019

var dir1;
var list;
var firstimage;
var channels = 0;
var frame = 1;
setBatchMode(true);
dir1 = getDirectory("[Choose Source Directory]");
list  = getFileList(dir1);
listTileConfigs = getFileList(dir1 + "TileConfigs/")
eval("bsh", "mpicbg.stitching.GlobalOptimization.ignoreZ = true;")

dirSplit = dir1 + "1_Split/";
File.delete(dirSplit);
File.makeDirectory(dirSplit);

getChannels();

dirCorrected = dir1 + "2_Corrected/"; 
dirMerged = dir1 + "3_Merged/";
dirFlat = dir1 + "Corrections/";

for (i = 1; i <= channels; i++) {
	print("Making directory" + i);
	File.delete(dirSplit + "C" + i + "/");
	File.makeDirectory(dirSplit + "C" + i + "/");
}

File.delete(dirCorrected);
File.makeDirectory(dirCorrected);
File.delete(dirMerged);
File.makeDirectory(dirMerged);
File.delete(dirFlat);
File.makeDirectory(dirFlat);


for (i = 1; i <= listTileConfigs.length; i++) {
	File.copy(dir1 + "TileConfigs/TileConfiguration" + i + ".prn", dirMerged + "TileConfiguration" + i + ".txt");
}

Split();
basicCorrect();
mergeCorrected();

for (i = 1; i <= listTileConfigs.length; i++) {
	run("Grid/Collection stitching", "type=[Positions from file] order=[Right & Down                ] directory=[" + dirMerged + "] layout_file=TileConfiguration" + i + ".txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=0.5 absolute_displacement_threshold=2 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	saveAs("ZIP", dir1 + "Stitched_" + substring(list[firstimage],0,lengthOf(list[firstimage])-10) + i);	
}

for (i = 1; i <= channels; i++) {
	deleteTemp(dirSplit + "C" + i + "/");
}

File.delete(dirSplit);
deleteTemp(dirCorrected);
deleteTemp(dirMerged);

setBatchMode(false);
print("Done!");



function getChannels() {
	n = 0;
	while (!(endsWith(list[n], ".oir") || endsWith(list[n], ".tif")) || (startsWith(list[n], "Stitch"))) {
		n++;
	}
	firstimage = n;
	print(n);
	print(list[n]);
	run("Bio-Formats Importer", "open=[" + dir1 + list[n] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	getDimensions(w, h, chan, slice, framenum);
	close();
	print("Number of channels: " + chan);
	channels = chan;
	frame = framenum;
}

function Split() {
	print("Splitting Projecting");
	for (i = 0; i < list.length; i++) {
		if ((endsWith(list[i], ".oir") || endsWith(list[i], ".tif")) && !startsWith(list[i], "Stitch")) {
			print(list[i]);
			name = substring(list[i],0,lengthOf(list[i])-4);
			number = substring(name,lengthOf(name)-9,lengthOf(name));
			run("Bio-Formats Importer", "open=[" + dir1 + list[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			run("Z Project...", "projection=[Max Intensity]");
			run("Split Channels");
			for (j = channels; j >= 1; j--) {
				saveAs("tiff", dirSplit + "C" + j + "/C" + j + "-" + number);
				close();
			}
			close();
		}
	}
}

function basicCorrect() {
	for (i = 1; i <= channels; i++) {
		print("Correcting for channel " + i);
		run("Image Sequence...", "open=[" + dirSplit + "C" + i + "/] sort");
		rename("C" + i);
		run("BaSiC ", "processing_stack=C" +i +" flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
		selectWindow("Flat-field:C" + i);
		saveAs("tiff", dirFlat + "flatfieldC" + i);
		close();
		selectWindow("Dark-field:C" + i);
		saveAs("tiff", dirFlat + "darkfieldC" + i);
		run("Close All");
	}
}

function mergeCorrected() {
	print("Merging channels of corrected images");
	for (i = 0; i < list.length; i++) {
		if ((endsWith(list[i], ".oir") || endsWith(list[i], ".tif")) && !startsWith(list[i], "Stitch")) {
			arg = "";
			print(list[i]);
			name = substring(list[i],0,lengthOf(list[i])-4);
			number = substring(name,lengthOf(name)-9,lengthOf(name));
			run("Bio-Formats Importer", "open=[" + dir1 + list[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			rename("temp");
			run("Split Channels");
			for (j = channels; j >= 1; j--) {
				open(dirFlat + "flatfieldC" + j + ".tif");
				open(dirFlat + "darkfieldC" + j + ".tif");
				run("BaSiC ", "processing_stack=C" + j + "-temp flat-field=[flatfieldC" + j + ".tif] dark-field=[darkfieldC" + j + ".tif] shading_estimation=[Skip estimation and use predefined shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
			}
			
			for (j = 1; j <= channels; j++) {
				arg = arg + " c" + j + "=Corrected:C" + j + "-temp";
			}
			
			run("Merge Channels...", arg + " create");
			saveAs("tiff", dirMerged + name);
			run("Close All");
		}
	}
}

function deleteTemp(input) {
	listdel = getFileList(input);
	for (i = 0; i < listdel.length; i++) {
      File.delete(input + listdel[i]);
	}
  	File.delete(input);
}
