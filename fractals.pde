/*********************************************************************************
 
 This program runs the fractal generation program using the variables defined here.
 Sometime in the future I hope to make a UI so this program can be run as an exe,
 but for now it has to be run using the IDE.
 
 *********************************************************************************/

import javax.swing.*;

//left, right, bottom, and top bounds (where the boundaries of the screen map to)
double left = -2.7;
double right = 1.8;
double bottom = -1.3;
double top = 1.3;
//current angular offset for frame in radians, for example angle of PI/2 would rotate screen by 90 deg
double angle = 0;
//how much the angle changes using keyboard commands
double changeAngle = PI/24;
//maximum number of iterations to calculate per point
int maxIter = 100;
//number of lines to draw during phase line display
int numLines = 10;

//Stored image and displayed image
PImage img, dispImg;
//width and height of stored image (how good is the resolution)
int imgWidth = 500, imgHeight = 250;
//initial coordinates for rendering display image
double imgX = 0, imgY = 0;
//boolean that keeps track of when to redraw the fractal after a view change
boolean repaint = false;
//setthing this to true renders the image, auto-prompts for filename, saves image and quits program
boolean autoSave = false;

//draw phase display colors
boolean phaseDisplay = false;
//draw framerate on screen
boolean drawFrameRate = false;
//current vector used for iteration constant
PVector current = new PVector(0, 0);

void setup() {
  optionsPane();
  fullScreen();
  pixelDensity(displayDensity());
  img = createImage(imgWidth, imgHeight, RGB);
  dispImg = createImage(imgWidth, imgHeight, RGB);
  colorMode(HSB, 360);
  //comment this out if you want dynamic bounds, otherwise the right and left bounds are scaled automatically to preserve 1:1 scale
  //left = -width * ((top - bottom) / height)/2;
  right = left + width * ((top - bottom) / height);

  //initial render of image
  paintImage();

  //if autosave option selected, then save picture and exit
  if (autoSave) {
    savePicture();
    noLoop();
    exit();
  }
}

void draw() {
  background(0);

  //repaints the image if a view change has occured
  if (!mousePressed && repaint) {
    paintImage();
    repaint = false;
    imgX = 0;
    imgY = 0;
  }
  //makes display image a copy of rendered image, resizes, and displays
  dispImg = img.copy();
  dispImg.resize(width, height);
  image(dispImg, (int)imgX, (int)imgY);

  //draw phase lines if left mouse button is pressed
  if (mousePressed && mouseButton == LEFT) {
    drawLines();
  }
  //draw framerate
  if (drawFrameRate) {
    noStroke();
    fill(255);
    rect(0, 20, 200, 20);
    fill(0);
    textSize(20);
    textAlign(LEFT, TOP);
    text("Framerate: " + frameRate, 0, 20);
  }
}

//paints image with fractal generator algorithm
void paintImage() {
  img.loadPixels();
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      //assign mapped a and b values to current vector
      current.x = map(i, 0, img.width, left, right);
      current.y = map(j, 0, img.height, top, bottom);
      //assign each pixel color according to iteration algorithm
      img.pixels[j*img.width+i] = findColor(current);
    }
    if (autoSave) println(100*(float)i/img.width + "% done");
  }
  img.updatePixels();
}

//function shows phase lines at mouse cursor
void drawLines() {
  PVector current = new PVector(0, 0);
  PVector old = current.copy();
  PVector mouse = new PVector(map(mouseX, 0, width, left, right), map(mouseY, 0, height, top, bottom));
  for (int i = 0; i < numLines; i++) {
    current = function(old, mouse);
    stroke(0, 0, 360);
    strokeWeight(1);
    PVector dispCurrent = new PVector(map(current.x, left, right, 0, width), map(current.y, bottom, top, height, 0));
    PVector dispOld = new PVector(map(old.x, left, right, 0, width), map(old.y, bottom, top, height, 0));
    line((float)dispCurrent.x, (float)dispCurrent.y, (float)dispOld.x, (float)dispOld.y);
    old = current.copy();
  }
}

//save a snap of the screen to generated images folder with custom filename
void savePicture() {
  String filename = JOptionPane.showInputDialog("Enter filename");
  if (filename != null) img.save("generated-images/" + filename + ".png");
}

//pan screen if mouse is dragged
void mouseDragged() {
  if (mouseButton == CENTER) {
    imgX += (mouseX - pmouseX);
    imgY += (mouseY - pmouseY);

    double xShift = map(mouseX - pmouseX, 0, width, 0, left - right);
    double yShift = map(mouseY - pmouseY, 0, height, 0, top - bottom);

    left += xShift;
    right += xShift;
    bottom += yShift;
    top += yShift;
  }
  repaint = true;
}

//print current mapped coordinates to console if right mouse button is clicked
void mouseClicked() {
  if (mouseButton == RIGHT) {
    println(map(mouseX, 0, width, left, right) + ", " + map(mouseY, 0, height, top, bottom));
  }
}

