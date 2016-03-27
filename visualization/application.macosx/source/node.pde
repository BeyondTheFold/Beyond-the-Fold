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
  
  Integer getDuration() {
    return(this.duration); 
  }
  
  Integer getParentIndex() {
    return(this.parentIndex); 
  }
  
  Integer getIndex() {
     return(this.index); 
  }
  
  ArrayList<Integer> getChildrenIndicies() {
     return(this.childIndicies); 
  }
  
  void setParent(Node parent) {
    this.parent = parent; 
  }
  
  Node getParent() {
    return(this.parent); 
  }
  
  void setIndex(Integer index) {
    this.index = index; 
  }
  
  void addChild(Node child) {
    this.children.add(child);
  }
  
  ArrayList<Node> getChildren() {
    return(children); 
  }
  
  void setCoordinates(ArrayList<Float> coordinates) {
    this.coordinates = coordinates;
  }

  ArrayList<Float> getCoordinates() {
    return(this.coordinates);
  }
  
  void setAngle(Float angle) {
    this.angle = angle;
  }
  
  Float getAngle() {
     return(this.angle); 
  }
  
  void setDuration(Integer duration) {
    this.duration = duration;
  }
}