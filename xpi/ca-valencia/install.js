var err = initInstall("Diccionari català (valencià) - test", "ca-valencia@dev.softcatala.org", "9.9.9");
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", "ca-valencia@dev.softcatala.org",
		   "dictionaries", fProgram, "dictionaries", true);
if (err != SUCCESS)
    cancelInstall();

performInstall();
