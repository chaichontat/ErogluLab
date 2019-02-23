' Embed ROIs from ROI manager into image overlay and call save dialog

setBatchMode(true);

counts = roiManager("count");
for (j = 0; j < counts; j++){ 
    roiManager("Select", j);
    roiManager("Rename", "cell");
    roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info");
}
run("From ROI Manager");

path =  getInfo("image.directory"); 
call("ij.io.OpenDialog.setDefaultDirectory", path); 
run("Tiff...");