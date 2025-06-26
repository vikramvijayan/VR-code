# VR-code
 This is code to build a virtual reaility environment for fruit flies. 

**Typical use would be to call the function "temp_reality_jump" (or an older version without jumps -- temp_reality).**

This code creates a virtual 2D environment that the fly can interact with. Note that it needs:
1) Inputs from the ball (typically FicTrac) that come through 
2) a NIDAQ acquisition board (in this case National Instruments PCIe-6351).
3) This code can control Reiser visual LED panels,
4) lasers to heat fly (or for optogenetics), 
5) closed loop temperature control with a FLIR thermal camera, etc. 

The code can also trigger events (like bar jumps) based on the flies behavior (for example only if the fly is walking straight). This code has been used by others in the lab with simple modifications to trigger events like sucrose feeding.  
