function [v1,v2] = version(o)
%VERSION  [v1,v2] = version(tree) returns the Mtree version numbers

% Copyright 2006-2014 The MathWorks, Inc.

    v1 = o.V{1};
    v2 = o.V{2};
end
