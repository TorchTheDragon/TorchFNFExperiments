package;

// Torch's Stuff
import TorchsCoolFunctions as QuickFunc;
import TorchsGameJolt.GameJoltLogin;
// TenTools Stuff
import tentools.api.FlxGameJolt as GJApi;
// Fixel Stuff
import flixel.FlxG;
import flixel.util.FlxTimer;

class TorchsGJFunctions
{
	public static var userLogin:Bool = false;
	public static var leaderboardToggle:Bool;

	public static function getUserInfo(username:Bool = true):String
	{
		if (username)
			return GJApi.username;
		else
			return GJApi.usertoken;
	}

	public static function getStatus():Bool
	{
		return userLogin;
	}

	public static function connect():Bool
	{
		trace("Grabbing API Keys...");
		var val:Bool = false;
		GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool)
		{
			val = data;
		});
		return val;
	}

	public static function authUser(in1, in2, ?loginArg:Bool = false):Bool
	{
		var val:Bool = false;
		if (!userLogin)
		{
			GJApi.authUser(in1, in2, function(v:Bool)
			{
				trace("User: " + (in1 == "" ? "N/A" : in1));
				trace("Token: " + in2);
				if (v)
				{
					trace("User authenticated!");
					FlxG.save.data.gjUser = in1;
					FlxG.save.data.gjToken = in2;
					FlxG.save.flush();
					userLogin = true;
					startSession();
					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
						// LoadingState.loadAndSwitchState(new GameJoltLogin());
					}
					val = true;
				}
				else
				{
					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
						// LoadingState.loadAndSwitchState(new GameJoltLogin());
					}
					trace("User login failure!");
					val = false;
				}
			});
		}
		return val;
	}

	public static function deAuthUser()
	{
		closeSession();
		userLogin = false;
		trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
		FlxG.save.data.gjUser = "";
		FlxG.save.data.gjToken = "";
		FlxG.save.flush();
		trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
		trace("Logged out!");
		QuickFunc.restartGame();
	}

	public static function getTrophy(trophyID:Int)
	{
		if (userLogin)
		{
			GJApi.addTrophy(trophyID, function(data:Map<String, String>)
			{
				trace(data);
				var bool:Bool = false;
				if (data.exists("message"))
					bool = true;
			});
		}
	}

	public static function checkTrophy(id:Int):Bool
	{
		var value:Bool = false;
		GJApi.fetchTrophy(id, function(data:Map<String, String>)
		{
			trace(data);
			if (data.get("achieved").toString() != "false")
				value = true;
			trace(id + "" + value);
		});
		return value;
	}

	public static function pullTrophy(?id:Int):Map<String, String>
	{
		var returnable:Map<String, String> = null;
		GJApi.fetchTrophy(id, function(data:Map<String, String>)
		{
			trace(data);
			returnable = data;
		});
		return returnable;
	}

	public static function addScore(score:Int, tableID:Int, ?extraData:String):Bool
	{
		if (leaderboardToggle)
		{
			trace("Trying to add a score");
			var formData:String = extraData.split(" ").join("%20");
			GJApi.addScore(score + "%20Points", score, tableID, false, null, formData, function(data:Map<String, String>)
			{
				trace("Score submitted with a result of: " + data.get("success"));
			});
			return true;
		}
		else
		{
			return false;
		}
	}

	public static function pullHighScore(tableID:Int):Map<String, String>
	{
		var returnable:Map<String, String>;
		GJApi.fetchScore(tableID, 1, function(data:Map<String, String>)
		{
			trace(data);
			returnable = data;
		});
		return returnable;
	}

	public static function startSession()
	{
		GJApi.openSession(function()
		{
			trace("Session started!");
			new FlxTimer().start(20, function(tmr:FlxTimer)
			{
				pingSession();
			}, 0);
		});
	}

	public static function pingSession()
	{
		GJApi.pingSession(true, function()
		{
			trace("Ping!");
		});
	}

	public static function closeSession()
	{
		GJApi.closeSession(function()
		{
			trace('Closed out the session');
		});
	}
}
