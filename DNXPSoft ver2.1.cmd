@Echo off
setlocal enableextensions enabledelayedexpansion
set bDebug=0
	cls
	echo Script DNXPScript [%~n0] created by Deen0X
	set myBAdmin=0
	call :isAdmin VarADM
	if %varADM%==0 (
		echo Re-Running this script using admin privileges...
		echo "%~0" "%~1" "%~2">%temp%\DNXMainTemp.cmd
		set myPS=powershell Start-Process powershell -Verb "runAs %temp%\DNXMainTemp.cmd"
		!myPS!
		goto :ToEnd2
	)
rem ========================= PREINIT VARS {
	if not defined GlobalTimeoutAction set GlobalTimeoutAction=5
	if not defined GlobalTimeoutActionShort set GlobalTimeoutActionShort=2
rem ========================= PREINIT VARS }
	call :InitScript %0 %1 %2
	call :checkResources
	echo DNXScript by Deen0X
	Title DNXScript [%~n0]
	call :REGDNXItemFile
	set myScriptFilePath=%~0
	call :AddStartMenuEntries
rem	set BaseDirPROC=%~1
	
		
	if "_%~1"=="_" (
		set BaseDirPROC=!ScriptFilePath!
	) else (
		call :IsFile "%~1" rcFile
		if "_%rcFile%"=="_DIR" (
			call :checkDIRF "%~1" BaseDirPROC
		) else (
			call :checkDIRF "%~dp1" BaseDirPROC
		)
	)
	echo.
	echo General Options (edit this script for change it, on INITSCRIPT routine):
	echo ________________________________________________________________________
	echo [%bQuickSC%] Generate Quick Script  [%bAutoReg%] Auto Registry Contextual Entries
	echo [%bReportG%] General Report         [%bReportD%] Detailed Report
	echo [%bFixOldV%] Fix old version        [%bAutoDRI%] Auto Download Icon Resources
	echo.
	echo General Info for excecution:______________________________
	echo [%bScriptDir%] Is running on Script Directory
	echo     CallMode            [%CallMode%]
	echo     BaseDirPROC         [!BaseDirPROC!]
	echo     ScriptFilePath      [!ScriptFilePath!]
	echo ___________________________________________________________
	
	if "_%CallMode%"=="_DIR" (
		call :PDIRECTORY "%ScriptFilePath%" "%~1"
	)
	if "_%CallMode%"=="_PARAM" (
		Goto :RunParam
	)
	
	if "_%CallMode%"=="_DNXItem" (
		echo var1=%1
		echo ______________________________ Processed Files
		call :write "PROCESSING FILE ["
		call :PFILE "%~1"
		echo.
		echo ______________________________ 
		echo.
		goto :ToEnd
	)
	if "_%CallMode%"=="_FILE" (
		call :GENFILE %1
		goto :ToEnd2
	)

	if "_%CallMode%"=="_NORMAL" (
		rem this is the default behavior of this script, if no parameters are informed
		rem will register the script for contextual entries
		rem will scan the script folder and subfolders for DNXItems and process them
		if "_%bAutoReg%"=="_X" (
			call :write "[Auto] Setting context menu items ["
			call :write "."
			call :write "F"
			call :REGDNXItemFile
			call :write "."
			call :write "A"
			call :CtxDNXAddItem
			call :write "."
			call :write "G"
			call :CtxDNXGenItem
			call :write ".]"
			echo.
			set "myMsg=Added context menu items for DNXPSoft Script"
			echo !myMsg!
		)
		call :PDIRECTORY "%ScriptFilePath%" "!ScriptFilePath!"
	)

Goto ToEnd

rem _________________________________________________________________ sub AddStartMenuEntries
:AddStartMenuEntries
	set mySCR=%myScriptFilePath%
	set mySCP=%~dp0
	set mySCD=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\_DNXScript\
	if not exist "%mySCD%" mkdir "%mySCD%"

	set myIcon=!mySCP!Icons\DNX_Register.ico
	if not exist "!myIcon!" set "myIcon="
	call :CreateShortCut "!mySCR!" "%mySCD%" "Register DNXScript" "/REGBOTH" "!myIcon!" ""

	set myIcon=!mySCP!Icons\DNX_Remove.ico
	if not exist "!myIcon!" set "myIcon="
	call :CreateShortCut "!mySCR!" "%mySCD%" "Remove DNXScript" "/DELBOTH" "!myIcon!" ""
(
	endlocal
	exit /b
)


