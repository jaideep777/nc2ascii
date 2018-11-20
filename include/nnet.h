#ifndef __DENSENET__
#define __DENSENET__

#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <algorithm>
using namespace std;


class Matrix{
	public:
	int m;
	int n;
	vector <float> data;
	
	public:		
	Matrix();
	Matrix(float _m, float _n);
	Matrix(float _m, float _n, float * dat);
	Matrix(float _m, float _n, vector <float> dat);

	void print();
	
	Matrix matmul(Matrix &B);
	Matrix operator+(const Matrix &B);
	Matrix operator*(float f);
	Matrix operator+(float f);
	Matrix operator*(Matrix &B);
	Matrix rowRepeat(int nrow);
		
};


class DenseNet{
	public:
	// core parameters
	int ninputs;
	int hidden_layers;
	int nclasses;
	vector <int> nneurons;
	
	// internal parameters
	vector <Matrix> W;
	vector <Matrix> b;
	
	Matrix (*activation_fcn)(Matrix &);

	Matrix out_probs;
	
	public:
	DenseNet();	
	DenseNet(int n_inputs, int n_classes, vector<int> neurons_per_layer);
	
	void initFromFile(string filename, bool input_layer);
	
	void print();
	
	Matrix forward_prop(Matrix &In, bool input_layer);

};



float sigmoid(float x);
float elu(float x);

template <class T>
vector <float> softmax(vector <T> &x);

Matrix sigmoid(Matrix &M);
Matrix elu(Matrix &M);

Matrix softmax(Matrix &A);

#endif
