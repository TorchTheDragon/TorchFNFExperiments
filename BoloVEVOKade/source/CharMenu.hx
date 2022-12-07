// This is completely re-typed out, I did this so I didn't just copy and paste so that HOPEFULLY it works better and doesn't need that many changes.
package;

import Section.SwagSection;

// These may be swapped depending on what may need it. Some older ones may need a different one based on the 'Song' TypeDef
// import Song.SwagSong; // Usually Used One
import Song.SongData; // What my version of Kade engine is apparently using

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import haxe.Json;
import Boyfriend.Boyfriend;
import Character.Character;
import HealthIcon.HealthIcon;
import flixel.ui.FlxBar;

import StringTools;

class CharMenu extends MusicBeatState{
    // Selectable Character Variables
    var selectableCharacters:Array<String> = ['bf', 'bf-christmas', 'pico']; // Currently Selectable characters
    var selectableCharactersNames:Array<String> = ['Default Character', 'Boyfriend but Christmas', 'Pico']; // Characters names
    var selectableCharactersBGs:Array<String> = ['BG2', 'BG2', 'BG1']; // Characters backgrounds, 4 are included by default
    
    // Unlockable characters
    var unlockableChars:Array<String> = ['spooky']; // Unlockable Characters
    var unlockableCharsNames:Array<String> = ['ITS SPOOKY MONTH']; // Names of unlockable Characters
    var unlockableCharsBGs:Array<String> = ['BG4']; // Backgrounds for Unlockable characters
    
    // This is the characters that actually appear on the menu
    var unlockedCharacters:Array<String> = [];
    var unlockedCharactersNames:Array<String> = [];
    var unlockedCharactersBGs:Array<String> = [];
    
    // Folder locations
    var backgroundFolder:String = 'background'; // The location of the folder storing the characters backgrounds
    var fontFolder:String = 'assets/fonts/'; // Please don't change unless font folder changes, leads to the fonts folder
    var sharedImagesFolder:String = 'assets/shared/images/'; // Please don't change, leads to the shared folder

    // Variables for what is shown on screen
    var curSelected:Int = 0; // Which character is selected
    var icon:HealthIcon; // The healthicon of the selected character
    var menuBG:FlxSprite; // The background
    private var imageArray:Array<Boyfriend> = []; // Array of all the selectable characters
    var selectedCharName:FlxText; // Name of selected character

    // Additional Variables
    var alreadySelected:Bool = false; // If the character is already selected
    var ifCharsAreUnlocked:Array<Bool> = FlxG.save.data.daUnlockedChars;

    // Animated Arrows Variables
    var newArrows:FlxSprite;

    override function create()
    {
        // Useless for now
        if (ifCharsAreUnlocked == null) 
        {
            ifCharsAreUnlocked = [false];
            FlxG.save.data.daUnlockedChars = [false];
        }
        // If the unlocked chars are empty, fill it with defaults
        if (unlockedCharacters == null) 
        {
            unlockedCharacters = selectableCharacters;
            unlockedCharacters[0] = PlayState.SONG.player1;
        } 
        // If names are empty, fill it with defaults
        if (unlockedCharactersNames == null) 
        {
            unlockedCharactersNames = selectableCharactersNames;
        }
        // If backgrounds are empty, fill it with defaults
        if (unlockedCharactersBGs == null) 
        {
            unlockedCharactersBGs = selectableCharactersBGs;
        }

        unlockedCharacters[0] = PlayState.SONG.player1;

        unlockedCharsCheck();

        // Making sure the background is added first to be in the back and then adding the character names and character images afterwords
        menuBG = new FlxSprite().loadGraphic(Paths.image(unlockedCharactersBGs[curSelected], backgroundFolder));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);

