public class Graph {
  ArrayList<ArrayList<Node>> adjacencyList;
  ArrayList<Integer> levelBreadths;
  ArrayList<Node> nodes;
  Float duration;
  Integer nodeCount;
  Float startAngle = 0.0;
  Float endAngle = 90.0;
  Float levelSeparation;
  Float sectorLengthSeparation;
  Float levelsStartDiameter;
  
  Graph(      
      Float levelSeparation, 
      Float sectorLengthSeparation, 
      Float levelsStartDiameter) {
        
    nodeCount = 0;
    
    this.levelSeparation = levelSeparation;
    this.sectorLengthSeparation = sectorLengthSeparation;
    this.levelsStartDiameter = levelsStartDiameter;
    
    // initialize duration to 0 microseconds
    this.duration = 0.0;
        
    // initialize adjacency list
    adjacencyList = new ArrayList<ArrayList<Node>>(1024);
    
    // initialize node list
    nodes = new ArrayList<Node>(1024);
        
    for(Integer i = 0; i < 1024; ++i) {
     adjacencyList.add(null); 
     nodes.add(null);
    }
    
    //
    this.levelBreadths = new ArrayList<Integer>();
  }
  
  Float getDuration() {
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
  
  void drawGraph(Float minDuration) {
      Node node;
      Shape shape = Shape.CIRCLE;
      
      // iterate through all nodes
      for(Integer i = 0; i < this.nodes.size(); ++i) {
        node = this.nodes.get(i);
        
        // if node exists at position
        if(node != null) {
          
          // dont display nodes with less than minimum duration
          if(node.getDuration() >= minDuration) {
          
            // if node is is a sub-domain draw circle, otherwise draw diamond
            if(node.isSubDomain()) {
              shape = Shape.CIRCLE;
            } else {
              shape = Shape.DIAMOND;
            }
            
            drawNode(node.getCoordinates(), shape);
          }
        }
      }
      
      // only draw lines on first layer
      if(minDuration == 0) {
        this.drawLines();
      }
  }
  
  void calculateLevelBreadths() {
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer breadth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Node current;
    Node start = null;
    
    // node to start with
    for(Integer i = 0; i < this.nodes.size(); ++i) {
      if(this.nodes.get(i) != null) {
        start = this.nodes.get(i);
        break;
      }
    }
    
    if(start == null) {
      return;
    }
        
    // add start node to queue
    queue.add(start);
    
    while(!queue.isEmpty()) {
      current = queue.poll();

      ++breadth;
      nextElementsToDepthIncrease += adjacencyList.get(current.getIndex()).size();

      if(--elementsToDepthIncrease == 0) {
        levelBreadths.add(breadth);
        breadth = 0;
        elementsToDepthIncrease = nextElementsToDepthIncrease;
        nextElementsToDepthIncrease = 0;
      }      
      
      // for each adacent node
      for(Integer i = 0; i < adjacencyList.get(current.getIndex()).size(); ++i) {
        Node adjacentNode = adjacencyList.get(current.getIndex()).get(i);
        queue.add(adjacentNode);
      }
    }
  }
  
  void calculateNodePositions() {
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer depth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Node current;
    Float separationAngle = 0.0;
    Float angle;
    Float parentAngle;
    Float anchorAngle;
    Node start = null;
    
    // node to start with
    for(Integer i = 0; i < this.nodes.size(); ++i) {
      if(this.nodes.get(i) != null) {
        start = this.nodes.get(i);
        break;
      }
    }
    
    if(start == null) {
      return;
    }
        
    // add start node to queue
    queue.add(start);
    
    // while queue is not empty
    while(!queue.isEmpty()) {
      current = queue.poll();
      
      Float radius = (levelsStartDiameter / 2) + (levelSeparation / 2) * depth;
      separationAngle = (endAngle - startAngle) / (levelBreadths.get(depth));
      angle = startAngle + (separationAngle * (elementsToDepthIncrease - 1)) + (separationAngle / 2);
      
      if(current != null) {
        current.setCoordinates(getCartesian(radius, radians(angle)));
        current.setAngle(radians(angle));
        assert(current.getAngle() == radians(angle));
        if(current.getParent() != null && current.getParent().getAngle() != null) {
          parentAngle = current.getParent().getAngle();
          anchorAngle = ((radians(angle) - parentAngle) * 0.25);
          current.setBezierAnchorA(getCartesian(radius, parentAngle + anchorAngle));
          current.setBezierAnchorB(getCartesian(radius - (levelSeparation / 2), radians(angle) - anchorAngle));
        } else {
          current.setBezierAnchorA(getCartesian(radius - (levelSeparation / 2), radians(angle)));
          current.setBezierAnchorB(getCartesian(radius - (levelSeparation / 2), radians(angle)));
        }
      }
            
      nextElementsToDepthIncrease += adjacencyList.get(current.getIndex()).size();
      
      if(--elementsToDepthIncrease == 0) {
        ++depth;
        elementsToDepthIncrease = nextElementsToDepthIncrease;
        nextElementsToDepthIncrease = 0;
      }

      // for each adacent node
      for(Integer i = 0; i < adjacencyList.get(current.getIndex()).size(); ++i) {
        Node adjacentNode = adjacencyList.get(current.getIndex()).get(i);
        queue.add(adjacentNode);
      }
    }
  }
  
  void drawLines() {
    ArrayList<Float> parentCoordinates;
    ArrayList<Float> childCoordinates;
    ArrayList<Float> bezierAnchorA;
    ArrayList<Float> bezierAnchorB;

    for(Integer i = 0; i < adjacencyList.size() - 1; ++i ) {
      if(adjacencyList.get(i) != null) {      
        for(Integer j = 0; j < adjacencyList.get(i).size(); ++j) {
          parentCoordinates = adjacencyList.get(i).get(j).getParent().getCoordinates();
          childCoordinates = adjacencyList.get(i).get(j).getCoordinates();
          bezierAnchorA = adjacencyList.get(i).get(j).getBezierAnchorA();
          bezierAnchorB = adjacencyList.get(i).get(j).getBezierAnchorB();

          if(childCoordinates != null && parentCoordinates != null) {
            strokeWeight(0.75);
            stroke(0);
            noFill();
            
            bezier(parentCoordinates.get(0), parentCoordinates.get(1), 
            bezierAnchorA.get(0), bezierAnchorA.get(1),
            bezierAnchorB.get(0), bezierAnchorB.get(1),
            childCoordinates.get(0), childCoordinates.get(1)); 
          }
        }
      }
    }
  }
  
  void createSubgraph(
    Random generator,
    Integer maxDepth, 
    Integer depth,
    Integer minChildren,
    Integer maxChildren,
    Node parent,
    Integer pathProbability) {
              
    if(depth >= maxDepth) {
      return;
    }
    
    Integer childCount;
    Integer takePath;

    if(minChildren == maxChildren) {
      childCount = maxChildren;
    } else {
      childCount = generator.nextInt(maxChildren) + minChildren;
    }
  
    for(Integer j = 0; j < childCount; ++j) {
      Node child = new Node();
      child.setIndex(nodeCount);
      ++nodeCount;
      
      // generate random node duration
      child.setDuration((float)generator.nextInt(10) + 3);
      
      // randomly decide to take path
      takePath = generator.nextInt(100);
      
      child.setParent(parent);
      parent.addChild(child);
      
      this.addNode(child);
      
      if(takePath <= pathProbability) {
        // recursively call create random subgraph
        createSubgraph(generator, maxDepth, depth + 1, minChildren, maxChildren, child, pathProbability);
      }
    } 
    
     this.addNode(parent);
  }

  void generateRandom(Integer maxDepth, Integer minChildren, Integer maxChildren) {
  
    Random generator = new Random();
    Integer depth = 0;
    Integer pathProbability = 50;
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0.0);
    ++nodeCount;
        
    createSubgraph(generator, maxDepth, depth, minChildren, maxChildren, root, pathProbability);    
  }
  
