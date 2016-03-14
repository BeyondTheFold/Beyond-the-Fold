import java.sql.*;


void importSessions() {
  Connection sqliteConnection = null;
  
  try {
    Class.forName("org.sqlite.JDBC");
    sqliteConnection = DriverManager.getConnection("jdbc:sqlite:Library/Safari/LocalStorage/safari-extension_com.yourcompany.browsingvisualizer-0000000000_0.localstorage");
  } catch (Exception error) {
    System.err.println(error.getClass().getName() + ": " + error.getMessage());
    return;
  }
  println("Successfully opened database.");
  
  //JSONObject json = loadJSONObject("sessions.json");
  
  /*
  JSONArray sessions = jsonObject.getJSONArray("sessions");
  for(int i = 0; i < sessions.length; ++i) {
    
  }
  */
}

void setup() {
  importSessions();
}

void draw() {
  
}