        // Adds the chars to the selection
        for (i in 0...unlockedCharacters.length)
        {
            var characterImage:Boyfriend = new Boyfriend(0, 0, unlockedCharacters[i]);
            if (StringTools.endsWith(unlockedCharacters[i], '-pixel'))
                characterImage.scale.set(5.5, 5.5);
            else
                characterImage.scale.set(0.8, 0.8);

            characterImage.screenCenter(XY);
            imageArray.push(characterImage);
            add(characterImage);
        }

        // Character select text at the top of the screen
        var selectionHeader:Alphabet = new Alphabet(0, 50, 'Character Select', true);
        selectionHeader.screenCenter(X);
        add(selectionHeader);

        // Old arrows
        // The left and right arrows on screen
        var arrows:FlxSprite = new FlxSprite().loadGraphic(Paths.image('arrowSelection', backgroundFolder));
        arrows.setGraphicSize(Std.int(arrows.width * 1.1));
        arrows.screenCenter();
        arrows.antialiasing = true;
        add(arrows);

        // Not centered Correctly, need to figure out how to do that
        /*
        // New Animated Arrows
        newArrows = new FlxSprite();
        newArrows.frames = Paths.getSparrowAtlas('newArrows', 'background');
        newArrows.animation.addByPrefix('idle', 'static', 24, false);
        newArrows.animation.addByPrefix('left', 'leftPress', 24, false);
        newArrows.animation.addByPrefix('right', 'rightPress', 24, false);
        newArrows.antialiasing = true;
        newArrows.screenCenter(XY);
        newArrows.animation.play('idle');
        add(newArrows);
        */

        // The currently selected character's name top right
        selectedCharName = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        selectedCharName.setFormat(fontFolder + 'vcr.ttf', 32, FlxColor.WHITE, RIGHT);
        selectedCharName.alpha = 0.7;
        add(selectedCharName);

