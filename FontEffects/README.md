# Font Effects
This script adds two font properties to RPG Maker XP: text shadow and outline.

### How to use
To use these properties in a specific window, use the following lines:
```
self.contents.font.shadow = true
self.contents.font.outline = true
```

If you want to set these properties to be used by default, use these lines anywhere:
```
Font.default_shadow = true
Font.default_outline = true
```

Colors for shadow and outline can be changed using `.shadow_color` and `.out_color`.
Alternatively, `Font.default_shadow_color` and `Font.default_out_color` can be used to make a general change.

### Screenshots

Text with shadow

![Shadow](https://raw.githubusercontent.com/do-sieg/RPGMaker/master/FontEffects/font_fx_screen1.png)



Text with outline

![Shadow](https://raw.githubusercontent.com/do-sieg/RPGMaker/master/FontEffects/font_fx_screen2.png)

Text with shadow and outline

![Shadow](https://raw.githubusercontent.com/do-sieg/RPGMaker/master/FontEffects/font_fx_screen3.png)
