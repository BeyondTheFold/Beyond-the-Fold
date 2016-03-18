import java.sql.*;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.ArrayList;

public class Session { 
  int index;
  int parent;
  ArrayList<Session> children;
  String url;
  Date start;
  int duration;
  Boolean subDomain;
 
  public Session() {
    
  }
  
  public Session(int index, int parent, ArrayList<Session> children, String url, Date start, int duration, Boolean subDomain) {
    this.index = index;
    this.parent = parent;
    this.children = children;
    this.url = url;
    this.start = start;
    this.duration = duration;
    this.subDomain = subDomain;
  }
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

ArrayList<Session> importFromJsonFile() {
  ArrayList<Session> sessions = new ArrayList<Session>();
  JSONObject json = loadJSONObject("test_data.json");

  Iterator iterator = json.keys().iterator();

  String url;
  String sessionStartString;
  Date sessionStart;
  int duration;
  int parent;
  String current_key;
  
  ArrayList<Session> children = new ArrayList<Session>();

  while(iterator.hasNext()) {
    current_key = (String)iterator.next();
    url = json.getJSONObject(current_key).getString("url");
    sessionStartString = json.getJSONObject(current_key).getString("sessionStart");
    sessionStart = new Date();
    duration = json.getJSONObject(current_key).getInt("sessionDuration");
    parent = json.getJSONObject(current_key).getInt("parent");

    //ArrayList<Session> children = getChildrenFromString(row.getString("Children"));
    
    Session session = new Session(Integer.parseInt(current_key), parent, children, url, sessionStart, duration, false);
    sessions.add(session);
  }
  
  return(sessions);
}

Session getParentFromInt(String index) {
  Session parent = new Session();
  
  return(parent);
}

ArrayList<Session> getChildrenFromString(String childrenString) {
  ArrayList<Session> children = new ArrayList<Session>();
  String[] indicies = childrenString.split(", ");
  
  return(children);
}

ArrayList<Session> importFromCsvFile() {
  Table table = loadTable("test_data.csv");
  ArrayList<Session> sessions = new ArrayList<Session>();
  
  for (TableRow row : table.rows()) {
    /*
    int index = row.getInt("Index");
    String url = row.getString("URL");
    String sessionStartString = row.getString("Session Start");
    Date sessionStart = new Date();
    int duration = row.getInt("Duration");
    Session parent = getParentFromInt(row.getString("Parent"));
    ArrayList<Session> children = getChildrenFromString(row.getString("Children"));
    
    Session session = new Session(index, parent, children, url, sessionStart, duration);
    
    sessions.add(session);
    */
  }
  
  return(sessions);
}

void setup() {
  importFromJsonFile();
}

void draw() {

}