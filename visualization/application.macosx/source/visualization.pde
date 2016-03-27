import java.sql.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.ArrayList;
import processing.opengl.*;

Float pan_x = 0.0;
Float pan_y = 0.0;
Integer click_position_x = 0;
Integer click_position_y = 0;
Float zoom = 0.0;
Float rotate_x = 0.0;
Float rotate_y = 0.0;

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

void drawCylinder(Integer sides, Float radius, Float height) {
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

ArrayList<Node> importFromJsonFile(String filename) {
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

ArrayList<Node> getChildrenFromString(String childrenString) {
  ArrayList<Node> children = new ArrayList<Node>();
  String[] indicies = childrenString.split(", ");
  
  return(children);
}

Boolean toBoolean(Integer value) {
  return(value != 0);
}

ArrayList<Node> importFromCsvFile(String filename) {
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

void drawNode(ArrayList<Float> coordinates, Shape shape) {
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
  
  //testGraph.drawGraph(20.0);
}

Slice slice = new Slice(800.0, 200.0, 20, 5);

void mousePressed() {
  click_position_x = mouseX;
  click_position_y = mouseY;
}

void mouseDragged() {  
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

void mouseWheel(MouseEvent event) {
  zoom += (float)event.getCount(); 
}

void setup() {
  size(1296, 864, OPENGL);
  smooth();
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

void draw() {
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
  camera((width/2.0) + pan_x, (height/2.0) + pan_y, (height/2.0) / tan(PI*30.0 / 180.0), 
        (width / 2.0) + pan_x, (height/2.0) + pan_y, 0, 
        0, 1, 0);
}