candle.exe -nologo netdata.wxs -out netdata.wixobj
light.exe netdata.wixobj -spdb -out netdata.msi
del netdata.wixobj