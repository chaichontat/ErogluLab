' Iterate through each subfolder, max project and save into corresponding "stitch" folder
var dir;
var dirmax;
var list;
var lastfile;
var maxproj;
var zstart;
var zend;
var currentstitch; // Number of groups - 1
setBatchMode(true);

dialoggen();

dirbig = getDirectory("Choose a Directory");
listbig = getFileList(dirbig);

for (j = 0; j < listbig.length; j++) { // Iterate through each subfolder
	if (endsWith(listbig[j], "_tiff/")) {
		dir = dirbig + listbig[j];
		list = getFileList(dir);
		lastfile = getLastFile();
		numstitch = parseInt(substring(list[lastfile], lengthOf(list[lastfile])-12,lengthOf(list[lastfile])-9)); // Number of stitches to make
		dirmax = newArray(numstitch);
		
		for (i = 0; i < numstitch; i++) { // Temp folder for images
			dirmax[i] = dir + "Max" + i+1 + "/";
			File.makeDirectory(dirmax[i]);
		}
		
		currentstitch = 0;
		for (i = 0; i < list.length; i++) { // Separate by G001..G00n
			if (endsWith(list[i], ".tif")) {
				while (indexOf(list[i], "G00" + (currentstitch+1)) == -1) { // Increase to G002 if there's no G001 in file name
					currentstitch++;
				}
				File.copy(dir + list[i], dirmax[currentstitch] + list[i]);
			}
		}

		containsconf = checkTileConfig(dir);
		
		for (i = 0; i < numstitch; i++) { // Stitch
			sublist = getFileList(dirmax[i]);
			if (sublist.length != 0) { // Protect against "skipping" G001 ... G003
				if (containsconf) {
					print("TileConfig Found");
					run("Grid/Collection stitching", "type=[Positions from file] order=[Right & Down                ] directory=[" + dirmax[i] + "] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=0.5 absolute_displacement_threshold=2 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
				} else {
					waitForUser("Tile configuration file not found. Stitching may take a long time.");
					run("Grid/Collection stitching", "type=[Unknown position] order=[All files in directory] directory=[" + dirmax[i] + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=0.5 absolute_displacement_threshold=2 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
				}

				getDimensions(width, height, channels, slices, frames);
				
				if (maxproj) {
					if (zend > slices || zstart < 1) {
						exit("Requested Z projection impossible, not enough slices");
					}
					run("Z Project...", "start=" + zstart + " stop=" + zend + " projection=[Max Intensity]");
				} else {
					setSlice(floor(channels/2));
				}
				run("16-bit");
				resetMinAndMax();
				saveAs("tiff", dirbig + "Stitched_" + substring(list[lastfile],0,lengthOf(list[lastfile])-10) + i+1);
				close();
				deletedir(dirmax[i]);
			}
		}
	}
}

function dialoggen() {
	Dialog.create("Post-denoise Stitching");
	Dialog.addMessage("Max Z Projection Configuration\nFor no projection, put 0 in both boxes.")
	Dialog.addNumber("Start: ", 1);
	Dialog.addToSameRow();
	Dialog.addNumber("End: ", 9);
	Dialog.show();

	zstart = Dialog.getNumber();
	zend   = Dialog.getNumber();

	if (zstart == 0 || zend == 0) {
		maxproj = false;
	} else {
		maxproj = true;
	}
}

function getLastFile() {
	n = list.length - 1;
	while (!(endsWith(list[n], ".oir") || endsWith(list[n], ".tif")) || (startsWith(list[n], "Stitch"))) {
		n--;
	}
	return n;
}

function checkTileConfig(dir) {
	confdir = substring(dir, 0, lengthOf(dir)-10) + "/";
	conflast = "TileConfiguration" + currentstitch+1 + ".txt";
	if (File.exists(confdir + conflast)) {
		containsconf = true;
		for (j=1; j<=currentstitch+1; j++) {
			File.copy(confdir + "TileConfiguration" + j + ".txt", dirmax[j-1] + "/TileConfiguration.txt");
		}
	} else {
		containsconf = false;
	}
	return containsconf;
}

function deletedir(dirdel) {
	listdel = getFileList(dirdel);
	for (i = 0; i < listdel.length; i++) {
		x = File.delete(dirdel + listdel[i]);
	}
	x = File.delete(dirdel);
}
