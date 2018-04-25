function B = fi_matrix_column_sum(A)
% Sum the columns of matrix A.
% Copyright 2008-2010 The MathWorks, Inc.
%#codegen
    [m,n] = size(A);
    w = get(A,'WordLength') + ceil(log2(m));
    f = get(A,'FractionLength');
    B = fi(zeros(1,n),true,w,f,fimath(A));
    for j = 1:n
        for i = 1:m
            B(j) = B(j) + A(i,j);
        end
    end
