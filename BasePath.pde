//
//The following code will generate a single line path out of a 3D model
//It will begin by constructing a support structure or grid
//Then it will create a random path on the surface of the model following 3 criteria:
//  1.The next point is far enough away (minDist)
//  2.The next point is not too far away (minDist)
//  3.The next point follows a level of tangency next to the two previous points (angleMult)
// 
// In case a valid point can't be found after "debugN" itterations, the constrainst willl be ignored to allow the program to continue
//
// For the 3D model to work, first save file as an .OBJ, open file in text editor and remove every line that does not start with 'V'
//
// Sebastian Morales 2013. In advance I ampologize, first time teaching myself how to code.
//

// Import 
import peasy.*;
import java.util.Collections;

// User Variables
String fileName = "faceSS.txt";
int gridResolution = 10;// support grid

double minDist=3;// Minumum Distance between two points. 
double maxDist=8.;//Max Distance between two points
double angleMult=.81;//.This number will ensure a level of tangency and continuity in the path
int iterrationN=1800;//number of segments desired
int debugN=100;// In case no valid point is found after debugN times, constraints will be ignored and the path will be able to continue
// Variables
String[] file;
PeasyCam cam;
ArrayList<SortYVector> Yvertexes = new ArrayList();//SortYVector will be used to sort by Y
ArrayList<SortXVector> Xvertexes = new ArrayList();//SortYVector will be used to sort by X
ArrayList<SortZYVector> Zvertexes = new ArrayList();//SortYVector will be used to sort by Y
ArrayList<PVector> pathVertexes = new ArrayList();
float limitMaxY, limitMinY, limitMaxX, limitMinX, limitMaxZ, limitMinZ;
double horizontalPos, verticalPos;
int xRawResolution, yRawResolution;
int xIncrement, yIncrement;
int photo=1;

PVector iniP;
PVector pp=iniP;
PVector oldP=iniP;
PVector randP;
PVector oldPath=iniP;
int randN;
int pointsFound=0;

double distR1;//distnace from initial point to newpoint
double distR0;//distance from old point to newpoint 

int debug=100;
float rotation=0;

void setup()
{
  // Initial Setup
  println("Running begin");
  size(1250, 750, P3D);
  perspective(PI/3, (float)width/height, 0.01, 500);
  cam = new PeasyCam(this, 10);

  // Open file
  file=loadStrings(fileName);
  println(fileName+" opened");

  //Iterate Through the File
  for (int i = 0; i < file.length; i++)
  {
    // Listen for Vertex Lines Only
    if (file[i].charAt(0)=='v')
    {
      String[] vertexArray = split(file[i].substring(2, file[i].length()), ' ');

      // Sort X
      SortXVector vX = new SortXVector (int(vertexArray[0]), int(vertexArray[1]), int(vertexArray[2]));      
      // Sort Y
      SortYVector vY = new SortYVector(int(vertexArray[0]), int(vertexArray[1]), int(vertexArray[2]));
      // Sort Z
      SortZYVector vZ = new SortZYVector(int(vertexArray[0]), int(vertexArray[1]), int(vertexArray[2]));

      Xvertexes.add(vX);
      Yvertexes.add(vY);
      Zvertexes.add(vZ);
    }
  }

  Collections.sort(Xvertexes);
  Collections.sort(Yvertexes);

  limitMinY=(Yvertexes.get(0)).y;
  limitMaxY=(Yvertexes.get(Yvertexes.size()-1)).y;
  yRawResolution = (int)(limitMaxY - limitMinY);

  limitMinX=(Xvertexes.get(0)).x;
  limitMaxX=(Xvertexes.get(Xvertexes.size()-1)).x;  
  xRawResolution = (int)(limitMaxX - limitMinX);

  limitMinZ=(Zvertexes.get(0)).z;
  limitMaxZ=(Zvertexes.get(Zvertexes.size()-1)).z;

  xIncrement = (int)(xRawResolution / gridResolution);
  println("X Increment"+xIncrement);
  yIncrement = (int)(yRawResolution / gridResolution);

  boolean direction = false;
  for (int i = (int)limitMinY; i < limitMaxY; i+= xIncrement)
  { 
    direction = !direction;
    pathVertexes.addAll(getLineWithDirection(Xvertexes, direction, true, i, 1));
  }

  pathVertexes.add(new PVector(limitMinX, limitMaxY, 0));


  for (int i = (int)limitMinX; i < limitMaxX; i+= xIncrement)
  {
    direction = !direction;
    pathVertexes.addAll(getLineWithDirection(Xvertexes, direction, false, i, 1));
  }

  iniP= pathVertexes.get(pathVertexes.size()-1);
  oldP=new PVector(0, 0, 0);
  //println(iniP);
  println("looking for random points");

  /////////////////////////////////////////////////////////////////////////////////
  //Random generator
  /////////////////////////////////////////////////////////////////////////////////
  while (pointsFound!=iterrationN) {

    int x = Xvertexes.size();
    randN=int(random(x));//find range available
    randP=Xvertexes.get(randN);//select random num from range
    distR1=PVector.dist(iniP, randP);
    distR0=PVector.dist(oldP, randP);

    if (distR1<=maxDist&&distR1>=minDist) {
      debug++;
      if (debug==debugN || distR1<(distR0*angleMult)) {
        pathVertexes.add(iniP);
        oldP=iniP;
        iniP=randP;
        pointsFound++;
        debug=0;//reset debug
        println(pointsFound+"/"+iterrationN+" points to found...");
      }//angle
    }//distance
  }//iterrationNumber 




  writeToFile();
}

