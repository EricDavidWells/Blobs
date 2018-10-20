class Population{
  ArrayList<Blob> individuals;
  int generation = 0;
  
  Population(){
    individuals = new ArrayList<Blob>();
  }
  
  void drive(){
    for (int i = individuals.size()-1; i>=0; i--){
      Blob individual = individuals.get(i);
      individual.drive();
    }
  }
  
  void display(){
    for (int i = individuals.size()-1; i>=0; i--){
      Blob individual = individuals.get(i);
      individual.display();
    }
    
  }
  
  void check_collisions(){
      // cycle through all blobs
    for (int i = blobs.individuals.size()-1; i>=0; i--){
      Blob blob = blobs.individuals.get(i);
    
      // check if blobs hit walls
      blob.check_wall_collision();
    
      //check if blobs hit each other
      for (int j = i-1; j>=0; j--){
        Blob other_blob = blobs.individuals.get(j);
        blob.check_blob_collision(other_blob);
        
        // remove dead blobs from array
        if (blob.r <= 0){
          blobs.individuals.remove(i);  //<>//
          break;
        }
        // remove dead blobs from array
        if (other_blob.r <= 0){
          blobs.individuals.remove(j); //<>//
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
  }
  
  void evaluate_fitness(){
    float total_fitness = 0;
    float max_fitness = 0;
    for (int i = individuals.size()-1; i>=0; i--){
      Blob individual = individuals.get(i);
      individual.fitness = 10*pow((individual.max_r-r_start), 1.5) + individual.energy_consumed + individual.age/30;
      total_fitness += individual.fitness;
      max_fitness = max(max_fitness, individual.fitness);
    }
    String line = str(max_fitness) + ',' + str(total_fitness) + ',' + str(millis()/1000.00);
    print('l');
    writer.println(line);
    writer.flush();
  }
  
  void reproduce(){
    if (individuals.size() <= pop_no-2){
      
      evaluate_fitness();  
  
      // selection   
      Blob parent_1 = roulette_wheel_selection(individuals);
      Blob parent_2 = roulette_wheel_selection(individuals);
      
      // crossover
      float [][] baby_chromosomes = two_point_crossover(parent_1.chromosome, parent_2.chromosome);
      
      // mutation
      float[] baby_chromosome_1 = random_mutation(baby_chromosomes[0], mutation_rate);
      float[] baby_chromosome_2 = random_mutation(baby_chromosomes[1], mutation_rate);
      
      // create new blobs
      Blob baby_blob1 = new Blob(r_start, sp_max, vis_mult, d_inputs_n, a_inputs_n, "NN", sizes);
      baby_blob1.chromosome = baby_chromosome_1;
      baby_blob1.rebuild();
      individuals.add(baby_blob1);
      
      Blob baby_blob2 = new Blob(r_start, sp_max, vis_mult, d_inputs_n, a_inputs_n, "NN", sizes);
      baby_blob2.chromosome = baby_chromosome_2;
      baby_blob2.rebuild();
      individuals.add(baby_blob2);
      generation += 1;
    }
    
  }
  
}

Blob roulette_wheel_selection(ArrayList<Blob> individuals){
  // get fitness total from population
  float roulette_total = 0;
  for (int j = individuals.size()-1; j>=0; j--){
    Blob individual = individuals.get(j);
    roulette_total += individual.fitness;
  }
  
  // spin the wheel twice to select two parents
  int h = 0;
  float roulette_spin = random(0, roulette_total);
  while (roulette_spin > 0){
    Blob individual = individuals.get(h);
    roulette_spin -= individual.fitness;
    h++;
  }
  Blob parent = individuals.get(h-1);
  return parent;
}

float[][] two_point_crossover(float[] chromosome_1, float[] chromosome_2){

  int cross_point_1 = int(random(0, chromosome_1.length));
  int cross_point_2 = int(random(0, chromosome_2.length));
  int cross_index_1 = min(cross_point_1, cross_point_2);
  int cross_index_2 = max(cross_point_1, cross_point_2);
  float[] crossover_11 = subset(chromosome_1, 0, cross_index_1);
  float[] crossover_12 = subset(chromosome_1, cross_index_1, (cross_index_2-cross_index_1));
  float[] crossover_13 = subset(chromosome_1, cross_index_2, (chromosome_1.length-cross_index_2));
  float[] crossover_21 = subset(chromosome_2, 0, cross_index_1);
  float[] crossover_22 = subset(chromosome_2, cross_index_1, (cross_index_2-cross_index_1));
  float[] crossover_23 = subset(chromosome_2, cross_index_2, (chromosome_2.length-cross_index_2));
  
  float[] new_chromosome_1 = concat(concat(crossover_11,crossover_22), crossover_13);
  float[] new_chromosome_2 = concat(concat(crossover_21,crossover_12), crossover_23);
  float[][] new_chromosomes = {new_chromosome_1, new_chromosome_2};
  return new_chromosomes;
}

float[] random_mutation(float[] chromosome, float mutation_rate_){
 for (int j = 0; j<chromosome.length; j++){
        if (random(0, 1) < mutation_rate_){
          // if else statement for choosing between random weights and random color
          if (j < chromosome.length-3){
          chromosome[j] = random(-2, 2); 
          }
          else{
           chromosome[j] = random(255); 
          }
        }
      }
  return chromosome;
}