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
	
	// This is shit lmao - Torch
	public function whatAreWeLookingFor(objective:String, ?valueToReturn:String = '') {
		switch (objective) {
			case "ease":
				switch (valueToReturn.toLowerCase().trim()) {
					case 'backin': return FlxEase.backIn;
					case 'backinout': return FlxEase.backInOut;
					case 'backout': return FlxEase.backOut;
					case 'bouncein': return FlxEase.bounceIn;
					case 'bounceinout': return FlxEase.bounceInOut;
					case 'bounceout': return FlxEase.bounceOut;
					case 'circin': return FlxEase.circIn;
					case 'circinout': return FlxEase.circInOut;
					case 'circout': return FlxEase.circOut;
					case 'cubein': return FlxEase.cubeIn;
					case 'cubeinout': return FlxEase.cubeInOut;
					case 'cubeout': return FlxEase.cubeOut;
					case 'elasticin': return FlxEase.elasticIn;
					case 'elasticinout': return FlxEase.elasticInOut;
					case 'elasticout': return FlxEase.elasticOut;
					case 'expoin': return FlxEase.expoIn;
					case 'expoinout': return FlxEase.expoInOut;
					case 'expoout': return FlxEase.expoOut;
					case 'quadin': return FlxEase.quadIn;
					case 'quadinout': return FlxEase.quadInOut;
					case 'quadout': return FlxEase.quadOut;
					case 'quartin': return FlxEase.quartIn;
					case 'quartinout': return FlxEase.quartInOut;
					case 'quartout': return FlxEase.quartOut;
					case 'quintin': return FlxEase.quintIn;
					case 'quintinout': return FlxEase.quintInOut;
					case 'quintout': return FlxEase.quintOut;
					case 'sinein': return FlxEase.sineIn;
					case 'sineinout': return FlxEase.sineInOut;
					case 'sineout': return FlxEase.sineOut;
					case 'smoothstepin': return FlxEase.smoothStepIn;
					case 'smoothstepinout': return FlxEase.smoothStepInOut;
					case 'smoothstepout': return FlxEase.smoothStepInOut;
					case 'smootherstepin': return FlxEase.smootherStepIn;
					case 'smootherstepinout': return FlxEase.smootherStepInOut;
					case 'smootherstepout': return FlxEase.smootherStepOut;
				}
				return FlxEase.linear;
			default:
				return null;
		}
	}
}
