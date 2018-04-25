function tb = renamecats(ta,varargin)
%RENAMECATS Rename categories in a tall categorical array.
%   B = RENAMECATS(A,NAMES)
%   B = RENAMECATS(A,OLDNAMES,NEWNAMES)
%
%   See also CATEGORICAL/RENAMECATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);
nargoutchk(1,1);
tb = categoricalPiece(mfilename, ta, varargin{:});
end
