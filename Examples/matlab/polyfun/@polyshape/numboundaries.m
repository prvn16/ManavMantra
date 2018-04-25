function nb = numboundaries(pshape)
% NUMBOUNDARIES Find the number of boundaries in a polyshape
%
% N = NUMBOUNDARIES(pshape) returns the number of boundaries of a polyshape.
%
% See also numsides, boundary, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
nb = zeros(n);
for i=1:numel(pshape)
    nb(i) = pshape(i).Underlying.numboundaries();
end

end
