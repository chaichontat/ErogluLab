var dir1;
var list1;
var dir2;
var list2;
var dirbig;
var listbig;
var dirflat;
var dirtiff;
var listp1;
var listp2;
var numchan;
var batch;
var correction;
var train;

dialoggen();
setBatchMode(true);

if (batch == false) { // Individual
	dir1 = getDirectory("Choose P1");
	list1 = getFileList(dir1);

	if (numchan > 2) {
		dir2 = getDirectory("Choose P2");
		list2 = getFileList(dir2);
	}
	
	getdirflat();
	processfolder();
	
} else { // Batch
	dirbig = getDirectory("Choose big directory");
	listbig = getFileList(dirbig);
	getdirflat();
	if (numchan < 3) {
		for (j = 0; j < listbig.length; j++) {
			new = listbig[j];
			if (endsWith(new, "/") || endsWith(new, "\\")) { // Check if directory
				dir1 = dirbig + new;
				list1 = getFileList(dir1);
				processfolder();
			}
		}
	} else { // Batch two phases
		listp1 = newArray();
		listp2 = newArray();
		for (j = 0; j < listbig.length; j++) {
			new = listbig[j];
			cycloc = indexOf(new, "P1_Cycle");
			if ((endsWith(new, "/") || endsWith(new, "\\")) && cycloc != -1 && !endsWith(new, "tiff/") && !endsWith(new, "restored/")) { // Check if directory and from Olympus
				p2index = -1;
				newp2 = substring(new,0,cycloc) + "P2_Cycle";
				for (k=0; k<listbig.length; k++) {  // Check index of P2
					if (indexOf(listbig[k], newp2) != -1) {
						p2index = indexOf(listbig[k], newp2);
					}
				}
				if (p2index != -1) {
					listp1 = Array.concat(listp1, new);
					listp2 = Array.concat(listp2, listbig[p2index]);
				} else {
					exit("Unequal P1 and P2 folder. Please recheck naming of " + new + ".");
				}
			}
		}
		
		for (j = 0; j < listp1.length; j++) {
			dir1 = dirbig + listp1[j];
			dir2 = dirbig + listp2[j];
			list1 = getFileList(dir1);
			list2 = getFileList(dir2);
			processfolder();
		}
	}
}


function dialoggen() {
	Dialog.create("Denoising pre-process");
	Dialog.addMessage("DISCLAIMER: Always check the images for z-drift and exposure before processing.\nComputational methods are not a substitute for good data acquisition technique.");
	Dialog.addRadioButtonGroup("Operation", newArray("Train", "Run"), 1, 2, "Run");
	Dialog.addNumber("Total number of channels:", 4);
	
	Dialog.addRadioButtonGroup("Directory Options", newArray("Individual", "Batch"), 1, 2, "Individual")
	Dialog.addMessage("For individual, choose P1 then P2 folder.");
	Dialog.addMessage("For batch, choose a big folder containing folders of each MATL folder.\n\t\t\t\t\t\tIf two phases, each MATL folder must end with \"P1\" or \"P2\"");
	
	Dialog.addRadioButtonGroup("Vignette Correction:", newArray("None", "Flatfield"), 1, 2, "None");
	Dialog.addMessage("If flatfield vignette correction is selected, choose the flatfield directory after choosing P1/P2.");
	Dialog.show();

	if (Dialog.getRadioButton() == "Train") {
		train = true;
	} else {
		train = false;
	}

	numchan  = Dialog.getNumber();
	
	if (Dialog.getRadioButton() == "Individual") {
		batch = false;
	} else {
		batch = true;
	}

	if (Dialog.getRadioButton() == "None") {
		correction = "None";
	} else {
		correction = "flatfield";
	}	
}

function processfolder() {
	foldername = File.getName(dir1);
	dirtiff = dir1 + "../" + foldername +"_tiff/";
	File.makeDirectory(dirtiff);
	
	for (i=0; i<list1.length; i++) {
		if (endsWith(list1[i], ".oir") || endsWith(list1[i], ".tif") ) {
			run("Bio-Formats Importer", "open=[" + dir1 + list1[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			
			name = getTitle();
			name = substring(name, 0, lengthOf(name)-4);
			rename("temp");
			
			if (numchan > 1) {
				run("Split Channels");
				selectWindow("C1-temp");
				rename("C1");
				selectWindow("C2-temp");
				rename("C2");
			} else {
				rename("C1");
			}
			
			if (numchan > 2) {
				run("Bio-Formats Importer", "open=[" + dir2 + list2[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
				rename("temp");
				if (numchan > 3) {
					run("Split Channels");
					selectWindow("C1-temp");
					rename("C3");
					selectWindow("C2-temp");
					rename("C4");
				} else {
					rename("C3");
				}
			}

			if (correction == "flatfield") {
				for (j = 1; j <= numchan; j++) {
					open(dirflat + "Flat_C" + j + ".tif");
					run("BaSiC ", "processing_stack=C" + j +" flat-field=[Flat_C" + j + ".tif] dark-field=None shading_estimation=[Skip estimation and use predefined shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
				}
			} else if (correction == "infer") {
				// TODO
			}

			if (numchan > 1) {
				run("Merge Channels...", genarg(correction));
			}
			
			saveAs("tiff", dirtiff + name);
			run("Close All");
		}
	}
}

function genarg(correction) {
	arg = "";
	if (correction != "None") {
		for (i=1; i<=numchan; i++) {
			arg = arg + " c" + i + "=" + "[Corrected:C" + i + "]";
		}
	} else {
		for (i=1; i<=numchan; i++) {
			arg = arg + " c" + i + "=" + "[C" + i + "]";
		}
	}

	arg = arg + " create";
	return arg;
}

function getdirflat() {
	if (correction == "flatfield") {
		dirflat = getDirectory("Choose Flatfield");
	}
}
