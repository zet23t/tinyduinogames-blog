$date=21/4/2015
<img class="floatleft" src="/inc/posts/asteroids-002.png" />
<img class="floatleft" src="/inc/posts/asteroids-001.png" />

<br clear="both" />
I've continued working a bit on the Asteroids game while redoing the blog!

-MORE-

The game has now a proper start screen, a pause screen and when all asteroids
are destroyed, the next level starts. Also, there's now a threat level bar on the 
right which displays the number of asteroids flying around. On the left there's
a shield energy meter that decreases each time when the ship hits an asteroid. 
The asteroid and the ship get repulsed then.

Missing stuff:

* There's right now no level counting or
level difficulty increases
* No score tracking or displaying
* No death by asteroids (with explosion)
* No finish screen

Memory isn't an issue right now. I use 24kb of the flash memory and 1.3kb of RAM. 
For what's left to do, that's more than enough. 

However, I had a small realization when doing the graphic artwork that I wasn't aware
of that sharply: An 256x128 image with 8bit color depth is the entire flash memory that's available. 
I stumbled over that when resizing my tileset image a bit. It looks like this right now (3x magnified):

<img src="/inc/posts/asteroids-003.png" width="480" height="192" class='center' />

Once the game is complete, I want to make the ship turning smoother by mirroring the ship sprites 
vertically and having 8 images for half a turn. Shooting works already with 16 directions.