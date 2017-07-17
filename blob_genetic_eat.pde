int pop_no = 50;
ArrayList<Blob> blobs;

void setup() {
  // initialize size of window
  size(1000,700);
  // initialize blobs
  blobs = new ArrayList<Blob>();
  for (int i = 0; i<pop_no; i++){
    // make new generic blob  
    Blob blob = new Blob(color(0, 0, 0), 0, 0, "", 0, 0);
    // randomize blob
    blob.randomize();
    // add blob to array
    blobs.add(blob);
  }

}

void draw() {
  background(0);
  // move and draw blobs
  for (Blob blob : blobs){
    blob.drive();
    blob.display();
    blob.check_wall_collsion();
  }

}

class Blob {
  PVector pos;
  PVector vel;
  String name;
  color c;
  float sz;
  float sp;
  
  Blob(color c_, float sz_, float sp_, String name_, float xpos_, float ypos_){
    c = c_;
    sz = sz_;
    sp = sp_/sz_;
    name = name_;
    pos = new PVector(xpos_, ypos_);
    vel = new PVector(0, 0);
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, sz, sz);
  }

  void drive() {
    // random brownian movement
    vel.x += random(-1, 1)*sp;
    vel.y += random(-1, 1)*sp;
      
    // limit speed
    vel.x = constrain(vel.x, -sp, sp);
    vel.y = constrain(vel.y, -sp, sp);
    
    // update position
    pos.add(vel);
  }
  
  void check_wall_collsion(){
    if (pos.x > width-sz/2) {
      pos.x = width-sz/2;
      vel.x *= -0.5;
      } 
    else if (pos.x < sz/2) {
      pos.x = sz/2;
      vel.x *= -0.5;
      } 
    else if (pos.y > height-sz/2) {
      pos.y = height-sz/2;
      vel.y *= -0.5;
      } 
    else if (pos.y < sz/2) {
      pos.y = sz/2;
      vel.y *= -0.5;
      }
    }
  
  void randomize(){
    c = color(random(255), random(255), random(255));
    sz = random(10, 100);
    sp = 50/sz;
    name = "random blob";
    pos = new PVector(random(width), random(height));
    vel = new PVector(0, 0);
  }
}