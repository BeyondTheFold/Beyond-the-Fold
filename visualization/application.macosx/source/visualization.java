import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.sql.*; 
import java.util.*; 
import java.nio.charset.StandardCharsets; 
import java.util.Date; 
import java.util.ArrayList; 
import processing.opengl.*; 

import org.sqlite.core.*; 
import org.sqlite.date.*; 
import org.sqlite.*; 
import org.sqlite.javax.*; 
import org.sqlite.jdbc3.*; 
import org.sqlite.jdbc4.*; 
import org.sqlite.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class visualization extends PApplet {








Float pan_x = 0.0f;
Float pan_y = 0.0f;
Integer click_position_x = 0;
Integer click_position_y = 0;
Float zoom = 0.0f;
Float rotate_x = 0.0f;
Float rotate_y = 0.0f;

enum Shape {
  CIRCLE,
  DIAMOND
}

public ArrayList<Float> getCartesian(Float radius, Float angle) {
  ArrayList<Float> coordinates = new ArrayList<Float>(2);
  
  coordinates.add(0, radius * cos(angle));
  coordinates.add(1, radius * sin(angle));
  
  return coordinates;
}

public void drawCylinder(Integer sides, Float radius, Float height) {
  Float angle = (float)360 / sides;
  Float halfHeight = height / 2;
   
  // top of cylinder
  beginShape();
  for(Integer i = 0; i < sides; ++i) {
    Float x = cos(radians(i * angle)) * radius;
    Float y = sin(radians(i * angle)) * radius;
    vertex(x, y, -halfHeight);
  }
  endShape(CLOSE);
   
  // bottom of cylinder
  beginShape();
  for(Integer i = 0; i < sides; ++i) {
    Float x = cos(radians(i * angle)) * radius;
    Float y = sin(radians(i * angle)) * radius;
    vertex(x, y, halfHeight);
  }
  endShape(CLOSE);
   
  // draw body
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
      float x = cos( radians( i * angle ) ) * radius;
      float y = sin( radians( i * angle ) ) * radius;
      vertex( x, y, halfHeight);
      vertex( x, y, -halfHeight);    
  }
  endShape(CLOSE);
}

public String getSessionsFromDatabase() {
  Connection connection = null;
  Statement statement = null;
  String sessions;
  
  try {
    Class.forName("org.sqlite.JDBC");
    connection = DriverManager.getConnection("jdbc:sqlite:Library/Safari/LocalStorage/safari-extension_com.yourcompany.browsingvisualizer-0000000000_0.localstorage");
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
    return(null);
  }
  println("Successfully opened database.");
  
  try {
    statement = connection.createStatement();
    ResultSet result = statement.executeQuery("SELECT value FROM ItemTable WHERE key='sessions'");
    byte[] b = result.getBytes("value");
    sessions = new String(b, StandardCharsets.UTF_8);
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
    return(null);
  }
  
  return(sessions);
}

public ArrayList<Node> importFromJsonFile(String filename) {
  ArrayList<Node> nodes = new ArrayList<Node>();
  JSONObject json = loadJSONObject(filename);

  Iterator iterator = json.keys().iterator();

  String url;
  String sessionStartString;
  Date sessionStart;
  Integer duration;
  Integer parent;
  String current_key;
  
  ArrayList<Node> children = new ArrayList<Node>();

  while(iterator.hasNext()) {
    current_key = (String)iterator.next();
    url = json.getJSONObject(current_key).getString("url");
    sessionStartString = json.getJSONObject(current_key).getString("sessionStart");
    sessionStart = new Date();
    duration = json.getJSONObject(current_key).getInt("sessionDuration");
    parent = json.getJSONObject(current_key).getInt("parent");
    //children = getChildrenFromString(row.getString("Children"));
    
    Node node = new Node(Integer.parseInt(current_key), parent, url, sessionStart, duration, false);
    nodes.add(node);
  }
  
  return(nodes);
}

