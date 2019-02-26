macro "Smart Rotate [r]" {
	setTool("line");
	getSelectionCoordinates(x, y);
	slope = -(y[1] - y[0])/ (x[1] - x[0]);
	angle = atan2(-(y[1] - y[0]), (x[1] - x[0])) * 180 / PI;
	run("Rotate... ", "angle=" + angle + " grid=1 interpolation=Bilinear stack");
	setTool("rectangle");
}

macro "Flip Horizontal [h]" {
	run("Flip Horizontally", "stack");
}

macro "Flip Vertical [v]" {
	run("Flip Vertically", "stack");
}

macro "Line Tool [l]" {
	setTool("line");
}