rem ===================================================================================================================
rem ===================================================================================================================
rem ===================================================================================================================
rem _________________________________________________________________ Sub InitScript
:InitScript
rem setlocal enableextensions enabledelayedexpansion
rem ========================= INIT VARS {
rem User config
	set "NoCategory=__Uncategorized Items"
	rem Case Not Script Dir, maybe PARENTFOLDER or NOCATEGORY
	set CaseNotScriptDir=NOCATEGORY
	set bFixOldV=X
	set bAutoReg=X
	set bReportG=X
	set bReportD=X
	set bQuickSC=X
	set bAutoDRI=X
	set fReportN=DNXScript_Report
	set fQuickFN=DNXScript_Quick
rem =========================	
	set TokenP=/
	set ScriptFileFull=%~1
	set ScriptFileName=%~nx1
	set ScriptFilePath=%~dp1
	call :GetCallMode "%~2" CallMode
	call :strLen "%ScriptFilePath%" ScriptFilePathLen
	set /a xScriptFilePathLen=%ScriptFilePathLen%
	set bScriptDir=_
	set paramA=%%%
	set paramA=%paramA%1
rem ========================= INIT VARS }
	set aCATEGORY=__
	set aFOLD=__
	set xCheck=0
	if "_%CallMode%"=="_DIR" set /a xCheck+=1
	if "_%CallMode%"=="_DNXItem" set /a xCheck+=1
	if %xCheck% GTR 0 (
		rem Verify if the dir is part of script path
		set DirProcFull=%~2
		set DirProcName=%~nx2
		call :checkDIRF "%~2" DirProcPath
		call set tmpx=%%DirProcPath:~0,%xScriptFilePathLen%%%
		
		if "_!tmpx!"=="_%ScriptFilePath%" (
			set bScriptDir=X
		)
	)
	if "_%bReportG%"=="_X" (
		set xReportG=%ScriptFilePath%%fReportN%_GEN.txt
		echo DNXPSoft installation Summary [General]>"!xReportG!"
		echo _______________________________________>>"!xReportG!"
	) else (
		set xReportG=nul
	)
	if "_%bReportD%"=="_X" (
		set xReportD=%ScriptFilePath%%fReportN%_DET.txt
		echo DNXPSoft installation Summary [Detail]>"!xReportD!"
		echo ______________________________________>>"!xReportD!"
	) else (
		set xReportD=nul
	)
	if "_%bQuickSC%"=="_X" (
		set xQuickFN=%ScriptFilePath%%fQuickFN%.cmd
		echo @Echo Off>"!xQuickFN!"
		echo cd /d "%%~dp0">>"!xQuickFN!"
		echo echo DNXPSoft Quick Add Items Batch>>"!xQuickFN!"
		call :createFunctionVar
	) else (
		set xQuickFN=nul
	)

	if "_%CallMode%"=="_NORMAL" set bScriptDir=X

	if %bDebug%==2 (
		echo ==== Debug InitScript
		echo * ScriptFileFull          =%ScriptFileFull%
		echo * ScriptFileName          =%ScriptFileName%
		echo * ScriptFilePath          =%ScriptFilePath%
		echo * ScriptFilePathLen       =%ScriptFilePathLen%
		echo * tmpx                    =%tmpx%
		echo * xScriptFilePathLen      =%xScriptFilePathLen%
		echo * ScriptFilePath          =%ScriptFilePath%
		echo * bScriptDir              =%bScriptDir%
		echo * DirProcFull             =%DirProcFull%
		echo * DirProcName             =%DirProcName%
		echo * DirProcPath             =%DirProcPath%
		pause
	)
exit /b


rem ________________________________________________________________________ sub checkResources
:checkResources
	if not exist "%ScriptfilePath%Icons" (
		if "_%bAutoDRI%"=="_X" (
			echo The script will try to download icon resources from Github DNXScript project.
			timeout %GlobalTimeoutActionShort%
			mkdir "%ScriptfilePath%Icons"
		) else (
			goto :checkResourcesOut
		)
	)
	set myRes=DNXItem.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "Downloading %myRes%" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_AddItem.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_AddItemF.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_GenItem.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_Folder.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_Register.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"

	set myRes=DNX_Remove.ico
	Title %~n0 - Downloading resources [%myRes%]
	if not exist "%ScriptfilePath%Icons\%myRes%" bitsadmin.exe /transfer "DNXDownloading" "https://github.com/Deen0X/DNXPSoft/releases/download/Scripting/%myRes%" "%ScriptfilePath%Icons\%myRes%"
:checkResourcesOut
exit /b


rem _________________________________________________________________ sub ProcDIRECTORY
:PDIRECTORY
	set myScriptFilePath=%~1
	set BaseDirPROC=%~2
	call :checkDIRF "%BaseDirPROC%" BaseDirPROC
	if %bDebug%==3 (
		echo ==== Debug ProcDIRECTORY
		echo * myScriptFilePath    =%myScriptFilePath%
		echo * BaseDirPROC         =%BaseDirPROC%
	)
	set iFile=0

	call :getFolderName "%DNXItemFileFullPath%." FolderN
	echo Folder:%FolderN%>>!xReportG!
	echo ______________________________>>!xReportG!
	echo %FolderN%>>!xReportG!

	echo Folder:%FolderN%>>!xReportD!
	echo ______________________________>>!xReportD!
	echo %FolderN%>>!xReportD!

	echo ______________________________ Processed Files
	for /r "%BaseDirProc%." %%i in (*.DNXItem) do (
		set /a iFile+=1
		rem %%i
		if !iFile! LEQ 9 (
			set XXFILE=0!iFile!
		) else (
			set XXFILE=!iFile!
		)
		call :write "PROCESSING FILE [!XXFILE!]["
		call :PFILE "%%i" !XXFILE!
		echo.
	)
	echo ______________________________ 
	echo Total Files processed:!iFile!
	echo.
exit /b