public ArrayList<Node> getChildrenFromString(String childrenString) {
  ArrayList<Node> children = new ArrayList<Node>();
  String[] indicies = childrenString.split(", ");
  
  return(children);
}

public Boolean toBoolean(Integer value) {
  return(value != 0);
}

public ArrayList<Node> importFromCsvFile(String filename) {
  Table table = loadTable(filename, "header");
  ArrayList<Node> nodes = new ArrayList<Node>();
  
  for (TableRow row : table.rows()) {
    Integer index = row.getInt("index");
    String url = row.getString("url");
    String sessionStartString = row.getString("sessionStart");
    Date sessionStart = new Date();
    Integer duration = row.getInt("sessionDuration");
    Integer parent = row.getInt("parent");
    String children = row.getString("children");
    Boolean subDomain = toBoolean(row.getInt("subDomain"));
    
    Node node = new Node(index, parent, url, sessionStart, duration, subDomain);
    nodes.add(node);
  }
  
  return(nodes);
}

public void drawNode(ArrayList<Float> coordinates, Shape shape) {
  float x = coordinates.get(0);
  float y = coordinates.get(1);

  if(shape == Shape.CIRCLE) {
    fill(0, 0, 0);
    noStroke();
    ellipse(x, y, 10, 10);
  } else if(shape == Shape.DIAMOND) {
    pushMatrix();
    translate(x, y);
    //rotate(radians + PI/4);
    rect(0, 0, 10, 10);
    popMatrix();
  }
}

public void drawNode(float radius, float angle, Shape shape) {
  float radians = radians(angle);
  ArrayList<Float> coordinates = getCartesian(radius, radians);
  float x = coordinates.get(0);
  float y = coordinates.get(1);

  if(shape == Shape.CIRCLE) {
    fill(0, 0, 0);
    noStroke();
    ellipse(x, y, 10, 10);
  } else if(shape == Shape.DIAMOND) {
    pushMatrix();
    translate(x, y);
    rotate(radians + PI/4);
    rect(0, 0, 10, 10);
    popMatrix();
  }
}

public void testDrawLinearGraph() {
  Graph testGraph = new Graph();
  
  for(Integer i = 0; i < 10; ++i) {
    Node node = new Node();
    node.setIndex(i);
    if(i != 0) {
      node.setParent(node);
    }
    if(i != 9) {
      Node child = new Node();
      child.setIndex(i + 1);
      node.addChild(child);
    }
    testGraph.addNode(node);
  }
  
  //testGraph.drawGraph(20.0);
}

Slice slice = new Slice(800.0f, 200.0f, 20, 5);

public void mousePressed() {
  click_position_x = mouseX;
  click_position_y = mouseY;
}

public void mouseDragged() {  
  if(mouseButton == RIGHT) {
    Float delta_x = (float)mouseX - click_position_x;
    Float delta_y = (float)mouseY - click_position_y;
    // panning
    if(pan_x + delta_x < 100 && pan_x + delta_x > -100) {
      pan_x += delta_x;
    }
    
    if(pan_y + delta_y < 100 && pan_y + delta_y > -100) {
      pan_y += delta_y;
    }
  }
  
  if(mouseButton == LEFT) {
    // rotation
    rotate_x += (float)(mouseX - click_position_x);
    rotate_y += (float)(mouseY - click_position_y);

  }
}

public void mouseWheel(MouseEvent event) {
  zoom += (float)event.getCount(); 
}

public void setup() {
  
  
  ellipseMode(CENTER);
  rectMode(CENTER);
  frameRate(30);
  
  /*
  importFromJsonFile("3-23-16-browsing-history.json");
  //ArrayList<Node> nodeList = importFromCsvFile("3-23-16-browsing-history.csv");


  */

  slice.generateRandom();
  slice.calculatePositions();
}

