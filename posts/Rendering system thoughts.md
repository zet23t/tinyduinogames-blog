$date=13/4/2015

Tiny Circuits provides [a library](https://codebender.cc/library/TinyScreen#TinyScreen.h) for using the TinyScreen. There are various useful functions like drawing pixels, rectangles, lines and even text! This is certainly cool to get started but there is a major drawback when it comes to updating the screen with some more graphical content: Flickering. Sadly, most of the functionality in that library is therefore not suitable for making games except for a few…

-MORE-

Coming from PC programming with superfluous amounts of RAM, it’s quite normal to draw in memory and send it to the screen when it’s done. This is usually without flickering or anything alike. The problem with the Arduino is that the 96×64 pixels on the screen would require 6144 bytes for doing this trick. That’s about 4kb more than we have in total. Even if you’d go for monochrome and using all bits, it would practically fill the entire RAM without letting you much space to do anything else.

The technique that we have to rely on is to send the data to the screen line by line. This is also what the [Flappy Birds demo](https://codebender.cc/sketch:77043) is doing: Drawing the screen from top to bottom line by line. This is quite efficient and allows us to update the screen with about 50fps! As long as each line is empty.

The problem with this approach is that you can’t simply draw stuff on the screen and forget about it: You have to keep track of the stuff you want to draw and scan it later – line by line. Doing this efficiently is the key to making games.

The Flappy Bird Demo is doing this without much algorithms around it: It’s basically one function that takes care of drawing. While this is quite efficient, it’s quite hard to work with this approach on something bigger as it lacks flexibility to do something else.

The approach that I want to take is to have a list of render commands that get flushed to the screen each frame. Each render command has to satisfy an interface that is drawing the command to the screen line by line. Meanwhile, each rendercommand has to be as small as possible in memory. And since we want to avoid malloc / free / new / delete altogether as well and do static / stack allocations ahead of time, this’ll require to make some sacrifices.

So when mentioning “interface” in the previous paragrap, you maybe built the mental model of a C++ class framework already. But I’d like to wreck your dreams as soon as possible, because this is not feasible in my opinion. I don’t have much C++ experience (almost none), but it’s sort of hard to control every byte in your program when using classes with virtual methods or multiple inheritance. Moreover, it turns out that static function calls are way cheaper than virtual method calls: Just placing a function in a different file and specifying it in a header will make a function call to that function about twice as slow according to my finding. While this is normally not that much of a problem, it quickly becomes a heavy problem when you plan to call various functions for each horizontal line on the screen for each object you want to draw. You can’t afford that when you want to stay above 20fps.

So in order to make a fast rendering system, I want to sacrifice the object oriented programming language elements first. After all, object oriented programming is an idea, not a programming language and secondly, we won’t have more than a few thousand lines of code. So “reusability” is not what I am aiming for.

While this may sound horrible to you, rest assured: The core of the idea remains actually “object oriened”:

* Each drawing command is represented in a RenderCommand struct
* The drawing commands are used in methods that are prefixed with “RenderCommand_” and take a pointer to a RenderCommand struct as first argument
* These functions are working with the dara of those structs (objects).
* Each RenderCommand has a type that is used to split functionality into its own branches that take care of:
    * Drawing Rectangles
    * Drawing Circles
    * Drawing Text
    * Etc.
* Render Commands are stored in an array of fixed length in a RenderScreen struct that is statically allocated

The last point may sound also “unclean”, however it doesn’t make sense to waste resources when you can’t hold more than a handful commands in RAM anyway as well not being able to draw them all without dropping the FPS below our 20fps mark. With a screen of this size, 60 draw commands should be enough for most games. Don’t forget: A render command can be also something more complex than a rectangle – it can be complex geometry or simply something that forwards a request to fill a line to draw to some specialized logic. At the core, the system is about reducing the amount of cycles spent on drawing – which means to apply some basic data structures.