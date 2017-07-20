
class Food {
  
  color c;
  float sz;
  PVector pos;
  float energy;
  
  Food(color c_, float sz_, float xpos, float ypos, float energy_){
    c = c_;
    sz = sz_;
    pos = new PVector(xpos, ypos);
    energy = energy_;
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, sz, sz);
  }
  
}