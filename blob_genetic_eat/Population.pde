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
  

}