$date=12/4/2015

I received my [TinyDuino Game Kit](https://www.kickstarter.com/projects/kenburns/tinyscreen-a-color-display-the-size-of-your-thumb) as a backer reward two weeks ago. I had zero experience with programming for the Arduino platform. However, I have quite some experience with C and game programming in general, so I want to blog now my findings and experiences.

![](/inc/MyTinyDuinoGameKit.jpg)

-MORE-

The TinyDuino platform by [Tiny Circuits](https://tiny-circuits.com/) is an Arduino compatible system. At the core is an Atmega328P processor running with 8Mhz. It has 32kb flash memory, 2kb of RAM and 1kb of EEPROM memory.

The Kickstarter funding was intended to finance the TinyScreen shield for the system but it included also a gamepad with two analog sticks. That really adorable small system convinced me instantly to back this project.

Having 2kb of RAM, 32kb of programmable space and a 96×64 sized display about as big as your thumb seems to be a bit harsh for making games, but the limitations are useful to keep projects small. Learning the system is easy – the installation took less than 30 minutes. Installing the Arduino IDE and the required USB drivers was almost enough – I only had to reconfigure the serial port to use com1 and after that, everything worked as it should.

My focus for this platform is, obviously, making games. Games that run at 20 FPS and that are a bit bigger than the classic Pong or Space Invader game. The technical limitations are steep, so everything matters. To give you an idea: The text you have just read has almost as many characters as the system has RAM!

So for each blog I do here, I’ll try to point out my thoughts and findings about the peculiarities of the system. In the end, there’ll be some games – hopefully!