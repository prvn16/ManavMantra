function out = overlaps(P, Q)
% OVERLAPS Determine if two polyshapes overlap
%
% TF = OVERLAPS(pshape1, pshape2) returns a logical matrix whose elements
% are 1 when the corresponding pairwise elements of the arrays pshape1 and
% pshape2 overlap. pshape1 and pshape2 must have compatible array sizes.
%
% TF = OVERLAPS(pshape) returns a logical matrix whose elements are 1 when 
% the corresponding pairwise polyshape elements of the polyshape vector 
% pshape overlap. If pshape has length N, then TF is NxN.

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkArray(P);

if nargin == 1
    if ~isvector(P)  %1x0 passes, 4x0 fails 
        error(message('MATLAB:polyshape:vectorPolyshapeError'));
    end
    Q = P';
else
    polyshape.checkArray(Q);
end

[sz, sP, sQ] = findSize(P, Q);
if numel(P) == 0 || numel(Q) == 0
    out = logical.empty(sz);
    return;
end
    
P2 = repmat(P, sP);
Q2 = repmat(Q, sQ);

out = false(sz);
for i=1:numel(P2)
    out(i) = isOverlapping(P2(i), Q2(i));
end

end

%actually checking if two shapes overlap
function tf = isOverlapping(P, Q)

if P.isEmptyShape || Q.isEmptyShape
    tf = false;
    return;
end

[xP, yP] = boundingbox(P);
[xQ, yQ] = boundingbox(Q);

tf = true;
if xP(2) < xQ(1) || xP(1) > xQ(2) || yP(2) < yQ(1) || yP(1) > yQ(2)
    tf = false;
else
    inte = intersect(P, Q);
    if numboundaries(inte) == 0
        tf = false;
    end
end
end