rem _________________________________________________________________ sub PFILE
:PFILE 
setlocal enableextensions enabledelayedexpansion
	rem un fichero si es con path de script, tiene 3 componentes:
	rem    path script
	rem    path hasta aplicación (que no contiene la parte del script)
	rem    aplicación/fichero
	rem si no es parte de script, entonces tiene solo 2 componentes:
	rem    path del fichero
	rem    aplicación/fichero
	set DNXItemFile=%~1
	set DNXItemFileFullPath=%~dp1
	set /a xFLen=ScriptFilePathLen
    set /p myF=<"%DNXItemFile%"
	set bNew=0

	if "_%myF:~0,1%"=="_/" set bNew=1
	if "_%myF:~0,1%"=="_\" set bNew=1
	if "_%bFixOldV%" NEQ "_X" set bNew=1
	if %bNew%==0 (
		call :inStr "%myF%" "/" 0 posSlash
		call :inStr "%myF%" "\" 0 posBSlash
		if !posSlash! GTR !posBSlash! (
			set mychar=/
		) else (
			set mychar=\
		)
		set bnewChar=0
		call :sTrim "%myF%" myFxx
		set "myFxx=!mychar!!myFxx!"
		echo|set /P=!myFxx!>"%DNXItemFile%"
		call :write "X"
	) else (
		call :write "."
	)
	
	set /p myDNXIF=<"%DNXItemFile%"
	call :sSplitB "!myDNXIF!" destFile titleFile iconFile iconNumber arguments
	call :sTrim "!titleFile!" titleFile
	call :sTrim "!iconFile!" iconFile
	call :getCategoryAndSubPath "%DNXItemFileFullPath%" SUBFOLDER CATEGORY
	Title %~n0 - Processing {!CATEGORY!} !titleFile!
	
	if "_%bScriptDir%"=="_X" (
		rem Es parte del script path. Se debe sacar el path del script (que será el %CD%) y el subpath al fichero
		call :getCategoryAndSubPath "%DNXItemFileFullPath%" SUBFOLDER CATEGORY
		rem sDest sPath sTitle sArgs sIcon sINum
		set sDESTShortCut=%%USERPROFILE%%\AppData\Roaming\Microsoft\Windows\Start Menu\!CATEGORY!\
		set SC_FileFull=%ScriptFilePath%!SUBFOLDER!!destFile!
		call :write "."
	) else (
		rem No es parte, va por su cuenta (uncassified items)
		if "_%CaseNotScriptDir%"=="_NOCATEGORY" (
			set CATEGORY=%NoCategory%
			call :write "U"
		) else (
			call :getParentFolder "%DNXItemFile%" CATEGORY
			call :write "P"
		)
		set sDESTShortCut=%%USERPROFILE%%\AppData\Roaming\Microsoft\Windows\Start Menu\!CATEGORY!\
		set SC_FileFull=%DNXItemFileFullPath%!destFile!
		call :write "."
	)

	if "_!iconFile!" NEQ "_" (
		set SC_IconFile=%ScriptFilePath%!SUBFOLDER!!iconFile!
		set xICONFILE=%%CD%%\!SUBFOLDER!!iconFile!
		call :write "I"
	) else (
		set SC_IconFile=!SC_FileFull!
		set xICONFILE=%%CD%%\!SUBFOLDER!!destFile!
		call :write "."
	)
	call set xsDESTShortCut=!sDESTShortCut!
	call :write "."
	if not exist "!xsDESTShortCut!" (
		mkdir "!xsDESTShortCut!"
		call :write "D"
	) else (
		call :write "."
	)
	if %bDebug%==11 (
		echo * CATEGORY      ={!CATEGORY!}
		echo * destFile      ={!destFile!}
		echo * titleFile     ={!titleFile!}
		echo * iconFile      ={!iconFile!}
		echo * iconNumber    ={!iconNumber!}
		echo * arguments     ={!arguments!}
	)
	call :CreateShortCut "!SC_FileFull!" "!sDESTShortCut!" "!titleFile!" "!arguments!" "!SC_IconFile!" "!iconNumber!"
	
	set aCAT=%CATEGORY%
	if "_!aCATEGORY!" NEQ "_!CATEGORY!" (
		echo     [!CATEGORY!]>>!xReportG!
		echo     [!CATEGORY!]>>!xReportD!
		set aCAT=!CATEGORY!
	)
	if %iFile% LEQ 9 (
		set xIFILE=0%iFile%
	) else (
		set xIFILE=%iFile%
	)
	call :getParentFolder "%DNXItemFileFullPath%" FolderN

	set aFOLD=%aFOLDERN%
	if "_%aFOLDERN%" NEQ "_%FolderN%" (
		echo         %FolderN%>>!xReportG!
		echo         %FolderN%>>!xReportD!
		set aFOLD=%FolderN%
	)
	echo             %xIFILE% - !titleFile!>>!xReportD!
	echo echo Adding Item [%2] - {!CATEGORY!} !titleFile!>>"!xQuickFN!"
	echo if not exist "!sDESTShortCut!" mkdir "!sDESTShortCut!">>"!xQuickFN!"
	echo call :CreateShortCut "%%CD%%\!SUBFOLDER!!destFile!" "!sDESTShortCut!" "!titleFile!" "!arguments!" "!xICONFILE!" "!iconNumber!">>"!xQuickFN!"
	set mySubScript=%DNXItemFile%.cmd
	if exist "%mySubScript%" (
		start /WAIT cmd /C "%mySubScript%"
		echo start /WAIT cmd /C "%%CD%%\!SUBFOLDER!%~nx1.cmd">>"!xQuickFN!"
		call :write "S"
	) else (
		call :write "."
	)
	call :write "] "
	rem call :write "{!CATEGORY!}"
	call :write "{!CATEGORY!} - !titleFile!"

(
	endlocal
	set aCATEGORY=%aCAT%
	set aFOLDERN=%aFOLD%
	exit /b
)


rem _________________________________________________________________ sub getParentFolder
:getParentFolder
setlocal enableextensions enabledelayedexpansion
	SET CDIR=%~dp1
	SET _CDIR=%CDIR:~1,-1%
	for %%i in ("%_CDIR%") do SET ParentFolderName=%%~nxi
(
	endlocal
	set %2=%ParentFolderName%
	exit /b
)

rem _________________________________________________________________ Sub getFolderName
:getFolderName strPath [varRC]
setlocal enableextensions enabledelayedexpansion
rem echo var1=%1
for %%I in (%1) do set "xfolderName=%%~nxI"
rem echo __xfolderName__=%xfolderName%
endlocal & set "%2=%xfolderName%"
exit /b

rem _________________________________________________________________ sub sTrim
:sTrim
setlocal enableextensions enabledelayedexpansion
	set str=%~1&rem
	call :sTrimL "%str%" strRC
	call :sTrimR "%strRC%" strRC2
(
	endlocal
	set %2=%strRC2%
	exit /b
)


rem _________________________________________________________________ sub sTrimL
:sTrimL
setlocal enableextensions enabledelayedexpansion
	set str=%~1&rem
	for /l %%a in (1,1,31) do if "!str:~-1!"==" " set str=!str:~0,-1!
(
	endlocal
	set %2=%str%
	exit /b
)

