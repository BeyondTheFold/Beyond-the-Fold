float angle = 0;

void setup() {
  size(1296, 864);
  background(255);
  translate(width/2, height/2);
  
  noFill();
  strokeWeight(2);
  ellipse(0,0,57,57);
  ellipse(0,0,142,142);
  
  strokeWeight(0.5);
  for(int i = 192; i < 738; i += 28){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(1.5);
  for(int i = 304; i < 738; i += 140){
    ellipse(0,0,i,i);
  }
  
  strokeWeight(0.5);
  for(int i = 0; i < 24; i++) {
        angle = i * 360 / 24;
        drawHandle(20, 362);
  }
  
  strokeWeight(1.5);
  for(int i = 0; i < 4; i++) {
        angle = i * 360 / 4;
        drawHandle(15, 362);
  }
}

void draw() {
  
}

void drawHandle(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
     
    line(xin, yin, xout, yout);
}