attrib -h -s desktop.ini
del desktop.ini
copy _desktop.ini desktop.ini
attrib +h +s desktop.ini
set "ICODB=%USERPROFILE%\AppData\Local\IconCache.db"
attrib -H -S "%ICODB%"
del "%ICODB%"
set myD=%~dp0
set myD=%myD:~0,-1%
echo myD=%myD%
attrib +R %myD%
