int pop_no = 50;
int food_no = 200;
float food_energy = 2.5;
ArrayList<Blob> blobs;
ArrayList<Food> foods;

// genetic variables
int d_inputs_n = 5;    // number of distance regions
int a_inputs_n = 10;    // number of angle regions
float sp_max = 50;

void setup() {
  
  // initialize size of window
  size(1000,700);
  
  // initialize blobs
  blobs = new ArrayList<Blob>();
  for (int i = 0; i<pop_no; i++){
    Blob blob = new Blob(color(0, 0, 0), 0, 0, sp_max, "", 0, 0, 0, d_inputs_n, a_inputs_n, "brownian");
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

  // display food outside of blob loop
  for (int i = foods.size()-1; i>=0; i--){
    Food food = foods.get(i);
    food.display();
  }
  
  // display and drive blobs
  
  for (int i = blobs.size()-1; i>=0; i--){
    Blob blob = blobs.get(i);
    blob.drive();
    blob.display();
  }
    
  // cycle through all blobs
  for (int i = blobs.size()-1; i>=0; i--){
    Blob blob = blobs.get(i);
    
    // check if blobs hit walls
    blob.check_wall_collision();
    
    //check if blobs hit each other
    for (int j = i-1; j>=0; j--){
      Blob other_blob = blobs.get(j);
      blob.check_blob_collision(other_blob);
      
      // remove dead blobs from array
      if (blob.r <= 0){
        blobs.remove(i);  //<>//
        break;
      }
      // remove dead blobs from array
      if (other_blob.r <= 0){
        blobs.remove(j); //<>//
        i--;
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
  
  fill(255);
  text("blobs left: " + str(blobs.size()), width/2, height/2);
  text("foods left: " + str(foods.size()), width/2, height/2-12);
}

class Blob {

  color c;
  float r;
  float sp;
  float sp_max;
  String name;
  PVector pos;
  PVector vel;
  float vis_r;
  float[] d_inputs;
  float[] a_inputs;
  float[] blob_neural_input;
  float[] food_neural_input;
  float[] wall_neural_input;
  String dr_mode;

  Blob(color c_, float r_, float sp_, float sp_max_, String name_, float xpos_, float ypos_, float vis_r_, int d_inputs_n, int a_inputs_n, String dr_mode_){
    c = c_;
    r = r_;
    sp_max = sp_max_;
    sp = sp_max/r;
    name = name_;
    pos = new PVector(xpos_, ypos_);
    vel = new PVector(0, 0);
    vis_r = vis_r_;
    d_inputs = new float[d_inputs_n];
    a_inputs = new float[a_inputs_n];
    blob_neural_input = new float[d_inputs_n*a_inputs_n];
    food_neural_input = new float[d_inputs_n*a_inputs_n];
    wall_neural_input = new float[d_inputs_n*a_inputs_n];
    dr_mode = dr_mode_;
}
  
  void display() {
    
    // display vision circle
    stroke(red(c), green(c), blue(c), 20);
    fill(red(c), green(c), blue(c), 20);
    ellipse(pos.x, pos.y, 2*vis_r, 2*vis_r);
    
    // display body
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, 2*r, 2*r);

  }

  void drive() {
    
    if (dr_mode == "brownian"){
    // random brownian movement
    vel.x += random(-1, 1)*sp;
    vel.y += random(-1, 1)*sp;
      
    // limit speed
    vel.x = constrain(vel.x, -sp, sp);
    vel.y = constrain(vel.y, -sp, sp);
    
    // update position
    pos.add(vel);
    }
    else if (dr_mode == "mouse"){
      pos.x = pos.x*(100-sp)/100 + float(mouseX)*sp/100;
      pos.y = pos.y*(100-sp)/100 + float(mouseY)*sp/100; 
    }
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
    
    // check body collision
    if (pos.dist(other_blob.pos) < (r + other_blob.r)){
        
      if (r < other_blob.r){
        other_blob.r = sqrt(pow(other_blob.r, 2) + pow(r, 2));
        other_blob.vis_r = 2*other_blob.r;
        other_blob.sp = other_blob.sp_max/other_blob.r;
        r = 0;
      }
      else if (r > other_blob.r){
       r = sqrt(pow(other_blob.r, 2) + pow(r, 2));
       vis_r = 2*r;
       sp = sp_max/r;
       other_blob.r = 0;
      } 
    }
    
    // check vision collision
    if (pos.dist(other_blob.pos) < (vis_r + other_blob.r)){
      
      float dist = pos.dist(other_blob.pos) - other_blob.r;
      float dist_normal = max(dist/vis_r, 0);
      int dist_region = int(dist_normal*d_inputs.length);
      float angle = atan2((other_blob.pos.y-pos.y), -(other_blob.pos.x-pos.x)) + PI;
      float angle_normal = angle/TWO_PI;
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      
      int neural_input_location = dist_region * a_inputs.length + angle_region;
      blob_neural_input[neural_input_location] = r-other_blob.r; //<>//
      
      stroke(255);
      fill(255);
      line(pos.x, pos.y, pos.x + cos(angle_rounded)*r, pos.y - sin(angle_rounded)*r);
      //line(pos.x, pos.y, pos.x + cos(angle)*r, pos.y - sin(angle)*r);
      text(str(neural_input_location), pos.x, pos.y);
    }
    
    if (pos.dist(other_blob.pos) < (r + other_blob.vis_r)){
     
      float dist = other_blob.pos.dist(pos) - r;
      float dist_normal = max(dist/other_blob.vis_r, 0);;
      int dist_region = int(dist_normal*other_blob.d_inputs.length);
      float angle = atan2((pos.y-other_blob.pos.y), -(pos.x-other_blob.pos.x)) + PI;
      float angle_normal = angle/TWO_PI;
      int angle_region = int(angle_normal*other_blob.a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/other_blob.a_inputs.length + PI/other_blob.a_inputs.length;
      
      int neural_input_location = dist_region * other_blob.a_inputs.length + angle_region;
      other_blob.blob_neural_input[neural_input_location] = other_blob.r-r; //<>//
      
      stroke(255);
      fill(255); 
      line(other_blob.pos.x, other_blob.pos.y, other_blob.pos.x + cos(angle_rounded)*other_blob.r, other_blob.pos.y - sin(angle_rounded)*other_blob.r);
      //line(other_blob.pos.x, other_blob.pos.y, other_blob.pos.x + cos(angle)*other_blob.r, other_blob.pos.y - sin(angle)*other_blob.r); 
      text(str(neural_input_location), other_blob.pos.x, other_blob.pos.y);  
  }
    
    
  }
  
  void check_food_collision(Food food){
    
    // check collision with blob
    if (pos.dist(food.pos) < (r + food.r)){
      if (r > food.r){
       r = sqrt(pow(food.energy, 2) + pow(r, 2));
       vis_r = 2*r;
       sp = sp_max/r;
       food.r = 0;
      }
    }
    
    // check collision with blob vision
    if (pos.dist(food.pos) < (vis_r + food.r)){
      float angle = atan2((food.pos.y-pos.y), -(food.pos.x-pos.x)) + PI;
      stroke(200, 100, 100);
      fill(200, 100, 100);
      //line(pos.x, pos.y, pos.x + cos(angle)*r, pos.y - sin(angle)*r);
    }
  }
  
  void randomize(){
    // randomize blobs
    
    c = color(random(255), random(255), random(255));
    r = random(5, 50);
    sp = sp_max/r;
    name = "random blob";
    pos = new PVector(random(width), random(height));
    vel = new PVector(0, 0);
    vis_r = r*1.5;
  }
}

void mousePressed(){
  Blob mouseblob = new Blob(color(0, 0, 0), 0, 0, sp_max, "", 0, 0, 0, d_inputs_n, a_inputs_n, "mouse");
  mouseblob.randomize();
  mouseblob.r = 10;
  mouseblob.sp = 100;
  blobs.add(mouseblob); 
}

void keyPressed(){

}