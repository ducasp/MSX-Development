# jANSI v1.1

Original version (1.0) for MSX developed by MST (MSX Software Team) in 
Netherlands by early 90's.

My version improves it in two manners:

- Some BBS's want to locate cursor at last line/column by sending commands to
move down 255 and right 255. jANSI will consider a two digit value that will
not move cursor to the last line/column, causing erroneous screen capabilities
detection. They did this because of a buggy BBS, I've changed it so if it is
three digit, will consider value 99 that is enough for those purposes. :)

- If screen background color (changed by setting a different background color
and clearing the screen) is not black, black was rendered as the border color.
They probably done that because their sprite cursor leave marks on the screen
in such case. I've changed it so if you disable cursor (ESCx5) it will not tie
black to border color and disables the sprite as well, so no marks are left on
screen. This change was only possible due to VDP Jedi Master Grauw help. :)
