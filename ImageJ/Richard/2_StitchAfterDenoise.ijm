' Iterate through each subfolder, max project and save into corresponding "stitch" folder
var dir;
var list;
var lastfile;
setBatchMode(true);

dirbig = getDirectory("Choose a Directory");
listbig = getFileList(dirbig);

for (j = 0; j < listbig.length; j++) { // Iterate through each subfolder
	if (endsWith(listbig[j], "_restored/")) {
		dir = dirbig + listbig[j];
		list = getFileList(dir);
		lastfile = getLastFile();
		numstitch = parseInt(substring(list[lastfile], lengthOf(list[lastfile])-12,lengthOf(list[lastfile])-9)); // Number of stitches to make
		dirmax = newArray(numstitch);
		
		for (i = 0; i < numstitch; i++) { // Temp folder for max-projected images
			dirmax[i] = dir + "Max" + i + "/";
			File.makeDirectory(dirmax[i]);
		}
		
		currentstitch = 0;
		for (i = 0; i < list.length; i++) { // Max project
			if (endsWith(list[i], ".tif")) {
				while (indexOf(list[i], "G00" + (currentstitch+1)) == -1) { // Increase to G002 if there's no G001 in file name
					currentstitch++;
				}
				
				open(dir + list[i]);
				run("Z Project...", "projection=[Max Intensity]");
	//			run("Z Project...", "stop=9 projection=[Max Intensity]");
				saveAs(dirmax[currentstitch] + list[i]);
				close();
				close();
			}
		}

		containsconf = checkTileConfig(dir);
		
		for (i = 0; i < numstitch; i++) { // Stitch
			sublist = getFileList(dirmax[i]);
			if (sublist.length != 0) { // Protect against "skipping" G001 ... G003
				if (containsconf) {
					print("TileConfig Found");
					run("Grid/Collection stitching", "type=[Positions from file] order=[Right & Down                ] directory=[" + dirmax[i] + "] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=0.5 absolute_displacement_threshold=2 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
				} else {
					run("Grid/Collection stitching", "type=[Unknown position] order=[All files in directory] directory=[" + dirmax[i] + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=0.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
				}
				
				run("16-bit");
				saveAs("tiff", dirbig + "Stitched_" + substring(list[lastfile],0,lengthOf(list[lastfile])-10) + i+1);
				close();
				File.delete(dirmax[i]);
			}
		}
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
	confdir = substring(dir, 0, lengthOf(dir)-10) + "/TileConfigs/";
	print(confdir);
	conflist = getFileList(confdir);
	if (conflist.length > 0) {
		containsconf = true;
		for (j=1; j<=conflist.length; j++) {
				File.copy(confdir + "TileConfiguration" + j + ".prn", dir + "Max" + j-1 + "/TileConfiguration.txt");
		}
	} else {
		containsconf = false;
	}
	/*
	for (i=0; i<orilist.length; i++) {
		if (orilist[i] == "TileConfigs/") {
			containsconf = true;
			listconf = getFileList(oridir + "TileConfigs/");
			for (j=1; j<=listconf.length; j++) {
				File.copy(orilist + "TileConfigs/TileConfiguration" + i + ".prn", dir + "Max" + i-1 + "/TileConfiguration" + i + ".txt");
			}
		}
	}*/
	return containsconf;
}