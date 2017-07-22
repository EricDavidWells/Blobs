int pop_no = 25;
int food_no = 500;
float food_energy = 2.5;
ArrayList<Blob> blobs;
ArrayList<Food> foods;



void setup() {
  
  // initialize size of window
  size(1000,700);
  
  // initialize blobs
  blobs = new ArrayList<Blob>();
  for (int i = 0; i<pop_no; i++){
    Blob blob = new Blob(color(0, 0, 0), 0, 0, "", 0, 0);
    blob.randomize();
    blobs.add(blob);
  }
  
  // initialize foods
  foods = new ArrayList<Food>();
  for (int i = 0; i<food_no; i++){
    Food food = new Food(color(random(10, 255), random(10, 255), random(10, 255), 50), 2.5, random(0, width), random(0, height), food_energy);
    foods.add(food);
  }

}

void draw() {
  background(0);
    
  // cycle through all blobs
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
      if (blob.r <= 0){
        blobs.remove(i); 
        break;
      }
      // remove dead blobs from array
      if (other_blob.r <= 0){
        blobs.remove(j); 
        continue;
      } 
    }
    
    // check if blobs hit food
    for (int j = foods.size()-1; j>=0; j--){
      Food food = foods.get(j);
      blob.check_food_collision(food);
      
      // remove dead food and add a new food
      if (food.r <= 0){
       foods.remove(j);
       Food new_food = new Food(color(random(255), random(255), random(255), 100), 2.5, random(0, width), random(0, height), food_energy);
       foods.add(new_food);
       continue;
      }
    }
  }
  
  // display food outside of blob loop
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
  float r;
  float sp;
  String name;
  PVector pos;
  PVector vel;
  float vis_r;
  
  Blob(color c_, float r_, float sp_, String name_, float xpos_, float ypos_, float vis_r_){
    c = c_;
    r = r_;
    sp = sp_/r;
    name = name_;
    pos = new PVector(xpos_, ypos_);
    vel = new PVector(0, 0);
    vis_r = vis_r_;
  }
  
  void display() {
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, 2*r, 2*r);
    stroke(red(c), green(c), blue(c), 50);
    fill(red(c), green(c), blue(c), 50);
    ellipse(pos.x, pos.y, 2*vis_r, 2*vis_r);
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
    if (pos.x > width-r) {
      pos.x = width-r;
      vel.x *= -0.5;
      } 
    else if (pos.x < r) {
      pos.x = r;
      vel.x *= -0.5;
      } 
    else if (pos.y > height-r) {
      pos.y = height-r;
      vel.y *= -0.5;
      } 
    else if (pos.y < r) {
      pos.y = r;
      vel.y *= -0.5;
      }
    }
    
  void check_blob_collision(Blob other_blob){
    if (pos.dist(other_blob.pos) < (r + other_blob.r)){
      
        if (r < other_blob.r){
          other_blob.r = sqrt(pow(other_blob.r, 2) + pow(r, 2));
          other_blob.sp = 50/other_blob.r;
          r = 0;
        }
        if (r > other_blob.r){
         r = sqrt(pow(other_blob.r, 2) + pow(r, 2));
         sp = 50/r;
         other_blob.r = 0;
        }
    }
  }
  
  void check_food_collision(Food food){
      if (pos.dist(food.pos) < (r + food.r)){
        if (r > food.r){
         r = sqrt(pow(food.energy, 2) + pow(r, 2));
         sp = 25/r;
         food.r = 0;
        }
    }
  }
  
  void randomize(){
    c = color(random(255), random(255), random(255));
    r = random(5, 50);
    sp = 25/r;
    name = "random blob";
    pos = new PVector(random(width), random(height));
    vel = new PVector(0, 0);
  }
}