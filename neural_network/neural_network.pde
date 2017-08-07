import org.jblas.*;
import org.jblas.exceptions.*;
import org.jblas.util.*;
import org.jblas.benchmark.*;
import org.jblas.ranges.*;

int[] sizes = {2, 4, 2};
float[] chromosome;
int gene_count;
ArrayList<org.jblas.FloatMatrix> weights;
ArrayList<org.jblas.FloatMatrix> biases;
org.jblas.FloatMatrix input;
org.jblas.FloatMatrix output;


void setup() {
  for (int i=0; i<sizes.length; i++){
    gene_count += sizes[i];  
  }
  chromosome = new float[gene_count];
  
  weights = new ArrayList<org.jblas.FloatMatrix>();
  org.jblas.FloatMatrix w1 = new org.jblas.FloatMatrix(new float[][] {{1, 1}, {2, 2}, {3, 3}});
  org.jblas.FloatMatrix w2 = new org.jblas.FloatMatrix(new float[][] {{1, 1, 1}, {2, 2, 2}});
  weights.add(w1);
  weights.add(w2);
  
  biases = new ArrayList<org.jblas.FloatMatrix>();
  org.jblas.FloatMatrix b1 = new org.jblas.FloatMatrix(new float[][] {{1}, {2}, {3}});
  org.jblas.FloatMatrix b2 = new org.jblas.FloatMatrix(new float[][] {{-2.9}, {-5.9}});
  biases.add(b1);
  biases.add(b2);
  
  org.jblas.FloatMatrix input = org.jblas.FloatMatrix.ones(2,1);
  
  org.jblas.FloatMatrix output = feed_forward(weights, biases, input);
  print(output); //<>//
}

void draw(){
  
}

  
org.jblas.FloatMatrix feed_forward(ArrayList<org.jblas.FloatMatrix> weights_, ArrayList<org.jblas.FloatMatrix> biases_, org.jblas.FloatMatrix input_ ){ //<>//
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