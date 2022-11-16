REM Legal version values should look like 'x.x.x.x'
candle.exe -dProductVersion="1.36.0" -nologo netdata.wxs -out netdata.wixobj
light.exe netdata.wixobj -spdb -out netdata.msi