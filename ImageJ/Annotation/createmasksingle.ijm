close();
run("Split Channels");
name = getTitle();
name = substring(name, 3, lengthOf(name)-40);
rename("mask"); // channel 2
run("16-bit");
selectImage(name);
rename("temp");
run("Split Channels");
arg = "";
for (i=1; i<=channels; i++) {
	arg = arg + " c" + i + "=" + "C" + i + "-temp";
}
arg = arg + " c" + i + "=mask create";
run("Merge Channels...", arg);