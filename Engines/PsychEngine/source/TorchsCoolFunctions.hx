package;

import flixel.FlxG;
import lime.system.System;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if VIDEOS_ALLOWED
#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0")
import VideoHandler as MP4Handler;
#else
import vlc.MP4Handler;
#end
#end
class TorchsCoolFunctions
{
<<<<<<< HEAD
	// Just found out this was in CoolUtil lol, still gonna keep it here for now
=======
>>>>>>> 2dc76f588cbe79ffe407a6159f3ed686d6142752
	public static function openLink(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function restartGame()
	{
		#if cpp
		var os = Sys.systemName();
		var args = "Test.hx";
		var app = "";
		var workingdir = Sys.getCwd();

		FlxG.log.add(app);

		app = Sys.programPath();

		var result = systools.win.Tools.createProcess(app, args, workingdir, false, false);

		if (result == 0)
		{
			FlxG.log.add('Hmmmmmm....');
			System.exit(1337);
		}
		else
			throw "Failed to restart";
		#end
	}
}
