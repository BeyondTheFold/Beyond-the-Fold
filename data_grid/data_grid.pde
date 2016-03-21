float angle = 0;
int totalDiameter = 800;
float innerDiameter = 0.075 * totalDiameter;
float secondaryInnerDiameter = 0.175 * totalDiameter;

void setup() {
  size(1296, 864);
  background(255);
  translate(width/2, height/2);
  smooth();
  ellipseMode(CENTER);
  rectMode(CENTER);
 
  Node a = new Node();
  Node b = new Node();
  Node c = new Node();
  Node d = new Node();
  Node e = new Node();
  Node f = new Node();
  Node g = new Node();
  Node h = new Node();
  
  a.children = new Node[]{b, c};
  b.children = new Node[]{d, e};
  c.children = new Node[]{f, g};
  d.children = new Node[]{h};
  
  drawTree(a, 0.0, 45.0, 20, 200.0);
 
  sessionDuration();
  drawGrid(20, 5, 200.0);
  
}

void draw() {
  translate(width/2,height/2);
}