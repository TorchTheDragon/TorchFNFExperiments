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

using StringTools;

class GameJoltAPI
{
    public static var userLogin:Bool = false;
    public static var leaderboardToggle:Bool;

    public static function getUserInfo(username:Bool = true):String
    {
        if(username)return GJApi.username;
        else return GJApi.usertoken;
    }

    public static function getStatus():Bool
    {
        return userLogin;
    }

    public static function connect()
    {
        trace("Grabbing API Keys...");
        GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool){
            #if debug
            //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Game " + (data ? "authenticated!" : "not authenticated..."), (!data ? "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!" : "Yay!"));
            GameJoltLogin.toastManager.newToast(GameJoltInfo.imagePath, "Game " + (data ? "authenticated!" : "not authenticated..."), (!data ? "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!" : "Yay!"));
            #end
        });
    }

    public static function authUser(in1, in2, ?loginArg:Bool = false):Void
    {
        if(!userLogin)
        {
            GJApi.authUser(in1, in2, function(v:Bool)
            {

                trace("User: " + (in1 == "" ? "N/A" : in1));
                trace("Token: " + in2);
                if(v)
                {
                    // Main.gjToastManager.createToast(GameJoltInfo.imagePath, in1 + " SIGNED IN", "CONNECTED TO GAMEJOLT");
                    GameJoltLogin.toastManager.newToast(GameJoltInfo.imagePath, in1 + " SIGNED IN", "CONNECTED TO GAMEJOLT");
                    trace("User authenticated!");
                    FlxG.save.data.gjUser = in1;
                    FlxG.save.data.gjToken = in2;
                    FlxG.save.flush();
                    userLogin = true;
                    startSession();
                    if(loginArg)
                    {
                        GameJoltLogin.login=true;
                        FlxG.switchState(new GameJoltLogin());
                    }
                } else {
                    if(loginArg)
                    {
                        GameJoltLogin.login=true;
                        FlxG.switchState(new GameJoltLogin());
                    }
                    //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!", "");
                    GameJoltLogin.toastManager.newToast(GameJoltInfo.imagePath, "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!", "");
                    trace("User login failure!");
                }
            });
        }
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
        if(userLogin)
        {
            GJApi.addTrophy(trophyID, function(data:Map<String,String>){
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
            trace(id+""+value);
        });
        return value;
    }

    public static function pullTrophy(?id:Int):Map<String,String>
    {
        var returnable:Map<String,String> = null;
        GJApi.fetchTrophy(id, function(data:Map<String,String>){
            trace(data);
            returnable = data;
        });
        return returnable;
    }

    public static function addScore(score:Int, tableID:Int, ?extraData:String)
    {
        if (leaderboardToggle)
        {
            trace("Trying to add a score");
            var formData:String = extraData.split(" ").join("%20");
            GJApi.addScore(score+"%20Points", score, tableID, false, null, formData, function(data:Map<String, String>){
                trace("Score submitted with a result of: " + data.get("success"));
                //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score submitted!", "Score: " + score + "\nExtra Data: "+extraData, true);
                GameJoltLogin.toastManager.newToast(GameJoltInfo.imagePath, "Score submitted!", "Score: " + score + "\nExtra Data: " + extraData);
            });
        }
        else
        {
            //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score not submitted!", "Score: " + score + "Extra Data: " +extraData+"\nScore was not submitted due to score submitting being disabled!", true);
            GameJoltLogin.toastManager.newToast(GameJoltInfo.imagePath, "Score not submitted!", "Score: " + score + "Extra Data: " +extraData+"\nScore was not submitted due to score submitting being disabled!");
        }
    }

    public static function pullHighScore(tableID:Int):Map<String,String>
    {
        var returnable:Map<String,String>;
        GJApi.fetchScore(tableID,1, function(data:Map<String,String>){
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
            new FlxTimer().start(20, function(tmr:FlxTimer){pingSession();}, 0);
        });
    }

    public static function pingSession()
    {
        GJApi.pingSession(true, function(){trace("Ping!");});
    }

    public static function closeSession()
    {
        GJApi.closeSession(function(){trace('Closed out the session');});
    }
}

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

    public static var toastManager:ToastManager;

    private var camGame:FlxCamera;
    public static var camToasts:FlxCamera;

    override function create() 
    {
        toastManager = new ToastManager();
        add(toastManager);

        camGame = new FlxCamera();
        camToasts = new FlxCamera();
		camToasts.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camToasts, false);
        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        if (FlxG.save.data.lbToggle != null)
        {
            GameJoltAPI.leaderboardToggle = FlxG.save.data.lbToggle;
        }

        if(!login)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'),0);
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
        loginTexts.forEach(function(item:FlxText){
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
        loginBoxes.forEach(function(item:FlxUIInputText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        if(GameJoltAPI.getStatus())
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
            GameJoltAPI.authUser(usernameBox.text,tokenBox.text,true);
        });

        helpBox = new FlxButton(0, 550, "GameJolt Token", function()
        {
            if (!GameJoltAPI.getStatus())
                QuickFunc.openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE');
            else
            {
                GameJoltAPI.leaderboardToggle = !GameJoltAPI.leaderboardToggle;
                trace(GameJoltAPI.leaderboardToggle);
                FlxG.save.data.lbToggle = GameJoltAPI.leaderboardToggle;
                //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score Submitting", "Score submitting is now " + (GameJoltAPI.leaderboardToggle ? "Enabled":"Disabled"));
                toastManager.newToast(GameJoltInfo.imagePath, "Score Submitting", "Score submitting is now " + (GameJoltAPI.leaderboardToggle ? "Enabled":"Disabled") );
            }
        });
        helpBox.color = FlxColor.fromRGB(84,155,149);

        logOutBox = new FlxButton(0, 625, "Log Out & Close", function()
        {
            GameJoltAPI.deAuthUser();
        });
        logOutBox.color = FlxColor.RED;

        cancelBox = new FlxButton(0,625, "Not Right Now", function()
        {
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, function(){
                FlxG.save.flush();
                //remove(Main.gjToastManager);
                remove(toastManager);
                FlxG.switchState(GameJoltInfo.changeState);
            });
        });

        if(!GameJoltAPI.getStatus())
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

        loginButtons.forEach(function(item:FlxButton){
            item.screenCenter(X);
            item.setGraphicSize(Std.int(item.width) * 3);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
            username1.alignment = CENTER;
            username1.screenCenter(X);
            username1.x += baseX;
            add(username1);

            username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUserInfo(true) + "", 40);
            username2.alignment = CENTER;
            username2.screenCenter(X);
            username2.x += baseX;
            add(username2);
        }

        if(GameJoltInfo.font != null)
        {       
            username1.font = GameJoltInfo.font;
            username2.font = GameJoltInfo.font;
            loginBoxes.forEach(function(item:FlxUIInputText){
                item.font = GameJoltInfo.font;
            });
            loginTexts.forEach(function(item:FlxText){
                item.font = GameJoltInfo.font;
            });
        }
    }

    override function update(elapsed:Float)
    {
        if (FlxG.save.data.lbToggle == null)
        {
            FlxG.save.data.lbToggle = false;
            FlxG.save.flush();
        }

        if (GameJoltAPI.getStatus())
        {
            helpBox.text = "Leaderboards:\n" + (GameJoltAPI.leaderboardToggle ? "Enabled" : "Disabled");
            helpBox.color = (GameJoltAPI.leaderboardToggle ? FlxColor.GREEN : FlxColor.RED);
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
            //remove(Main.gjToastManager);
            remove(toastManager);
            FlxG.switchState(GameJoltInfo.changeState);
        }

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();
    }
}

