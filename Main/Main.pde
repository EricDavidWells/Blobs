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
float mutation_rate = 0.1;
float walldecay = 0.5;;
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

 //<>// //<>//

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
