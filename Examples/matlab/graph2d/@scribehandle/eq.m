function val = eq(a,b)
%SCRIBEHANDLE/EQ Test equality for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2005 The MathWorks, Inc. 

S.type = '.';
S.subs = 'HGHandle';

if iscell(a) || length(a)>1
   aH = subsref(a,S);
   aH = [aH{:}];
else
   aH = a.HGHandle;
end
if iscell(b) || length(b)>1
   bH = subsref(b,S);
   bH = [bH{:}];
else
   bH = b.HGHandle;
end

val = aH == bH;
