$date=16/5/2015
I've optimized the tile map rendering system a bit so now it's about 10-15% faster.
It's still beyond what I was hoping for, but I think this is as good as it gets.

I also realized at a point that I could add repeated background images quite easily:

<img class="center shadow round" src="/inc/posts/backgroundbitmaps.jpg" />

It's actually really cheap too, memory *and* speedwise: The background is a 
gradient that's just 4 pixels wide and 160 pixels tall (to support parallax 
vertical scrolling). When filling the line for the background, I first draw the
bitmap's line just as usual. Then however I `memcpy` the fragment of the line
and copy it once. Then I repeat the process but with twice the size. Not
really a big deal, but it's fairly efficient (the `memcpy_P` function that
copies memory from flash to ram is also very efficient by the way).

I think I want to implement a jump'n'run game at some point, just because
it might look very neat :).