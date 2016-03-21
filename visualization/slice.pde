public class Slice {
  ArrayList<Tab> tabs;
  
  void drawSlice(Integer subLevelCount, Integer superLevelCount, Float levelsStartDiameter) {
    this.drawGrid(subLevelCount, superLevelCount, levelsStartDiameter);
    //this.drawTabs();
  }
  
  void drawGrid(Integer subLevelCount, Integer superLevelCount, Float levelsStartDiameter){
    noFill();
    stroke(0);
  
    strokeWeight(1.2);
    
    Float levelSeparation = (totalDiameter - levelsStartDiameter) / subLevelCount;
    
    // inner tab ring
    ellipse(0,0,(0.075*totalDiameter),(0.075*totalDiameter));
    
    // outer tab ring
    ellipse(0,0,(0.175*totalDiameter),(0.175*totalDiameter));
    
    
    strokeWeight(0.5);
    for(float i = levelsStartDiameter; i <= totalDiameter; i += levelSeparation){
      ellipse(0,0,i,i);
    }
  
    strokeWeight(1.2);
    for(float i = levelsStartDiameter + levelSeparation * superLevelCount; i <= totalDiameter; i += levelSeparation * superLevelCount){
      ellipse(0,0,i,i);
    }
    
    strokeWeight(0.5);
    for(int i = 0; i < 12; i++) {
          angle = (float)i * 360 / 12;
          this.drawGridSpokes(0.025*totalDiameter, totalDiameter/2);
    }
    
    strokeWeight(1.2);
    for(int i = 0; i < 4; i++) {
          angle = (float)i * 360 / 4;
          this.drawGridSpokes(0.01875*totalDiameter, totalDiameter/2);
    }
  }
  
  void drawGridSpokes(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
    
    line(xin, yin, xout, yout);
  }
  
  void drawTabs() {
    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < tabs.size(); ++i) {
       
    }
  }
}