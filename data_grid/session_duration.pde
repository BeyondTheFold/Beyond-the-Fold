Tab[] duration;

void sessionDuration() {
  stroke(0, 153, 255);
  
  //cooked sessions data
  int[] sessions = {120,40,29,98,46,10,25,64};
  int sessionStart = 0;
  int sessionEnd = 0;
  
  // create new instance of array
  duration = new Tab[sessions.length];
  
  //scan through sessions data and store into duration array with start, end, and duration
  for(int i = 0; i < sessions.length; i++) {
    sessionStart = sessionEnd;
    sessionEnd = sessions[i] + sessionStart;
    duration[i] = new Tab(sessionStart, sessionEnd, sessions[i]);
    duration[i].printTab();
  }
  
  //draw Tabs and TabSpokes
  for(int i = 0; i < duration.length; i++) {
    duration[i].drawSessionTabs();
    duration[i].drawBeginSpoke(innerDiameter/2,(totalDiameter/2)+20);
    duration[i].drawEndSpoke(innerDiameter/2,(totalDiameter/2)+20);
  }
}

class Tab {
  float sessionStart;
  float sessionEnd;
  float sessionDuration;
  float angleStart;
  float angleEnd;
  
  Tab (float sessionStart, float sessionEnd, float sessionDuration) {
    //convert values to keep the ratio of time correct
    this.sessionStart = map(sessionStart, 0, 720, 0, 360);
    this.sessionEnd = map(sessionEnd, 0, 720, 0, 360);
    this.sessionDuration = map(sessionDuration, 0, 720, 0, 360);
  }
  
  void printTab () {
    //println(this.sessionEnd);
  }
  
  //spokes function
  void drawSpoke(float angle, float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
    
    strokeWeight(2);
    line(xin, yin, xout, yout);
  }
  
  void drawBeginSpoke (float inside, float outside) {
    drawSpoke(this.sessionStart, inside, outside);
  }
  
  void drawEndSpoke (float inside, float outside) {
    drawSpoke(this.sessionEnd, inside, outside);
    /* pushMatrix();
    fill(0);
    textSize(20);
    rotate(radians(this.sessionEnd));
    text(this.sessionEnd, sin(radians(-sessionEnd - 180)) * outside, cos(radians(-sessionEnd - 180)) * outside);
    popMatrix(); */
  }
    
  //tabs function
  void drawSessionTabs() {
    noFill();
    strokeWeight(40);
    strokeCap(SQUARE);
    arc(0, 0, 100, 100, radians(this.sessionStart) - HALF_PI, radians(this.sessionEnd) - HALF_PI);
    
    //println(this.sessionStart + " to " + this.sessionEnd);
    //println(radians(this.sessionDuration));
  }
}