class ToastManager extends FlxSpriteGroup
{
    public var toast:Toast = null;

    public function newToast(imagePath:String, titleText:String, description:String, ?camera:FlxCamera = null, ?color:FlxColor = 0xFF3848CC)
    {
        toast = new Toast(imagePath, titleText, description, color);
        toast.onFinish = endToast;
        if (camera != null) {toast.camera = camera;} else toast.camera = GameJoltLogin.camToasts;
        // toast.x = 50;
        // toast.y = 50;
	toast.screenCenter(XY);
        add(toast);
    }

    public function endToast():Void
    {
        toast = null;
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

    public function new(imagePath:String, titleText:String, description:String, ?color:FlxColor = 0xFF3848CC)
    {
        super(x, y);
        back = new FlxSprite().makeGraphic(500, 125, FlxColor.BLACK);
        back.alpha = 0.9;
        back.x = 0;
        back.y = 0;

        if (imagePath != "")
        {
            image = new FlxSprite().loadGraphic(Paths.image(imagePath));
            image.width = 100;
            image.height = 100;
            image.x = 10;
            image.y = 10;
        }

        title = new FlxText();
        title.setFormat(GameJoltInfo.fontPath, 30, color, CENTER);
        title.text = titleText;
        if(imagePath != "") title.x = 120; else title.x = 5; 
        title.y = 5;
        title.bold = true;
        title.wordWrap = true;
        title.width = 360;

        desc = new FlxText();
        desc.setFormat(GameJoltInfo.fontPath, 24, FlxColor.WHITE, CENTER);
        desc.text = description;
        if(imagePath != "") desc.x = 120; else desc.x = 5; 
        desc.y = 35;
        desc.wordWrap = true;
        desc.width = 360;
        desc.height = 95;
        if (titleText.length >= 25 || titleText.contains("\n"))
        {   
            desc.y += 25;
            desc.height -= 25;
        }

        add(back);
        if(imagePath != "") add(image);
        add(title);
        add(desc);

        alpha = 0;

        if (this.cameras != null)
        {
            back.cameras = this.cameras;
            if(imagePath != "") image.cameras = this.cameras;
            title.cameras = this.cameras;
            desc.cameras = this.cameras;
        }

        /*
        width = back.width;
        height = back.height;
        */

        alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
    }

    override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}

class GameJoltInfo
{
    public static var fontPath:String = "assets/fonts/vcr.ttf";
    public static var font:String = null;
    public static var imagePath:String = "";
    public static var changeState:FlxUIState = new options.OptionsState(); // Change this if you need it to go back to another state.
    // For you to see updates on this
    public static var version:String = 'v1.0';
}