rem _________________________________________________________________ sub sTrimR
:sTrimR
setlocal enableextensions enabledelayedexpansion
	set str=%~1&rem
	for /f "tokens=* delims= " %%a in ("%str%") do set str=%%a
(
	endlocal
	set %2=%str%
	exit /b
)

rem _________________________________________________________________ sub sSplit
:sSplit sVar sToken var1 var2 var3...
setlocal enableextensions enabledelayedexpansion
	set tVar=%~1
	set tToken=%~2
	set tMaxSplit=6
	if not defined tMaxSplit set tMaxSplit=9
	set iCount=0
	set iCountb=-1
	set lPos=-1
	call :strLen "%tToken%" tTokenLen
	call :inStr "%tVar%" "%tToken%" 0 lPos
	:loopsSplit
		set /a iCount+=1
		set /a iCountb+=1
		set sVar=%tVar:~0,!lPos!%
		set /a lPosb=!lPos!-1
		set /a lPosDif=!lPosb!+tTokenLen
		call set vVar=%%tVar:~0,!lPosb!%%
		call set tVar=%%tVar:~!lPosDif!,1000%%
		call :inStr "%tVar%" "%tToken%" 0 lPos
		if !iCount! GTR %tMaxSplit% (
			set tmp_!iCount!=%vVar%%tToken%%tVar%
			goto :loopsSplitExit
		) else (
			set tmp_!iCount!=%vVar%
		)
	
	if %bDebug%==10 (
		echo ==== Debug sSplit
			echo * iCount    =%iCount%
			echo * var1      =%~1
			echo * vVar      =%vVar%
			echo * tVar      =%tVar%
			echo * tmp_1     =%tmp_1%
			echo * tmp_2     =%tmp_2%
			echo * tmp_3     =%tmp_3%
			echo * tmp_4     =%tmp_4%
			echo * tmp_5     =%tmp_5%
			echo * tmp_6     =%tmp_6%
			echo * tmp_7     =%tmp_7%
			pause

	)
	if "_%tVar%" NEQ "_" goto :loopsSplit
	:loopsSplitExit
(
	endlocal
	if "_%3" NEQ "_" set %3=%tmp_1%
	if "_%4" NEQ "_" set %4=%tmp_2%
	if "_%5" NEQ "_" set %5=%tmp_3%
	if "_%6" NEQ "_" set %6=%tmp_4%
	if "_%7" NEQ "_" set %7=%tmp_5%
	if "_%8" NEQ "_" set %8=%tmp_6%
	if "_%9" NEQ "_" set %9=%tmp_7%
	exit /b
)

rem _________________________________________________________________ sub sSplitB
:sSplitB
rem take the first character on the input parameter and assign as splitter token
setlocal enableextensions enabledelayedexpansion
	set tVar=%~1
	set tToken=%tVar:~0,1%
	set tVar=%tVar:~1,1000%
	set tMaxSplit=7
	if not defined tMaxSplit set tMaxSplit=9
	set iCount=0
	set iCountb=-1
	set lPos=-1
	call :strLen "%tToken%" tTokenLen
	call :inStr "%tVar%" "%tToken%" tTokenLen lPos
	:loopsSplitB
		set /a iCount+=1
		set /a iCountb+=1
		set sVar=%tVar:~0,!lPos!%
		set /a lPosb=!lPos!-1
		set /a lPosDif=!lPosb!+tTokenLen
		call set vVar=%%tVar:~0,!lPosb!%%
		call set tVar=%%tVar:~!lPosDif!,1000%%
		if !iCount! GTR %tMaxSplit% (
			set tmp_!iCount!=%vVar%%tToken%%tVar%
			goto :loopsSplitExitB
		) else (
			set tmp_!iCount!=%vVar%
		)
	
		if %bDebug%==10 (
			echo ==== Debug sSplit
				echo * iCount    =%iCount%
				echo * var1      =%~1
				echo * vVar      =%vVar%
				echo * tVar      =%tVar%
				echo * lPos      =!lPos!
				echo * tmp_1     =%tmp_1%
				echo * tmp_2     =%tmp_2%
				echo * tmp_3     =%tmp_3%
				echo * tmp_4     =%tmp_4%
				echo * tmp_5     =%tmp_5%
				echo * tmp_6     =%tmp_6%
				echo * tmp_7     =%tmp_7%
				pause

		)
		call :inStr "%tVar%" "%tToken%" 0 lPos
	if !lPos! NEQ 0 goto :loopsSplitB
	:loopsSplitExitB
	if "_%tVar%" NEQ "" (
		set /a iCount+=1
		set tmp_!iCount!=%tVar%
	)
(
	endlocal
	if "_%2" NEQ "_" set %2=%tmp_1%
	if "_%3" NEQ "_" set %3=%tmp_2%
	if "_%4" NEQ "_" set %4=%tmp_3% 
	if "_%5" NEQ "_" set %5=%tmp_4%
	if "_%6" NEQ "_" set %6=%tmp_5%
	if "_%7" NEQ "_" set %7=%tmp_6%
	if "_%8" NEQ "_" set %8=%tmp_7%
	if "_%9" NEQ "_" set %9=%tmp_8%
	exit /b
)
rem _________________________________________________________________ sub getCategoryAndSubPath
:getCategoryAndSubPath
setlocal enableextensions enabledelayedexpansion
	set FolderBase=%~1
rem 	set /a xLen=%ScriptFilePathLen%+2
	set /a xLen=%ScriptFilePathLen%
	call set SubPath=%%FolderBase:~%xLen%,1000%%
	call :inStr "%SubPath%" "\" 0 xEndSP
	set /a xEndSP=%xEndSP%-1
	if "_%SubPath%"=="_" (
		if "_%CaseNotScriptDir%"=="_NOCATEGORY" (
			set sCategory=%NoCategory%
		) else (
			call :getFolderName "FolderBase% sCategory
		)
	) else (
		call set sCategory=%%SubPath:~0,%xEndSP%%%
	)
	if %bDebug%==8 (
		echo ==== Debug getCategoryAndSubPath
		echo * xEndSP            =%xEndSP%
		echo * sCategory         =%sCategory%
		echo * subpath           =%SubPath%
	)
