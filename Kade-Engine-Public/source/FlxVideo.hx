package;

import openfl.media.SoundTransform;
import openfl.net.NetStream;
import openfl.net.NetConnection;
import flixel.FlxG;
import openfl.media.Video;
import flixel.FlxBasic;

using StringTools;

class FlxVideo extends FlxBasic
{
	var video:Video;
	var netStream:NetStream;

	public var finishCallback:Dynamic;

	override public function new(videoAsset:String)
	{
		super();

		video = new Video();
		video.x = 0;
		video.y = 0;
		FlxG.addChildBelowMouse(video);

		var netConnection:NetConnection = new NetConnection();
		netConnection.connect(null);
		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: client_onMetaData};
		netStream.addEventListener('asyncError', netStream_onAsyncError);
		netConnection.addEventListener('netStatus', netConnection_onNetStatus);
		netStream.play(videoAsset);

		netStream.soundTransform = new SoundTransform(FlxG.sound.volume);
	}

	public function finishVideo()
	{
		netStream.dispose();
		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}
		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	private function client_onMetaData(e)
	{
		video.attachNetStream(netStream);
		video.width = FlxG.width;
		video.height = FlxG.height;
	}

	private function netStream_onAsyncError(e)
	{
		Debug.logError('Error loading video');
	}

	private function netConnection_onNetStatus(e)
	{
		if (e.info.code == 'NetStream.Play.Complete')
		{
			finishVideo();
		}
	}
}
