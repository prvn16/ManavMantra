function Y = fi_vector_sum(A,j)
% Sum column j of matrix A.
% Copyright 2008-2010 The MathWorks, Inc.
%#codegen
m = size(A,1);
w = get(A,'WordLength') + ceil(log2(m));
f = get(A,'FractionLength');
Y = fi(0,true,w,f,fimath(A));
for i = 1:m
    Y(1) = Y + A(i,j);
end
