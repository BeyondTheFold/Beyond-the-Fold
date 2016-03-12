
void drawGrid(){
  noFill();
  strokeWeight(1.2);
  ellipse(0,0,(0.075*diagramSize),(0.075*diagramSize));
  ellipse(0,0,(0.175*diagramSize),(0.175*diagramSize));
  
  strokeWeight(0.5);
  for(float i = (0.2875*diagramSize); i <= diagramSize; i += (0.0375*diagramSize)){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(1.2);
  for(float i = (0.4375*diagramSize); i <= diagramSize; i += (0.1875*diagramSize)){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(0.5);
  for(int i = 0; i < 24; i++) {
        angle = i * 360 / 24;
        drawHandle(0.025*diagramSize, diagramSize/2);
  }
  
  strokeWeight(1.2);
  for(int i = 0; i < 4; i++) {
        angle = i * 360 / 4;
        drawHandle(0.01875*diagramSize, diagramSize/2);
  }
}

void drawHandle(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
     
    line(xin, yin, xout, yout);
}