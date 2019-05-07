' Rotate in X and Y axes

getDimensions(width, height, channels, slices, frames);

// Y-axis
makeRectangle(0, floor(height/2), width, 50);
setBatchMode(true);
run("Duplicate...", "duplicate");
run("Reslice [/]...", "output=1.000 start=Top avoid");
angley = -1 * get_line();
print("Y angle: " + angley);

// X-axis
makeRectangle(floor(width/2), 0, 50, height);
setBatchMode(true);
run("Duplicate...", "duplicate");
run("Reslice [/]...", "output=1.000 start=Left avoid");
anglex = get_line();
print("X angle: " + anglex);

setBatchMode(true);
run("TransformJ Rotate", "z-angle=0.0 y-angle=" + angley + " x-angle=" + anglex + " interpolation=Linear background=0.0 adjust");
make_substack();
resetMinAndMax();

function get_line() {
	run("Z Project...", "projection=[Max Intensity]");
	getDimensions(width, height, channels, slices, frames);
	run("Size...", "width=" + floor(width/2) + " height=" + height*4 + " depth=" + channels + " average interpolation=Bilinear");
	setBatchMode("show");
	setTool("line");
	waitForUser("Drag plane of image FROM LEFT TO RIGHT");
	getSelectionCoordinates(x, y);
	angle = (1/8) * (atan2(-(y[1] - y[0]), (x[1] - x[0]))* 180 / PI);
	close();
	setBatchMode(false);
	return angle;
}

function make_substack() {
	getDimensions(width, height, channels, slices, frames);
	start = get_stats("up", 0);
	print(start);
	end = get_stats("down", (slices*channels)+1);
	print(end);
	run("Make Substack...", "channels=1-" + channels + " slices=" + start + "-" + end);
	setBatchMode("show");
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