  void generateFull(Integer maxDepth, Integer maxChildren) {
  
    Random generator = new Random();
    Integer depth = 0;
    Integer pathProbability = 100;
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0.0);
    ++nodeCount;
        
    createSubgraph(generator, maxDepth, depth, maxChildren, maxChildren, root, pathProbability);    
  }
  
  void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
  
  Integer getNodeCount() {
    return(this.nodeCount); 
  }
  
  ArrayList<Node> getNodes() {
    return(this.nodes); 
  }
  
  void printAdjacencyList() {
    for(Integer i = 0; i < this.nodeCount; ++i) {
      print(i + " -> ");
      if(adjacencyList.get(i) != null) {
        for(Integer j = 0; j < adjacencyList.get(i).size(); ++j) {
          if(adjacencyList.get(i).get(j) != null) {
            print(adjacencyList.get(i).get(j).getIndex() + " ");
          }
        }
      }
      println();
    }
  }
  
  ArrayList<Integer> getLevelBreadths() {
    return(this.levelBreadths);
  }
 
  Node constructGraph(ArrayList<Node> nodeTable, Node node) {
    if(node == null) {
      return(null);
    }
    
    for(Integer i = 0; i < node.getChildIndicies().size(); ++i) {
      Node child = constructGraph(nodeTable, nodeTable.get(node.getChildIndicies().get(i)));
      if(child != null) {
        child.setParent(node);
        node.addChild(child);
        ++this.nodeCount;
      }
    }
    
    this.addNode(node);
    return(node);
  }
}