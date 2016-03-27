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
Boolean forLaserCutting = true;

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

Connection connection = null;
Statement statement = null;

void connectToDatabase() {
  try {
    Class.forName("org.sqlite.JDBC");
    connection = DriverManager.getConnection("jdbc:sqlite:Library/Safari/LocalStorage/safari-extension_browsingvisualizer-0000000000_0.localstorage");
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
  }
  println("Successfully opened database.");
}

String getSessionsFromDatabase() {
  String sessions = "";
 
  try {
    statement = connection.createStatement();
    ResultSet result = statement.executeQuery("SELECT value FROM ItemTable WHERE key='sessions'");
    byte[] b = result.getBytes("value");

    for(byte character : b) {
      if(character != 0) {
        sessions += new String(new byte[] { character });
      }
    }
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
    return(null);
  }

  return(sessions);
}

void constructFromJSON(JSONObject json) {
  JSONArray values = json.getJSONArray("sessions");

  Integer index;
  String url;
  String sessionStartString;
  Date sessionStart;
  Integer duration;
  Integer parent = 0;
  String current_key;
  
  ArrayList<Node> nodes = new ArrayList<Node>();
  JSONObject session;
  JSONArray childrenArray;
  
  for(Integer i = 0; i < values.size(); ++i) {
    session = values.getJSONObject(i);
    index = session.getInt("index");
    //url = session.getString("url");
    sessionStartString = session.getString("sessionStart");
    sessionStart = new Date();
    duration = session.getInt("sessionDuration");
    duration = (duration / 1000) / 60;
    parent = session.getInt("parent");
    childrenArray = session.getJSONArray("children");
    ArrayList<Integer> children = new ArrayList<Integer>();
    
    for(int j = 0; j < childrenArray.size(); ++j) {
      children.add(childrenArray.getInt(j));
    }

    nodes.ensureCapacity(index + 1);
    while(nodes.size() < index + 1) {
      nodes.add(new Node());
    }
    
    Node node = new Node(index, parent, sessionStart, duration, false);
    node.setChildIndicies(children);
    nodes.set(index, node);
  }
  
  ArrayList<Graph> graphs = new ArrayList<Graph>();
  
  // for all nodes without parents
  for(Integer i = 0; i < nodes.size(); ++i) {
    if(nodes.get(i).getIndex() != null && nodes.get(i).getParentIndex() == -1) {
      Graph graph = new Graph(100.0, 20.0, 200.0);
      graph.constructGraph(nodes, nodes.get(i));
      graphs.add(graph);
    }
  }

  for(Integer i = 0; i < graphs.size(); ++i) {
    graphs.get(i).calculateLevelBreadths();
    graphs.get(i).calculateNodePositions();
    graphs.get(i).drawGraph(0);

  }
  
  //graphs.get(0).printAdjacencyList();
  //graphs.get(maxIndex).printAdjacencyList();
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
    
    Node node = new Node(index, parent, sessionStart, duration, subDomain);
    nodes.add(node);
  }
  
  return(nodes);
}

void drawNode(ArrayList<Float> coordinates, Shape shape) {
  Float x = coordinates.get(0);
  Float y = coordinates.get(1);

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
  Float radians = radians(angle);
  ArrayList<Float> coordinates = getCartesian(radius, radians);
  Float x = coordinates.get(0);
  Float y = coordinates.get(1);

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

JSONObject json;

void setup() {
  //size(1296, 864, OPENGL);
  size(1296, 864);
  
  connectToDatabase();
  json = loadJSONObject("test_data2.json");
  //json = loadJSONObject("test_data.json");

  
  /*
  importFromJsonFile("3-23-16-browsing-history.json");
  //ArrayList<Node> nodeList = importFromCsvFile("3-23-16-browsing-history.csv");
  */
  
  //JSONObject json = parseJSONObject(getSessionsFromDatabase());
  //println(getSessionsFromDatabase());

  /*
  translate((width / 2), (height / 2));
  
  Slice slice = new Slice(800.0, 200.0, 10, 5);
  slice.generateRandom();
  slice.calculatePositions();
  slice.drawSlice(0); 
  
  //testDrawNode();
  //testGetCartesian();
  //testDrawGraph();
  */
}

void draw() {
  clear();
  smooth();
  ellipseMode(CENTER);
  rectMode(CENTER);
  background(255);
  
  //json = parseJSONObject(getSessionsFromDatabase());
  constructFromJSON(json);
  /*
  lights();
  

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
  
  
  pushMatrix();
  //translate((width / 2) + pan_x, (height / 2) + pan_y, zoom);
  translate(width / 2, height / 2, 0);
  slice.drawSlice(0); 
  popMatrix();
  
  //translate((width / 2) + pan_x, (height / 2) + pan_y, 10);
  camera((width/2.0) + pan_x, (height/2.0) + pan_y, (height/2.0) / tan(PI*30.0 / 180.0), 
        (width / 2.0) + pan_x, (height/2.0) + pan_y, 0, 
        0, 1, 0);
  */
}