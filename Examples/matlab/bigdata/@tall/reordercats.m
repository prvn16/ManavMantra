function tb = reordercats(ta,varargin)
%REORDERCATS Reorder categories in a tall categorical array.
%   B = REORDERCATS(A)
%   B = REORDERCATS(A,NEWORDER)
%
%   See also CATEGORICAL/REORDERCATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(1,1);
tb = categoricalPiece(mfilename, ta, varargin{:});
end
