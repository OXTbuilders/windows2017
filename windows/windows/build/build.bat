set BUILDID=%1
set BRANCH=%2
set REPO=%3

set CUSTOM=yes

if "%BRANCH%"=="None" set BRANCH=master
if "%REPO%"=="None"   set REPO=git://github.com/OpenXT

if "%REPO%"=="git://github.com/OpenXT" set CUSTOM=no
if "%REPO%:~0,13"=="git://172.21." set CUSTOM=no

rm -rf openxt
git clone %REPO%/openxt.git || goto :error
cd openxt
git checkout %BRANCH% || goto :error
cd windows

sed -i "s/Put Your Company Name Here/OpenXT/g" config\sample-config.xml

powershell .\winbuild-prepare.ps1 config=sample-config.xml build=%BUILDID% giturl=%REPO% branch=%BRANCH% certname=developer developer=true
powershell .\winbuild-all.ps1

cd output
echo %BUILDID% > BUILD_ID
if "%CUSTOM%"=="no"  rsync --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r -a --delete --exclude=xc-wintools.iso ./ buildbot@172.21.152.1:/home/builds/win/%BRANCH%/
if "%CUSTOM%"=="no"  rsync --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r -a xc-wintools.iso                       builds@144.217.69.51:/home/builds/windows/%BRANCH%/%BUILDID%/
if "%CUSTOM%"=="yes" rsync --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r -a *                                     builds@144.217.69.51:/home/builds/windows/custom/%BUILDID%/

exit /b 0

:error
exit /b %errorlevel%