////////////////////////////////////////////////////////////////////////////////
// Get Line With Direction
////////////////////////////////////////////////////////////////////////////////
public ArrayList<PVector> getLineWithDirection(ArrayList inputVertexes, boolean direction, boolean horizontal, int position, int range)
{
  ArrayList<PVector> outputVectorArrayList = new ArrayList();
  // Travelling to the Right by Default
  for (int i = 0; i < inputVertexes.size(); i++ ) 
  { 
    PVector p = (PVector) inputVertexes.get(i);
    if (p.y < (position + range) && p.y > (position - range) && horizontal)
    {
      outputVectorArrayList.add(p);
    }
    if (p.x < (position + range) && p.x > (position - range) && !horizontal)
    {
      outputVectorArrayList.add(p);
    }
  }
  // Travelling to the Left (Reverse Arraylist)
  if (!direction)
  {
    Collections.reverse(outputVectorArrayList);
  }

  return outputVectorArrayList;
}

////////////////////////////////////////////////////////////////////////////////
// Write to File
////////////////////////////////////////////////////////////////////////////////
public  void writeToFile()
{
  double multX=(281.67);
  double multY=(326.25);
  double multZ=(358.3);
  double multP=.377;
  double extruderLinear1=.0093;//constants from calibration 
  double extruderLinear2=.0435;//refer to file Path 360.xlsx
  int extruder;
  int pathX;
  int pathY;
  int pathZ;
  double pump;
  //Save file to path.txt
  PrintWriter write= createWriter("Path.txt");
  PVector oldPath = new PVector(0, 0, 0);
  for (int counter=0;counter<pathVertexes.size();counter++)
  {
    PVector writeLine=pathVertexes.get(counter);
    pathX=(int)(writeLine.x*multX);
    pathY=(int)(writeLine.y*multY);
    pathZ=(int)(writeLine.z*multZ);

    //extruder is time in ms
    extruder=(int)((extruderLinear2+PVector.dist(oldPath, writeLine))/extruderLinear1);
    //pump should be then divided by 1000 but the arduino code will do it later 
    pump= ((int)(PVector.dist(oldPath, writeLine)*1000));
    oldPath=writeLine;
    write.println(pathX+";"+pathY+";"+pathZ+";"+extruder+";"+pump+";"); 
    if (counter==pathVertexes.size()-1) {
      write.flush();
      write.close();
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// Draw Method
////////////////////////////////////////////////////////////////////////////////
void draw()
{

  PVector pp=new PVector(0, limitMinY, 0);
  if (keyPressed)
  {
    saveFrame("image" + photo + ".png");
    photo++;
    keyPressed=false;
  }
  background(0);
  scale(1.);
  lights();

  float orbitRadius= mouseX/2+100;
  float ypos= mouseY/3;
  float xpos= cos(radians(rotation))*orbitRadius;
  float zpos= sin(radians(rotation))*orbitRadius;
  rotation++;


  camera(xpos, ypos, zpos, 0, 0, 0, 0, 1, 0);

  for (int i=0;i < pathVertexes.size();i++)
  {
    PVector p = pathVertexes.get(i);

    line((p.x), (p.y), (p.z), (pp.x), (pp.y), (pp.z));
    stroke(255, 255, 255);//color of the line
    pp=p;
  }
}

