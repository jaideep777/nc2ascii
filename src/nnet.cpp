#include "../include/nnet.h"
using namespace std;


Matrix::Matrix(){
	m = 1; n=1;
	data.resize(m*n);
	for (int i=0;i<m*n;++i) data[i]=0;
}

Matrix::Matrix(float _m, float _n){
	m = _m; n=_n;
	data.resize(m*n);
	for (int i=0;i<m*n;++i) data[i]=0;
}

Matrix::Matrix(float _m, float _n, float * dat){
	m = _m; n=_n;
	data = vector<float> (dat, dat+m*n);
}

Matrix::Matrix(float _m, float _n, vector <float> dat){
	m = _m; n=_n;
	data = dat;
	if (dat.size() != m*n) cout << "mat-assign error: data size not equal to dimensions\n";
}

void Matrix::print(){
	for (int i=0; i<m; ++i){
		for (int j=0; j<n; ++j){
			cout << data[i*n+j] << "\t";
		}
		cout << "\n";
	}
}

Matrix Matrix::operator+(const Matrix &B){
	Matrix C(m,n);
	if (m != B.m || n != B.n){
		cout << "Mat-add: Matrix dimensions do not match\n";
		C = *this;
	}
	else{
		for (int i=0; i< m*n; ++i){
			C.data[i] = data[i] + B.data[i];
		}
	}
	return C;
}

Matrix Matrix::operator*(float f){
	Matrix C(m,n);
	for (int i=0; i< m*n; ++i){
		C.data[i] = data[i]*f;
	}
	return C;
}

Matrix Matrix::operator+(float f){
	Matrix C(m,n);
	for (int i=0; i< m*n; ++i){
		C.data[i] = data[i]+f;
	}
	return C;
}

Matrix Matrix::matmul(Matrix &B){
	Matrix C(m, B.n);
	if (n != B.m){
		cout << "Mat-mul: Matrices do not conform\n";
		C = *this;
	}
	else{
		for (int i=0; i< m; ++i){
			for (int j=0; j<B.n; ++j){
				float sum = 0;
				for (int k=0; k<n; ++k) sum += data[i*n+k]*B.data[k*B.n+j];
				C.data[i*B.n+j] = sum;
			}
		}
	}
	return C;
} 

Matrix Matrix::operator*(Matrix &B){
	return this->matmul(B);
}

Matrix Matrix::rowRepeat(int nrow){
	if (m != 1){
		cout << "Row-repeat error: matrix in not single rowed\n";
		return *this;
	}
	else{
		Matrix C(nrow, n);
		for (int i=0; i<nrow; ++i){
			for (int j=0; j<n; ++j){
				C.data[i*n+j] = data[j];
			}
		}
		return C;
	}
}
	


DenseNet::DenseNet(){}

DenseNet::DenseNet(int n_inputs, int n_classes, vector<int> neurons_per_layer){
	ninputs = n_inputs;
	hidden_layers = neurons_per_layer.size(); // number of hidden layers (excluding output layer)
	nclasses = n_classes;

	nneurons = neurons_per_layer;				// hidden layers 1-L have specified neurons
	nneurons.insert(nneurons.begin(), ninputs);	// input layer 
	nneurons.push_back(nclasses);				// output layer

	W.resize(hidden_layers+2);
	b.resize(hidden_layers+2);

	// Layer 0: input layer
	nneurons[0] = ninputs;
	W[0] = Matrix(ninputs,ninputs);	// input layer weights are I(nx,nx) | can be used for scaling of inputs
	b[0] = Matrix(1,ninputs);		 

	// Layers 1-L: hidden layers
	for (int i=1; i<=hidden_layers; ++i){
		W[i] = Matrix(nneurons[i-1], nneurons[i]);
		b[i] = Matrix(1, nneurons[i]);
	}
	
	// Layer L+1: output layer
	W[hidden_layers+1] = Matrix(nneurons[hidden_layers], nneurons[hidden_layers+1]);
	b[hidden_layers+1] = Matrix(1, nneurons[hidden_layers+1]);
}

