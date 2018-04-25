function tb = mergecats(ta,varargin)
%MERGECATS Merge categories in a tall categorical array.
%   B = MERGECATS(A,OLDCATEGORIES,NEWCATEGORY)
%   B = MERGECATS(A,CATEGORIES)
%
%   See also CATEGORICAL/MERGECATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);
nargoutchk(1,1);
tb = categoricalPiece(mfilename, ta, varargin{:});
end
