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
