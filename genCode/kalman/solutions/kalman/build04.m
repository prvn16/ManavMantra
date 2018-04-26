% Load the position vector
load position.mat
N=100;
% Get the first N vectors in the position matrix to
% use as an example input
z = position(1:2,1:N);
% Specify the upper bounds of the variable-size input z 
% using the emlcoder.typeof declaration - the upper bound
% for the first dimension is 2; the upper bound for 
% the second dimension is N
eg_z = coder.typeof(z, [2 N], [0 1]);
% Generate C code only 
% specify upper bounds for variable-size input z
codegen -c -config coder.config('lib') -report kalman03.m -args {eg_z}