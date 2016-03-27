public class Slice {
  ArrayList<Tab> tabs;
  Integer duration;
  Float diameter;
  Float levelStartDiameter;
  Integer levelCount;
  Integer superLevelCount;
  Float levelSeparation;
  Float angle;
  Integer nodeCount;
  Float startAngle;
  Float endAngle;
 
  Slice(Float diameter, Float levelStartDiameter, Integer levelCount, Integer superLevelCount) {
    this.startAngle = 0.0;
    this.endAngle = 0.0;
    this.diameter = diameter;
    this.levelStartDiameter = levelStartDiameter;
    this.levelCount = levelCount;
    this.superLevelCount = superLevelCount;
    this.levelSeparation = (diameter - levelStartDiameter) / levelCount;
    this.duration = 0;
    this.nodeCount = 0;
    this.tabs = new ArrayList<Tab>();
  }
  
  void drawSlice(Integer minDuration) {
    if(minDuration == 0) {
      this.drawGrid();
    }
    
    this.drawTabs(minDuration);
  }
  
  void drawGrid(){
    noFill();
    stroke(0);
  
    strokeWeight(1.2);
    
    // inner tab ring
    ellipse(0,0,(0.075*diameter),(0.075*diameter));
    
    // outer tab ring
    ellipse(0,0,(0.175*diameter),(0.175*diameter));
    
    
    strokeWeight(0.5);
    for(float i = levelStartDiameter; i <= diameter; i += levelSeparation){
      ellipse(0,0,i,i);
    }
  
    strokeWeight(1.2);
    for(float i = levelStartDiameter + levelSeparation * superLevelCount; i <= diameter; i += levelSeparation * superLevelCount){
      ellipse(0,0,i,i);
    }
    
    strokeWeight(0.5);
    for(int i = 0; i < 12; i++) {
          angle = (float)i * 360 / 12;
          this.drawGridSpokes(0.025*diameter, diameter/2);
    }
    
    strokeWeight(1.2);
    for(int i = 0; i < 4; i++) {
          angle = (float)i * 360 / 4;
          this.drawGridSpokes(0.01875*diameter, diameter/2);
    }
  }
  
  void drawGridSpokes(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
    
    line(xin, yin, xout, yout);
  }
  
  void addTab(Tab tab) {
    this.tabs.add(tab);
    this.duration += tab.getDuration();
    this.nodeCount += tab.getNodeCount();
  }
  
  void generateRandom() {
    Random generator = new Random();

    Integer randomTabCount = generator.nextInt(3) + 3;
    
    for(Integer i = 0; i < randomTabCount; ++i) {
      Tab tab = new Tab(diameter, levelSeparation, levelStartDiameter);
      tab.generateRandom();
      
      this.addTab(tab);
    }
  }
  
  void calculatePositions() {
    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < tabs.size(); ++i) {
       this.endAngle = startAngle + (((float)tabs.get(i).getDuration() / (12 * 60)) * 360);
       tabs.get(i).setStartAngle(startAngle);
       tabs.get(i).setEndAngle(endAngle);
       this.startAngle = this.endAngle;
    }
  }
  
  void drawTabs(Integer minDuration) {
    for(Integer i = 0; i < tabs.size(); ++i) {
       tabs.get(i).drawTab(minDuration);
    }
    
    stroke(0, 153, 255);
    noFill();
    strokeWeight(40);
    strokeCap(SQUARE);
    arc(0, 0, 100, 100, 0.0, radians(this.endAngle));
    
    for(Integer i = 0; i < tabs.size(); ++i) {
      tabs.get(i).drawTab(minDuration);
    }
  }
  
  void printInfo() {
    println("Total nodes: " + this.nodeCount);
    println("Total duration: " + this.duration / 60 + " minutes"); 
  }
}