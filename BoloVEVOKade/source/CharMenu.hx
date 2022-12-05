// This is completely re-typed out, I did this so I didn't just copy and paste so that HOPEFULLY it works better and doesn't need that many changes.
package;

import Section.SwagSection;

// These may be swapped depending on what may need it. Some older ones may need a different one based on the 'Song' TypeDef
// import Song.SwagSong; // Usually Used One
import Song.SongData; // What my version of an engine is apparently using

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

class CharMenu extends MusicBeatState{
    // Selectable Character Variables
    var selectableCharacters:Array<String> = ['bf', 'bf-christmas', 'pico']; // Currently Selectable characters
    var selectableCharactersNames:Array<String> = ['Boyfriend.XML', 'Boyfriend but Christmas', 'Pico']; // Characters names
    var selectableCharactersBGs:Array<String> = ['BG2', 'BG2', 'BG1']; // Characters backgrounds, 4 are included by default
    var charOffsets:Array<Array<Int>> = [[0, 0], [0, 0], [0, 0]]; // Small offsets that YOU need to add to better center your characters
    // Unlockable characters are not yet implemented, but will be hopefully soon
    // Requesting help btw if anyone has an idea on how to implement this
    var unlockableChars:Array<String> = ['torch']; // Unlockable Characters
    var unlockableCharsNames:Array<String> = ['Torch the Dragon']; // Names of unlockable Characters
    var unlockableCharsBGs:Array<String> = ['BG3']; // Backgrounds for Unlockable characters
    var unlockableCharsOffsets:Array<Array<Int>> = [[0, 0]]; // Offsets for the unlockable characters

    // This is the characters that actually appear on the menu
    var unlockedCharacters:Array<String> = FlxG.save.data.unlockedChars;
    var unlockedCharactersNames:Array<String> = FlxG.save.data.unlockedCharsNames;
    var unlockedCharactersBGs:Array<String> = FlxG.save.data.unlockedCharsBGs;
    var unlockedOffsets:Array<Array<Int>> = FlxG.save.data.unlockedOffsets;

    // Folder locations
    var backgroundFolder:String = 'background'; // The location of the folder storing the characters backgrounds
    var fontFolder:String = 'assets/fonts/'; // Please don't change unless font folder changes, leads to the fonts folder
    var sharedImagesFolder:String = 'assets/shared/images/'; // Please don't change, leads to the shared folder

    // Variables for what is shown on screen
    var curSelected:Int = 0; // Which character is selected
    var icon:HealthIcon; // The healthicon of the selected character
    var menuBG:FlxSprite; // The background
    var grpMenu:FlxTypedGroup<Alphabet>; // The name of the char top right
    var grpMenuImages:FlxTypedGroup<FlxSprite>; // The currently selected char
    private var imageArray:Array<Boyfriend> = []; // Array of all the selectable characters
    var selectedCharName:FlxText; // Name of selected character

    // Additional Variables
    var alreadySelected:Bool = false; // If the character is already selected
    var doesntExist:Bool = false; // ??? I forgor
    var ifCharsAreUnlocked:Array<Bool> = FlxG.save.data.daUnlockedChars;

    override function create()
    {
        // Useless for now
        if (ifCharsAreUnlocked == null) 
        {
            ifCharsAreUnlocked = [false];
            FlxG.save.data.daUnlockedChars = ifCharsAreUnlocked;
        }
        // If the unlocked chars save data is null, fill it with defaults
        if (unlockedCharacters == null) 
        {
            unlockedCharacters = selectableCharacters;
            FlxG.save.data.unlockedChars = unlockedCharacters;
        } 
        // If names are empty, fill it with defaults
        if (unlockedCharactersNames == null) 
        {
            unlockedCharactersNames = selectableCharactersNames;
            FlxG.save.data.unlockedCharsNames = unlockedCharactersNames;
        }
        // If backgrounds are empty, fill it with defaults
        if (unlockedCharactersBGs == null) 
        {
            unlockedCharactersBGs = selectableCharactersBGs;
            FlxG.save.data.unlockedCharsBGs = unlockedCharactersBGs;
        }
        //
        if (unlockedOffsets == null)
        {
            unlockedOffsets = charOffsets;
            FlxG.save.data.unlockedOffests = unlockedOffsets;
        }

        // Making sure the background is added first to be in the back and then adding the character names and character images afterwords
        menuBG = new FlxSprite().loadGraphic(Paths.image(unlockedCharactersBGs[curSelected], backgroundFolder));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);
        grpMenu = new FlxTypedGroup<Alphabet>();
        add(grpMenu);
        grpMenuImages = new FlxTypedGroup<FlxSprite>();
        add(grpMenuImages);

