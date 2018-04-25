%ANCESTOR  Get object ancestor.
%    P = ANCESTOR(H,TYPE) returns the handle of the closest ancestor of h
%    that matches one of the types in TYPE, or empty if there is no matching
%    ancestor.  TYPE may be a single string (single type) or cell array of
%    strings (types). If H is a vector of handles then P is a cell array the
%    same length as H and P{n} is the ancestor of H(n). If H is one of the
%    specified types then ancestor returns H.
%
%    P = ANCESTOR(H,TYPE,'TOPLEVEL') finds the highest level ancestor of one
%    of the types in TYPE
%
%    If H is not an Handle Graphics object, ANCESTOR returns empty.
%
%  Examples:
%
%    p = ancestor(gca,'figure');
%    p = ancestor(gco,{'hgtransform','hggroup','axes'},'toplevel');

%   Copyright 1984-2008 The MathWorks, Inc.
