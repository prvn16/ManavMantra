function oo = dominator( o )
%DOMINATOR  o = DOMINATOR( obj )  Return the dominator set of obj
%   The dominator is the set of nodes in obj whose parent is not
%   in obj.  The dominator of a subtree is the root of that
%   subtree.  The dominator of a List is the head of the List.

% Copyright 2006-2014 The MathWorks, Inc.

    if ismember( root(o), o )
        
    end
    oo = mtfind( o, 'Parent.~Member', o );
end
