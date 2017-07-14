int pop_no = 10;
ArrayList<Blob> blobs;
Blob random_blob;

void setup() {
  size(1000,1000);
  blobs = new ArrayList<Blob>();
  
  for (int i = 0; i<pop_no; i++){
    blobs.add(make_random_blob());  
  }
}

void draw() {
  background(255);
  for (Blob blob : blobs){
    blob.drive();
    blob.display();
  }
}

class Blob {
  String name;
  float xpos;
  float ypos;
  color c;
  float sz;
  float sp;
  float xsp;
  float ysp;
  
  Blob(color c_, float sz_, float sp_, String name_, float xpos_, float ypos_){
    c = c_;
    sz = sz_;
    sp = sp_/sz_;
    name = name_;
    xpos = xpos_;
    ypos = ypos_;
    xsp = sp_/sz_;
    ysp = sp_/sz_;
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(xpos, ypos, sz, sz);
  }
  
  void drive() {
    xsp += random(-100, 100)*sp/100;
    ysp += random(-100, 100)*sp/100;
    xpos += xsp;
    ypos += ysp;
  }
}

Blob make_random_blob(){
  color rand_c = color(random(255), random(255), random(255));
  float rand_size = random(100);
  String name = "random blob";
  float rand_xpos = random(width);
  float rand_ypos = random(height);
  float speed = 50;
  random_blob = new Blob(rand_c, rand_size, speed, name, rand_xpos, rand_ypos);
  
  return random_blob;
}

class Wall {
  

  
}