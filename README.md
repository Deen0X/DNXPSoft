# DNXPSoft
Script for adding items to start menu, from portabilized applications

# Overview:
Each time i need to re-install windows (or do a Windows Reset), the process that take more time to get windows ready, is to reinstall all software i need.
One solution is to re-use the same installed directories i installed on previous windows installation, because most of the software can run without problems directly, without need to re-install using standard installer, just run the "EXE" or similar associated program.

With this simple "trick" i can save a lot of time downloading and installing software on my pc, because is "installed" previously, but now i have a problem, search for each program and add to Windows Start Menu, to use it as standard application.

So, i decided to create a script that scan a directory and automatic add specific entries to Windows Start Menu, helping to do a quick setup of the machine, saving a lot of time.

# HOW IT WORK?
For get this to work i must stabish few things previously.
1- I created a folder on different drive than C: (where usually Windows is installed), and copy the folder of installed programs here. In my case i created the folder "D:\DNXPSoft_Prod", from now i will call this as my BASE Folder.
2- The script MUST BE on the BASE folder.
3- I organize my software in different categories, to maintain some organization on windows start menu. I don´t like the way that windows adds software, based on alphabetical order of the name of each program, so i prefer to create my own organization and for this i created some basic structure on my BASE folder, something like this:

![image](https://user-images.githubusercontent.com/3720302/137115547-255ce77b-72a5-4887-8c75-d4186d9e675c.png)

NOTE: I used the character underline "_" to ensure that the category name will be on the first places on Windows Start Menu. Is not required to use this character.

4- Each program that i copy will be inside of any of these Categories.

![image](https://user-images.githubusercontent.com/3720302/137116100-488d8342-0648-47a7-b74e-6e209449fe3e.png)

On this example, i expanded my "_Chat Software" and "_Game Launchers and Stores", and there are some of the programs inside these categories.

5- I need a way to give info to the script, to get a program/file to be added to Windows Start Menu as entry. For solve this, i will create a file for each program/file i want to add to Windows Start Menu.
This file will have the specific extension .DNXItem, and will have basic info about the program i want to add to Windows Start Menu. This file may have any name, but need the specific extension .DNXItem.
For convenience, i suggest to name this file the same as the program/file you want to add to Windows Start Menu. In my case, i add an underline "_" as prefix, for easy search inside directories.
So, for example, if i want to add Telegram as item on Windows Start Menu, i will create a file called "_telegram.exe.DNXItem"

![image](https://user-images.githubusercontent.com/3720302/137118031-c827703f-0556-4f3c-9f81-c6c730dbe544.png)

NOTE: The icon is assigned later, with the script itself.

Finally, the content of this file is the following:

![image](https://user-images.githubusercontent.com/3720302/137119732-3b188a3b-30fb-4a94-a802-968a2dfd1acb.png)

The file structure is:
[@][DESTFILE][@][TITLE][@][ICONFILE][@][ICONNUMBER][@][ARGUMENTS]

[@]           = Token Character that will be used for split the info of the file into fields (*)
[DESTFILE]    = File destination of the Shortcut (*)
[TITLE]       = Title for the Shortcut
[ICONFILE]    = Alternative Icon (if not supplied, then will use default)
			          Can be: .exe, .dll, .ico and must be on the same directory
			          as [DESTFILE]
[ICONNUMBER]  = Icon number (if there is more than 1 icon on ICONFILE
[ARGUMENTS]   = Arguments used by DESTFILE
(*) = Required Fields

NOTE: The First character will be the token for split the info of the file
This character can be anything that will not be used on the values of each field
for example: / \ - : ; _ 
Take note that this character cannot be any special character used on batch file.

on the sample.
/Telegram.exe/Telegram Desktop/Telegram.exe/0/-startintray

/                 = Token Character
Telegram.exe      = Program
Telegram Desktop  = Title on the Windows Start Menu
Telegram.exe      = File to extract icon
0                 = Icon number
-startintray      = Argument to launch the program

When the script run, will add this entry to Windows Start Menu with the parameters indicated on this file

![image](https://user-images.githubusercontent.com/3720302/137120665-abb17e8f-05d4-49dc-939e-291afefab6cb.png)

NOTE: The file "_Telegram.exe", only needs 3 parameters to run, the first character (Token character), the program/File and the title
![image](https://user-images.githubusercontent.com/3720302/137118525-e7b89b33-1a4a-4bc2-a091-b8506e57bea1.png)

The icon file and number will automatically taken by the program or file default icon. The arguments will be empty. In the case of the example, the program "Telegram" will run minimized on systray when launched, due the argument "-startintray" is passed.


# Automated Generation of .DNXItem files

The script itself can help with few tasks too. The first one, is to create a new .DNXItem file, taking a program or file as base for create it.

You can run the script, giving any file as input, and will create the corresponding file with basic information. The script take the file input, get their name, and create a text file with "_" and the file intput name+extension and add .DNXItem extension, then adds a slash "/" as token, insert the filename and extension of input file, and as title use the filename (without extension), finally open notepad and show the file created to allow to you to edit it (or simply close it)

The screen of the script shows a basic help for editing this file.

![image](https://user-images.githubusercontent.com/3720302/137123663-eae7019c-4060-4a92-b4b8-94e38a88a07f.png)

on this example i start the script with the program nircmd.exe as parameter (with full path), and the script opens and show the _nircmd.exe.DNXItem file on notepad.

# Windows Explorer Contextual Menu for generating .DNXItem files

When you run the Script, there are an internal option (that come enabled by default) that adds entries to windows Explorer conextual menu to generate .DNXItem files.

![image](https://user-images.githubusercontent.com/3720302/137124917-4dd30066-21d2-4901-bb6b-096d7dca21a3.png)

Now you can select any file on explorer, and with right click can generate quickly the .DNXItem for this file.
The entry simply runs the script, and give the file selected as parameter, and runs in the same way as previous point.


# Processing DNXItem files to add entries on Windows Start Menu

The standard way is to run directly the script from the BASE folder. This will scann all subfolders looking for .DNXItem files and process them.

![image](https://user-images.githubusercontent.com/3720302/137141925-856c9bc1-6a6f-480a-b284-f2f86311c756.png)

Running the Main script from BASE folder

![image](https://user-images.githubusercontent.com/3720302/137142977-084f6f6e-9c34-4c29-9d81-6e906109ef00.png)

Main Script finished.

The direct way is starting the script, passing a .DNXItem file as parameter (with full path). This way, the script open it, and process adding to the corresponding category on Windows Start Menu.

There is another way, is passing a folder as parameter to the Script. This will scan the indicated folder, looking for ".DNXItem" files on it and subfolders and process them.

# Windows Explorer Contextual Menu for Process DNXItem files

On Windows Explorer, there are two entries for processing DNXItem files.

![image](https://user-images.githubusercontent.com/3720302/137126578-6d322d7f-bf50-4591-954e-9cd58eef292a.png)

The "Process DNXItem" option, will process the selected ".DNXItem" file, adding the entry on Windows Start Menu
The "Process all DNXItems on this directory" will process all the DNXIte files contained on the current directory, and subdirectories.

# Run subscripts for initialize aplications

If the main Script found a file .DNXItem.cmd, will launch it as standard cmd file.
This may be interesting for setup some things that requires the program to run.

Example. I have a small script for windirstat that adds contextual entries for folders and drives on Windows Explorer, to launch directly the program on these selections.

![image](https://user-images.githubusercontent.com/3720302/137140769-a0c48091-581c-4036-83dd-2526631cc23d.png)

The program process the _windirstat.exe.DNXItem.

The "S" on the progress bar indicates that there is a Subscript associated and was called.

![image](https://user-images.githubusercontent.com/3720302/137139675-c618135d-1a42-4e06-9088-cc4dc1687e94.png)

The subscript _windirstat.exe.DNXItem.cmd launched.

![image](https://user-images.githubusercontent.com/3720302/137140506-2972e733-c71e-4d04-9ba1-bc08fa14dd2d.png)

This is the content of the subscript

Note: there are two global variables defined on main Script
__GlobalTimeoutActionShort__ with default value is 2
__GlobalTimeoutAction__ with default value is 5

These variables may be used to show some info on screen, with some delay before continue.
I prefer to use the command "timeout" instead of "pause", because "pause" need an interact with user to continue.

# Reports

The script can generate two kind of reports, for processed .DNXItems

General Report: Will include the Category and the folder name of the program.

![image](https://user-images.githubusercontent.com/3720302/137128143-c8971346-16db-49b9-8633-9aaa42b30d9a.png)

Example of general report generated by the script

Detailed Report: similar to General, but including each item added by each program

![image](https://user-images.githubusercontent.com/3720302/137128292-417bba87-42a1-4c70-b7cf-0a2e4f8827c8.png)

Example of detailed report generated by the script


These reports may help to control what software we have installed on the system, when reinstall windows.


# Generating Subscript

The Subscript is a second script generated by the main script.
When you run the main script on BASE Folder, this may take some time on process each item, reading files, extracting fileds, generating corresponding entries to be processed, etc, etc.
The script can generate a subscript that include all these processed info, and may be useful to quick reinstall windows, running directly this subscript instead of the main.

To explain better this subscript, i have many machines on my local lan. one of them i used to update and maintain the main BASE folder. In my case, i shared my BASE folder to the other devices on my lan.

Usually, i test and add more portable applications to my BASE folder, and run the script to ensure is working correctly.

On the other machines, simply run the SubScript generated on my machine, and they update quickly with my lasts changes, without need to process again all the folder sctructure, that currently have more than 150 apps on my case. 

Another way to update this subscript is... if you plan to reset windows and start from fresh install, before doing it, run the script on the BASE folder, and when finish, reset windows, then simply run the subscript generated to quick add all entries to Windows Start Menu

![image](https://user-images.githubusercontent.com/3720302/137129948-3229b10a-45df-4847-9477-3888c77c9cf4.png)

Example of running the Subscript generated by the main Script.

Another use of this script (and is the main reason i generated it), is to quick setup a Windows Sandbox Environment, where each time a sandbox is launched there is no software installed, so i quickly can add all my software to the virtualized environment in less than a minute.

In any case, if you're not sure how to use this subscript, simply don´t mind on it. Use the main script and you will get the same result.


# General note and summary about this Script
This utility is developed in standard windows batch file, and their pourpouse is to help users when must reset their windows installation, and re-install all their software again

The script will work itself, but for some cosmetics, need few icons to be on the BASE folder\Icons folder
If there is not exist this Folder or icons, the script itself will try to create the folder and download from Github repository.
If cannot be downloaded (example, if you're runnning from read only directory), the script will use standard icons from Windows\System2\Shell32.dll library.

When you run the first time the script, with default options on it (you can open the script and check the :InitScript section for more info), the script will:
- Generate a new Windows Menu entry called "_DNXScript", with some options on it to adds or remove contextual entries on Windows Explorer.
- Run subscript related to .DNXItem that can custom the setup of the portable aplication (creating folders, adding some registry entries, etc)
- Register file extension .DNXItem
- Assign an Icon to .DNXItem extension
- Add entry on Windows Explorer Contextual Menu: "Generate DNXItem for selected file"
- Add entry on Windows Explorer Contextual Menu: "Process DNXItem"
- Add entry on Windows Explorer Contextual Menu: "Process all DNXItems on this directory"
- Generate General Report
- Generate Detailed Report
- Generate Subscript to quick add items to Windows Start Menu


# Q&A

- Q:Why i did not use common portable apps suites i can found on internet?
- A:I used for long time some of these solutions (PortableApps.com, ThinInstall, VMWare Virtual Apps, etc), but most of these solutions have some problems when running.
Most of these Virtualized apps, requires to generate virtual environment and sometimes get troubles interact with other native apps on windows, or cannot be updated because they are running on compressed packages that cannot be changed, or simply use a lot more resources to run than the app itself.
Some portable apps i downloaded, i found virus/malwares that only are discover when the app is running (when the cointained files are uncompress/unpack)
Many portable apps are false positive on virus suites. The problem is when youre running these programs on controlled environments where any of these false positive are warning to admin, and this is not a desidered scenario to run.

For these reasons i prefer to avoid the use of portable apps found on the web.

- Q:How i can create my own "portable" apps?
- A: you can use two computers, one of them you can install a program, then copy the installed folder and run on the another PC. If run without problems, then you have a portable apps. if not, then delete.
Another way can be using a Windows Sandbox environment. This feature only can be activated on Windows 10 Pro or above. install the application on the Sandbox, then copy the installed app to the real machine and test.
Another way may be, if you only have a single computer, then install some program using installer, then copy the installed Folder to some place, then uninstall the application. Ainally, test the application you copied the folder (after uninstalled it). if run, then is portable.

- Q: When i install a program, this requires a serial key, or account. this info is saved on the "portable" application?
- A: usually this info is not on the installed folder. Maybe on the windows registry, etc. The process of adding the entry of the program to windows start menu, is similar to install the application, this means, you must provide the serial or account when the program ask (when you run it)




Hope you found useful this script

Deen0X
