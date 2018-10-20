import org.jblas.*;
import org.jblas.exceptions.*;
import org.jblas.util.*;
import org.jblas.benchmark.*;
import org.jblas.ranges.*;

int pop_no = 25;
int food_no = 50;
float food_energy = 8;
ArrayList<Food> foods;
Population blobs;

// genetic variables
int d_inputs_n = 1;    // number of distance regions
int a_inputs_n = 12;    // number of angle regions
int extra_inputs = 0;
int[] sizes = {d_inputs_n*a_inputs_n*3 + extra_inputs, 6, 2};
float sp_max = 20;    // max speed for all blobs, actual speed is sp_max/r
float r_start = 10;    // radius to start blobs at
float vis_mult = 3;    // number to multiply radius by to get vision range
float vis_min = 60;
float move_decay_rate = 0.0100;   // rate at which blobs decay
float age_decay_rate = 0.000005;
float mutation_rate = 0.05;
float walldecay = 1;
float dead_band = 0.05;

boolean display_flag = true;

PrintWriter writer;

void setup() {
  
  // initialize size of window
  size(1000,700);
  frameRate(50);
  String filename = str(year()) + '-' + str(month()) + '-' + str(day()) + '_' + str(hour()) + 'h' + str(minute()) + "_fitness_data.txt";
  writer = createWriter("fitness_data\\" + filename);
  
  blobs = new Population();
  // initialize blobs into population class
  for (int i = 0; i<pop_no; i++){
    Blob blob = new Blob(r_start, sp_max, vis_mult, d_inputs_n, a_inputs_n, "NN", sizes);
    blob.randomize();
    blob.rebuild();
    blobs.individuals.add(blob);
  }
  
  // initialize foods into arraylist object
  foods = new ArrayList<Food>();
  for (int i = 0; i<food_no; i++){
    Food food = new Food(color(random(10, 255), random(10, 255), random(10, 255), 50), 2.5, random(0, width), random(0, height), food_energy);
    foods.add(food);
  }

}

void draw() {
  background(0);
  
  if (display_flag == true){
    // display food
    for (int i = foods.size()-1; i>=0; i--){
      Food food = foods.get(i);
      food.display();
    }
    // display all blobs
    blobs.display();
  }
  // drive all blobs
  blobs.drive();
  // check all collisions
  blobs.check_collisions();
  // evaluate fitness
  //blobs.evaluate_fitness();
  // selection and reproduction
  blobs.reproduce();
    
  fill(255);
  //text("blobs left: " + str(blobs.individuals.size()), width/2, height/2);
  //text("foods left: " + str(foods.size()), width/2, height/2-12);
  text("frame count: " + str(frameCount), width-110, 14);
  text("time: " + str(millis()/1000), width-110, 26);
  text("generation: " + str(blobs.generation), width-110, 38);
}

class Blob {

  color c;  // color
  float r;  // radius
  float sp;  // speed
  float sp_max;  // max speed
  String name;  // name
  PVector pos;  // position
  PVector vel;  // velocity
  float vis_r;  // vision radius
  float vis_mult;
  float[] d_inputs;  // number of distance input neurons
  float[] a_inputs;  // number of angular input neurons
  float[] NN_blob_input;  // input for blob vision
  float[] NN_food_input;  // input for food vision
  float[] NN_wall_input;  // input for wall vision
  String dr_mode;  // drive mode
  int[] sizes = new int[3];
  float[] chromosome;
  ArrayList<org.jblas.FloatMatrix> weights = new ArrayList<org.jblas.FloatMatrix>();
  ArrayList<org.jblas.FloatMatrix> biases = new ArrayList<org.jblas.FloatMatrix>();
  float max_r;
  float energy_consumed;
  float birthday;
  float age;
  float fitness;
  int wallflag;
  float direction;
  org.jblas.FloatMatrix output;

