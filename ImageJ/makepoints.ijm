dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

for (k=0; k < list.length; k++) {
	if (startsWith(list[k], "Mask")) {
		run("Clear Results");
		name = substring(list[k], 5, lengthOf(list[k]));
		open(dir + "ColocResults_" + name + ".csv");
		
		var paira = newArray(0);
		var pairb = newArray(0);
		var dist = newArray(0);
		
		//selectWindow("ColocResults");
		numresults = getValue("results.count");
		print(numresults);
		print(getResult("ColocFromABvolume", 5));
		for (i = 0; i < numresults; i++) {
			if ((getResult("ColocFromABvolume", i) > 5) && (getResult("Dist CenterA-CenterB", i) < 0.8)) {
				// Add list of passed objects to array
				getLabel(getResultString("Label", i));
				dist = Array.concat(dist, 10000 - floor(getResult("Dist CenterA-CenterB", i) * 10000));
			}
		}
		
		close("Results");
		numpuncta = paira.length;
		print("Number of puncta within criteria:" + numpuncta);
		xa = newArray(numpuncta);
		ya = newArray(numpuncta);
		za = newArray(numpuncta);
		
		xb = newArray(numpuncta);
		yb = newArray(numpuncta);
		zb = newArray(numpuncta);
		
		// Get data for ObjA
		open(dir + "ObjA_" + name + ".csv");
		//selectWindow("ObjectsMeasuresResults-A");
		for (i = 0; i < numpuncta; i++) {
			xa[i] = getResult("X", paira[i] - 1);
			ya[i] = getResult("Y", paira[i] - 1);
			za[i] = getResult("Z", paira[i] - 1);
		}
		close("Results");
		
		// Get data for ObjB
		open(dir + "ObjB_" + name + ".csv");
		//selectWindow("ObjectsMeasuresResults-B");
		for (i = 0; i < numpuncta; i++) {
			xb[i] = getResult("X", pairb[i] - 1);
			yb[i] = getResult("Y", pairb[i] - 1);
			zb[i] = getResult("Z", pairb[i] - 1);
		}
		close("Results");
		
		open(dir + list[k]);
		getDimensions(width, height, channels, slices, frames);
		
		// Make points

		for (i = 1; i <= slices ; i++) {
			currentx = newArray(0);
			currenty = newArray(0);
			for (j = 0; j < numpuncta; j++) {
				if (z == i) {
					currentx = Array.concat(currentx, midpos(xa[i], xb[i]));
					currenty = Array.concat(currenty, midpos(ya[i], yb[i]));
				}
			}
			setSlice(i);
			makePoint("point", currentx, currenty);
			run("To ROI Manager");
		}
		
		}
		
		saveAs("tiff", dir + "Spots_" + list[k]);
		close();
	}
}


function getLabel(label) {
	part = split(label, "_");
	parta = split(part[0], "A");
	partb = split(part[1], "B");
	paira = Array.concat(paira, parseInt(parta[1]));
	pairb = Array.concat(pairb, parseInt(partb[1]));
}

function midpos(a, b) {
	return floor(((a + b) / 2) + 1);
}
