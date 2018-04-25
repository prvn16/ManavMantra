function nterms = fibodemo(dtype)
%FIBODEMO Used by SINGLEMATH demo.
% Calculate number of terms in Fibonacci sequence.

% Copyright 1984-2014 The MathWorks, Inc.

fcurrent = ones(dtype);
fnext = fcurrent;
goldenMean = (ones(dtype)+sqrt(5))/2;
tol = eps(goldenMean);
nterms = 2;
while abs(fnext/fcurrent - goldenMean) >= tol
   nterms = nterms + 1;
   temp  = fnext;
   fnext = fnext + fcurrent;
   fcurrent = temp;
end
