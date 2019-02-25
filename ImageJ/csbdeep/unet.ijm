dir = getDirectory("Choose a Directory");
list = getFileList(dir);

path = File.openDialog("Choose a File");
modeldef = path + "/" + substring(File.getName(path),0,lengthOf(File.getName(path))-14) + ".modeldef.h5";

for (i=0; i <list.length; i++) {
	open(dir + list[i]);
	run("Remove Overlay");
	call('de.unifreiburg.unet.SegmentationJob.processHyperStack', 'modelFilename=' + modeldef + ',weightsFilename=' + path + ',Tile shape (px):=244x244,gpuId=GPU 0,useRemoteHost=true,hostname=localhost,port=22,username=eroglulab,RSAKeyfile=/home/eroglulab/_key.rsa,processFolder=/home/eroglulab/Desktop/cellnet/,average=none,keepOriginal=true,outputScores=false,outputSoftmaxScores=true');
	
	close();
	run("Split Channels");
	setAutoThreshold("Default dark");
	run("Convert to Mask");
	run("Watershed");
	roiManager("Deselect");
	run("Analyze Particles...", "size=50-Infinity display clear add");
	close(); // channel 2
	close(); // channel 1
	close(); // normalized
	run("From ROI Manager");
	saveAs("tiff", dir + list[i]);
	close();
}