int pop_no = 25;
int food_no = 100;
ArrayList<Blob> blobs;
ArrayList<Food> foods;

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
  
  foods = new ArrayList<Food>();
  for (int i = 0; i<food_no; i++){
    Food food = new Food(color(random(255), random(255), random(255), 100), 5, random(0, width), random(0, height));
    foods.add(food);
  }

}

void draw() {
  background(0);
  
  
  for (int i = blobs.size()-1; i>=0; i--){
    Blob blob = blobs.get(i);
    
    // move blobs
    blob.drive();
    blob.display();
    
    // check if blobs hit walls
    blob.check_wall_collision();
    
    //check if blobs hit each other
    for (int j = i-1; j>=0; j--){
      Blob other_blob = blobs.get(j);
      blob.check_blob_collision(other_blob);
      
      // remove dead blobs from array
      if (blob.sz <= 0){
        blobs.remove(i); 
        break;
      }
      // remove dead blobs from array
      if (other_blob.sz <= 0){
        blobs.remove(j); 
        continue;
      } 
    }
    
    // check if blobs hit food
    for (int j = foods.size()-1; j>=0; j--){
      Food food = foods.get(j);
      blob.check_food_collision(food);
      if (food.sz <= 0){
       foods.remove(j);
       Food new_food = new Food(color(random(255), random(255), random(255), 100), 5, random(0, width), random(0, height));
       foods.add(new_food);
       continue;
      }
    }
  }
  
  for (int i = foods.size()-1; i>=0; i--){
    Food food = foods.get(i);
    food.display();
  }
  
  fill(255);
  text("blobs left: " + str(blobs.size()), width/2, height/2);
  text("foods left: " + str(foods.size()), width/2, height/2-12);
}

class Blob {

  color c;
  float sz;
  float sp;
  String name;
  PVector pos;
  PVector vel;
  
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
  
  void check_wall_collision(){
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
    
  void check_blob_collision(Blob other_blob){
    if (pos.dist(other_blob.pos) < (sz/2 + other_blob.sz/2)){
      
        if (sz < other_blob.sz){
          other_blob.sz = sqrt(pow(other_blob.sz, 2) + pow(sz, 2));
          other_blob.sp = 50/other_blob.sz;
          sz = 0;
        }
        if (sz > other_blob.sz){
         sz = sqrt(pow(other_blob.sz, 2) + pow(sz, 2));
         sp = 50/sz;
         other_blob.sz = 0;
        }
    }
  }
  
  void check_food_collision(Food food){
      if (pos.dist(food.pos) < (sz/2 + food.sz/2)){
        if (sz > food.sz){
         sz = sqrt(pow(food.sz, 2) + pow(sz, 2));
         sp = 50/sz;
         food.sz = 0;
        }
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