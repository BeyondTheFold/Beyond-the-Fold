enum Shape {
  CIRCLE,
  DIAMOND
}

ArrayList<Float> getCartesian(float radius, float angle) {
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