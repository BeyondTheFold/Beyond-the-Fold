float angle = 0;
int totalDiameter = 800;
float innerDiameter = 0.075 * totalDiameter;
float secondaryInnerDiameter = 0.175 * totalDiameter;



void setup() {
  size(1296, 864);
  background(255);
  translate(width/2, height/2);
  smooth();
 
  sessionDuration();
  drawGrid();
}

void draw() {
  translate(width/2,height/2);
}