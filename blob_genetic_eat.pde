int pop_no = 50;
ArrayList<Blob> blobs;
ArrayList<Line_Wall> walls;

void setup() {
  size(1000,1000);
  
  // initialize blobs
  blobs = new ArrayList<Blob>();
  for (int i = 0; i<pop_no; i++){
    blobs.add(make_random_blob());  
  }
  
  // initialize walls
  walls = new ArrayList<Line_Wall>();
  walls.add(new Line_Wall(0, width, 0, 0, 0, 1));
  walls.add(new Line_Wall(width, width, 0, height, 0, 1));
  walls.add(new Line_Wall(width, 0, height, height, 0, 1));
  walls.add(new Line_Wall(0, 0, height, 0, 0, 1));

}

void draw() {
  background(0);
  // move and draw blobs
  for (Blob blob : blobs){
    blob.drive();
    blob.display();
  }
  
  // draw walls
  for (Line_Wall wall : walls){
   wall.display(); 
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
    vel.x += random(-1, 1)*sp;
    vel.y += random(-1, 1)*sp;
    pos.add(vel);
  }
  
  void check_wall_collsion(ArrayList <Line_Wall> walls_){
    float radius = sz/2;
    for (Line_Wall wall : walls_){
      
    }
  }
}



Blob make_random_blob(){
  color rand_c = color(random(255), random(255), random(255));
  float rand_size = random(100);
  String name = "random blob";
  float rand_xpos = random(width);
  float rand_ypos = random(height);
  float speed = 50;
  Blob random_blob = new Blob(rand_c, rand_size, speed, name, rand_xpos, rand_ypos);
  
  return random_blob;
}  