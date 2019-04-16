' Auto max project based on intensity

num = getNumber("Enter the desired number of slices", 9);

dir = getDirectory("[Choose Source Directory]");
list  = getFileList(dir);
setBatchMode(true);

resultfile = dir + "MaxProjectData.txt";
if (!(File.exists(resultfile))) {
	f = File.open(resultfile);
	print(f, "Name\tStart\tEnd");
	File.close(f);
}

for (ind=0; ind<list.length; ind++) {
	if (endsWith(list[ind], ".tif") && indexOf(list[ind], "max") == -1) {
		open(dir + list[ind]);
		getDimensions(width, height, channels, slices, frames);
		intensity = newArray(slices+1);
	
		if (num > slices) {
			exit("Requested number of slices higher than that available.");
		}
		
		for (i=1; i<=slices*channels; i++) {
			setSlice(i);
			getStatistics(area, mean, min, max, std, histogram);
			intensity[floor((i-1)/channels)+1] += mean; // Slice - 1 
		}
		
		start = floor(slices/2);
		end = start + 1; // Inclusive
		count = 2;
		
		while (count < num) {
			print("Count " + count);
			if (start > 1 && end < slices) {
				if (intensity[start-1] > intensity[end]) {
					start--;
					print("Dec");
				} else {
					end++;
					print("Inc");
				}
				
				count++;
			} else {
				if (start == 1) {
					end = end + (num - count);
					count = num;
				}
				
				if (end == slices) {
					start = start - (num - count);
					count = num;
				}
			}
		}
		
		print(start);
		print(end);
		run("Z Project...", "start=" + start + " stop=" + end + " projection=[Max Intensity]");
		resetMinAndMax();
		run("16-bit");
		saveAs("tiff", dir + substring(list[ind],0,lengthOf(list[ind])-4) + "_max");
		close();
		close();
		File.append(list[ind] + "\t" + start + "\t" + end, resultfile);
	}
}