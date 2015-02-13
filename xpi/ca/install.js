var err = initInstall("Diccionari català (general) - test", "ca@dev.softcatala.org", "9.9.9");
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", "ca@dev.softcatala.org",
		   "dictionaries", fProgram, "dictionaries", true);
if (err != SUCCESS)
    cancelInstall();

performInstall();
