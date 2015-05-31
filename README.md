
The following code will generate a single line path out of a 3D model
It will begin by constructing a support structure or grid
Then it will create a random path on the surface of the model following 3 criteria:
1.The next point is far enough away (minDist)
2.The next point is not too far away (minDist)
3.The next point follows a level of tangency next to the two previous points (angleMult)

In case a valid point can't be found after "debugN" itterations, the constrainst willl be ignored to allow the program to continue

For the 3D model to work, first save file as an .OBJ, open file in text editor and remove every line that does not start with 'V'

Sebastian Morales 2013. In advance I ampologize, first time teaching myself how to code.
