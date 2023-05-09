package;

// Fixel Stuff
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
// OpenFL Stuff
import openfl.Lib;
import openfl.utils.Assets as OpenFlAssets;
// TenTools Stuff
import tentools.api.FlxGameJolt as GJApi;
// Torch's Stuff
import TorchsCoolFunctions as QuickFunc;
import TorchsGJFunctions;

using StringTools;

class GameJoltLogin extends MusicBeatState
{
	var loginTexts:FlxTypedGroup<FlxText>;
	var loginBoxes:FlxTypedGroup<FlxUIInputText>;
	var loginButtons:FlxTypedGroup<FlxButton>;
	var usernameText:FlxText;
	var tokenText:FlxText;
	var usernameBox:FlxUIInputText;
	var tokenBox:FlxUIInputText;
	var signInBox:FlxButton;
	var helpBox:FlxButton;
	var logOutBox:FlxButton;
	var cancelBox:FlxButton;
	var username1:FlxText;
	var username2:FlxText;

	public static var charBop:FlxSprite;

	var baseX:Int = -190;

	public static var login:Bool = false;

	private var camGame:FlxCamera;

	public static var camToasts:FlxCamera;

	var toast:Toast;

	public function newToast(imagePath:String, library:String, titleText:String, description:String, ?camera:FlxCamera = null, ?color:FlxColor = 0xFF3848CC,
			?camera:FlxCamera = null)
	{
		if (camera == null)
			camera = camToasts;
		toast = new Toast(imagePath, library, titleText, description, color, camera);
		toast.onFinish = endToast;
		// commented till I know the positioning is fixed
		// toast.x = 50;
		// toast.y = 50;
		// toast.screenCenter(XY);
		add(toast);
	}

	public function endToast():Void
	{
		toast = null;
	}

	override function create()
	{
		camGame = new FlxCamera();
		camToasts = new FlxCamera();
		camToasts.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camToasts, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		if (FlxG.save.data.lbToggle != null)
		{
			TorchsGJFunctions.leaderboardToggle = FlxG.save.data.lbToggle;
		}

		if (!login)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(2, 0, 0.85);
		}
		trace(GJApi.initialized);
		FlxG.mouse.visible = true;

		Conductor.changeBPM(102);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.alpha = 0.25;
		add(bg);

		charBop = new FlxSprite(FlxG.width - 400, 250);
		charBop.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
		charBop.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		charBop.animation.addByPrefix('loggedin', 'BF HEY', 24, false);
		charBop.setGraphicSize(Std.int(charBop.width * 1.4));
		charBop.antialiasing = true;
		charBop.flipX = false;
		add(charBop);

		loginTexts = new FlxTypedGroup<FlxText>(2);
		add(loginTexts);

		usernameText = new FlxText(0, 125, 300, "Username:", 20);

		tokenText = new FlxText(0, 225, 300, "Token:", 20);

		loginTexts.add(usernameText);
		loginTexts.add(tokenText);
		loginTexts.forEach(function(item:FlxText)
		{
			item.screenCenter(X);
			item.x += baseX;
			item.font = GameJoltInfo.font;
		});

		loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
		add(loginBoxes);

		usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
		tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

		loginBoxes.add(usernameBox);
		loginBoxes.add(tokenBox);
		loginBoxes.forEach(function(item:FlxUIInputText)
		{
			item.screenCenter(X);
			item.x += baseX;
			item.font = GameJoltInfo.font;
		});

		if (TorchsGJFunctions.getStatus())
		{
			remove(loginTexts);
			remove(loginBoxes);
		}

		loginButtons = new FlxTypedGroup<FlxButton>(3);
		add(loginButtons);

		signInBox = new FlxButton(0, 475, "Sign In", function()
		{
			trace(usernameBox.text);
			trace(tokenBox.text);
			if (TorchsGJFunctions.authUser(usernameBox.text, tokenBox.text, true))
				newToast(GameJoltInfo.imagePath[0], GameJoltInfo.imagePath[1], usernameBox.text + " SIGNED IN!", "CONNECTED TO GAMEJOLT");
			else
				newToast(GameJoltInfo.imagePath[0], GameJoltInfo.imagePath[1], "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!",
					"");
		});

		helpBox = new FlxButton(0, 550, "GameJolt Token", function()
		{
			if (!TorchsGJFunctions.getStatus())
				QuickFunc.openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE');
			else
			{
				TorchsGJFunctions.leaderboardToggle = !TorchsGJFunctions.leaderboardToggle;
				trace(TorchsGJFunctions.leaderboardToggle);
				FlxG.save.data.lbToggle = TorchsGJFunctions.leaderboardToggle;
				newToast(GameJoltInfo.imagePath[0], GameJoltInfo.imagePath[1], "Score Submitting",
					"Score submitting is now " + (TorchsGJFunctions.leaderboardToggle ? "Enabled" : "Disabled"));
			}
		});
		helpBox.color = FlxColor.fromRGB(84, 155, 149);

		logOutBox = new FlxButton(0, 625, "Log Out & Close", function()
		{
			TorchsGJFunctions.deAuthUser();
		});
		logOutBox.color = FlxColor.RED;

