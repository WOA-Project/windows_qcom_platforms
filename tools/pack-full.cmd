@echo off

mkdir ..\..\Qualcomm-Drivers-Release
del ..\..\Qualcomm-Drivers-Release\Qualcomm-Drivers-Full.7z

mkdir Qualcomm-Drivers-Full
mkdir Qualcomm-Drivers-Full\components
mkdir Qualcomm-Drivers-Full\definitions
xcopy /cheriky ..\components\ANYSOC Qualcomm-Drivers-Full\components\ANYSOC
xcopy /cheriky ..\components\Devices Qualcomm-Drivers-Full\components\Devices
xcopy /cheriky ..\components\QC8150 Qualcomm-Drivers-Full\components\QC8150
xcopy /cheriky ..\components\QC8350 Qualcomm-Drivers-Full\components\QC8350
xcopy /cheriky ..\definitions\Desktop Qualcomm-Drivers-Full\definitions\Desktop

"7z.exe" a -t7z -r ..\..\Qualcomm-Drivers-Release\Qualcomm-Drivers-Full.7z Qualcomm-Drivers-Full\*

rmdir /Q /S Qualcomm-Drivers-Full