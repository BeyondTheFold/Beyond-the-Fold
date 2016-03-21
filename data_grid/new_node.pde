class Node { 
  Node[] children;
  
  public Node() {
     
  }
}

enum Shape {
  CIRCLE,
  DIAMOND
}

ArrayList<Float> getCartesian(Float radius, Float angle) {
  ArrayList<Float> coordinates = new ArrayList<Float>(2);
  
  coordinates.add(0, radius * cos(angle));
  coordinates.add(1, radius * sin(angle));
  
  return coordinates;
}

void drawNode(float radius, float angle, Shape shape) {
  float radians = radians(angle);
  ArrayList<Float> coordinates = getCartesian(radius, radians);
  float x = coordinates.get(0);
  float y = coordinates.get(1);

  if(shape == Shape.CIRCLE) {
    fill(0, 0, 0);
    noStroke();
    ellipse(x, y, 10, 10);
  } else if(shape == Shape.DIAMOND) {
    pushMatrix();
    translate(x, y);
    rotate(radians + PI/4);
    rect(0, 0, 10, 10);
    popMatrix();
  }
}

void drawTree(Node root, Float startAngle, Float endAngle, Integer levelCount, Float startDiameter) {
  float startRadius = startDiameter / 2;
  float levelSeparation = (totalDiameter - startDiameter / 2) / levelCount;
  

  int current_level = 0;
  int level_node_count = 2;
  float nodeSeparation = endAngle - startAngle / level_node_count;
  Node current_node = root;
  //while(current_node.children.length > 0) {
  drawNode(startRadius + current_level * levelSeparation, startAngle + nodeSeparation, Shape.CIRCLE);
  //}
}