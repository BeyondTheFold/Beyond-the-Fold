public class Graph {
  ArrayList<ArrayList<Node>> adjacencyList;
  ArrayList<Node> nodes;
  Integer duration;
  Integer nodeCount;
  Float startAngle;
  Float endAngle;
  
  Graph() {
    nodeCount = 0;
    
    // initialize duration to 0 microseconds
    this.duration = 0;
        
    // initialize adjacency list
    adjacencyList = new ArrayList<ArrayList<Node>>(50625);
    
    // initialize node list
    nodes = new ArrayList<Node>(50625);
        
    for(Integer i = 0; i < 50625; ++i) {
     adjacencyList.add(i, null); 
     nodes.add(i, null);
    }
  }
  
  Integer getDuration() {
    return(this.duration);
  }
  
  void addNode(Node node) { 
    nodes.set(node.getIndex(), node);
    
    // add duration to graph duration
    this.duration += node.getDuration();
    
    if(!adjacencyList.contains(node)) {
      adjacencyList.set(node.getIndex(), new ArrayList<Node>()); 
    }
    
    // iterate through children passed to function
    for(Integer i = 0; i < node.getChildren().size(); ++i) {
      this.adjacencyList.get(node.getIndex()).add(node.getChildren().get(i));
    }
  }
  
  void drawGraph(Float levelSeparation) {
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer depth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Integer breadth = 0;
    Integer breadthIndex = 0;
    Node current;
    Float parentAngle = 0.0;
    Float sectorLengthSeparation = 20.0;
    Float separationAngle = 10.0;
    Float graphAngle = (abs(startAngle) - abs(endAngle)) / 2;
    
    Float totalAngle = 0.0;
                       
    // node to start with
    Node start = this.nodes.get(0);
        
    // add start node to queue
    queue.add(start);
    
    // while queue is not empty
    while(!queue.isEmpty()) {
      current = queue.poll();
      
      Float radius = (levelsStartDiameter / 2) + (levelSeparation / 2) * depth;
  
      if(depth != 0) {
        separationAngle = degrees(sectorLengthSeparation / radius);
      }
      
      if(current != null && current.getParent() != null) {
        parentAngle = current.getParent().getAngle(); 
      }
      
      Float angle = graphAngle + (separationAngle * (elementsToDepthIncrease - 1) - (totalAngle / 2));
      //Float angle = (separationAngle * (elementsToDepthIncrease - 1));
            
      drawNode(radius, angle, Shape.CIRCLE);
      
      if(current != null) {
        current.setCoordinates(getCartesian(radius, radians(angle)));
        current.setAngle(angle);
      }
      
      nextElementsToDepthIncrease += adjacencyList.get(current.getIndex()).size();
      
      if(--elementsToDepthIncrease == 0) {
        ++depth;
        totalAngle = (nextElementsToDepthIncrease - 1) * separationAngle;
        elementsToDepthIncrease = nextElementsToDepthIncrease;
        nextElementsToDepthIncrease = 0;
      }
    
      // for each adacent node
      for(Integer i = 0; i < adjacencyList.get(current.getIndex()).size(); ++i) {
        Node adjacentNode = adjacencyList.get(current.getIndex()).get(i);
        
        queue.add(adjacentNode);
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
  
  void createRandomSubgraph(Random generator,
                        Integer maxDepth, 
                        Integer depth,
                        Integer maxChildren,
                        Node parent
                        ) {
                          
    if(depth >= maxDepth) {
      return;
    }
  
    Integer randomChildCount = generator.nextInt(maxChildren) + 1;
    Integer takePath;
  
    for(Integer j = 0; j < randomChildCount; ++j) {
      Node child = new Node();
      child.setIndex(nodeCount);
      ++nodeCount;
      
      // generate random node duration
      child.setDuration(generator.nextInt(10) + 1);
      
      // randomly decide to take path
      takePath = generator.nextInt(10) + 1;
  
      if(takePath >= 4) {
        // recursively call create random subgraph
        createRandomSubgraph(generator, maxDepth, depth + 1, maxChildren, child);
      }
      
      child.setParent(parent);
      parent.addChild(child);
      
      this.addNode(child);
    } 
    
     this.addNode(parent);
  }

  void generateRandom(Integer maxDepth, Integer maxChildren) {
    Graph testGraph = new Graph();
  
    Random generator = new Random();
    Integer depth = 0;
    
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0);
    ++nodeCount;
        
    createRandomSubgraph(generator, maxDepth, depth, maxChildren, root);    
  }
  
  void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
}