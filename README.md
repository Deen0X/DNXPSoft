# DNXPSoft
Script for adding items to start menu, from portabilized applications

This utility is developoed in standard windows batch file, and their pourpouse is to help users when must reset their windows installation, and re-install all their software again

Most of the software we install on machines, can be executed directly without installing again, so the main point of this script is tho change the usual installation path on "C:\Program Files\etc..." (usually), and replace by a custom folder on another drive (D: as example)
so, when you must reset your windows installation (restore windows or even a fresh installa from scratch), this process usually format your C: drive, but not the rest of drives you have on your machine, so the directory with the installed applications remains and simply you must create the proper entries for each item on the windows start menu, for use the programs as usual, but without installing it.

I call this process the "portabilization" of programs, and this is the main goal of this script. Take note that not all programs can be "portabilized", because some needs to modify your windows system files, add new components to windows, services, etc. These apps cannot be included to our portabilized applications directory and we must install again on the fresh windows installation, but the rest, near the 90% of the programs we use daily, can be portabilized, and this mean a lot of time we can gain after fresh install of Wwindows.

There is another advantage using portabilized applications instead of standard setup procedure. When you use installers, many of them add components that maybe we don´t want. Some services, registry entries, system components, etc that increase our windows, and become slow with time.
Using portaibilized applications, most of these components will not be installed, and this means Windows will be more clean in general. Of course, some of these components may be needed in some circumstances, so if the case, you must consider if the application you want to run really can run as portable, or you prefer to install using a standard setup.

Example. Most of game launchers (steam, epic, amazon, etc) install helpers on the system, to help quick webpages, or control new installations/modifcations on disc, etc... and these kind of components are not really necessary for most users, so you can portabilized and run the program you want without any "extra" on background.
