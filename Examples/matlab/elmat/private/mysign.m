function S = mysign(A)
%MYSIGN True sign function with MYSIGN(0) = 1.

%   Called by various matrices in elmat/private.
%
%   Nicholas J. Higham
%   Copyright 1984-2013 The MathWorks, Inc.

S = sign(A);
S(S==0) = 1;