public void draw() {
  background(255);
  lights();
  
  /*
  pushMatrix();
  rotateX( PI/4 );
  rotateY( radians( frameCount ) );
  rotateZ( radians( frameCount ) );
  drawCylinder(20, 30.0, 40.0);
  popMatrix();
  */
 
  /*   pushMatrix();
  translate((width / 2), (height / 2), -20);
  slice.drawSlice(1); 
  popMatrix();
  */
  
  pushMatrix();
  //translate((width / 2) + pan_x, (height / 2) + pan_y, zoom);
  translate(width / 2, height / 2, 0);
  slice.drawSlice(0); 
  popMatrix();
  
  //translate((width / 2) + pan_x, (height / 2) + pan_y, 10);
  camera((width/2.0f) + pan_x, (height/2.0f) + pan_y, (height/2.0f) / tan(PI*30.0f / 180.0f), 
        (width / 2.0f) + pan_x, (height/2.0f) + pan_y, 0, 
        0, 1, 0);
}
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
    adjacencyList = new ArrayList<ArrayList<Node>>(1048576);
    
    // initialize node list
    nodes = new ArrayList<Node>(1048576);
        
    for(Integer i = 0; i < 1048576; ++i) {
     adjacencyList.add(i, null); 
     nodes.add(i, null);
    }
  }
  
  public Integer getDuration() {
    return(this.duration);
  }
  
  public void addNode(Node node) { 
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
  
  public void drawGraph(Integer minDuration) {
      Node node;
      
      /*
      for(Integer i = 0; i < this.nodes.size(); ++i) {
        node = this.nodes.get(i);
        if(node.getDuration() >= minDuration) {
          drawNode(node.getCoordinates(), Shape.CIRCLE);
        }
      }
      */
      
      if(minDuration == 0) {
        this.drawLines();
      }
  }
  
  public void calculateNodePositions(
      Float levelSeparation, 
      Float sectorLengthSeparation, 
      Float levelsStartDiameter) {
        
    ArrayDeque<Node> queue = new ArrayDeque<Node>();
    Integer depth = 0;
    Integer elementsToDepthIncrease = 1;
    Integer nextElementsToDepthIncrease = 0;
    Integer breadth = 0;
    Integer breadthIndex = 0;
    Node current;
    Float parentAngle = 0.0f;
    Float separationAngle = 10.0f;
    Float graphAngle = startAngle + (abs(endAngle - startAngle) / 2);
    
    Float totalAngle = 0.0f;
                       
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
      
      Float angle = graphAngle + (separationAngle * (elementsToDepthIncrease - 1) - (totalAngle / 2));
      
      if(current != null && current.getParent() != null) {
        parentAngle = current.getParent().getAngle(); 
      
        // if only child
        if(adjacencyList.get(current.getParent().getIndex()).size() == 1) {
          angle = parentAngle;
        }
      }
      
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
  }
  
  public void drawLines() {
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
  
  public void createRandomSubgraph(Random generator,
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
      child.setDuration(generator.nextInt(10));
      
      // randomly decide to take path
      takePath = generator.nextInt(10) + 1;
      
      child.setParent(parent);
      parent.addChild(child);
      
      this.addNode(child);
      
      if(takePath >= 4) {
        // recursively call create random subgraph
        createRandomSubgraph(generator, maxDepth, depth + 1, maxChildren, child);
        break;
      }
    } 
    
     this.addNode(parent);
  }

  public void generateRandom(Integer maxDepth, Integer maxChildren) {
    Graph testGraph = new Graph();
  
    Random generator = new Random();
    Integer depth = 0;
    
    Node root = new Node();
    root.setIndex(nodeCount);
    root.setDuration(0);
    ++nodeCount;
        
    createRandomSubgraph(generator, maxDepth, depth, maxChildren, root);    
  }
  
  public void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  public void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
  
  public Integer getNodeCount() {
    return(this.nodeCount); 
  }
}
public class Node { 
  Integer index;
  Integer parentIndex;
  Node parent;
  ArrayList<Integer> childIndicies;
  ArrayList<Node> children;
  String url;
  Date start;
  Integer duration;
  Boolean subDomain;
  ArrayList<Float> coordinates;
  Float angle;
 
