function tb = addcats(ta,varargin)
%ADDCATS Add categories to a tall categorical array.
%   B = ADDCATS(A,NEWCATEGORIES)
%   B = ADDCATS(A,NEWCATEGORIES,'Before',WHERE)
%   B = ADDCATS(A,NEWCATEGORIES,'After',WHERE)
%
%   See also CATEGORICAL/ADDCATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,4);
nargoutchk(1,1);
tb = categoricalPiece(mfilename, ta, varargin{:});
end
