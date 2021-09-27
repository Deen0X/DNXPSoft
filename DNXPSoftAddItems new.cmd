@Echo off
set bDebug=2
cls
setlocal enableextensions enabledelayedexpansion
echo Script created by Deen0X
if not defined GlobalTimeoutAction set GlobalTimeoutAction=5
if not defined GlobalTimeoutActionShort set GlobalTimeoutActionShort=2
set myBAdmin=0
call :isAdmin VarADM
if %varADM%==0 (
rem powershell Start-Process powershell -Verb "runAs %temp%\dnxtmpcmd.cmd"
echo Re-Running this script using admin privileges...
rem set myPS=powershell Start-Process powershell -Verb "runAs ""%~0"" ""%~1"""
echo "%~0" "%~1">%temp%\DNXMainTemp.cmd
set myPS=powershell Start-Process powershell -Verb "runAs %temp%\DNXMainTemp.cmd"
!myPS!
goto :ToEnd2
)
setlocal enableextensions enabledelayedexpansion
set "mypref=%~1"
cd /d "%~dp0"
pushd "%~dp0"
set myD=%~d0
set myD=%myD:~0,1%
set dPrefix=
set dSufix= [%myD%]
set "NOCATEGORYLABEL=__Uncategorized Items"
set bQuickF=X
set bReporG=X
set bReporD=X

rem ______________________________________Call Mode
if "_%mypref%"=="_" (
    set "mypref=%~dp0"
    set mypref=!mypref:~0,-1!
    set "myprefx=!mypref!"
    echo Main Call Mode.
	echo _______________________________
) else (
	set firstL=%mypref:~0,1%
	if "_!firstL!"=="_/" (
		goto ProcessParameters
    ) else (
        echo Context Menu Call Mode
	echo _______________________________
    )
)
call :getCurrentPathName %mypref%\ myCFolder
set QUICKFile="%~dp0DNXPSoft_Quick [%COMPUTERNAME%][%myD%][%myCFolder%].cmd"
call :initQuickDNXPS


set iCount=0
set iCountT=0
set iPathLen=0
call :strLen mypref iPathLen
rem iPathRSTart se le suman 2, por que es el largo del path actual, mas 2 posiciones para saltarnos el \
set /a iPathRStart=%iPathLen%+2
rem ____________________________________________________________ Count how much items are
echo list items>listitems.txt
for /r "%mypref%\." %%a in (*.DNXItem) do (
    set /a iCountT=!iCountT!+1
    echo [!iCountT!] %%a >>listitems.txt
    title DNXPSoft Found items: [!iCountT!]
    )


echo     Directory To Process ="%mypref%"
echo [%bQuickF%] QuickFile Generated  =%QUICKFile%
echo [%bReporG%] Report File General  = 
echo [%bReporD%] Report File Detailed = 
echo     Total Files Found    =!iCountT!

