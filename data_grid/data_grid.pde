int diagramSize = 800;
float angle = 0;

void setup() {
  size(1296, 864);
  background(255);
  translate(width/2, height/2);
  
  drawGrid();
}

void draw() {
  float timeAccessed = 600;
  float timeConverted = map(timeAccessed, 0, 1440, 0, 360); 
  angle = timeConverted * 360 / 24;
}