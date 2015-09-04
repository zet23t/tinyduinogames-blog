$date=14/4/2015
The first two blog entries haven't gone into detail, so I'd like to change this now - with an ugly picture taken and some explanations about it:

![](/inc/scanlinerendering.png)

What you see is a photo of a rendering test. I am drawing circles and rectangles with some simple calls:

-MORE-

![](/inc/codesample.png)

The arguments to these function calls don't matter, what you see is however that the system is fairly simple: We can call functions to queue drawing primitives. Only when "flush" is called, the geometry data is drawn to the screen. You might also wonder why the text "oh hay" is not shown on the screen - that's because I exceeded the render command count of 64 commands. This is ... unfortunate. But the debug data here is a bit more interesting since it explains a few things of what is going on:

You can see the frame time and a 50ms marker at pixel position x=50 - so you can guess that this screen takes about 40ms to draw.  This is only possible because the system is doing some optimizations while scanning the command list:

Every 16 pixels (starting with y=0), the list of render commands is scanned entirely:
Commands that don't matter any more are removed from the list. The number of objects in the list are marked with the red lines on the screen. By filtering obsolete render commands, subsequent filter processes take fewer cycles.
During the filtering, commands that are relevant for the next 16 lines are kept in a linked list. (pointed out with blue lines / white lines on the screen). You can see that while we start with a lot (64) commands in the list, so we only have a few elements to scan in each line later on until the end of our 16-lines slice
Each following line, we walk over the list of commands that are within our 96x16 window of interest
Everytime a command falls out, we update the list pointers to omit this command in later lines
The list is rebuilt when the full scan happens every 16 pixels
Without this system, drawing everything would take about 20ms longer to draw the same screen:

![](/inc/scanline_unoptimized.jpg)

The blue time indicator time is between the 50ms marker and the 64 render object count marker.

# Structs

Now to the code I wrote: Foremost is the struct definition:

    typedef struct RenderCommand_s {
      unsigned char type, color, nextIndex;
      union {
        struct {
          // rect
          unsigned char x1, y1, w, y2;
        } rect;
        struct {
          // circle
          unsigned char x, y, r;
          unsigned short r2;
        } circle;
        struct {
          // star
          unsigned char x, y, size;
        } star;
        struct {
          // text
          unsigned char x,y,fontIndex;
          char *str;
        } text;
      };
    } RenderCommand;

There are three char sized values that are shared between all render command types:

* type: The type of the render command
* color: The rgb color value of the command
* nextIndex: An index position in the list of render commands to continue drawing to skip commands that are not present in our range of scan lines

The following union section is describing each type individually. The union block is a way to let the compiler know that a block of memory is following with varying content, depending on how the entire structure is used. The size of the union is determined by the largest structure in the union. For instance, the rectangle part is using 4 characters to describe its form - so it's 4 bytes large in memory. The circle structure is using 3 chars and one short - so it's 5 bytes large. It is also the largest structure in the union. Therefore the entire RenderCommand size is 8 bytes right now (sadly, some more bytes will be needed in the future).