//keyboard controls
void keyReleased() {
  //save screen as image if spacebar is pressed
  if (key == ' ') savePicture();
  //reset screen bounds if r key is pressed
  else if (key == 'r') {
    bottom = -5;
    top = 5;
    left = -width * ((top - bottom) / height)/2;
    right = width * ((top - bottom) / height)/2;
    repaint = true;
  }
  //toggle phase display if p key is pressed
  else if (key == 'p') {
    phaseDisplay = !phaseDisplay;
    repaint = true;
  }
  //toggle framerate display if f key is pressed
  else if (key == 'f') {
    drawFrameRate = !drawFrameRate;
  }
  //if left arrow is pressed, rotate image to the left
  else if (keyCode == LEFT) {
    angle -= changeAngle;
    repaint = true;
  }
  //if right arrow is pressed, rotate image to the right
  else if (keyCode == RIGHT) {
    angle += changeAngle;
    repaint = true;
  } else if (keyCode == UP) {
    imgWidth *= 1.5;
    imgHeight *= 1.5;
    img.resize(imgWidth, imgHeight);
    repaint = true;
  } else if (keyCode == DOWN) {
    imgWidth /= 1.5;
    imgHeight /= 1.5;
    img.resize(imgWidth, imgHeight);
    repaint = true;
  }
  //print current bounds and angle offset to console if b key is pressed
  else if (key == 'b') {
    println("left: " + left);
    println("right: " + right);
    println("bottom: " + bottom);
    println("top: " + top);
    println("angle: " + angle);
  }
}

void mouseWheel(MouseEvent event) {
  double e = event.getCount();
  double xFactor = .1;
  double yFactor = .1;
  //zoom in
  if (e < 0) {
    double mX = map(mouseX, 0, width, left, right);
    double mY = map(mouseY, 0, height, top, bottom);

    left += xFactor * (mX - left);
    right -= xFactor * (right - mX);
    bottom += yFactor * (mY - bottom);
    top -= yFactor * (top - mY);
  }
  //zoom out
  else if (e > 0) {
    double mX = map(mouseX, 0, width, left, right);
    double mY = map(mouseY, 0, height, top, bottom);

    left -= xFactor * (mX - left);
    right += xFactor * (right - mX);
    bottom -= yFactor * (mY - bottom);
    top += yFactor * (top - mY);
  }
  repaint = true;
}

//current iteration rule, default "return square(z).add(c)" makes mandelbrot.
//use PVector functions and custom functions in "functions" tab to do cool stuff
//PS the commented out manual rule makes the burning ship fractal
PVector function(PVector z, PVector c) {
  double x = z.x*z.x - z.y*z.y + c.x;
  double y = -2*Math.abs(z.x*z.y) + c.y;
  return new PVector(x, y);

  //return powerComplex(cosComplex(z), tanComplex(z)).add(c);
}

//coloring algorithm for each point on the screen
color findColor(PVector c) {
  //initial position of z-vector used in iteration
  PVector pos = new PVector(0, 0);
  //rotate the c-vector used in iteration by the current angle offset
  c = c.sub(new PVector((right+left)/2, (top + bottom)/2));
  c = c.rotate(-angle);
  c = c.add(new PVector((right+left)/2, (top + bottom)/2));

  //variable for current number of iterations
  int i = 0;
  //vector that keeps track of difference between z-vectors between iterations for phase display
  PVector change = new PVector(0, 0);
  //while the number of iterations is less than the maximum and the z-vector hasn't blown up
  while (i < maxIter && pos.mag() < 10) {
    //assign oldPos to be the last z-vector
    PVector oldPos = pos.copy();
    //compute new z-vector using rule and c-vector
    pos = function(pos, c);
    //compute difference between old and new z-vector
    change = oldPos.sub(pos);
    //increment number of iterations
    i++;
  }

  //for the next part, the phase display coloring is kind of a mess right now.
  //maybe in the future I'll make it more generalized/easier to read, but for now coloring is very custom

  //check if the iteration stayed within bounds the whole time (z-vector did not blow up)
  if (i >= maxIter) {
    //if phaseDisplay, then color interestingly
    if (phaseDisplay) {
      return color((int)map(change.mag(), 0, pos.mag(), 0, 272), 360, 150);
    }
    //otherwise color it black
    else return color(#000000);
  } else {
    //temp variable that normalizes how many iterations the algorithm ran for
    double col = map(i, 0, maxIter, 0, 1);
    //interesing colors
    if (phaseDisplay) {
      return color((int)map(change.mag(), 0, 10, 0, 360), 360, (int)map(Math.pow(col, 0.4), 0, 1, 0, 360));
    }
    //grayscale or monochromatic based on iteration variable
    else {
      return color(0, 0, (int)map(Math.pow(col, 0.4), 0, 1, 0, 360));
    }
  }
}
