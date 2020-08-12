# VR-code
 Matlab based virtual reaility for flies

Typical use would be to call the function "temp_reality_jump" (or an older version without jumps -- temp_reality). 

This code is creates a virtual 2D environment that the fly can interact with. Note that it needs inputs from the ball (typically FicTrac) that come through a NIDAQ acquisition board (in this case National Instruments PCIe-6351). This code can control Reiser visual LED panels, lasers to heat fly (or for optogenetics), closed loop temperature control with a thermal camera, etc. The code can also trigger events (like bar jumps) absed ont he flies behavior (for example only if the fly is walking straight).  
