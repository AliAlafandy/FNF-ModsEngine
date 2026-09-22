#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git lime https://github.com/AlafandyPorting/lime-0.7.3 --quiet
haxelib install openfl 9.3.2 --quiet
haxelib git flixel https://github.com/AliAlafandy/flixel-alafandy --quiet
haxelib install flixel-addons 3.2.1 --quiet
haxelib install flixel-tools 1.5.1 --quiet
haxelib install flixel-ui 2.5.0 --quiet
haxelib git hxcpp https://github.com/AlafandyPorting/hxcpp --quiet
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec --quiet --skip-dependencies
haxelib git SScript https://github.com/AlafandyPorting/SScript --quiet
haxelib install tjson 1.4.0 --quiet
haxelib install hxdiscord_rpc --quiet --skip-dependencies
haxelib git linc_luajit https://github.com/AlafandyPorting/linc_luajit-0.7.3 --quiet
haxelib git flxanimate https://github.com/ShadowMario/flxanimate.git dev --quiet
echo Finished!
