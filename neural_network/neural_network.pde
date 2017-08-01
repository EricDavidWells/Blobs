int[] sizes = {2, 4, 2};
float[] input = {1, 1};
float[][] input2 = new float[input.length][1];
//double[][] input2 = {{2},{2}};

void setup() {
  
  Multilayer_Perceptron NN = new Multilayer_Perceptron(3, sizes);
  for (int i=0; i<input.length; i++){
    input2[i][0] = input[i];   
  }
  //print(input[0]);
  NN.feed_forward(input2); //<>//
}

void draw(){
  
}


class Multilayer_Perceptron {
  
  int layers;
  int[] sizes;
  float[][][] weights;
  float[][] biases;
  
  Multilayer_Perceptron(int layers_, int[] sizes){
    layers   = layers_;
    biases = new float[layers-1][];
    weights = new float[layers-1][][];
    
    for (int i=1; i<sizes.length; i++){
      biases[i-1] = new float[sizes[i]]; 
    }
    
    for (int i=1; i<sizes.length; i++){
      weights[i-1] = new float[sizes[i]][];
      for (int j=0; j<sizes[i]; j++){
       weights[i-1][j] = new float[sizes[i-1]]; 
      }
    } 
  }
  
  void feed_forward(float[][] input){
    Matrix_Operations.multiply(weights[0], input);
  }
  
}

static class Matrix_Operations {
  
     static double[][] multiply(float[][] a, float[][] b) {
        int m1 = a.length;
        int n1 = a[0].length;
        int m2 = b.length;
        int n2 = b[0].length;
        if (n1 != m2) throw new RuntimeException("Illegal matrix dimensions.");
        double[][] c = new double[m1][n2];
        for (int i = 0; i < m1; i++)
            for (int j = 0; j < n2; j++)
                for (int k = 0; k < n1; k++)
                    c[i][j] += a[i][k] * b[k][j];
        return c; 
}
}