        changeSelection();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super.create();
    }

    override function update(elapsed:Float)
    {
        selectedCharName.text = unlockedCharactersNames[curSelected].toUpperCase();
        selectedCharName.x = FlxG.width - (selectedCharName.width + 10);
        if (selectedCharName.text == '')
        {
            trace('');
            selectedCharName.text = '';
        }

        // Must be changed depending on how an engine uses its own controls
        // var leftPress = controls.UI_LEFT_P; // Psych
        var leftPress = controls.LEFT_P; // Kade
        // var rightPress = controls.UI_RIGHT_P; // Psych
        var rightPress = controls.RIGHT_P; // Kade
        var accepted = controls.ACCEPT; // Should be Universal
        var goBack = controls.BACK; // Should be Universal

        // Testing only DO NOT USE
        var unlockTest = FlxG.keys.justPressed.U;

        if (!alreadySelected)
        {
            if (leftPress)
            {
                // newArrows.animation.play('left', true);
                changeSelection(-1);
            }
            if (rightPress)
            {
                // newArrows.animation.play('right', true);
                changeSelection(1);
            }
            if (accepted)
            {
                alreadySelected = true;
                var daSelected:String = unlockedCharacters[curSelected];
                if (unlockedCharacters[curSelected] != PlayState.SONG.player1)
                    PlayState.SONG.player1 = daSelected;

                FlxFlicker.flicker(imageArray[curSelected], 0);
                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    LoadingState.loadAndSwitchState(new PlayState()); // Usual way
                    // FlxG.switchState(new PlayState()); // Gonna try this for Psych
                });
            }
            if (goBack)
            {
                if (PlayState.isStoryMode)
                    // LoadingState.loadAndSwitchState(new StoryMenuState());
                    FlxG.switchState(new StoryMenuState());
                else
                    // LoadingState.loadAndSwitchState(new FreeplayState());
                    FlxG.switchState(new FreeplayState());
            }
            if (unlockTest)
            {
                if (FlxG.save.data.daUnlockedChars[0] == true)
                    trace("Unlocked Secret");
                else
                    trace("Locked Secret");
                FlxG.save.data.daUnlockedChars[0] = !FlxG.save.data.daUnlockedChars[0];
            }

            for (i in 0...imageArray.length)
            {
                imageArray[i].dance();
            }

            if (newArrows.animation.finished == true)
                newArrows.animation.play('idle');

            super.update(elapsed);
        }
    }

    // Changes the currently selected character
    function changeSelection(changeAmount:Int = 0):Void
    {
        // This just ensures you don't go over the intended amount
        curSelected += changeAmount;
        if (curSelected < 0)
            curSelected = unlockedCharacters.length - 1;
        if (curSelected >= unlockedCharacters.length)
            curSelected = 0;
        
        for (i in 0...imageArray.length)
        {
            // Sets the unselected characters to a more transparent form
            imageArray[i].alpha = 0.6;

            // These adjustments for Pixel characters may break for different ones, but eh, I am just making it for bf-pixel anyway
            if (StringTools.endsWith(imageArray[i].curCharacter, '-pixel'))
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * 400) + 325;
                imageArray[i].y = (FlxG.height / 2) - 60;
            }
            else
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * 400) + 150;
                imageArray[i].y = (FlxG.height / 2) - (imageArray[i].height / 2);
            }
        }

        // Makes sure the character you ave selected is indeed visible
        imageArray[curSelected].alpha = 1;

        charCheck();
    }

    // Checks for what char is selected and creates an icon for it
    function charCheck()
    {
        remove(icon);

        menuBG.loadGraphic(Paths.image(unlockedCharactersBGs[curSelected], backgroundFolder));

        var barBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(sharedImagesFolder + 'healthBar.png');
        barBG.screenCenter(X);
        barBG.scrollFactor.set();
        barBG.visible = false;
        add(barBG);

        var bar:FlxBar = new FlxBar(barBG.x + 4, barBG.y + 4, RIGHT_TO_LEFT, Std.int(barBG.width - 8), Std.int(barBG.height - 8), this, 'health', 0, 2);
        bar.scrollFactor.set();
        bar.createFilledBar(0xFFFF0000, 0xFF66FF33);
        bar.visible = false;
        add(bar);

        icon = new HealthIcon(unlockedCharacters[curSelected], true);

        // This code is for Psych but if necessary can be use on other engines too
        if (unlockedCharacters[curSelected] == 'bf-car' || unlockedCharacters[curSelected] == 'bf-christmas' || unlockedCharacters[curSelected] == 'bf-holding-gf')
            icon.changeIcon('bf');
        if (unlockedCharacters[curSelected] == 'pico-player')
            icon.changeIcon('pico');
        if (unlockedCharacters[curSelected] == 'tankman-player')
            icon.changeIcon('tankman');

        icon.screenCenter(X);
        icon.setGraphicSize(-4);
        icon.y = (bar.y - (icon.height / 2)) - 20;
        add(icon);
    }

    function unlockedCharsCheck()
    {
        // Resets all values to ensure that nothing is broken
        resetCharacterSelectionVars();

        // Makes this universal value equal the save data
        ifCharsAreUnlocked = FlxG.save.data.daUnlockedChars;

        // If you have managed to unlock a character, set it as unlocked here
        for (i in 0...ifCharsAreUnlocked.length)
        {
            if (ifCharsAreUnlocked[i] == true)
            {
                unlockedCharacters.push(unlockableChars[i]);
                unlockedCharactersNames.push(unlockableCharsNames[i]);
                unlockedCharactersBGs.push(unlockableCharsBGs[i]);
            }
        }
    }

    function resetCharacterSelectionVars() 
    {
        // Just resets all things to defaults
        ifCharsAreUnlocked = [false];

        // Ensures the characters are reset and that the first one is the default character
        unlockedCharacters = selectableCharacters;
        unlockedCharacters[0] = PlayState.SONG.player1; 

        // Grabs default character names
        unlockedCharactersNames = selectableCharactersNames;

        // Grabs default backgrounds
        unlockedCharactersBGs = selectableCharactersBGs;
    }
}