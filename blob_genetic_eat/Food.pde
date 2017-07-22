
class Food {
  
  color c;
  float r;
  PVector pos;
  float energy;
  
  Food(color c_, float r_, float xpos, float ypos, float energy_){
    c = c_;
    r = r_;
    pos = new PVector(xpos, ypos);
    energy = energy_;
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
  
}