(
	endlocal
	set "%2=%SubPath%"
	set "%3=%sCategory%"
exit /b
)
rem _________________________________________________________________ sub CreateShortCut
:CreateShortCut sDest sPath sTitle sArgs sIcon sINum
setlocal enableextensions enabledelayedexpansion
rem oLink.TargetPath
rem oLink.Arguments
rem oLink.Description
rem oLink.HotKey
rem oLink.IconLocation
rem oLink.WindowStyle
rem oLink.WorkingDirectory
rem oLink.Save
	set sDest=%~1
	set sPath=%~2
	set sTitle=%~3
	set sArgs=%~4
	set sIcon=%~5
	set sWork=%~dp1
	set SCRIPT="%TEMP%\DNSPScriptCreateSC-%RANDOM%%RANDOM%%RANDOM%%RANDOM%.vbs"

	call :checkDIRF "%sPath%" sPath

	if %bDebug%==4 (
		echo * sDest      =%sPath%
		echo * sPath      =%sPath%
		echo * sTitle     =%sTitle%
		echo * sArgs      =%sArgs%
		echo * sIcon      =%sIcon%
		echo * sWork      =%sWork%
		echo * SCRIPT     =%SCRIPT%
	)
	
rem Creating File	
	echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
	echo sLinkFile = "%sPath%%sTitle%.lnk" >> %SCRIPT%
	echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
	echo oLink.TargetPath = "%sDest%" >> %SCRIPT%
	echo oLink.Arguments = "%sArgs%" >> %SCRIPT%
	echo oLink.WorkingDirectory = "%sWork%" >> %SCRIPT%
	echo oLink.IconLocation = "%sIcon%" >> %SCRIPT%
	echo oLink.Save >> %SCRIPT%
	cscript /nologo %SCRIPT%
	del %SCRIPT%
(
endlocal
exit /b
)


rem ____________________________________________________________ sub inStr
:inStr strVar strF stAt [rtnVar]
rem example:
rem call :inStr %RootPath%New New 0 Var3
setlocal enabledelayedexpansion
	if %bDebug%==6 echo inStr [%1] [%2] [%3] [%4] [%5]
	rem @echo on 
	set str1=%~1
	set sstr=%~2
	set stAt=%3
	
rem	set /a stAt=%stAt%-1
	call :strlen "%str1%" len1
	call :strlen "%sstr%" len2
	set /a stop=len1-len2
	set fpos=0
	
	if %bDebug%==6 (
		echo ==== Debug inStr
		echo * str1          =%str1%
		echo * sstr          =%sstr%
		echo * stAt          =%stAt%
		echo * len1          =%len1%
		echo * len2          =%len2%
		echo * stop          =%stop%
	)
	
	if %stop% gtr 0 for /l %%i in (%stAt%,1,%stop%) do (
		if "!str1:~%%i,%len2%!"=="%sstr%" (
			set /a position=%%i+1
			goto ExitinStr1
		)
	)
:ExitinStr1
	if defined position (
		set fpos=%position%
	) else (
		set fpos=0
	)
(
	endlocal
	set %4=%fpos%
	exit /b
)

rem _________________________________________________________________ checkDIRF
:checkDIRF
setlocal enableextensions enabledelayedexpansion
	set mySV=%~1
	call :strLen "%mySV%" mySVLen
	rem start counting from zero
 	set /a mySVLen=%mySVLen%-1
	set mySVLen=%mySVLen%
	call set myLL=%%mySV:~%mySVLen%,1%%%
	if "_%myLL%" NEQ "_\" (
		set sRC=%mySV%\
	) else (
		set sRC=%mySV%
	)
(
	endlocal
	set %2=%sRC%
	exit /b
)

rem _________________________________________________________________ Sub RunParam
:RunParam
rem setlocal enableextensions enabledelayedexpansion
	set param=%~1
	if %bDebug%==1 (
		echo ==== Debug RunParam
		echo * var1=%~1
		echo * TokenP=%TokenP%
	)
	if "_%param%"=="_%TokenP%REGADD" (
		call :CtxDNXAddItem
		set "myMsg=Added context menu item for process folder containing (.DNXItem) files"
		echo %myMsg%
		goto :ToEnd
	)
	if "_%param%"=="_%TokenP%REGGEN" (
		call :CtxDNXGenItem
		set "myMsg=Added context menu item for generating (.DNXItem) files"
		echo !myMsg!
		goto :ToEnd
	)
	if "_%param%"=="_%TokenP%DELADD" (
		call :RemoveCtxDNXAddItem
		set "myMsg=Removed context menu item for process folder containing (.DNXItem) files"
		echo !myMsg!
		goto :ToEnd
	)
	if "_%param%"=="_%TokenP%DELGEN" (
		call :RemoveCtxDNXGenItem
		set "myMsg=Removed context menu item for generating (.DNXItem) files"
		echo !myMsg!
		goto :ToEnd
	)
	if "_%param%"=="_%TokenP%REGBOTH" (
		call :CtxDNXAddItem
		call :CtxDNXGenItem
		set "myMsg=Added context menu items for DNXPSoft Script"
		echo !myMsg!
		goto :ToEnd
	) 
	if "_%param%"=="_%TokenP%DELBOTH" (
		call :RemoveCtxDNXAddItem
		call :RemoveCtxDNXGenItem
		set "myMsg=Removed context menu items for DNXPSoft Script"
		echo !myMsg!
		goto :ToEnd
	)
	if "_%param%"=="_%TokenP%PROCDIR" (
		echo process directory indicated [contextual menu]
rem 		echo param2v2=%2
rem 		echo param2v21=%~dp2
			call :PDIRECTORY "%ScriptFilePath%" "%~dp2"
		goto :ToEnd
	)
