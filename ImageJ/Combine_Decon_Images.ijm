dir = getDirectory("Choose a Directory");
list = getFileList(dir);
ch = getString("What is the name of your first channel folder?", "CH1");
combined = dir +"/Combined-Tiffs/";
File.makeDirectory(combined)

list_Ch1 = getFileList(dir+ch);

setBatchMode(true);

for (i = 0; i < list_Ch1.length; i++) {
	name = list_Ch1[i];
	image_root = substring(name,2,lengthOf(name));
	for(n = 0; n < list.length-1; n++){
		m = n+1;
		open(dir+list[n]+"/C"+m+image_root);
		run("16-bit");
		
		//print(dir+list[n]+"/C"+m+image_root);
	}
	//print("stop");
	run("Merge Channels...", "c1=[C1"+image_root+"] c2=[C2"+image_root+"] c3=[C3"+image_root+"] c4=[C4"+image_root+"] create");
	sve_img = substring(image_root, 1, lengthOf(image_root)-9);
	//print(sve_img);
	saveAs("tiff", combined+sve_img);
	run("Close All");
}
