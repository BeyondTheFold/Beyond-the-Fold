public class Graph {
  ArrayList<ArrayList<Node>> adjacencyList;
  ArrayList<Node> nodes;
  Integer duration;
  
  Graph() {
    
    // initialize duration to 0 microseconds
    this.duration = 0;
        
    // initialize adjacency list
    adjacencyList = new ArrayList<ArrayList<Node>>(300);
    
    // initialize node list
    nodes = new ArrayList<Node>(300);
        
    for(Integer i = 0; i < 300; ++i) {
     adjacencyList.add(i, null); 
     nodes.add(i, null);
    }
  }
  
  void calculateDuration() {

  }
  
  Integer getDuration() {
    this.calculateDuration();
    return(this.duration);
  }
  
  void addNode(Node node) { 
    nodes.set(node.getIndex(), node);
    
    if(!adjacencyList.contains(node)) {
      adjacencyList.set(node.getIndex(), new ArrayList<Node>()); 
    }
    
    // iterate through children passed to function
    for(Integer i = 0; i < node.getChildren().size(); ++i) {
      this.adjacencyList.get(node.getIndex()).add(node.getChildren().get(i));
    }
  }
  
  void drawGraph(Float startAngle, Float endAngle, Float levelSeparation) {
    ArrayDeque<Integer> queue = new ArrayDeque<Integer>();
    Integer depth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Integer breadth = 0;
    Integer breadthIndex = 0;
    Integer current = 0;

    Float sectorLengthSeparation = 30.0;
    Float separationAngle = 25.0;
    
    Float totalAngle = 0.0;
                    
                    
    // index to start with
    Integer start = 0;
        
    // add start index to queue
    queue.add(start);
    
    
    // while queue is not empty
    while(!queue.isEmpty()) {
      current = queue.poll();
      
      Float radius = /*(levelsStartDiameter / 2) + */(levelSeparation / 2) * depth;
      
      /*
      if(depth != 0) {
        separationAngle = degrees(sectorLengthSeparation / radius);
      }
      */
      
      Float angle = separationAngle * (elementsToDepthIncrease - 1) - (totalAngle / 2);
      
      //println("Drawing at r=" + separation + " a=" + separationAngle * breadthIndex);
      
      drawNode(radius, angle, Shape.CIRCLE);
      
      if(current != null) {
        nodes.get(current).setCoordinates(getCartesian(radius, radians(angle)));
        println(getCartesian(radius, radians(angle)));
      }
      
      nextElementsToDepthIncrease += adjacencyList.get(current).size();
      
      if(--elementsToDepthIncrease == 0) {
        ++depth;
        totalAngle = (nextElementsToDepthIncrease - 1) * separationAngle;
        elementsToDepthIncrease = nextElementsToDepthIncrease;
        nextElementsToDepthIncrease = 0;
      }
     

      if(current != -1) {
        // for each adacent node
        for(Integer i = 0; i < adjacencyList.get(current).size(); ++i) {
          Integer adjacentIndex = adjacencyList.get(current).get(i).getIndex();
          
          queue.add(adjacentIndex);
        }
      }
    }
    
    this.drawLines();
  }
  
  
  void drawLines() {
    ArrayList<Float> parentCoordinates;
    ArrayList<Float> childCoordinates;

    for(Integer i = 0; i < nodes.size() - 1; ++i ) {
      if(adjacencyList.get(i) != null) {
        parentCoordinates = nodes.get(i).getCoordinates();
        for(Integer j = 0; j < adjacencyList.get(i).size(); ++j) {
          childCoordinates = adjacencyList.get(i).get(j).getCoordinates();

          if(childCoordinates != null && parentCoordinates != null) {
          strokeWeight(2);
          stroke(0);
          line(parentCoordinates.get(0), parentCoordinates.get(1), childCoordinates.get(0), childCoordinates.get(1)); 
          }
        }
      }
    }
  }
}