rem	if "_%param%"=="_%TokenP%GENFILE" (
rem	rem generate file for selected file
rem	echo var2=%2
rem	)
	rem not recognized parameter
	echo Help for DNXPScript
	echo usage: %~nx0 [PARAMETER][File]
	echo this script only accept a single parameter, except for CRAETEITEM that requires a second parameter [File].
	echo   [/REGADD]         - Register contextual menu for process current directory.
	echo   [/REGGEN]         - Register contextual menu for quick generation of .DNXItem file.
	echo   [/REGBOTH]        - Register both previous contextual menu entries.
	echo   [/DELADD]         - Delete contextual menu for process current directory.
	echo   [/DELREG]         - Delete contextual menu for quick generation of .DNXItem file.
	echo   [/DELBOTH]        - Delete both previous contextual menu entries.
	echo   [/CREATEITEM]     - Create a new item from the file
	echo   [/GENFILE] [File] - Generate .DNXItem for [File]
	echo   [Directory]       - Process directory.
	echo   [.DNXItem]        - Proces .DNXItem file.
	echo.
	echo contextual entries launch this script with [Directory], [.DNXItem file] or [/CREATEITEM File] options as parameters.
	echo.
rem endlocal
rem exit /b
goto :ToEnd


rem _________________________________________________________________ sub GenFile
:GenFile
setlocal enableextensions enabledelayedexpansion
	if %bDebug%==9 (
		echo Debug ==== GenFile
		echo var1             =%1
		echo var1dp           =%~dp1
		echo var1nx           =%~nx1
	)
		set "myFile=%~dp1_%~nx1.DNXItem"
		echo.
		echo Generated and Editing file: 
		echo [!myFile!]
		echo _________________________________
		echo Help for editing this file
		echo.
		echo The file structure is:
		echo [@][DESTFILE][@][TITLE][@][ICONFILE][@][ICONNUMBER][@][ARGUMENTS]
		echo.
		echo [@]           = Token Character (*)
		echo [DESTFILE]    = File destination of the Shortcut (*)
		echo [TITLE]       = Title for the Shortcut
		echo [ICONFILE]    = Alternative Icon (if not supplied, then will use default)
		echo                 Can be: .exe, .dll, .ico and must be on the same directory
		echo                 as [DESTFILE]
		echo [ICONNUMBER]  = Icon number (if there is more than 1 icon on ICONFILE
		echo [ARGUMENTS]   = Arguments used by DESTFILE
		echo (*) = Required Fields
		echo.
		echo NOTE: The First character will be the token for split the info of the file
		echo This character can be anything that will not be used on the values of each field
		echo for example: / \ - : ; _ 
		echo Take note that this character cannot be any special character used on batch file.
		echo.
		echo examples:
		echo /chrome.exe/Google Chrome Browser
		echo       for this case, the token of the file will be the character :[/]
		echo       this will create a shortcut for [Chrome.exe], with [Google Chrome Browser] as title,
		echo       using default Chrome.exe icon
		echo.
		echo -notepad.exe-Windows Notepad-customicons.dll-3-C:\debug.log
		echo       for this case, the token of the file will be the character :[-]
		echo       this will create a shortcut for [notepad.exe], with [Windows Notepad] as title, using
		echo       the library [customicons.dll] and the icon number [3], and passing the parameter
		echo       [C:\debug.log]to the program.
		echo.
		echo \%~nx1\%~n1
		echo       for this case, the token of the file will be the character :[\]
		echo       this will create a basic structure using [%~nx1] as dest file and
		echo       [%~n1] as title for this file.
		echo.
		echo|set /P="\%~nx1\%~n1">"!myFile!"
		call "notepad.exe" "!myFile!"
(
	endlocal
	exit /b
)

rem _________________________________________________________________ Sub GetCallMode
:GetCallMode
setlocal enableextensions enabledelayedexpansion

	set param1=%~1

	if "_%param1%" NEQ "_" (
		set paraFC=%param1:~0,1%
	)

	if %bDebug%==1 (
		echo * param1	=%param1%
		echo * paraFC	=%paraFC%
		echo * TokenP	=%TokenP%
	)
	if "_%paraFC%"=="_%TokenP%" (
		set CallType=PARAM
	) else (
		if "_%param1%"=="_" (
			set CallType=NORMAL
		) else (
			call :IsFile "%param1%" CallType
			if "_%~x1"=="_.DNXItem" (
				set CallType=DNXItem
			)
		)
	)
(
	endlocal
	set %2=%CallType%
	exit /b
)

rem _________________________________________________________________ Sub IsFile
:IsFile
SETLOCAL ENABLEEXTENSIONS
	set ATTR=%~a1
	set DIRATTR=%ATTR:~0,1%

	if /I "%DIRATTR%"=="d" (
		set sRC=DIR
	) else (
		set sRC=FILE
	)
(
	endlocal
	set %2=%sRC%
	exit /b
)

rem _________________________________________________________________ Sub strLen
:strLen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    rem (set^ xtmp="!%~1!")
	set "xtmp=%~1"
rem 	echo var1=%1
rem 	echo var1b=%~1
rem 	echo xtmp=!xtmp!
rem 	pause
    if defined xtmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!xtmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "xtmp=!xtmp:~%%P!"
            )
        )
    ) ELSE (
        set len=0
    )
)
( 
    endlocal
    set "%~2=%len%"
    exit /b
)

rem _________________________________________________________________ Sub REGDNXItemFile
:REGDNXItemFileA
 	ftype DNXItem="%ScriptFileFull%" "%paramA%"
 	assoc .DNXItem=DNXItem
	set xmyIcon=%ScriptFilePath%Icons\DNXItem.ico
	set myIcon=%xmyIcon%
	if NOT exist "%xmyIcon%" (
		echo asignando icono por defecto
		set myIcon=%SystemRoot%\System32\SHELL32.dll,68
	)
	rem set myIcon=%SystemRoot%\System32\SHELL32.dll,68
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\Open\command" /t REG_SZ /d "notepad ""%paramA%""" /f  >nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\DefaultIcon" /t REG_SZ /d "%myIcon%" /f  >nul
	
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\Open\command" /t REG_SZ /d "notepad ""%paramA%""" /f
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\DefaultIcon" /t REG_SZ /d "%myIcon%" /f
	
