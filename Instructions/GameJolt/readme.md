# READ

These are not yet done, just getting this area ready for when I add instructions

I am using [TentaRJ's GameJolt Integration](https://github.com/TentaRJ/GameJolt-FNF-Integration) for this. I am just showing ways of implementing it.

# Instructions

1. Firstly, install these libraries and rebuild systools (for what is needed)

```
haxelib git tentools https://github.com/TentaRJ/tentools.git
haxelib git systools https://github.com/haya3218/systools
haxelib run lime rebuild systools [windows, mac, linux]
```

2. After that has been done, ensure you put it into your project.xml file

```
<haxelib name="tentools" />
<haxelib name="systools" />
<ndll name="systools" haxelib="systools" />
```
