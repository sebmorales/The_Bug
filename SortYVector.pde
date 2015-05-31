class SortYVector extends PVector implements Comparable<PVector>{
  
  public SortYVector(float x, float y, float z){
    super(x,y,z);
  }
  
  public int compareTo(PVector other) {
    if(this.y < other.y){
      return -1;
    }
    if(this.y > other.y){
      return 1;
    }
    if(this.x < other.x){
      return -1;
    }
    if(this.x > other.x){
      return 1;
    }
    if(this.z > other.z){
      return -1;
    }
    if(this.z < other.z){
      return 1;
    }
    else{
      return 0;
    }
  }
}