  Blob(float r_start, float sp_max_, float vis_mult_, int d_inputs_n, int a_inputs_n, String dr_mode_, int[] sizes_){
    c = 0;
    r = r_start;
    sp_max = sp_max_;
    sp = sp_max/r;
    name = "blob";
    pos = new PVector(random(r_start, width-r_start), random(r_start, height-r_start));
    vel = new PVector(0, 0);
    vis_mult = vis_mult_;
    vis_r = r*vis_mult_;
    max_r = 0;
    energy_consumed = 0;
    birthday = frameCount;
    age = 0;
    d_inputs = new float[d_inputs_n];
    a_inputs = new float[a_inputs_n];
    NN_blob_input = new float[d_inputs_n*a_inputs_n];
    NN_food_input = new float[d_inputs_n*a_inputs_n];
    NN_wall_input = new float[d_inputs_n*a_inputs_n];
    dr_mode = dr_mode_;
    //sizes[0] = d_inputs_n*a_inputs_n*3;
    //sizes[1] = 8;
    //sizes[2] = 4;
    sizes = sizes_;
    chromosome = new float[((sizes[1] + sizes[2]) + (sizes[0]*sizes[1] + sizes[1]*sizes[2])) + 3];
    output = org.jblas.FloatMatrix.zeros(4);
    wallflag = 0;
    direction = random(0, TWO_PI);
}
  
  void display() {
    
    // display vision circle
    stroke(red(c), green(c), blue(c), 20);
    fill(red(c), green(c), blue(c), 20);
    ellipse(pos.x, pos.y, vis_r*2, vis_r*2);
    
    // display body
    stroke(c);
    fill(c);
    ellipse(pos.x, pos.y, 2*r, 2*r);
    
    stroke(255);
    fill(255);
    //text(str(round(fitness)), pos.x, pos.y);

    stroke(0, 0, 255);
    fill(0, 0, 255);
    strokeWeight(5);
    line(pos.x, pos.y, cos(direction)*r + pos.x, -sin(direction)*r + pos.y);
    strokeWeight(2);

    // display NN output values
    //stroke(255);
    //fill(255);
    //text(str(output.get(0)), pos.x, pos.y+24);
    //text(str(output.get(1)), pos.x, pos.y+12);
    //text(str(output.get(2)), pos.x, pos.y);
    //text(str(output.get(3)), pos.x, pos.y-12);

  }

  void drive() {
    
    vis_r = max(vis_mult*r, vis_min);
    sp = sp_max/r;
    
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
      // follow mouse movement
      pos.x = pos.x*(100-sp)/100 + float(mouseX)*sp/100;
      pos.y = pos.y*(100-sp)/100 + float(mouseY)*sp/100; 
    }
    else if (dr_mode == "NN"){
      //float[] NN_extra_input = {sqrt(pow(vel.x, 2) + pow(vel.y, 2))*10/sp, 10*direction};
      float[] NN_extra_input = {};
      
      // use neural net to drive blob
      org.jblas.FloatMatrix input = new org.jblas.FloatMatrix(concat(concat(NN_blob_input, NN_food_input), concat(NN_wall_input, NN_extra_input)));
      output = feed_forward(weights, biases, input);
      
      float dir_change = map(output.get(0), 0, 1, -1, 1);
      if (abs(dir_change) > dead_band){
        direction += dir_change;
      } //<>//
      
      if (direction >= TWO_PI){
       direction -= TWO_PI; 
      }
      else if (direction <= 0){
       direction += TWO_PI; 
      }
      vel.x = (output.get(1)*sp)*cos(direction);
      vel.y = -(output.get(1)*sp)*sin(direction);
      vel.x = constrain(vel.x, -sp, sp);
      vel.y = constrain(vel.y, -sp, sp);
      
      //vel.x += sp*(output.get(0) - output.get(1));
      //vel.y += sp*(output.get(2) - output.get(3));
      //vel.x = constrain(vel.x, -sp, sp);
      //vel.y = constrain(vel.y, -sp, sp);
      
      //vel.x = sp*(output.get(0) - output.get(1));
      //vel.y = sp*(output.get(2) - output.get(3));
      //vel.x = constrain(vel.x, -sp, sp);
      //vel.y = constrain(vel.y, -sp, sp);
           
      pos.add(vel);
      
      for (int i = 0; i<NN_blob_input.length; i++){
        NN_blob_input[i] = 0; 
      }
      for (int i = 0; i<NN_food_input.length; i++){
        NN_food_input[i] = 0; 
      }
      for (int i = 0; i<NN_wall_input.length; i++){
        NN_wall_input[i] = 0; 
      }
      
    }
    
