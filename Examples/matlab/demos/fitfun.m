function err = fitfun(lambda,t,y)
%FITFUN Used by FITDEMO.
%   FITFUN(lambda,t,y) returns the error between the data and the values
%   computed by the current function of lambda.
%
%   FITFUN assumes a function of the form
%
%     y =  c(1)*exp(-lambda(1)*t) + ... + c(n)*exp(-lambda(n)*t)
%
%   with n linear parameters and n nonlinear parameters.

%   Copyright 1984-2014 The MathWorks, Inc.

A = zeros(length(t),length(lambda));
for j = 1:length(lambda)
   A(:,j) = exp(-lambda(j)*t);
end
c = A\y;
z = A*c;
err = norm(z-y);

