

void drawGrid(){
  noFill();
  stroke(0);
  
  strokeWeight(1.2);
  ellipse(0,0,(0.075*totalDiameter),(0.075*totalDiameter));
  ellipse(0,0,(0.175*totalDiameter),(0.175*totalDiameter));
  
  strokeWeight(0.5);
  for(float i = (0.2875*totalDiameter); i <= totalDiameter; i += (0.0375*totalDiameter)){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(1.2);
  for(float i = (0.4375*totalDiameter); i <= totalDiameter; i += (0.1875*totalDiameter)){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(0.5);
  for(int i = 0; i < 12; i++) {
        angle = i * 360 / 12;
        drawGridSpokes(0.025*totalDiameter, totalDiameter/2);
  }
  
  strokeWeight(1.2);
  for(int i = 0; i < 4; i++) {
        angle = i * 360 / 4;
        drawGridSpokes(0.01875*totalDiameter, totalDiameter/2);
  }
}

void drawGridSpokes(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
    
    line(xin, yin, xout, yout);
}