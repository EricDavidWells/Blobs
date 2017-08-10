class Population{
  ArrayList<Blob> individuals;
  
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
  
  void evaluate(){
    
  }
  
}