void DenseNet::initFromFile(string filename, bool input_layer){
	ifstream fin(filename.c_str());
	if (!fin) throw filename;
	
	int _hl;
	int _nin;
	int _nc;
	vector <int> _npl;

	fin >> _hl;
	fin >> _nin;
	for (int i=0; i< _hl; ++i){
		int L; fin >> L;
		_npl.push_back(L);
	}
	fin >> _nc;

	*this = DenseNet(_nin, _nc, _npl);	

	if (input_layer){
		for (int i=0; i<W[0].m*W[0].n; ++i) fin >> W[0].data[i];
		for (int i=0; i<b[0].m*b[0].n; ++i) fin >> b[0].data[i];
	}

	for (int l=1; l<hidden_layers+2; ++l){
		for (int i=0; i<W[l].m*W[l].n; ++i) fin >> W[l].data[i];
		for (int i=0; i<b[l].m*b[l].n; ++i) fin >> b[l].data[i];
	} 
}

void DenseNet::print(){
	for (int i=0; i<hidden_layers+2; ++i){
		W[i].print();
		cout << "-----------------\n";
		b[i].print();
		cout << "|\n|\nv\n";
	}
}

Matrix DenseNet::forward_prop(Matrix &In, bool input_layer){
	Matrix temp = In;
	// input layer
	if (input_layer){
		temp = temp*W[0] + b[0];
	}
	// hidden layers
	for (int l=1; l<hidden_layers+1; ++l){
		temp = temp*W[l] + b[l];
		temp = activation_fcn(temp);
	}
	// output layer
	temp = temp*W[hidden_layers+1] + b[hidden_layers+1];
	temp = softmax(temp);
	out_probs = temp;
	return out_probs;
}


float sigmoid(float x){
	if (x >=0) return 1.0f/(1+exp(-x));
	else return exp(x)/(1+exp(x));
}

Matrix sigmoid(Matrix &M){
	Matrix A(M.m, M.n);
	for (int i=0; i<A.m*A.n; ++i){
		A.data[i] = sigmoid(M.data[i]);
	}
	return A;
}

float elu(float x){
	if (x >=0) return x;
	else return exp(x)-1;
}

Matrix elu(Matrix &M){
	Matrix A(M.m, M.n);
	for (int i=0; i<A.m*A.n; ++i){
		A.data[i] = elu(M.data[i]);
	}
	return A;
}

template <class T>
vector <float> softmax(vector <T> &x){
	vector <float> y(x.size());
	float xmax = *max_element(x.begin(),x.end());
	float expsum = 0;
	for (int i=0; i<x.size(); ++i){
		expsum += exp(x[i]-xmax);
	}
	for (int i=0; i<x.size(); ++i){
		y[i] = exp(x[i]-xmax)/expsum;
	}
	return y;
}


Matrix softmax(Matrix &A){
	if (A.m !=1 && A.n !=1){
		cout << "Softmax Warning: matrix not 1D: " << A.m << " " << A.n << "\n";
	}
	vector <float> v = softmax(A.data);
	return Matrix(A.m, A.n, v);
}


//int main(){

//	float a[] = {1,8,19,2,-1,6};
//	float b[] = {-1,21,-30,12,2,13};
//	Matrix A(3,2, a);
//	Matrix B(2,3, b);
//	A.print();
//	B.print();
//	Matrix C = A.matmul(B);
//	C.print();
//	C = C+100.5;
//	C.print();
//	
//	vector <float> z;
//	z.push_back(-2);
//	z.push_back(3);
//	z.push_back(-2);
//	softmax(z);
//	
//	cout << sigmoid(0) << endl;
//	
//	vector <int> layers(2);
//	layers[0] = 7; layers[1] = 10;
//	DenseNet nn(3, 2, layers);
//	nn.W[1] = sigmoid(nn.W[1]);
//	nn.print();
//	
//	softmax(A).print();
//	
//	DenseNet nn2;
//	nn2.initFromFile("wts2.txt");
//	nn2.print();
//	nn2.activation_fcn = sigmoid;
//	
//	float x [] = {1.73018};
//	Matrix X(1,1,x);
//	Matrix Y = nn2.forward_prop(X, false);
//	Y.print();
//	
//	return 0;
//}