    max_r = max(max_r, r);
    age = (frameCount-birthday); 

    float decay_amount = sqrt((pow(vel.x, 2) + pow(vel.y, 2)))/sp*move_decay_rate + age*age_decay_rate;
    r = max(0, r-decay_amount);
    if (wallflag >= 1){
     r = max(0, r-walldecay); 
    }
    if (r<2.5){
      r = 0;
    }
    
    
    
  }
  
  void check_wall_collision(){
    // check if collision with edges of screen and adjust position to not exceed it
    
    wallflag = 0;
    if (pos.x > width-r) {
      pos.x = width-r;
      vel.x *= -0.5;
      wallflag += 1;
      } 

    if (pos.x < r) {
      pos.x = r;
      vel.x *= -0.5;
      wallflag += 1;
      }
    
    if (pos.y > height-r) {
      pos.y = height-r;
      vel.y *= -0.5;
      wallflag += 1;
      }

    if (pos.y < r) {
      pos.y = r;
      vel.y *= -0.5;
      wallflag += 1;
    }
    
    stroke(255);
    fill(255);  
    // check vision collision
    if (pos.x > width-vis_r) {
      float dist_normal = abs(width-pos.x)/vis_r; //<>//
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2(0, -(width-pos.x)) + PI;
      float angle = direction - 0;
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      int NN_wall_index = dist_region * a_inputs.length + angle_region;
      NN_wall_input[NN_wall_index] = min(0.1/dist_normal, 1);
      text(str(NN_wall_index), pos.x, pos.y);
      } 
    if (pos.x < vis_r) {
      float dist_normal = abs(pos.x)/vis_r;
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2(0, -(-pos.x)) + PI;
      float angle = direction - PI;
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      int NN_wall_index = dist_region * a_inputs.length + angle_region;
      NN_wall_input[NN_wall_index] = min(0.1/dist_normal, 1);
      text(str(NN_wall_index), pos.x, pos.y);
      }
    if (pos.y > height-vis_r) {
      float dist_normal = abs(height-pos.y)/vis_r;
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2(height-pos.y, 0) + PI;
      float angle = direction - 3*PI/2;
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      int NN_wall_index = dist_region * a_inputs.length + angle_region;
      NN_wall_input[NN_wall_index] = min(0.1/dist_normal, 1);
      text(str(NN_wall_index), pos.x, pos.y);
    } 
    if (pos.y < vis_r) {
      float dist_normal = abs(pos.y)/vis_r;
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2(-pos.y, 0) + PI;
      float angle = direction - PI/2;
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      int NN_wall_index = dist_region * a_inputs.length + angle_region;
      NN_wall_input[NN_wall_index] = min(0.1/dist_normal, 1);
      text(str(NN_wall_index), pos.x, pos.y);
    }
  }
    
    
    
  void check_blob_collision(Blob other_blob){
    // check collision with another blob as well as collision of vision with another blob
    
    // check body collision
    if (pos.dist(other_blob.pos) < (r + other_blob.r)){
        
      if (r < other_blob.r){
        other_blob.r = sqrt(pow(other_blob.r, 2) + pow(r, 2));
        other_blob.energy_consumed += r;
        r = 0;
      }
      else if (r > other_blob.r){
       r = sqrt(pow(other_blob.r, 2) + pow(r, 2));  
       energy_consumed += other_blob.r;
       other_blob.r = 0;
      } 
    }
    
    // check vision collision
    if (pos.dist(other_blob.pos) < (vis_r + other_blob.r) && other_blob.r > 0){
      
      float dist = abs(pos.dist(other_blob.pos) - other_blob.r);
      float dist_normal = min(dist/vis_r, 0.99);
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2((other_blob.pos.y-pos.y), -(other_blob.pos.x-pos.x)) + PI;
      float angle = direction - (atan2((other_blob.pos.y-pos.y), -(other_blob.pos.x-pos.x)) + PI);
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      
      int NN_blob_index = dist_region * a_inputs.length + angle_region;
      NN_blob_input[NN_blob_index] = r/other_blob.r;
      
      if (display_flag == true){
        stroke(255);
        fill(255);
        //line(pos.x, pos.y, pos.x + cos(angle_rounded)*r, pos.y - sin(angle_rounded)*r);
        line(pos.x, pos.y, pos.x + cos(direction-angle-PI)*r, pos.y - sin(direction-angle-PI)*r);
        //text(str(NN_blob_index), pos.x, pos.y);
      }
      
    }
    
    if (pos.dist(other_blob.pos) < (r + other_blob.vis_r) && r>0){
     
      float dist = abs(other_blob.pos.dist(pos) - r);
      float dist_normal = min(dist/other_blob.vis_r, 0.99);
      int dist_region = int(dist_normal*other_blob.d_inputs.length);
      //float angle = atan2((pos.y-other_blob.pos.y), -(pos.x-other_blob.pos.x)) + PI;
      float angle = other_blob.direction - (atan2((pos.y-other_blob.pos.y), -(pos.x-other_blob.pos.x)) + PI);
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*other_blob.a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/other_blob.a_inputs.length + PI/other_blob.a_inputs.length;
      
      int NN_blob_index = dist_region * other_blob.a_inputs.length + angle_region;
      other_blob.NN_blob_input[NN_blob_index] = other_blob.r/r;
      
      if (display_flag == true){
        stroke(255);
        fill(255); 
        //line(other_blob.pos.x, other_blob.pos.y, other_blob.pos.x + cos(angle_rounded)*other_blob.r, other_blob.pos.y - sin(angle_rounded)*other_blob.r);
        line(other_blob.pos.x, other_blob.pos.y, other_blob.pos.x + cos(other_blob.direction-angle-PI)*other_blob.r, other_blob.pos.y - sin(other_blob.direction-angle-PI)*other_blob.r); 
        //text(str(NN_blob_index), other_blob.pos.x, other_blob.pos.y); 
      }
  }
    
    
  }
  
  void check_food_collision(Food food){
    
    // check collision with blob
    if (pos.dist(food.pos) < (r + food.r)){
      if (r > food.r){
       r = sqrt(pow(food.energy, 2) + pow(r, 2));
       energy_consumed += food.energy;
       food.r = 0;
      }
    }
    
    // check collision with blob vision
    if (pos.dist(food.pos) < (vis_r + food.r)){

      float dist = abs(pos.dist(food.pos) - food.r);
      float dist_normal = min(dist/vis_r, 0.99);
      int dist_region = int(dist_normal*d_inputs.length);
      //float angle = atan2((food.pos.y-pos.y), -(food.pos.x-pos.x)) + PI;
      float angle = direction - (atan2((food.pos.y-pos.y), -(food.pos.x-pos.x)) + PI);
      if (angle > PI){
       angle = -TWO_PI+angle; 
      }
      else if (angle < -PI){
        angle = TWO_PI + angle; 
      }
      angle += PI;
      float angle_normal = min(angle/TWO_PI, 0.99);
      int angle_region = int(angle_normal*a_inputs.length);
      float angle_rounded = angle_region*TWO_PI/a_inputs.length + PI/a_inputs.length;
      
      int NN_food_index = dist_region * a_inputs.length + angle_region;
      NN_food_input[NN_food_index] = food.energy/r;
      
      if (display_flag == true){
        stroke(200, 100, 100);
        fill(255);
        line(pos.x, pos.y, pos.x + cos(direction-angle-PI)*r, pos.y - sin(direction-angle-PI)*r);
        //text(NN_food_index, pos.x, pos.y);
      }
    }
  }
  
  void randomize(){
    // randomize chromosome
    int c_index = 0;
    for (int i = 0; i<(sizes[1] + sizes[2]) + (sizes[0]*sizes[1] + sizes[1]*sizes[2]); i++){
      chromosome[i] = random(-2, 2); 
      c_index += 1;
    }
    chromosome[c_index] = random(0, 255);
    chromosome[c_index + 1] = random(0, 255);
    chromosome[c_index + 2] = random(0, 255);
    c_index += 3;
    
  }
  
  void rebuild(){
    // rebuild attributes with new chromosome
    int c_index = 0;
    for (int i=1; i<sizes.length; i++){  // for each hidden layer and output layer 
    // add a column matrix of length of current layer to biases array list
    biases.add(new org.jblas.FloatMatrix(subset(chromosome, c_index, sizes[i]))); 
    // update chromosome index
    c_index += sizes[i];
  }
  
  // create weights arraylist of matrices from chromosome
  for (int i=1; i<sizes.length; i++){  // for each hidden layer and output layer
    // create temporary empty weight matrix with # of rows = length of current layer and # of columns = length of previous layer
    int rows = sizes[i];
    int cols = sizes[i-1];
    org.jblas.FloatMatrix w = new org.jblas.FloatMatrix(new float[rows][cols]);  
    for (int j=0; j<rows; j++){  // for each row in weight matrix
      // add a row onto the weight matrix from chromosome
      w.putRow(j, new org.jblas.FloatMatrix(subset(chromosome, c_index, cols)));
      // update chromosome index
      c_index += cols;
    }
    // add weight matrix into the weights array list
    weights.add(w);
  }
    
    c = color(max(chromosome[c_index], 20), max(chromosome[c_index+1], 20), max(chromosome[c_index+2], 20));
    c_index += 3;
  }
}

