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

//setBatchMode(true);

for (z=0; z<list.length; z++) {
	if (endsWith(list[z], ".tif") && !startsWith(list[z], "Spots")) {
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
		}
		
		open(dir + list[z]);
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
		//setBatchMode("hide");
		getThreshold(lowera, uppera);
		run("Analyze Particles...", "size=" + minsize + "-Infinity pixel show=Nothing display");
		numa = getValue("results.count");
		xa = newArray(numa);
		ya = newArray(numa);
		ra = newArray(numa);
		
		for (i = 0; i < numa; i++) {
			xa[i] = getResult("X", i);
			ya[i] = getResult("Y", i);
			ra[i] = sqrt(getResult("Area", i) / PI);
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
		// setBatchMode("hide");
		getThreshold(lowerb, upperb);
		run("Analyze Particles...", "size=" + minsize + "-Infinity pixel show=Nothing display");
		numb = getValue("results.count");
		xb = newArray(numb);
		yb = newArray(numb);
		rb = newArray(numb);
		
		start = getTime();
		
		for (i = 0; i < numb; i++) {
			xb[i] = getResult("X", i);
			yb[i] = getResult("Y", i);
			rb[i] = sqrt(getResult("Area", i) / PI);
		}
		print("Radius: " + getTime() - start);
		
		close("Results");

		xpuncta = newArray(100000);
		ypuncta = newArray(100000);
		numpuncta = 0;

		print(numa);
		print(numb);

		for (i = 0; i < numa; i++) {
			for (j = 0; j < numb; j++) {
				if (punctaornot(xa[i], ya[i], ra[i], xb[j], yb[j], rb[j])) {
					xpuncta[numpuncta] = midpos(xa[i], xb[j]);
					ypuncta[numpuncta] = midpos(ya[i], yb[j]);
					numpuncta++;
				}
			}
		}

		xpuncta = Array.trim(xpuncta, numpuncta);
		ypuncta = Array.trim(ypuncta, numpuncta);

		print("Dist: " + getTime() - start);

		run("Merge Channels...", "c1=[temp (green)] c2=[temp (red)] create");
		run("Select None");
		makeSelection("point", xpuncta, ypuncta);
		roiManager("Add");
		roiManager("Select", 0);
		roiManager("Rename", "synapse");
		run("From ROI Manager");
		print("ROI: " + getTime() - start);
		saveAs("tiff", dir + "Spots_" + list[z]);
		run("Close All");
	
		File.append(list[z] + "\t" + numa + "\t" + numb + "\t" + numpuncta + "\t" + lowera + "\t" + lowerb, resultfile);
	}
}

function punctaornot(xa, ya, ra, xb, yb, rb) {
	if ((xb-xa) < 50 && (yb-ya) < 50) {
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
