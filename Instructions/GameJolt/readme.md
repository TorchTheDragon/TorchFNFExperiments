# READ

These are not yet done, just getting this area ready for when I add instructions

I am using [TentaRJ's GameJolt Integration](https://github.com/TentaRJ/GameJolt-FNF-Integration) for this. ~~I am just showing ways of implementing it.~~
Correction, I am using it as a base as I had to rewite parts of it.

# Instructions

1. Firstly, install these libraries and rebuild systools (for what is needed)

```
haxelib git tentools https://github.com/TentaRJ/tentools.git
haxelib git systools https://github.com/haya3218/retools.git
haxelib run lime rebuild systools [windows, mac, linux]
```

2. After that has been done, ensure you put it into your project.xml file

```
<haxelib name="tentools" />
<haxelib name="systools" />
<ndll name="systools" haxelib="systools" />
```

3. Then you need to put these three files into your source files. (One of them is just because I plan on making a file for universal functions)

 - [TorchsCoolFunctions](https://github.com/TorchTheDragon/TorchFNFExperiments/blob/main/Engines/PsychEngine/source/TorchsCoolFunctions.hx)
 - [TorchsGJFunctions](https://github.com/TorchTheDragon/TorchFNFExperiments/blob/main/Engines/PsychEngine/source/TorchsGJFunctions.hx)
 - [TorchsGameJolt](https://github.com/TorchTheDragon/TorchFNFExperiments/blob/main/Engines/PsychEngine/source/TorchsGameJolt.hx)

Note: In the actual GameJolt source file you need to change [this line](https://github.com/TorchTheDragon/TorchFNFExperiments/blob/main/Engines/PsychEngine/source/TorchsGameJolt.hx#L432) to either another image or make it blank (I don't think nulling it will work, havent tested it though)

4. Add a switch to the GameJolt state where it is needed.