void mousePressed(){

}

void keyPressed(){
  if (key == 'd'){
    if (display_flag == true){
      display_flag = false; 
      frameRate(20000);
    }
    else if (display_flag == false){
      display_flag = true;
      frameRate(50);
    }
  }
  if (key == 'n'){
    Blob mouseblob = new Blob(r_start, sp_max, vis_mult, d_inputs_n, a_inputs_n, "mouse", sizes);
    mouseblob.randomize();
    mouseblob.rebuild();
    mouseblob.r = 10;
    mouseblob.sp_max = 1000;
    mouseblob.sp = mouseblob.sp_max/mouseblob.r;
    mouseblob.pos.x = mouseX;
    mouseblob.pos.y = mouseY;
    blobs.individuals.add(mouseblob); 
  }
}

org.jblas.FloatMatrix feed_forward(ArrayList<org.jblas.FloatMatrix> weights_, ArrayList<org.jblas.FloatMatrix> biases_, org.jblas.FloatMatrix input_ ){
  org.jblas.FloatMatrix output;
  
  // feed forward through first layer
  output = weights_.get(0).mmul(input_);
  output = output.add(biases_.get(0));
  // apply activation function
  for (int i = 0; i < output.length; i++){
    output.put(i, sigmoid_neuron(output.get(i)));
  }
  
  // feed forward through rest of layers
  for (int i = 1; i < weights_.size(); i++){
     output = weights_.get(i).mmul(output);
     output = output.add(biases_.get(i));
     for (int j = 0; j < output.length; j++){
        output.put(j, sigmoid_neuron(output.get(j)));
     }
  }
  
  return output;
}
  
float sigmoid_neuron(float x){
  float y = 1/(1+exp(-x));
  return y;
}
  
float perceptron_neuron(float x){
  float y;
  if (x > 0){
    y = 1;
  }
  else{
    y = 0; 
  }
  return y;
}