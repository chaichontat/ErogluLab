dir = getDirectory("Choose a Directory");
list = getFileList(dir);
setBatchMode(true);

dirout = dir + "Rotated/";
File.makeDirectory(dirout)

for (i=0;i<list.length; i++) {
	if (startsWith(list[i], "Stitched_") && endsWith(list[i], ".tif")) {
		open(dir + list[i]);
		getDimensions(width, height, channels, slices, frames);
		// Y-axis
		angley = get_angle("y");
		print("Y angle: " + angley);
		// X-axis
		anglex = -1 * get_angle("x");
		print("X angle: " + anglex);
		run("TransformJ Rotate", "z-angle=0.0 y-angle=" + angley + " x-angle=" + anglex + " interpolation=Linear background=0.0 adjust");
		make_substack();
		resetMinAndMax();
		saveAs("tiff", dirout + list[i]);
		close();
	}
}



function get_angle(axis) {
	if (axis == "y") {
		makeRectangle(0, floor(height/2), width, 50);
		run("Duplicate...", "duplicate");
		run("Reslice [/]...", "output=1.000 start=Top avoid");
	} else {
		makeRectangle(floor(width/2), 0, 50, height);
		run("Duplicate...", "duplicate");
		run("Reslice [/]...", "output=1.000 start=Left avoid");
	}
	
	run("Z Project...", "projection=[Max Intensity]");
	getDimensions(width, height, channels, slices, frames);
	x = newArray(0);
	y = newArray(0);
	
	for (c=1; c<=channels; c++) {
		setSlice(c);
		for (i=0; i<width; i++) {
			sum = 0;
			intensity = 0;
			for (j=0; j<height; j++) {
				sum += j * getPixel(i,j);
				intensity += getPixel(i,j);
			}
		
			// Only consider if intensity above threshold
			if (intensity > height * 80) {
				x = Array.concat(x, i);
				y = Array.concat(y, sum/intensity);
			}
		}
	}
	
	angle = regression(x,y);
	close();
	close();
	close();
	return angle;
}

function regression(x, y) {
	sumx = 0;
	sumy = 0;
	sumx2 = 0;
	sumy2 = 0;
	sumxy = 0;

	for (i=0; i<x.length; i++) {
		sumx += x[i];
		sumy += y[i];
		sumx2 += pow(x[i],2);
		sumy2 += pow(y[i],2);
		sumxy += x[i] * y[i];
	}

	a = (sumy * sumx2 - sumx * sumxy) / (x.length * sumx2 - pow(sumx,2));
	b = (x.length * sumxy - sumx * sumy) / (x.length * sumx2 - pow(sumx,2));

	/*selectWindow("Untitled-1");
	for (i=0; i<width; i++) {
		setPixel(i, floor(i*b+a), 255);
	}*/

	angle = (180 / PI) * atan(b); // Factor for image stretch
	// Negative sign
	if (b < 0) {
		return -1 * angle;
	} else {
		return angle;
	}
}

function make_substack() {
	getDimensions(width, height, channels, slices, frames);
	start = get_stats("up", 0);
	print(start);
	end = get_stats("down", (slices*channels)+1);
	print(end);
	run("Make Substack...", "channels=1-" + channels + " slices=" + start + "-" + end);
}

function get_stats(direction, i) {
	getDimensions(width, height, channels, slices, frames);
	mean = 0;
	while (mean == 0) {
		if (direction == "up") {
			i++;
		} else {
			i--;
		}
		setSlice(i);
		run("Select All");
		getStatistics(area, mean, min, max, std, histogram);
	}
	return round(i/channels);
}

