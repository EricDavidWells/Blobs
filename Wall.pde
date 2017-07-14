class Line_Wall {
  float x1;
  float x2;
  float y1;
  float y2;
  color c;
  float t;
  
  Line_Wall(float x1_,  float x2_, float y1_, float y2_, color c_, float t_){
    x1 = x1_;
    x2 = x2_;
    y1 = y1_;
    y2 = y2_;
    c = c_;
    t = t_;
  }
  
  void display(){
   stroke(c);
   strokeWeight(t);
   line(x1, x2, y1, y2);
  }
  
}