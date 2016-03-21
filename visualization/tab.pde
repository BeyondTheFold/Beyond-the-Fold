public class Tab {
  ArrayList<Graph> graphs;
  Integer duration;
  
  Tab() {
     this.duration = 0; 
  }
  
  void drawTree() {
    
  }
  
  void calculateDuration() {
     for(Integer i = 0; i < graphs.size(); ++i) {
       this.duration += graphs.get(i).getDuration();
     }
  }
  
  Integer getDuration() {
    this.calculateDuration();
    return(this.duration); 
  }
  
  void drawTab() {
    
  }
}