echo _______________________________ Entries Processed List:
title DNXPSoft Total Items Found:[0/!iCountT!]
rem ============================================================ MAIN LOOP
for /r "%mypref%\." %%a in (*.DNXItem) do (
    rem Set current vars
    if !bDebug!==1 (
        echo.
        echo MAINLOOP START _-_-_-_====_-_-_-_====_-_-_-_====_-_-_-_====_-_-_-_
    )

    set myF=%%a
    set myFx=%%~nxa
    set /p myFC=<"%%a"
    set /a iCount=!iCount!+1
    set myCPath=%%~dpa
    call :myTitle
    call :subStr0 "!myCPath!" !iPathRSTart! 1000 sRPath
    if "_!sRPath!"=="_" (
        set "CSECTION="
        set CSECTIONx=0
        set "CATEGORY="
    ) else (
        call :inStr "!sRPath!" \ 1 CSECTIONx
        set /a CSECTIONx=!CSECTIONx!-2
        call :substr0 "!sRPath!" 1 !CSECTIONx! CATEGORY
    )
    if "_!CATEGORY!"=="_" set CATEGORY=!NOCATEGORYLABEL!
    set "CFICON="
    set "IconNumber="
    call :getLMRStr "!myFC!" / NameFExe TitleFExe IconFile IconNumber

    set fTitleFExe=!dPrefix!!TitleFExe!!dSufix!
    set CSECTION=!CATEGORY!
    set CFEXE=%%~pda!NameFExe!
    if "_!IconFile!"=="_" (
        set "CFICON="
    ) else (
        set CFICON=!IconFile!)
    set PSOFTWARE=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\!CSECTION!

    if !bDebug! GEQ 1 (
        echo CATEGORY    =!CATEGORY!
        echo CFEXE       =!CFEXE!
        echo CFICON      =!CFICON!
        echo PSOFTWARE   =!PSOFTWARE!
        echo myD         =!myD!
        echo iPathRSTart =!iPathRSTart!
        echo myCPath     =!myCPath!
        echo CSECTIONx   =!CSECTIONx!
        echo muicount    =!iCount!
        echo varA        =%%a
        echo pathA       =%%~dpa
        echo mypref      =!mypref!
        echo sRPath      =!sRPath!
        echo CSECTION    =!CSECTION!
        echo NameFExe    =!NameFExe!
        echo TitleFExe   =!TitleFExe!
        echo IconFile    =!IconFile!
        echo IconNumber  =!IconNumber!
    )
    
    if !iCount! LSS 10 (
        call :write "Generating Item [0!iCount!]: [."
        echo echo Generating Item [0!iCount!]: {!CATEGORY!} - {!fTitleFExe!}>>%QUICKFile%
    ) else (
        call :write "Generating Item [!iCount!]: [."
        echo echo Generating Item [!iCount!]: {!CATEGORY!} - {!fTitleFExe!}>>%QUICKFile%
    )
    rem Will create the path if not exist
    call :checkCATEGORY "!PSOFTWARE!"
    call :createDNXItem "!NameFExe!" "!CATEGORY!" "!fTitleFExe!" "" "!CFICON!" "!IconNumber!" "!sRPath!"
    if !bDebug! GEQ 1 (
        pause
        cls
    )
    echo ] {!CATEGORY!} - {!fTitleFExe!} - Ok!
)


goto ToEnd


rem ____________________________________________________________ myTitle
:myTitle
setlocal enableextensions enabledelayedexpansion
    title DNXPSoft Adding Items:[!iCount!/!iCountT!]
    set /a pCount=!iCount!*100
    set /a pCount=%pCount%/!iCountT!
    
    if %bDebug%==2 (
    echo * iCount         =!iCount!
    echo * iCountT        =!iCountT!
    echo * pCount         =%pCount%
    echo * strV           =%strV%
    )
    
    title DNXPSoft Adding Items:[!iCount!/!iCountT!  -  %pCount%%%]
