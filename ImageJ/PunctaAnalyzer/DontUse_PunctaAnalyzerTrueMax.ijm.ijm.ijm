dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);
minsize = getNumber("Minimum puncta size? ", 4);

// Check result txt existence
resultfile = dir + "PunctaOutput.txt";
if (!(File.exists(resultfile))) {
	f = File.open(resultfile);
	print(f, "Name\tGreen Channel\tRed Channel\tPunctaCounts\tGreen threshold\tRed threshold");
	File.close(f);
}

setBatchMode(true);

for (z=0; z<list.length; z++) {
	if (endsWith(list[z], ".tif")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}
		
		open(dir + list[z]);
		run("Select None");
		getDimensions(width, height, channels, slices, frames);
		rename("temp");
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		run("Split Channels");
		close("temp (blue)");
		
		// Green channel
		selectWindow("temp (green)");
		run("Duplicate...", " ");
		run("Subtract Background...", "rolling=50");
		setAutoThreshold("Default dark no-reset");
		run("Threshold...");
		setBatchMode("show");
		waitForUser("File: " + z+1 + "/" + lengthOf(list), "Green: adjust threshold and click OK");
		setBatchMode("hide");
		getThreshold(lowera, uppera);
		
		run("Find Maxima...", "noise=" + lowera + " output=[Single Points]");
		
		selectWindow("temp (green)-1");
		run("Analyze Particles...", "size=" + minsize + "-Infinity pixel show=Masks display");
		close("Results");
		
		imageCalculator("AND create", "Mask of temp(green)-1.tif","temp (green)-1 Maxima");
		run("Analyze Particles...", "size=1-Infinity pixel show=Masks display");

		nummaxa = getValue("results.count");
		xmaxa = newArray(numa);
		ymaxa = newArray(numa);

		for (i = 0; i < nummaxa; i++) {
			xmaxa[i] = getResult("X", i);
			ymaxa[i] = getResult("Y", i);
		}
		close("Results");
		
		// Red channel
		selectWindow("temp (red)");
		run("Duplicate...", " ");
		run("Subtract Background...", "rolling=50");
		setAutoThreshold("Default dark no-reset");
		run("Threshold...");
		setBatchMode("show");
		waitForUser("File: " + z+1 + "/" + lengthOf(list), "Red: adjust threshold and click OK");
		setBatchMode("hide");
		getThreshold(lowerb, upperb);
		run("Find Maxima...", "noise=" + lowerb + " output=[Single Points]");
		
		selectWindow("temp (red)-1");
		run("Analyze Particles...", "size=" + minsize + "-Infinity pixel show=Masks display");

		close("Results");
		imageCalculator("AND create", "Mask of temp(red)-1.tif","temp (red)-1 Maxima");
		run("Analyze Particles...", "size=1-Infinity pixel show=Masks display");

		nummaxb = getValue("results.count");
		xmaxb = newArray(numb);
		ymaxb = newArray(numb);

		for (i = 0; i < nummaxb; i++) {
			xmaxb[i] = getResult("X", i);
			ymaxb[i] = getResult("Y", i);
		}
		close("Results");

		xpuncta = newArray(0);
		ypuncta = newArray(0);
		numpuncta = 0;
		//newImage("spots", "8-bit black", width, height, 1);
		
		for (i = 0; i < numa; i++) {
			for (j = 0; j < numb; j++) {
				if (punctaornot(xmaxa[i], ymaxa[i], rmaxa[i], xmaxb[j], ymaxb[j], rb[j])) {
					xpuncta = Array.concat(xpuncta, midpos(xa[i], xb[j]));
					ypuncta = Array.concat(ypuncta, midpos(ya[i], yb[j]));
					//setPixel(midpos(xa[i], xb[j]), midpos(ya[i], yb[j]), 255);
					numpuncta++;
				}
			}
		}

		run("Merge Channels...", "c1=[temp (green)] c2=[temp (red)] create");
		makeSelection("point", xpuncta, ypuncta);
		roiManager("Add");
		roiManager("Select", 0);
		roiManager("Rename", "synapse");
		run("From ROI Manager");
		
		saveAs("tiff", dir + "Spots_" + list[z]);
		run("Close All");
	
		File.append(list[z] + "\t" + numa + "\t" + numb + "\t" + numpuncta + "\t" + lowera + "\t" + lowerb, resultfile);
	}
}

function punctaornot(xa, ya, ra, xb, yb, rb) {
	if ((xb-xa) < 10 && (yb-ya) < 10) {
		thr = ra + rb;
		if (thr > sqrt(pow(yb - ya,2) + pow(xb - xa,2))) {
			return true;
		} else {
			return false;
		}
	} else {
		return false;
	}
}

function midpos(a, b) {
	return floor(((a + b) / 2) + 1);
}
