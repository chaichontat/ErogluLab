' Run U-Net and place mask in the last channel

path = File.openDialog("Choose a File");
modeldef = File.directory + substring(File.getName(path),0,lengthOf(File.getName(path))-14) + ".modeldef.h5";

print(path);
print(modeldef);

dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);
for (i=0; i<list.length; i++) {
	open(dir + list[i]);
	getDimensions(width, height, channels, slices, frames);
	name = getTitle();
	run("Remove Overlay");
	call('de.unifreiburg.unet.SegmentationJob.processHyperStack', 'modelFilename=' + modeldef + ',weightsFilename=' + path + ',Tile shape (px):=244x244,gpuId=GPU 0,useRemoteHost=true,hostname=localhost,port=22,username=eroglulab,RSAKeyfile=/home/eroglulab/_key.rsa,processFolder=/home/eroglulab/Desktop/cellnet/,average=none,keepOriginal=true,outputScores=false,outputSoftmaxScores=true');
	
	close();
	run("Split Channels");
	rename("mask"); // channel 2
	run("16-bit");
	
	setAutoThreshold("Default dark");
	run("Convert to Mask");
	run("Watershed");
	roiManager("Deselect");
	run("Analyze Particles...", "size=50-Infinity display clear add");
	close();
	
	
	selectImage(name);
	run("From ROI Manager");
	saveAs("tiff", dir + list[i]);
	run("Close All");
}