endlocal
exit /b
rem ____________________________________________________________ createDNXItem
:createDNXItem "!CFEXE!" "!PSOFTWARE!" "!fTitleFExe!" "" "!CFICON!" "!IconNumber!"
    setlocal enableextensions enabledelayedexpansion
    set tvEXE=%~1
    set vCATEGORY=%~2
    set vTitle=%~3
    set vArgs=%~4
    set vICON=%~5
    set vICONNum=%~6
    set vRPath=%~7

    if "_%vCATEGORY%"=="_" (
        set vCATEGORY=%NOCATEGORYLABEL%
    )
    set vPATH=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\%vCATEGORY%
    set XXvPATH=%%USERPROFILE%%\AppData\Roaming\Microsoft\Windows\Start Menu\%vCATEGORY%
    set vPEXE=%vPATH%\%vEXE%
    set XXvPEXE=%vRPath%%vEXE%
    if "%vRPath%_"=="_" set "CMDScript=%cd%\%myFx%.cmd"
    if "%vRPath%_" NEQ "_" set "CMDScript=%cd%\%vRPath%%myFx%.cmd"
    set bScript=.
    if exist "%CMDScript%" ( 
		set "bScript=S"
	)
	call :getLRStr "%tvEXE%" \ vEXE vEXEPARAM
	if "_%vArgs%"=="_" set "vArgs=%vEXEPARAM%"
	rem %%~pda
    if %bDebug%==2 (
        echo **::createDNXItem::**
        echo "* myF             =%myF%"
        echo "* myFx            =%myFx%"
        echo "* vRPath          =%vRPath%"
        echo "* mypref          =%mypref%"
        echo "* NOCATEGORYLABEL =%NOCATEGORYLABEL%"
        echo "* tvEXE           =%tvEXE%"
        echo "* vEXE            =%vEXE%"
        echo "* vEXEPARAM       =%vEXEPARAM%"
        echo "* vPEXE           =%vPEXE%"
        echo "* vCATEGORY       =%vCATEGORY%"
        echo "* vPATH           =%vPATH%"
        echo "* vTitle          =%vTitle%"
        echo "* vArgs           =%vArgs%"
        echo "* vICON           =%vICON%"
        echo "* vICONNum        =%vICONNum%"
        echo "* XXvPEXE         =%XXvPEXE%"
        echo "* XXvPath         =%XXvPATH%"
        echo "* vRPath          =%vRPath%"
        echo "* cd              =%cd%"
        echo "* iCount          =%iCount%"
        echo "* CMDScript       =%CMDScript%"
        echo "* vpathxxvpexe    ="%vPath%\%XXvPEXE%""
        echo "* bScript         =%bScript%"
    )
    echo if not exist "%XXvPath%" mkdir "%XXvPath%">>%QUICKFile%
    

    if exist "%vPath%\%vTitle%.lnk" (
        set bExist=1
        call :write "E"
    ) else (
        set bExist=0
        call :write "."
    )
    if "_%vICON%"=="_" (
        nircmd shortcut "%cd%\%XXvPEXE%" "%vPATH%" "%vTitle%" "%vArgs%"
        echo nircmd shortcut "%%cd%%\%XXvPEXE%" "%XXvPATH%" "%vTitle%">>%QUICKFile%
    ) else (
        if "_%vICONNum%" NEQ "_" (
            nircmd shortcut "%cd%\%XXvPEXE%" "%vPATH%" "%vTitle%" "%vArgs%" "%cd%\%vRPath%%vICON%" "%vICONNum%"
            echo nircmd shortcut "%%cd%%\%XXvPEXE%" "%XXvPATH%" "%vTitle%" "%vArgs%" "%%cd%%\%vRPath%%vICON%" "%vICONNum%">>%QUICKFile%
        ) else (
            nircmd shortcut "%cd%\%XXvPEXE%" "%vPATH%" "%vTitle%" "%vArgs%" "%cd%\%vRPath%%vICON%"
            echo nircmd shortcut "%%cd%%\%XXvPEXE%" "%XXvPATH%" "%vTitle%" "%vArgs%" "%%cd%%\%vRPath%%vICON%">>%QUICKFile%
        )
    )
    call :write "."
    call :write %bScript%

    if "!bScript!"=="S" start /WAIT cmd /C "%CMDScript%"
    
endlocal
exit /b

rem ____________________________________________________________ checkCATEGORY
:checkCATEGORY PSOFTWARE
setlocal disableDelayedExpansion
    set "myD=%~1"
    if not exist "%myD%" (
        mkdir "%myD%"
        call :write "D"
    ) else (
        call :write "."
    )
endlocal
exit /b

rem ____________________________________________________________ isAdmin1
:isAdmin [varRC]
setlocal disableDelayedExpansion
    call :write Administrative permissions required. Detecting permissions...  
    set myRC=0
    net session >nul 2>&1
    if %errorLevel% == 0 (
        rem echo Success: Administrative permissions confirmed.
        set myRC=1
        echo  OK!
    ) else (
        rem echo Failure: Current permissions inadequate.
        echo  Failed!
    )
endlocal & set "%1=%myRC%"
exit /b

rem ____________________________________________________________ Write
:write strVar
::
:: Write the literal string Str to stdout without a terminating
:: carriage return or line feed. Enclosing quotes are stripped.
::
:: This routine works by calling :writeVar
::
setlocal disableDelayedExpansion
set "strVar=%~1"
call :writeVar strVar
exit /b

rem ____________________________________________________________ strLen
:strLen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    (set^ tmp=!%~1!)
    if defined tmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!tmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "tmp=!tmp:~%%P!"
            )
        )
    ) ELSE (
        set len=0
    )
)
( 
    endlocal
rem     echo len=%len%
    set "%~2=%len%"
    exit /b
)

rem ____________________________________________________________ subStrAlt
:subStr0 strVar lInit lLen [varRC]
rem Example:
rem call :subStr1 %strPath% %vL2% %LL% varRC
rem call :subStr1 1234567890 2 3 Var3
    setlocal enableextensions enabledelayedexpansion
    if %bDebug%==2 echo subStr1 [%1] [%2] [%3] [%4] [%5]
    set tVar=%~1
    set /a tInit=%2-1
    set tLen=%3
    call set tRC=%%tVar:~%tInit%,%tLen%%%
endlocal & call set %4=%tRC%
exit /b

