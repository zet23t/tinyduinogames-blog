$date=15/4/2015

Drawing textures on the TinyScreen is also possible with reasonable frame rates:

![](/inc/texturingefforts-debuganim.gif)

This demo shows that it's possible to draw >20 small textures with a transparent color index (8x8) and two larger images at the same time on the screen while maintaining around 16fps. It's also possible to fill the entire screen. Optimized with using `memcpy_P`, this is even running at 33ms, so about 30fps!

-MORE-

Lesson learned: memcpy and `memcpy_P` are much faster than looping. Without `memcpy_P`, filling the entire screen with the texture would take 55ms. With `memcpy_P` it decreased to 34ms, which is reasonably fast for many applications. Downside is that it uses quite some memory. The 16x16 texture takes about 280 bytes of flash memory. But this is small enough to allow creating a tilemap and using it for creating a tile based game - like Zelda or Super Mario. From what I see, I guess that such a game would run at 15fps+.

![](/inc/texturingefforts-mapcircle.gif)

If you want to try it yourself, [here's the link to the github repo of the commit that is doing what is shown above!](https://github.com/zet23t/tinyduinogame-playground/tree/58cd49e0aa43b49391da0657855fe35a79779f8f)