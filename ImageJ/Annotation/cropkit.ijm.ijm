macro "Smart Rotate [r]" {
	setTool("line");
	waitForUser("Hold", "Drag Line and Click OK");
	getSelectionCoordinates(x, y);
	slope = -(y[1] - y[0])/ (x[1] - x[0]);
	angle = atan2(-(y[1] - y[0]), (x[1] - x[0]));

	// For some reason, enlarge doesn't work. Fall back to manual linear algebra.
	aangle = abs(angle);
	getDimensions(width, height, channels, slices, frames);
	x_ori = width / 2;
	y_ori = height / 2;
	// Upper right corner
	newheight = abs(x_ori * sin(angle) + y_ori * cos(angle)) * 2;
	// Lower right corner
	newwidth  = abs(x_ori * cos(angle) + y_ori * sin(angle)) * 2;
	
	run("Canvas Size...", "width=" + newwidth + " height=" + newheight + " position=Center zero");
	run("Rotate... ", "angle=" + angle * 180 / PI + " grid=1 interpolation=Bilinear stack");
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
