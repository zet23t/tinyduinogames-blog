$date=9/12/2015

Lot's of stuff happened since my last post! One thing I got super excited of is the [the TinyArcade Kickstarter Campaign](https://www.kickstarter.com/projects/kenburns/tiny-arcade-a-retro-tiny-playable-game-cabinet) and I am looking forward to receive my pick next March. 

[Tiny Circuits](https://tiny-circuits.com/) was even so kind to send me an early production prototype so I can work on making games for that! The system itself is quite compatible to the old tiny duino board, just slimmer and a lot faster with much more RAM. And the flash memory is even reprogrammable so programs can be installed from SD card as well - which is  exciting for distributing games because it won't need an IDE any more.

So I've begun working on a new framework that uses C++. I'm fairly new to programming with C++, so this is also a learning process for me. [It's available on GitHub](https://github.com/zet23t/td2play). I've also managed to make a new game that resembes "Simon Says" but is named "Duino says":

<img class='center' src='/inc/posts/td2p-005-duinosays2.gif' />

-MORE-

You might also notice that the animated gif is not a video from the actual TinyScreen - that's because it's running in a simulator that's compiled and running through a normal IDE ([CodeBlocks](http://www.codeblocks.org/) in this case). The simulator code is also to be found on the same GitHub repository. Being able to compile and run code on the PC enables me to develop faster. All it does is to provide the TinyScreen API and map it to OpenGL calls using [GLFW3](http://www.glfw.org/docs/latest/), a multi plattform library. 

Last but not least: Having similar components as the TinyArcade is made of, I realized that using the same components I could make a tiny gameboy case that houses the TinyDuino hardware. It really looks very similar to an actual gameboy (I just need a lighter grey filament for that). The case enables using the four screen buttons, so I can test all TS+ hardware elements easily. It's not finished yet and I went through quite a couple of designs so far. I also want to make an extended version that houses an SD card a bluetooth board.

<img class='center' src='/inc/posts/tinyboy01.jpg' />