        // Adds the chars to the selection
        for (i in 0...unlockedCharacters.length)
        {
            var characterText:Alphabet = new Alphabet(170, (70 * i) + 230, unlockedCharacters[i], true);
            characterText.isMenuItem = true;
            characterText.targetY = i;
            grpMenu.add(characterText);

            var characterImage:Boyfriend = new Boyfriend(0, 0, unlockedCharacters[i]);
            characterImage.scale.set(0.8, 0.8);
            addCharImageOffset(characterImage, unlockedOffsets[i][0], unlockedOffsets[i][1]);
            // characterImage.x = (FlxG.width / 2) - (characterImage.width / 2);
            // characterImage.y = (FlxG.height / 2) - (characterImage.height / 2);
            characterImage.screenCenter(XY);
            imageArray.push(characterImage);
            add(characterImage);
        }

        // Character select text at the top of the screen
        var selectionHeader:Alphabet = new Alphabet(0, 50, 'Character Select', true);
        selectionHeader.screenCenter(X);
        add(selectionHeader);

        // The left and right arrows on screen
        var arrows:FlxSprite = new FlxSprite().loadGraphic(Paths.image('arrowSelection', backgroundFolder));
        arrows.setGraphicSize(Std.int(arrows.width * 1.1));
        arrows.screenCenter();
        arrows.antialiasing = true;
        add(arrows);

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

        if (!alreadySelected)
        {
            if (leftPress)
                changeSelection(-1);
            if (rightPress)
                changeSelection(1);
            if (accepted)
            {
                alreadySelected = true;
                var daSelected:String = unlockedCharacters[curSelected];
                if (unlockedCharacters[curSelected] != 'bf')
                    PlayState.SONG.player1 = daSelected;

                FlxFlicker.flicker(imageArray[curSelected], 0);
                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    LoadingState.loadAndSwitchState(new PlayState());
                });
            }
            if (goBack)
            {
                if (PlayState.isStoryMode)
                    FlxG.switchState(new StoryMenuState());
                else
                    FlxG.switchState(new FreeplayState());
            }

            for (i in 0...imageArray.length)
            {
                imageArray[i].dance();
            }

            super.update(elapsed);
        }
    }

    // Adds an offset to an image
    function addCharImageOffset(image:Boyfriend, xOffset:Int, yOffset:Int) 
    {
        image.x += xOffset;
        image.y += yOffset;
    }

    // Changes the currently selected character
    function changeSelection(changeAmount:Int = 0):Void
    {
        curSelected += changeAmount;
        if (curSelected < 0)
            curSelected = unlockedCharacters.length - 1;
        if (curSelected >= unlockedCharacters.length)
            curSelected = 0;
        
        for (i in 0...imageArray.length)
        {
            imageArray[i].alpha = 0;
        }
        imageArray[curSelected].alpha = 1;

        var tempInt:Int = 0;

        for (item in grpMenu.members)
        {
            item.targetY = tempInt - curSelected;
            tempInt++;

            item.alpha = 0;

            if (item.targetY == 0)
            {
                // Empty I guess, I forgot what this was supposed to be for
            }
        }

        charCheck();
    }

    // Checks for what char is selected and creates an icon for it
    function charCheck()
    {
        doesntExist = false;
        remove(icon);

        menuBG.loadGraphic(unlockedCharactersBGs[curSelected]);

        doesntExist = true;

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
        icon.screenCenter(X);
        icon.setGraphicSize(-4);
        icon.y = (bar.y - (icon.height / 2)) - 20;
        add(icon);
    }
}