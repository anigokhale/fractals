import javax.swing.*;

double left = -1;
double right = 1;
double bottom = -1;
double top = 1;
double angle = 0;
double changeAngle = PI/24;

int maxIter = 100;
int numLines = 10;

boolean phaseDisplay = false;
boolean drawFrameRate = false;
PVector test = new PVector(2, 0);
PVector current = new PVector(0, 0);

void setup() {
  fullScreen();
  pixelDensity(displayDensity());
  colorMode(HSB, 360);
  left = -width * ((top - bottom) / height)/2;
  right = width * ((top - bottom) / height)/2;
}

void draw() {
  loadPixels();
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      current.x = map(i, 0, width, left, right);
      current.y = map(j, 0, height, bottom, top);
      pixels[j*width+i] = findColor(current);
    }
  }
  updatePixels();
  if (mousePressed && mouseButton == LEFT) {
    drawLines();
  }
  if (drawFrameRate) {
    noStroke();
    fill(255);
    rect(0, 20, 200, 20);
    fill(0);
    textSize(20);
    textAlign(LEFT, TOP);
    text("Framerate: " + frameRate, 0, 20);
  }
  //println(frameRate);
}

void drawLines() {
  PVector current = new PVector(0, 0);
  PVector old = current.copy();
  PVector mouse = new PVector(map(mouseX, 0, width, left, right), map(mouseY, 0, height, top, bottom));
  for (int i = 0; i < numLines; i++) {
    current = rule(old, mouse);
    stroke(0, 0, 360);
    strokeWeight(1);
    PVector dispCurrent = new PVector(map(current.x, left, right, 0, width), map(current.y, bottom, top, height, 0));
    PVector dispOld = new PVector(map(old.x, left, right, 0, width), map(old.y, bottom, top, height, 0));
    line((float)dispCurrent.x, (float)dispCurrent.y, (float)dispOld.x, (float)dispOld.y);
    old = current.copy();
  }
}

void savePicture() {
  String filename = JOptionPane.showInputDialog("Enter filename");
  if (filename != null) save(filename + ".png");
}

void mouseDragged() {
  double xFactor = (right - left) * .01;
  double yFactor = (top - bottom) * .01;
  if (mouseButton == CENTER) {
    left -= xFactor*(mouseX - pmouseX);
    right -= xFactor*(mouseX - pmouseX);
    bottom -= yFactor*(mouseY - pmouseY);
    top -= yFactor*(mouseY - pmouseY);
  }
}

void mouseClicked() {
  if (mouseButton == RIGHT) {
    println(map(mouseX, 0, width, left, right) + ", " + map(mouseY, 0, height, top, bottom));
  }
}

void keyReleased() {
  if (key == ' ') savePicture();
  else if (key == 'r') {
    bottom = -5;
    top = 5;
    left = -width * ((top - bottom) / height)/2;
    right = width * ((top - bottom) / height)/2;
  } else if (key == 'p') {
    phaseDisplay = !phaseDisplay;
  } else if (key == 'f') {
    drawFrameRate = !drawFrameRate;
  } else if (keyCode == LEFT) {
    angle -= changeAngle;
  } else if (keyCode == RIGHT) {
    angle += changeAngle;
  } else if (key == 'b') {
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
  if (e < 0) {
    double mX = map(mouseX, 0, width, left, right);
    double mY = map(mouseY, 0, height, bottom, top);

    left += xFactor * (mX - left);
    right -= xFactor * (right - mX);
    bottom += yFactor * (mY - bottom);
    top -= yFactor * (top - mY);
  } else if (e > 0) {
    double mX = map(mouseX, 0, width, left, right);
    double mY = map(mouseY, 0, height, bottom, top);

    left -= xFactor * (mX - left);
    right += xFactor * (right - mX);
    bottom -= yFactor * (mY - bottom);
    top += yFactor * (top - mY);
  }
}

PVector rule(PVector z, PVector c) {
  //double x = z.x*z.x - z.y*z.y + c.x;
  //double y = 2*Math.abs(z.x*z.y) + c.y;
  //return new PVector(x, y);

  return square(z).add(c);
}

color findColor(PVector c) {
  PVector pos = new PVector(0, 0);
  c = c.rotate(-angle);

  int i = 0;
  PVector change = new PVector(0, 0);
  while (i < maxIter && pos.mag() < 10) {
    PVector oldPos = pos.copy();
    pos = rule(pos, c);
    change = oldPos.sub(pos);
    i++;
  }
  if (i >= maxIter) {
    if (phaseDisplay) {
      return color((int)map(change.mag(), 0, pos.mag(), 0, 360), 360, 150);
    } else return color(#000000);
  } else {
    double col = map(i, 0, maxIter, 0, 1);
    if (phaseDisplay) {
      return color((int)map(change.mag(), 0, 10, 0, 360), 360, (int)map(Math.pow(col, 0.75), 0, 1, 0, 450));
    } else {
      return color(122, 360, (int)map(Math.pow(col, 0.85), 0, 1, 0, 450));
    }
  }
}