If you have programmed with C before, [you might wonder if the struct is padded to align it in memory](http://forum.arduino.cc/index.php?topic=78026.0). I wondered the same - but it looks like there is no padding or memory alignment. It's optimized for size - probably because memory is more precious than saving cycles (if non aligned memory is even having an impact at all - I am unaware of such things).

So with 8 bytes per render command, we can have a few commands in memory without sacrificing too much memory. I picked 64 - so I am spending 512 bytes of memory for the rendering system.

The commands are themselves organized in a RenderScene structure:

    typedef struct RenderScreen_s {
      const FONT_INFO *fontFormats[RENDERSCREEN_TEXT_FORMAT_COUNT];
      RenderCommand commands[RENDERSCREEN_MAX_COMMANDS];
      unsigned char commandCount;
    } RenderScreen;

It's pretty simple: A list of font formats (probably only one can be afforded - though maybe a special font set could be used for numbers), the list of render commands and a counter for the actual number of render commands. So we are constrained to 256 commands - more than enough with our screen size.

# Queuing rectangles

Here's a snippet of how a rectangle is queued for drawing:

    static RenderScreen _renderScreen;

    static void RenderScreen_drawRect (int x, int y, int w, int h, int color) {
      if (_renderScreen.commandCount >= RENDERSCREEN_MAX_COMMANDS) return;
      if (x>=RENDERSCREEN_WIDTH || y >= RENDERSCREEN_HEIGHT || w <= 0 || h <= 0) return;
      int x2 = x+w;
      int y2 = y+h;
      if (x2 <= 0 || y2  RENDERSCREEN_WIDTH) x2 = RENDERSCREEN_WIDTH;
      if (y2 > RENDERSCREEN_HEIGHT) y2 = RENDERSCREEN_HEIGHT;
      if (x < 0) x = 0;
      if (y type = RENDERCOMMAND_TRECT;
      command->color = color;
      command->rect.x1 = x;
      command->rect.y1 = y;
      command->rect.w = x2-x;
      command->rect.y2 = y2;
    }

The first line is our global RenderScreen structure. While this is ugly in other programming environments, it makes more sense in the environment of Arduino programming: We could also pass the RenderScreen structure to functions that operate on that struct, therefore having a more "clean" implementation. However, it's highly unlikely that we'd need more than one render scene. Moreover, accessing a structure in global memory is actually faster than accessing the memory through a pointer that is laying on the stack. Additionally we'd need to pay flash memory for the additional function argument in our final binary. This is about 2-4 bytes more per function call. This can quickly sum up to 300-400 bytes that we can safe and use for something else more useful than something like code aesthetics.

The function is declared static and is included in the .ino file directly: Static functions consume less memory (for some reason I don't know) and calling them seems also to be a tiny bit faster. I assume that the compiler can avoid far jumps and do near jumps instead when calling those. Again, this can save multiple hundreds of bytes in the final binary!

The first lines in the function are trying to reject the command early on: If the command is not intersecting the screen, we can just ignore it anyway - no memory will be used. The coordinates of the rect are passed as ints (so 16 bit) - this way the caller can be quite naive in regards of culling against the screen coordinates. The coordinates are converted to mere char values in the following code that is also handling the clipping.

The rectangle's x,y coordinate is stored next to the entire width and the bottom y coordinate. The width is more important than an "x2" value because we can use that value directly to do a memset call without further arithmetic later on.

# Drawing rectangles

The next function that I want to highlight is the function for drawing the render commands. I'll shortening the code to the rectangle drawing part:

    static char RenderScreen_fillLine(RenderCommand *command,char y,unsigned char lineBuffer[RENDERSCREEN_WIDTH]) {
      if (command->type == RENDERCOMMAND_TRECT) {
        if (y >= command->rect.y1 && yrect.y2) {
          memset(&lineBuffer[command->rect.x1],command->color,command->rect.w);
        }
        return command->rect.y2 <= y;
      }
    ...
    return 1;

As you can see, the "fillLine" function part for drawing the rectangle is really simple: When our y-line is intersecting the rectangle, we set the memory with our color for the given range. When the y-line is below the rect, we return a 1, otherwise a 0. This helps our drawing logic to update the drawing list to omit this command once the rectangle is out of scope and isn't important any more. This saves some cycles in subsequent scans during drawing lines.

# Culling rectangles

Another important aspect is culling: We want to remove render commands for certain sections of the screen once they will be out of scope. Again, this code is only for the rectangles - and it's fairly simple:

    #define RENDERSCREEN_SLICE 15
    static char RenderScreen_onVLine(RenderCommand *command, char y) {
      if (command->type == RENDERCOMMAND_TRECT) {
        if (y + RENDERSCREEN_SLICE rect.y1) return -1;
        if (y >= command->rect.y2) return 1;
        return 0;
      }
      ...
    }

This function returns 0 when the command is intersecting with our "slice" of the screen that we will draw next. If the element is out of scope, 1 is returned. If it's getting into scope further down, -1 is returned.

This filtering function is called for each "slice" on the screen - the amount is defined as RENDERSCREEN_SLICE. The number must be (power of two - 1). This way, a simple bitwise-and (&) operation can be used to determine the position in the slice. Modulo is more expensive (under certain conditions - the code optimizer is doing some helping here during compilation).

The "flush" function is more complex since it needs to do the "clever" part of the code: Culling, removing, omitting.

    static void RenderScreen_flush() {
      unsigned char lineBuffer[RENDERSCREEN_WIDTH];
      TinyScreenC_goTo(0, 0);
      TinyScreenC_startData();
      unsigned char first; // position of first element in the list that's in the current slice
      for (char i = 0; i < RENDERSCREEN_HEIGHT; i += 1) {
        memset(lineBuffer, 0, RENDERSCREEN_WIDTH);
        if ((i&(RENDERSCREEN_SLICE)) == 0) {
          // filter the element that are in the next slice.
          first = 0xff; // invalid position in case no element is visible
          unsigned char p = 0, last = 0xff;
          for (char j=0;j<_renderScreen.commandCount;j+=1) {
              RenderCommand *command = &_renderScreen.commands[j];
              char cmp = RenderScreen_onVLine(command,i);           
              if (cmp == 0) {   // element is intersecting the slice, let's put it into our linked list             
              command->nextIndex = 0xff;
              if (first == 0xff) {
                last = first = p;
              } else {
                _renderScreen.commands[last].nextIndex = p;
                last = p;
              }
            } else if (cmp == 1) {
              // element is not important any more, remove it
              continue;
            }
            // remove elements that are no longer needed by overwriting.
            _renderScreen.commands[p++] = _renderScreen.commands[j];
          }
          // set new command count
          _renderScreen.commandCount = p;  
        }
        unsigned char prev = 0xff;
        for (unsigned char j=first;j<_renderScreen.commandCount;j = _renderScreen.commands[j].nextIndex) {
          if (RenderScreen_fillLine(&_renderScreen.commands[j],i,lineBuffer)) {
            // remove the element from the current slice linked list
            if (prev == 0xff) {
              first = _renderScreen.commands[j].nextIndex;
            } else {
              _renderScreen.commands[prev].nextIndex = _renderScreen.commands[j].nextIndex;
            }
          } else {
            prev = j;
          }
        }
        TinyScreenC_writeBuffer(lineBuffer, RENDERSCREEN_WIDTH);
      }
      TinyScreenC_endTransfer();
      _renderScreen.commandCount = 0;
    }


It is certainly more difficult to read. It's handling the parts I've described before.
You can explore the code as it was when writing the blog article over at [my github repository](https://github.com/zet23t/tinyduinogame-playground/tree/9d9a9bf14c6444132b85bfe25e1b1980998e8e40).