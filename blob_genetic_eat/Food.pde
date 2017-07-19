
class Food {
  
  color c;
  float sz;
  PVector pos;
  
  Food(color c_, float sz_, float xpos, float ypos){
    c = c_;
    sz = sz_;
    pos = new PVector(xpos, ypos);
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, sz, sz);
  }
  
}