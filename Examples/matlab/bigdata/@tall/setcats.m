function tb = setcats(ta,varargin)
%SETCATS Add categories to a tall categorical array.
%   B = SETCATS(A,NEWCATEGORIES)
%
%   See also CATEGORICAL/SETCATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);
nargoutchk(1,1);
tb = categoricalPiece(mfilename, ta, varargin{:});
end