rem	echo REGDNXItemFile
rem 	echo ScriptFileFull=%ScriptFileFull%
rem	echo xmyIcon=%xmyIcon%_
rem	echo  myIcon=%myIcon%_
rem 	echo paramA=%paramA%_
rem	echo revisar aqui
rem	pause
exit /b

:REGDNXItemFile
rem ____________________________________________________________ FILETYPE
	set xmyIcon=%ScriptFilePath%Icons\DNXItem.ico
	if not exist "%xmyIcon%" (
		set myIcon=%SystemRoot%\System32\SHELL32.dll,1
rem		call :write "Register"
	) else (
		set myIcon=%xmyIcon%
rem		call :write "C"
	)
	rem reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\Open\command" /t REG_SZ /d "notepad ""%paramA%""" /f>nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\DefaultIcon" /t REG_SZ /d "%myIcon%" /f>nul
exit /b

rem _________________________________________________________________ Sub CtxDNXAddItem
:CtxDNXAddItem
rem formula	set "myPar=\"algo\"" "\"algo2\""
	rem icon 1=file
	rem icon 76=runwindow
	rem icon 212=folder
	rem icon 216=editar
	ftype DNXItem="%ScriptFileFull%" "%paramA%">nul
	assoc .DNXItem=DNXItem>nul

	rem ____________________________________________________________ PROCESS DNXITEM (Single)
	set xmyIcon=%ScriptFilePath%Icons\DNX_AddItem.ico>nul
	if not exist "%xmyIcon%" (
		set myIcon=%SystemRoot%\System32\SHELL32.dll,76
rem		call :write "D"
	) else (
		set myIcon=%xmyIcon%
rem		call :write "C"
	)
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItem" /t REG_SZ /d "Process DNXItem" /f>nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItem" /v "Icon" /t REG_SZ /d "%myIcon%" /f>nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItem\command" /t REG_SZ /d "%ScriptFileFull% ""%paramA%""" /f>nul

	rem ____________________________________________________________ PROCESS DNXITEMS (Folder)
	set xmyIcon=%ScriptFilePath%Icons\DNX_AddItemF.ico
	if not exist "%xmyIcon%" (
		set myIcon=%SystemRoot%\System32\SHELL32.dll,212
rem		call :write "D"
	) else (
		set myIcon=%xmyIcon%
rem		call :write "C"
	)
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItems" /t REG_SZ /d "Process all DNXItems on this directory" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItems" /v "Icon" /t REG_SZ /d "%myIcon%" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItems\command" /t REG_SZ /d "%ScriptFileFull% %TokenP%PROCDIR ""%paramA%""" /f >nul
exit /b

rem _________________________________________________________________ Sub CtxDNXGenItem
:CtxDNXGenItem
	set xmyIcon=%ScriptFilePath%Icons\DNX_GenItem.ico
	set myIcon=%xmyIcon%
	if not exist "%xmyIcon%" (
		set myIcon=%SystemRoot%\System32\SHELL32.dll,216
rem		call :write "D"
	) else (
		set myIcon=%xmyIcon%
rem		call :write "C"
	)
	reg ADD "HKEY_CLASSES_ROOT\*\shell\DNXGenItem" /t REG_SZ /d "Generate DNXItem for selected file" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\*\shell\DNXGenItem" /v Icon /t REG_SZ /d "%myIcon%" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\*\shell\DNXGenItem\command" /t REG_SZ /d """"%ScriptFileFull%""" """%paramA%"""" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\lnkfile\shell\DNXGenItem" /t REG_SZ /d "Generate DNXItem for selected file" /f >nul

	reg ADD "HKEY_CLASSES_ROOT\lnkfile\shell\DNXGenItem" /v Icon /t REG_SZ /d "%myIcon%" /f >nul
	reg ADD "HKEY_CLASSES_ROOT\lnkfile\shell\DNXGenItem\command" /t REG_SZ /d """"%ScriptFileFull%""" """%paramA%"""" /f >nul
	rem reg ADD "HKEY_CLASSES_ROOT\InternetShortcut\shell\DNXGenItem" /t REG_SZ /d "Generate DNXItem for selected file" /f >nul
	rem reg ADD "HKEY_CLASSES_ROOT\InternetShortcut\shell\DNXGenItem" /v Icon /t REG_SZ /d "%myIcon%" /f >nul
	rem reg ADD "HKEY_CLASSES_ROOT\InternetShortcut\shell\DNXGenItem\command" /t REG_SZ /d "%myCI% ""%paramA%""" /f >nul
exit /b

rem _________________________________________________________________ Sub RemoveCtxDNXAddItem
:RemoveCtxDNXAddItem
	reg DELETE "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItem" /f >nul
	reg DELETE "HKEY_CLASSES_ROOT\DNXItem\shell\DNXAddItems" /f >nul
exit /b

rem _________________________________________________________________ Sub RemoveCtxDNXGenItem
:RemoveCtxDNXGenItem
	reg DELETE "HKEY_CLASSES_ROOT\*\shell\DNXGenItem" /f >nul
	reg DELETE "HKEY_CLASSES_ROOT\lnkfile\shell\DNXGenItem" /f >nul
	rem reg DELETE "HKEY_CLASSES_ROOT\InternetShortcut\shell\DNXGenItem" /f >nul
exit /b

