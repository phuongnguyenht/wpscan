@ECHO OFF
REM /*************************************************************************
REM * 
REM 
REM *************************************************************************
REM * File information
REM * Author: Ahihi
REM * date created: 22-July-2020
REM * description: This batch file reveals OS, hardware, and networking configuration.
REM * Known bugs:
REM *	1.
REM *	2.
REM * pending items:
REM *	1. 
REM *	2.
REM */

:: This batch file reveals OS, hardware, and networking configuration.
TITLE Checklist windows hardening
ECHO Please wait... Checking system information.

for /f "usebackq tokens=2 delims=:" %%f in (`ipconfig ^| findstr /c:"IPv4 Address"`) do ( set IP=%%f )
FOR /F "usebackq" %%i IN (`hostname`) DO SET name=%%i
set output="%name%_%IP%.txt"
echo %output%
if exist %output% (
	del %output%
) else (
   	echo file %output% doesn't exist
)

goto check_Permissions
:check_Permissions
    echo Administrator permissions required. Detecting permissions...
	NET SESSION >nul 2>&1
	IF %ERRORLEVEL% EQU 0 (
		ECHO Administrator PRIVILEGES Detected! >> %output%
    ) ELSE (
		echo ######## ########  ########   #######  ########  
		echo ##       ##     ## ##     ## ##     ## ##     ## 
		echo ##       ##     ## ##     ## ##     ## ##     ## 
		echo ######   ########  ########  ##     ## ########  
		echo ##       ##   ##   ##   ##   ##     ## ##   ##   
		echo ##       ##    ##  ##    ##  ##     ## ##    ##  
		echo ######## ##     ## ##     ##  #######  ##     ## 
		echo.
		echo.
		echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED ######### >> %output%
		echo This script must be run as administrator to work properly!  >> %output%
		echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator". >> %output%
		echo ########################################################## >> %output%
		echo.
		PAUSE
		EXIT /B 1
	)
	
echo Begin check user Account Guest >> %output%
REM net user Guest | findstr /c:"Account active" | findstr /c:"Yes"
net user Guest | findstr /c:"Account active" >> %output%

echo Begin List folder share on windows >> %output%
net share >> %output%
echo Begein check services Secondary Logon >> %output%
powershell -Command "Get-Service -DisplayName se*" | findstr /c:"Secondary Logon" >> %output%

set tempfile="tmp_sec.txt"
if exist %tempfile% (
	del %tempfile%
) else (
   	echo file %tempfile% doesn't exist
)

SecEdit.exe /export /areas SECURITYPOLICY USER_RIGHTS /cfg %tempfile%
rem type %tempfile% >> %output%
echo Begein check password policy meet complexity PasswordComplexity = 1 is Enable >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"PasswordComplexity" >> %output%
echo Begein check cau hinh thoi gian doi mat khau MaximumPasswordAge  >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"MaximumPasswordAge" >> %output%
echo Begein check cau hinh khong su dung lai n lan mat khau cu gan nhat PasswordHistorySize  >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"PasswordHistorySize" >> %output%
echo Begein check cau hinh Thoi gian Khoa tai khoan neu dang nhap sai nhieu lan LockoutDuration >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"LockoutDuration" >> %output%
echo Begein check cau hinh Khoa tai khoan neu dang nhap sai n lan LockoutBadCount >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"LockoutBadCount" >> %output%
echo Begein check cau thoi gian co the login lai ResetLockoutCount >> %output%
powershell -Command "Get-Content -Path %tempfile% | select -First 19" | findstr /c:"ResetLockoutCount" >> %output%
if exist %tempfile% (
	del %tempfile%
) else (
   	echo file %tempfile% doesn't exist
)	
echo Begein check list local account >> %output%
for /F "tokens=*" %%A in ('powershell -Command "$result = net user | Select-Object -Skip 4; $result = $result | Select-Object -First ($result.Count - 2); $result = $result.Trim(); $result -split '\s{2,}'"') do (net user "%%A" >> %output% ) 
echo Begein list all user in group administrators >> %output%
net localgroup administrators >> %output%
echo Begein list all local group >> %output%
net localgroup >> %output%
echo Begein check config NTP  >> %output%
reg query HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters | findstr /c:"10.36.32.13" >> %output%
echo Time on local computer >> %output%
w32tm /query /status >> %output%
echo Check Cau hinh idle timeout cho moi phien RDP >> %output%
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxIdleTime >> %output%
echo Get status SNMP Service >> %output%
Dism /online /Get-FeatureInfo /FeatureName:SNMP >> %output%
rem echo Enable SNMP Service >> %output%
rem Dism /online /Enable-Feature /FeatureName:SNMP >> %output%
echo Check Cau hinh SNMP key >> %output%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /s | findstr "lvbsnmpkey" >> %output%
rem powershell -Command "reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /s | Select-String -Pattern "ValidCommunities" -Context 1" >> %output%
rem echo Start snmp sevice >> %output%
rem net start snmp >> %output%
echo Check cau hinh gui log thu thap ve may chu luu log tap trung >> %output%
net user qradar >> %output%
echo Check service SMB >> %output%
powershell -Command "Get-SmbServerConfiguration | Select EnableSMB1Protocol,EnableSMB2Protocol" >> %output%
echo Check service OSSEC agent installed or not >> %output%
powershell -Command "Get-ItemProperty HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*" | findstr /c:"OSSEC HIDS" >> %output%
echo Check service OSSEC agent running >> %output%
tasklist | findstr "ossec" >> %output%
echo Check Symantec Endpoint Protection installed or not >> %output%
wmic product get name,version | findstr /c:"Symantec" >> %output%	

@echo on
