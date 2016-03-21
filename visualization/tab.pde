public class Tab {
  ArrayList<Graph> graphs;
  Integer duration;
  Float startAngle;
  Float endAngle;
  
  Tab() {
     this.duration = 0; 
     this.graphs = new ArrayList<Graph>();
  }
  
  Integer getDuration() {
    return(this.duration); 
  }
  
  void addGraph(Graph graph) {
    this.graphs.add(graph);
    this.duration += graph.getDuration();
  }
  
  void generateRandom() {
    Random generator = new Random();

    //Integer randomGraphCount = generator.nextInt(10) + 1;
    Integer randomGraphCount = 1;
    
    for(Integer i = 0; i < randomGraphCount; ++i) {
      Graph graph = new Graph();
      graph.generateRandom(10, 2);
      
      this.addGraph(graph);
    }
  }
  
  void drawTab() {
    Float graphStartAngle = this.startAngle;
    Float graphEndAngle;
    
    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < graphs.size(); ++i) {
       graphEndAngle = (float)graphStartAngle + (((float)graphs.get(i).getDuration() / this.duration)) * this.duration;
       println(graphEndAngle);
       graphs.get(i).setStartAngle(startAngle);
       graphs.get(i).setEndAngle(endAngle);
       graphs.get(i).drawGraph(levelSeparation);
       graphStartAngle += graphEndAngle;
    }
    
    drawSpoke(totalDiameter / 2, this.startAngle);
    drawSpoke(totalDiameter / 2, this.endAngle);
  }
  
  void drawSpoke(Float radius, Float angle) {
    ArrayList<Float> coordinates = getCartesian(radius, radians(angle));
    
    strokeWeight(3);
    stroke(0);
    line(0.0, 0.0, coordinates.get(0), coordinates.get(1));
  }
  
  void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
}