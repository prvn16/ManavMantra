function tb = removecats(ta,oldcats)
%REMOVECATS Remove categories from a tall categorical array.
%   B = REMOVECATS(A)
%   B = REMOVECATS(A,OLDCATEGORIES)
%
%   See also CATEGORICAL/REMOVECATS.

%   Copyright 2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(1,1);
if nargin == 1
    % Work out which category is not used
    % in the entire tall categorica array
    ta = tall.validateType(ta, upper(mfilename), {'categorical'}, 1);
    taUnique = reducefun(@unique, ta);
    taUnique.Adaptor = matlab.bigdata.internal.adaptors.CategoricalAdaptor();
    taRemove = clientfun(@removecats,taUnique);
    taRemove.Adaptor = matlab.bigdata.internal.adaptors.CategoricalAdaptor();
    cats = categories(taUnique);
    catsNoUnused = categories(taRemove);
    oldcats = clientfun(@(x,y)setdiff(x,y), cats, catsNoUnused);
end
tb = categoricalPiece(mfilename, ta, oldcats);
end

