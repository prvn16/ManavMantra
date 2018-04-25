function structure = qtri_struct(T)
%qtri_struct Block structure of a quasitriangular matrix T.
%
%   Let T be an n x n upper quasitriangular matrix then
%   structure is a list of numbers, of length n-1, 
%   where structure(j) encodes the block type of the j:j+1,j:j+1
%   diagonal block as one of the following.
%
%   0 - Not the start of a block.
%   1 - Start of a 2x2 triangular block.
%   2 - Start of a 2x2 quasi-triangular (full) block.

%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 2014-2015 The MathWorks, Inc.

n = size(T,1);
if n == 1
    structure = 0;
    return;
elseif n == 2;
    if T(2,1) == 0
        structure = 1;
        return;
    else
        structure = 2;
        return;
    end
end

j = 1;

structure = zeros(n-1, 1);

while j < n-1
    if T(j+1,j) ~= 0
        % Start of a 2x2 full block.
        structure(j:j+1) = [2; 0];
        j = j + 2; % Skip to next possible block start.
        continue;
    elseif T(j+1, j) == 0 && T(j+2, j+1) == 0
        % Start of a 2x2 triangular block.
        structure(j) = 1;
        j = j + 1;
        continue;
    else
        % Next block must start a 2x2 full block.
        structure(j) = 0;
        j = j + 1;
    end
end

% The n-1 entry has not yet been checked.
if T(n,n-1) ~= 0
    % 2x2 full block at the end.
    structure(n-1) = 2;
elseif (structure(n-2) == 0 || structure(n-2) == 1)
    structure(n-1) = 1;
end