  Node() {
    this.children = new ArrayList<Node>();
  }
  
  public Node(Integer index, Integer parentIndex, String url, Date start, Integer duration, Boolean subDomain) {
    this.index = index;
    this.parentIndex = parentIndex;
    this.url = url;
    this.start = start;
    this.duration = duration;
    this.subDomain = subDomain;
  }
  
  public Integer getDuration() {
    return(this.duration); 
  }
  
  public Integer getParentIndex() {
    return(this.parentIndex); 
  }
  
  public Integer getIndex() {
     return(this.index); 
  }
  
  public ArrayList<Integer> getChildrenIndicies() {
     return(this.childIndicies); 
  }
  
  public void setParent(Node parent) {
    this.parent = parent; 
  }
  
  public Node getParent() {
    return(this.parent); 
  }
  
  public void setIndex(Integer index) {
    this.index = index; 
  }
  
  public void addChild(Node child) {
    this.children.add(child);
  }
  
  public ArrayList<Node> getChildren() {
    return(children); 
  }
  
  public void setCoordinates(ArrayList<Float> coordinates) {
    this.coordinates = coordinates;
  }

  public ArrayList<Float> getCoordinates() {
    return(this.coordinates);
  }
  
  public void setAngle(Float angle) {
    this.angle = angle;
  }
  
  public Float getAngle() {
     return(this.angle); 
  }
  
  public void setDuration(Integer duration) {
    this.duration = duration;
  }
}
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
    this.startAngle = 0.0f;
    this.endAngle = 0.0f;
    this.diameter = diameter;
    this.levelStartDiameter = levelStartDiameter;
    this.levelCount = levelCount;
    this.superLevelCount = superLevelCount;
    this.levelSeparation = (diameter - levelStartDiameter) / levelCount;
    this.duration = 0;
    this.nodeCount = 0;
    this.tabs = new ArrayList<Tab>();
  }
  
  public void drawSlice(Integer minDuration) {
    if(minDuration == 0) {
      this.drawGrid();
    }
    
    this.drawTabs(minDuration);
  }
  
  public void drawGrid(){
    noFill();
    stroke(0);
  
    strokeWeight(1.2f);
    
    // inner tab ring
    ellipse(0,0,(0.075f*diameter),(0.075f*diameter));
    
    // outer tab ring
    ellipse(0,0,(0.175f*diameter),(0.175f*diameter));
    
    
    strokeWeight(0.5f);
    for(float i = levelStartDiameter; i <= diameter; i += levelSeparation){
      ellipse(0,0,i,i);
    }
  
    strokeWeight(1.2f);
    for(float i = levelStartDiameter + levelSeparation * superLevelCount; i <= diameter; i += levelSeparation * superLevelCount){
      ellipse(0,0,i,i);
    }
    
    strokeWeight(0.5f);
    for(int i = 0; i < 12; i++) {
          angle = (float)i * 360 / 12;
          this.drawGridSpokes(0.025f*diameter, diameter/2);
    }
    
    strokeWeight(1.2f);
    for(int i = 0; i < 4; i++) {
          angle = (float)i * 360 / 4;
          this.drawGridSpokes(0.01875f*diameter, diameter/2);
    }
  }
  
  public void drawGridSpokes(float inside, float outside) {
    float xin  = sin(radians(-angle - 180)) * inside;
    float yin  = cos(radians(-angle - 180)) * inside;
    float xout = sin(radians(-angle - 180)) * outside;
    float yout = cos(radians(-angle - 180)) * outside;
    
    line(xin, yin, xout, yout);
  }
  
  public void addTab(Tab tab) {
    this.tabs.add(tab);
    this.duration += tab.getDuration();
    this.nodeCount += tab.getNodeCount();
  }
  
  public void generateRandom() {
    Random generator = new Random();

    Integer randomTabCount = generator.nextInt(3) + 3;
    
    for(Integer i = 0; i < randomTabCount; ++i) {
      Tab tab = new Tab(diameter, levelSeparation, levelStartDiameter);
      tab.generateRandom();
      
      this.addTab(tab);
    }
  }
  
  public void calculatePositions() {
    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < tabs.size(); ++i) {
       this.endAngle = startAngle + (((float)tabs.get(i).getDuration() / (12 * 60)) * 360);
       tabs.get(i).setStartAngle(startAngle);
       tabs.get(i).setEndAngle(endAngle);
       this.startAngle = this.endAngle;
    }
  }
  
  public void drawTabs(Integer minDuration) {
    for(Integer i = 0; i < tabs.size(); ++i) {
       tabs.get(i).drawTab(minDuration);
    }
    
    stroke(0, 153, 255);
    noFill();
    strokeWeight(40);
    strokeCap(SQUARE);
    arc(0, 0, 100, 100, 0.0f, radians(this.endAngle));
    
    for(Integer i = 0; i < tabs.size(); ++i) {
      tabs.get(i).drawTab(minDuration);
    }
  }
  
  public void printInfo() {
    println("Total nodes: " + this.nodeCount);
    println("Total duration: " + this.duration / 60 + " minutes"); 
  }
}
public class Tab {
  ArrayList<Graph> graphs;
  Integer duration;
  Float startAngle;
  Float endAngle;
  Float levelSeparation;
  Float levelStartDiameter;
  Float diameter;
  Integer nodeCount;
  
