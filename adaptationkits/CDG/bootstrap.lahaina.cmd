@echo off

if not exist .\FMFiles\arm64\ModernPC\ (
  echo ERROR: Feature Manifests not found in .\FMFiles\arm64\ModernPC, recheck your copy of the 20279 WSK and try again.
  exit /b
)

if not exist .\MSPackages\appx\ (
  echo ERROR: APPX packages not found in .\MSPackages\appx, recheck your copy of the 20279 WSK and try again.
  exit /b
)

if not exist .\MSPackages\Retail\ARM64\fre\ (
  echo ERROR: CBS packages not found in .\MSPackages\Retail\ARM64\fre, recheck your copy of the 20279 WSK and try again.
  exit /b
)

echo Copying Driver Components...
mkdir .\MSPackages\Microsoft\MTP8350\ARM64\fre\Drivers\components
xcopy /cheriky ..\..\components .\MSPackages\Microsoft\MTP8350\ARM64\fre\Drivers\components

echo Copying App Components...
mkdir .\MSPackages\Microsoft\MTP8350\ARM64\fre\Drivers\apps
xcopy /cheriky ..\..\apps .\MSPackages\Microsoft\MTP8350\ARM64\fre\Drivers\apps

echo Copying WSK Components...
mkdir .\tools
xcopy /cheriky "%ProgramFiles(x86)%\Windows Kits\10\tools" .\tools\

echo Launching ImageApp...
set WSKContentRoot=%CD%
call build.lahaina.cmd

echo Mounting VHDX for patching...
powershell -command "Mount-DiskImage -ImagePath '%CD%\Output\Flash.vhdx'"

echo Getting EFIESP Drive Letter...
powershell -command "Get-Partition -Volume (Get-Volume -FileSystemLabel EFIESP) | Set-Partition -NewDriveLetter V"
set EFIESPDriveLetter=V:

echo Getting MainOS Drive Letter...
powershell -command "Get-Partition -Volume (Get-Volume -FileSystemLabel MainOS) | Set-Partition -NewDriveLetter W"
set MainOSDriveLetter=W:

echo Patching...
call patch.lahaina.cmd %EFIESPDriveLetter% %MainOSDriveLetter%

echo Unmounting VHDX...
powershell -command "Dismount-DiskImage -ImagePath '%CD%\Output\Flash.vhdx'"

echo Fixing GPT in VHDX...
%PROCESSOR_ARCHITECTURE%\GPTFixer.exe -i %CD%\Output\Flash.vhdx -s 4096

echo Generating FFU Image...
%PROCESSOR_ARCHITECTURE%\img2ffu.exe -i %CD%\Output\Flash.vhdx -f Output\Flash.ffu -c 16384 -s 4096 -p "Qualcomm.SM_LAHAINA.MTP.*;Qualcomm.SMP_LAHAINA.MTP.*" -o 10.0.20279.1002 -b 4000 -v V2 -d VenHw(860845C1-BE09-4355-8BC1-30D64FF8E63A) -l false -e .\provisioning-partitions.txt -t "cmd.exe /c sign.cmd"