run("16-bit");
run("Z Project...", "projection=[Max Intensity]");
getDimensions(width, height, channels, slices, frames);
run("Size...", "width=" + 2*width + " height=" + 2*height + " depth=" + channels + " constrain average interpolation=Bilinear");