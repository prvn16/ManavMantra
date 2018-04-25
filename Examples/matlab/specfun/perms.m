function P = perms(V)
%PERMS  All possible permutations.
%   PERMS(1:N), or PERMS(V) where V is a vector of length N, creates a
%   matrix with N! rows and N columns containing all possible
%   permutations of the N elements.
%
%   This function is only practical for situations where N is less
%   than about 10 (for N=11, the output takes over 3 gigabytes).
%
%   Class support for input V:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      logical, char
%
%   See also NCHOOSEK, RANDPERM, PERMUTE.

%   Copyright 1984-2015 The MathWorks, Inc.

[~,maxsize] = computer;
n = numel(V);
% Error if output dimensions are too large
if n*factorial(n) > maxsize
    error(message('MATLAB:pmaxsize'))
end

V = V(:).'; % Make sure V is a row vector
n = length(V);
if n <= 1
    P = V;
else
    P = permsr(n);
    if isequal(V, 1:n)
        P = cast(P, 'like', V);
    else
        P = V(P);
    end
end

%----------------------------------------
function P = permsr(n)
% subfunction to help with recursion

P = 1;

for nn=2:n
    
    Psmall = P;
    m = size(Psmall,1);
    P = zeros(nn*m,nn);
    
    P(1:m, 1) = nn;
    P(1:m, 2:end) = Psmall;
    
    for i = nn-1:-1:1
        reorder = [1:i-1, i+1:nn];
        % assign the next m rows in P.
        P((nn-i)*m+1:(nn-i+1)*m,1) = i;
        P((nn-i)*m+1:(nn-i+1)*m,2:end) = reorder(Psmall);
    end
    
end