rem ____________________________________________________________ inStr
:inStr strVar strF stAt [rtnVar]
rem example:
rem call :inStr %RootPath%New New 0 Var3
if %bDebug%==2 echo inStr [%1] [%2] [%3] [%4] [%5]
rem @echo on 
setlocal enabledelayedexpansion
set str1=%1
set sstr=%2
set stAt=%3
set /a stAt=%stAt%-1
call :strlen str1 len1
call :strlen sstr len2
rem echo len1=%len1%
rem echo len2=%len2%
set /a stop=len1-len2
set fpos=0
if %stop% gtr 0 for /l %%i in (%stAt%,1,%stop%) do (
if "!str1:~%%i,%len2%!"=="%sstr%" (
set /a position=%%i+1
goto ExitinStr1
)
)
:ExitinStr1
if defined position (set fpos=%position%) else (set fpos=0)
rem set fpos=%position%
endlocal & set %4=%fpos%
exit /b

rem ____________________________________________________________ getLRStr
:getLRStr strVar strToken [varRC]
setlocal enableextensions enabledelayedexpansion
if %bDebug%==2 echo **getLRStr [%1] [%2] [%3] [%4] [%5]
set varRC=0
call :inStr %1 %2 0 varRC
if %bDebug%==2 echo varRC__=%varRC%
set /a varRCL=%varRC%-2
if %varRC% == 0 (
    set varRCL=%~1
    )
if %varRC% NEQ 0 (
call :subStr0 %1 1 %varRCL% varRCL
call :subStr0 %1 %varRC% 1000 varRCR )
endlocal & set "%3=%varRCL%" & set "%4=%varRCR%"
exit /b

rem ____________________________________________________________ getLMRStr
:getLMRStr strVar strToken [varRC]
setlocal enableextensions enabledelayedexpansion
if %bDebug%==2 echo **getLMRStr [%1] [%2] [%3] [%4] [%5]
set myV=%2
call :getLRStr %1 !myV! varRCL varT
call :getLRStr "%varT%" !myV! varRCM varRCRt
call :getLRStr "%varRCRt%" !myV! varRCR varRCNum
if "_%varRCM%_"=="__" set varRCM=%varRCL%
if %bDebug%==2 (
echo var1=%1
echo var2=%2
echo myV=!myV!
echo varRCL=%varRCL%
echo varRCM=%varRCM%
echo varRCR=%varRCR%
echo varRCNum=%varRCNum%
)
endlocal & set "%3=%varRCL%" & set "%4=%varRCM%" & set "%5=%varRCR%" & set "%6=%varRCNum%"
exit /b

rem ____________________________________________________________ initQuickDNXPS
:initQuickDNXPS
setlocal enableextensions enabledelayedexpansion
echo @Echo Off>%QUICKFile%
echo echo DNXPSoft Quick Add Items Batch>>%QUICKFile%
endlocal
exit /b

rem ____________________________________________________________ Write
:write strVar
::
:: Write the literal string Str to stdout without a terminating
:: carriage return or line feed. Enclosing quotes are stripped.
::
:: This routine works by calling :writeVar
::
setlocal disableDelayedExpansion
set "strVar=%~1"
call :writeVar strVar
exit /b

rem ____________________________________________________________ WriteVar
:writeVar strVar
::
:: Writes the value of variable StrVar to stdout without a terminating
:: carriage return or line feed.
::
:: The routine relies on variables defined by :writeInitialize. If the
:: variables are not yet defined, then it calls :writeInitialize to
:: temporarily define them. Performance can be improved by explicitly
:: calling :writeInitialize once before the first call to :writeVar
::
if not defined %~1 exit /b
setlocal enableDelayedExpansion
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
exit /b

rem ____________________________________________________________ WriteVar
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

rem ____________________________________________________________ getCurrentPathName
:getCurrentPathName
setlocal enableextensions enabledelayedexpansion
for %%I IN (%1.) do set "myRC=%%~nI%%~xI"
endlocal & set %2=%myRC%
exit /b

rem ____________________________________________________________ ProcessParameters
:ProcessParameters
echo Parameter=%1
    if %1=="/?" (
	    echo Help for "%~nx0" script...
	    echo /REGBOTH     - Register both contextual menus
		echo /DELBOTH     - Delete both contextual menus
		echo [DIRECTORY]  - Scan the specific directory for .DNXItem files
		echo              - Running without parameters will scan current directory for .DNXItem files
		echo.
	)
    if %1=="/REGBOTH" echo Registering both entries..."
goto ToEnd2

:ToEnd
echo Script finished!
pause
:ToEnd2

