$date=16/4/2015

I've been spending quite some amount of time to track down an error yesterday - and failed.

Only when I woke up this morning I knew where the cause of the problem was:

    static void RenderScreen_drawRectTexturedUV (int x, int y, int w, int h, unsigned char imageId, int u, int v) {
      RenderCommand *cmd = RenderScreen_drawRectTextured(x,y,w,h,imageId);
      cmd->rect.u+=u;
      cmd->rect.v+=v;
    }

The problem with this piece of code is that it's not checking if cmd is NULL. It is designed to return NULL when the render command is culled for example and therefore isn't added.

-MORE-

So in such cases, it would write directly to the memory at address 0 (or with some offsets in that range)



I got interested in what is going on there in more detail. I wrote a test program to manipulate the address 0 data, but I couldn't get much out of this since my program wouldn't write sensible output to the serial port anymore in such cases.

Next I did this:

    static int Foobar[] = {1,2,3,4,5};
    void setup() {
      // put your setup code here, to run once:
      Serial.begin(9600);
      Serial.println("Begin tests");
      Serial.println("Address at NULL: "+String((int)NULL));
      Serial.println("Address at Foobar: "+String((int)Foobar));
      Serial.println("Address at Foobar[2048]: "+String((int)Foobar[2048]));
      Serial.println("Address at Foobar[2049]: "+String((int)Foobar[2049]));
      Serial.println("Done Testing");
    }

and the result was this:

    Begin tests
    Address at NULL: 0
    Address at Foobar: 262
    Address at Foobar[2048]: 1
    Address at Foobar[2049]: 2
    Done Testing

One of my assumptions turned out to be as expected: Increasing a memory address by the amount of entirely available RAM will loop and result in the same memory location when looked up (2kb memory => +2048 is the same memory location).

After these fairly simple experiments I decided to look up the documentation and see what I can learn of it. I found this diagram on page 19 fairly interesting:

![](/inc/memory.png)

If I understand it correctly, I can directly access the registers via memory addresses 0-31. Furthermore, the I/O registers appear to be used for various things such as the stack pointer.

So what happens when you access a NULL pointer is NOT that the program crashes like you might be used to when programming on a PC. Instead, you manipulate the program behavior, introducing many new interesting new effects (that you don't want to have).

Hopefully I won't need so much time to locate such a bug in the future since I am now more aware of what the typical symptoms are.