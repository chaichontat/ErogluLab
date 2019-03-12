var setstart;
var setend;
var listsmall;
var firstimage = 0;

bigdir = getDirectory("Choose");
list = getFileList(bigdir);
File.makeDirectory(bigdir + "results/");
setBatchMode(true);


for (k=0; k<list.length; k++) {
	dirsmall = bigdir + list[k];
	listsmall = getFileList(dirsmall);
	dirresults = bigdir + "results/" + list[k];
	File.makeDirectory(dirresults);
	
	while (!endsWith(listsmall[firstimage], ".tif")) {
		firstimage++;
	}

	getNumberofSets();
	for (i = setstart; i <= setend; i++) {
		print("Making directory" + i);
		File.delete(dirresults + "G00" + i + "/");
		File.makeDirectory(dirresults + "G00" + i + "/");
	}
	
	for (i=0; i<listsmall.length; i++) {
		if (startsWith(listsmall[i], "C1")) {
			name = substring(listsmall[i], 3, lengthOf(listsmall[i]));
			setnum = parseInt(substring(listsmall[i],lengthOf(listsmall[i])-10,lengthOf(listsmall[i])-9));
			print(name);
	
			for (j = 1; j <= 4; j++) {
				open(dirsmall + "C" + j + "-" + name);
				rename("C" + j);
			}
	
			run("Merge Channels...", "c1=C1 c2=C2 c3=C3 c4=C4 create");
			run("Z Project...", "stop=9 projection=[Max Intensity]");
			saveAs("tiff", dirresults + "G00" + setnum + "/" + name);
			close();
			close();
		}
	}

	stitch(dirresults, name);
	firstimage = 0;
}

function getNumberofSets() {
	n = listsmall.length - 1;
	while (!(endsWith(listsmall[n], ".zip") || endsWith(listsmall[n], ".tif")) || (startsWith(listsmall[n], "Stitch"))) {
		n--;
	}
	setstart = parseInt(substring(listsmall[firstimage],lengthOf(listsmall[firstimage])-10,lengthOf(listsmall[firstimage])-9));
	setend = parseInt(substring(listsmall[n],lengthOf(listsmall[n])-10,lengthOf(listsmall[n])-9));
}

function stitch(dirresults, name) {
	numsets = setend - setstart + 1;
	for (i = 1; i <= numsets; i++) {
		run("Grid/Collection stitching", "type=[Unknown position] order=[All files in directory] directory=[" + dirresults + "G00" + i + "] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=0.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
		run("16-bit");
		saveAs("tiff", dirresults + "../" + "Stitched_" + substring(name,0,lengthOf(name)-10) + i);
		close();
	}
}