  Tab(Float diameter, Float levelSeparation, Float levelStartDiameter) {
    this.nodeCount = 0;
    this.diameter = diameter;
    this.levelSeparation = levelSeparation;
    this.levelStartDiameter = levelStartDiameter;
    this.duration = 0; 
    this.graphs = new ArrayList<Graph>();
  }
  
  public Integer getDuration() {
    return(this.duration); 
  }
  
  public void addGraph(Graph graph) {
    this.graphs.add(graph);
    this.duration += graph.getDuration();
    this.nodeCount += graph.getNodeCount();
  }
  
  public void generateRandom() {
    Random generator = new Random();

    Integer randomGraphCount = generator.nextInt(5) + 1;
    
    for(Integer i = 0; i < randomGraphCount; ++i) {
      Graph graph = new Graph();
      graph.generateRandom(20, 2);
      
      this.addGraph(graph);
    }
  }
  
  public void calculateGraph() {
    Float graphStartAngle = this.startAngle;
    Float graphEndAngle;
    Float graphAngle;
    Float tabAngle = endAngle - startAngle;
    
    // sort tabs from first accessed to last accessed
    for(Integer i = 0; i < graphs.size(); ++i) {
        graphAngle = (((float)graphs.get(i).getDuration() / this.duration)) * tabAngle;
        graphEndAngle = (float)graphStartAngle + graphAngle;
        graphs.get(i).setStartAngle(graphStartAngle);
        graphs.get(i).setEndAngle(graphEndAngle);
        graphs.get(i).calculateNodePositions(levelSeparation, 15.0f, levelStartDiameter);
        graphStartAngle = graphEndAngle;
    }
  }
  
  public void drawTab(Integer minDuration) {
    for(Integer i = 0; i < graphs.size(); ++i) {
      this.graphs.get(i).drawGraph(minDuration);
    }
    
    drawSpoke(diameter / 2, this.startAngle);
    drawSpoke(diameter / 2, this.endAngle);
  }
  
  public void drawSpoke(Float radius, Float angle) {
    ArrayList<Float> coordinates = getCartesian(radius, radians(angle));
    
    strokeWeight(3);
    stroke(0);
    line(0.0f, 0.0f, coordinates.get(0), coordinates.get(1));
  }
  
  public void setStartAngle(Float angle) {
    this.startAngle = angle; 
  }
  
  public void setEndAngle(Float angle) {
    this.endAngle = angle; 
  }
  
  public Integer getNodeCount() {
    return(this.nodeCount); 
  }
}
  public void settings() {  size(1296, 864, OPENGL);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "visualization" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
