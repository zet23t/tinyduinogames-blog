The [TinyDuino](https://tiny-circuits.com/tinyduino_overview) platform by [Tiny-Circuits](https://tiny-circuits.com/) is an [Arduino](http://www.arduino.cc/) compatible system. 

Core specs:

* Atmega328P processor
	* 8MHz frequency
	* 32KB Flash (memory where the program is uploaded to)
	* 2KB RAM
	* 1KB EEPROM (persistent memory for application)
* Powered with Lithium battery
* Programmed with Arduino IDE using C/C++
* [Datasheet](http://www.atmel.com/images/Atmel-8271-8-bit-AVR-Microcontroller-ATmega48A-48PA-88A-88PA-168A-168PA-328-328P_datasheet_Complete.pdf)

The [shields](http://en.wikipedia.org/wiki/Arduino#Shields) that I use are:

* [TinyShield USB](https://tiny-circuits.com/tinyshield-usb.html)
	* Used to load battery and program the processor
	* *Top Mount model*: In case you want to buy one for your own game kit, be aware that there's a side-mount and a top-mount shield.
* [TinyScreen](https://tiny-circuits.com/tinyscreen.html)
	* 96x64 resolution
	* 8bit or 16bit color resolution
	* [Datasheet](https://www.newhavendisplay.com/app_notes/SSD1331.pdf)
* [Tinyshield Joystick](https://tiny-circuits.com/tinyshield-joystick.html)
	* Two Analog Joysticks, 10-bit ADC reading for each axis of each joystick returned
	* Two discrete pushbuttons

These shields were part my backer reward of [a kickstarter campaign to crowd fund the TinyScreen](https://www.kickstarter.com/projects/kenburns/tinyscreen-a-color-display-the-size-of-your-thumb).