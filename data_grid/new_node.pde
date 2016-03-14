void newNode() {
  float sessionDuration = 600;
  float timeConverted = map(sessionDuration, 0, 720, 0, 360); 
  angle = timeConverted * 360 / 12;
  
  for(int i = 0; i < 20; i++){
    
  }
  
}

void drawNewNode(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
     
}