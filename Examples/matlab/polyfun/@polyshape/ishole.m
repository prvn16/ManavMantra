function TF = ishole(pshape, I)
% ISHOLE  Determine if a boundary is a hole 
%
% TF = ISHOLE(pshape, I) returns a logical vector if the corresponding 
% boundaries of pshape indexed by I define a hole. TF is the same size as
% I. This syntax is only supported when pshape is a scalar polyshape object.
%
% TF = ISHOLE(pshape) returns a logical vector whose elements are true if 
% the corresponding boundary of pshape is a hole. The lenghth of TF is the
% same as the number of boundaries.
%
% See also simplify, boundary, holes, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkScalar(pshape);

if (nargin == 1)
    if pshape.isEmptyShape()
        TF = logical.empty(0, 1);
    else
        TF = ishole(pshape.Underlying);
    end
else
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, I);
    TF = ishole(pshape.Underlying, II);
end
end
