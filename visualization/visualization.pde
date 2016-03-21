import java.sql.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.ArrayList;

enum Shape {
  CIRCLE,
  DIAMOND
}

ArrayList<Float> getCartesian(Float radius, Float angle) {
  ArrayList<Float> coordinates = new ArrayList<Float>(2);
  
  coordinates.add(0, radius * cos(angle));
  coordinates.add(1, radius * sin(angle));
  
  return coordinates;
}

Float totalDiameter = 800.0;
Float angle = 0.0;
Integer sliceDuration = 12;
Float sliceStartAngle = radians(0.0);
Float levelsStartDiameter = 200.0;
Integer subLevelCount = 20;
Float levelSeparation = (totalDiameter - levelsStartDiameter) / subLevelCount;

String getSessionsFromDatabase() {
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

ArrayList<Node> importFromJsonFile() {
  ArrayList<Node> nodes = new ArrayList<Node>();
  JSONObject json = loadJSONObject("test_data.json");

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

ArrayList<Node> getChildrenFromString(String childrenString) {
  ArrayList<Node> children = new ArrayList<Node>();
  String[] indicies = childrenString.split(", ");
  
  return(children);
}

Boolean toBoolean(Integer value) {
  return(value != 0);
}

ArrayList<Node> importFromCsvFile() {
  Table table = loadTable("test_data.csv", "header");
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

void drawNode(float radius, float angle, Shape shape) {
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

void testDrawLinearGraph() {
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
  
  testGraph.drawGraph(levelSeparation);
}

void setup() {
  size(1296, 864);
  background(255);
  translate(width/2, height/2);
  smooth();
  ellipseMode(CENTER);
  rectMode(CENTER);
  
  //importFromJsonFile();
  //ArrayList<Node> nodeList = importFromCsvFile();

  Slice slice = new Slice();
  slice.generateRandom();
  slice.drawSlice(20, 5, 200.0);
}

void draw() {

}