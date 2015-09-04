I've finally added tilemap support for my rendering system:

<img class="center" src="/inc/posts/tilemap-rendering.gif" width="320" height="216"  />

The performance is so-so: It's more memory and CPU efficient than
rendering individual sprites by quite a bit. All you need to do is to
specify an image atlas containing all images with power-of-two 
sizes, ordered in a n x m way. Up to 16x16 maps are supported (though that 
is rather unlikely due to general memory constraints).

-MORE-

The tilemap itself is a character array where the lower 4 bits are the x
coordinate on the tilemap and the higher 4 bits are the y coordinate:

	  static unsigned char dataMap[] = {
	    0x00, 0x01,0x00,0x02, 0x00, 0x00,0x04,
	    0x10, 0x11,0x11,0x10, 0x11, 0x10,0x10,
	    0x00, 0x01,0x00,0x03, 0x01, 0x04,0x03,
	    0x08, 0x08,0x08,0x08, 0x08, 0x08,0x08,
	    0x10, 0x11,0x11,0x10, 0x11, 0x10,0x10,
	  };

Using this [tileset](http://opengameart.org/content/town-tiles) by [surt](http://opengameart.org/users/surt):

<img class="center" src="/inc/posts/tileset.png" />

... you should be able to figure this out:

0x00 means (0,0) on the atlas, 0x01 means (0,1), 0x10 means (1,0) and so on.

0xff is a special case to ignore that tile and leave it blank (transparent).

In this case the atlas uses 16x16 tiles and uses a 7x5 tilemap to fill the entire
screen. 

To draw the tilemap, it must be registered in the render screen structure:

	  _renderScreen.tileMap[0].tileSizeXBits = 4;
	  _renderScreen.tileMap[0].tileSizeYBits = 4;
	  _renderScreen.tileMap[0].dataMapWidth = 7;
	  _renderScreen.tileMap[0].dataMapHeight = 5;
	  _renderScreen.tileMap[0].dataMap = dataMap;
	  _renderScreen.tileMap[0].imageId = 0;

and can then be used in a tilemap draw command: 

  	RenderScreen_drawRectTileMap(screenX,screenY,width,height,tilemapId);

This way you can specify where a tilemap should be drawn, how big it is and of
course in which order. This way it should also be possible to use this to draw 
UIs as well. 

The rendering is utilizing 48ms for a 16x16 tileset (bigger renders faster). Drawing
some more stuff will raise this number, but this way it's possible to draw levels and
have some action on it without making it a slideshow. 

I was hoping for some better figures, but the individual image copying actions take 
its tolls. The code is up on [github](https://github.com/zet23t/tinyduinogame-playground), 
as usual.