rem _________________________________________________________________ Sub isAdmin
:isAdmin [varRC]
setlocal disableDelayedExpansion
rem     call :write Administrative permissions required. Detecting permissions...  
    set myRC=0
    net session >nul 2>&1
    if %errorLevel% == 0 (
        rem echo Success: Administrative permissions confirmed.
        set myRC=1
    ) else (
        rem echo Failure: Current permissions inadequate.
		set myRC=0
    )
endlocal & set "%1=%myRC%"
exit /b

rem _________________________________________________________________ Write
:write strVar
setlocal disableDelayedExpansion
	::
	:: Write the literal string Str to stdout without a terminating
	:: carriage return or line feed. Enclosing quotes are stripped.
	::
	:: This routine works by calling :writeVar
	::
	set "strVar=%~1"
	call :writeVar strVar
endlocal
exit /b

rem _________________________________________________________________ WriteVar
:writeVar strVar
if not defined %~1 exit /b
setlocal enableDelayedExpansion
	::
	:: Writes the value of variable StrVar to stdout without a terminating
	:: carriage return or line feed.
	::
	:: The routine relies on variables defined by :writeInitialize. If the
	:: variables are not yet defined, then it calls :writeInitialize to
	:: temporarily define them. Performance can be improved by explicitly
	:: calling :writeInitialize once before the first call to :writeVar
	::
	if not defined $write.sub call :writeInitialize
	set $write.special=1
	if "!%~1:~0,1!" equ "^!" set "$write.special="
	for /f delims^=^ eol^= %%A in ("!%~1:~0,1!") do (
	  if "%%A" neq "=" if "!$write.problemChars:%%A=!" equ "!$write.problemChars!" set "$write.special="
	)
	if not defined $write.special (
	  <nul set /p "=!%~1!"
	  exit /b
	)
	>"%$write.temp%_1.txt" (echo !str!!$write.sub!)
	copy "%$write.temp%_1.txt" /a "%$write.temp%_2.txt" /b >nul
	type "%$write.temp%_2.txt"
	del "%$write.temp%_1.txt" "%$write.temp%_2.txt"
	set "str2=!str:*%$write.sub%=%$write.sub%!"
	if "!str2!" neq "!str!" <nul set /p "=!str2!"
endlocal
exit /b

rem _________________________________________________________________ WriteVar
:writeInitialize
	::
	:: Defines 3 variables needed by the :write and :writeVar routines
	::
	::   $write.temp - specifies a base path for temporary files
	::
	::   $write.sub  - contains the SUB character, also known as <CTRL-Z> or 0x1A
	::
	::   $write.problemChars - list of characters that cause problems for SET /P
	::      <carriageReturn> <formFeed> <space> <tab> <0xFF> <equal> <quote>
	::      Note that <lineFeed> and <equal> also causes problems, but are handled elsewhere
	::
	set "$write.temp=%temp%\writeTemp%random%"
	copy nul "%$write.temp%.txt" /a >nul
	for /f "usebackq" %%A in ("%$write.temp%.txt") do set "$write.sub=%%A"
	del "%$write.temp%.txt"
	for /f %%A in ('copy /z "%~f0" nul') do for /f %%B in ('cls') do (
	  set "$write.problemChars=%%A%%B    ""
	  REM the characters after %%B above should be <space> <tab> <0xFF>
	)
exit /b

rem _________________________________________________________________ sub createFunctionVar
:createFunctionVar
rem xQuickFN
set "AA=set GlobalTimeoutAction=0"
echo !AA!>>"!xQuickFN!"
set "AA=set GlobalTimeoutActionShort=0"
echo !AA!>>"!xQuickFN!"
echo goto :StartDNXScriptQuick>>"!xQuickFN!"
echo :CreateShortCut sDest sPath sTitle sArgs sIcon sINum>>"!xQuickFN!"
echo setlocal enableextensions enabledelayedexpansion>>"!xQuickFN!"
echo     set sDest=%%~1>>"!xQuickFN!"
echo     set sPath=%%~2>>"!xQuickFN!"
echo     set sTitle=%%~3>>"!xQuickFN!"
echo     set sArgs=%%~4>>"!xQuickFN!"
echo     set sIcon=%%~5>>"!xQuickFN!"
echo     set sWork=%%~dp1>>"!xQuickFN!"
echo     set SCRIPT="%%TEMP%%\DNSPScriptCreateSC-%RANDOM%%RANDOM%%RANDOM%%RANDOM%.vbs">>"!xQuickFN!"
echo     echo Set oWS = WScript.CreateObject("WScript.Shell") ^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo sLinkFile = "%%sPath%%%%sTitle%%.lnk" ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo Set oLink = oWS.CreateShortcut(sLinkFile) ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo oLink.TargetPath = "%%sDest%%" ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo oLink.Arguments = "%%sArgs%%" ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo oLink.WorkingDirectory = "%%sWork%%" ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo oLink.IconLocation = "%%sIcon%%" ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     echo oLink.Save ^>^> %%SCRIPT%%>>"!xQuickFN!"
echo     cscript /nologo %%SCRIPT%%>>"!xQuickFN!"
echo     del %%SCRIPT%%>>"!xQuickFN!"
echo endlocal>>"!xQuickFN!"
echo exit /b>>"!xQuickFN!"
echo rem ___________________________________________________________>>"!xQuickFN!"
echo :StartDNXScriptQuick>>"!xQuickFN!"

rem echo Rem This is a message inside the file text.txt >> text.txt
rem echo @echo off ^>^> text.bat >> text.txt
rem echo echo Adding the carrot sign cancels the sign out ^>^> text.bat >> text.txt
rem echo pause ^>^> text.bat >> text.txt
rem notepad "!xQuickFN!"
endlocal
exit /b

:ToEnd
echo pause>>"!xQuickFN!"
echo No olvides visitarnos en: 
echo Portable Master Race (ESP) https://t.me/gpdwinhispano
echo Deen0X's Blog: www.deen0x.com
echo Zalu2^^!
echo Have a nice day!
pause
:ToEnd2