		cancelBox = new FlxButton(0, 625, "Not Right Now", function()
		{
			FlxG.save.flush();
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, function()
			{
				FlxG.save.flush();
				// remove(Main.gjToastManager);
				// remove(toast);
				// FlxG.switchState(GameJoltInfo.changeState);
				LoadingState.loadAndSwitchState(GameJoltInfo.changeState);
			});
		});

		if (!TorchsGJFunctions.getStatus())
		{
			loginButtons.add(signInBox);
		}
		else
		{
			cancelBox.y = 475;
			cancelBox.text = "Continue";
			loginButtons.add(logOutBox);
		}

		loginButtons.add(helpBox);
		loginButtons.add(cancelBox);

		loginButtons.forEach(function(item:FlxButton)
		{
			item.screenCenter(X);
			item.setGraphicSize(Std.int(item.width) * 3);
			item.x += baseX;
		});

		if (TorchsGJFunctions.getStatus())
		{
			username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
			username1.alignment = CENTER;
			username1.screenCenter(X);
			username1.x += baseX;
			add(username1);

			username2 = new FlxText(0, 145, 0, "" + TorchsGJFunctions.getUserInfo(true) + "", 40);
			username2.alignment = CENTER;
			username2.screenCenter(X);
			username2.x += baseX;
			add(username2);
		}

		if (GameJoltInfo.font != null)
		{
			username1.font = GameJoltInfo.font;
			username2.font = GameJoltInfo.font;
			loginBoxes.forEach(function(item:FlxUIInputText)
			{
				item.font = GameJoltInfo.font;
			});
			loginTexts.forEach(function(item:FlxText)
			{
				item.font = GameJoltInfo.font;
			});
		}

		if (TorchsGJFunctions.getStatus())
		{
			newToast(GameJoltInfo.imagePath[0], GameJoltInfo.imagePath[1], usernameBox.text + " SIGNED IN!", "CONNECTED TO GAMEJOLT");
		}
		else
		{
			newToast(GameJoltInfo.imagePath[0], GameJoltInfo.imagePath[1], "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!", "");
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.lbToggle == null)
		{
			FlxG.save.data.lbToggle = false;
			FlxG.save.flush();
		}

		if (TorchsGJFunctions.getStatus())
		{
			helpBox.text = "Leaderboards:\n" + (TorchsGJFunctions.leaderboardToggle ? "Enabled" : "Disabled");
			helpBox.color = (TorchsGJFunctions.leaderboardToggle ? FlxColor.GREEN : FlxColor.RED);
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.save.flush();
			FlxG.mouse.visible = false;
			// remove(Main.gjToastManager);
			// remove(toast);
			FlxG.switchState(GameJoltInfo.changeState);
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
	}
}

class Toast extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;

	var back:FlxSprite;
	var image:FlxSprite;
	var title:FlxText;
	var desc:FlxText;

	function determineX(s:String):Float
	{
		if (!(s == null || s == ''))
		{
			return 130;
		}
		else
		{
			return 5;
		}
	}

	public function new(imagePath:String, library:String, titleText:String, description:String, ?color:FlxColor = 0xFF3848CC, ?camera:FlxCamera = null)
	{
		super(x, y);
		back = new FlxSprite(0, 0).makeGraphic(500, 150, FlxColor.BLACK);
		back.alpha = 0.9;

		if (imagePath != "")
		{
			image = new FlxSprite(-10, -10).loadGraphic(Paths.image(imagePath, library), false, 100, 100);
		}

		title = new FlxText(determineX(imagePath), 5, 350, titleText, 30);
		title.setFormat(GameJoltInfo.fontPath, 30, color, LEFT);
		title.bold = true;
		title.wordWrap = true;
		// title.width = 360;

		desc = new FlxText(determineX(imagePath), 35, 350, description, 24);
		desc.setFormat(GameJoltInfo.fontPath, 24, FlxColor.WHITE, LEFT);
		desc.wordWrap = true;
		// desc.width = 360;
		// desc.height = 95;
		if (titleText.length >= 25 || titleText.contains("\n"))
		{
			desc.y += 25;
			desc.height -= 25;
		}

		title.x = desc.x;

		var readjust:Float = 20; // Made this for quick and easy change

		// Widths
		if ((desc.width > title.width) && imagePath != '')
		{
			back.width = desc.width + image.width + readjust;
		}
		else if ((desc.width < title.width) && imagePath != '')
		{
			back.width = title.width + image.width + readjust;
		}
		else if ((desc.width > title.width) && imagePath == '')
		{
			back.width = desc.width + readjust;
		}
		else if ((desc.width < title.width) && imagePath == '')
		{
			back.width = title.width + readjust;
		}

		add(back);
		if (imagePath != "")
			add(image);
		add(title);
		add(desc);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}

		alpha = 0;

		back.cameras = cam;
		if (imagePath != "")
			image.cameras = cam;
		title.cameras = cam;
		desc.cameras = cam;

		/*
			width = back.width;
			height = back.height;
		 */

		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {
			onComplete: function(twn:FlxTween)
			{
				alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
					startDelay: 2.5,
					onComplete: function(twn:FlxTween)
					{
						alphaTween = null;
						remove(this);
						if (onFinish != null)
							onFinish();
					}
				});
			}
		});
	}

	override function destroy()
	{
		if (alphaTween != null)
		{
			alphaTween.cancel();
		}
		super.destroy();
	}
}

class GameJoltInfo
{
	public static var fontPath:String = "assets/fonts/vcr.ttf";
	public static var font:String = null;
	public static var imagePath:Array<String> = ["credits/torch", "preload"];
	public static var changeState:FlxUIState = new options.OptionsState(); // Change this if you need it to go back to another state.
	// For you to see updates on this
	public static var version:String = 'v1.0';

	// For toasts
	public static var toastLocation:String = "topright"; // Use either 'topleft', 'topright', 'bottomleft', 'bottomright', or 'center' for where the toast should be
}
