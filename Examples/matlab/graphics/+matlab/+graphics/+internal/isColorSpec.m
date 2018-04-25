function tf = isColorSpec(str)
% This function is undocumented and may change in a future release.

%   Copyright 2016 The MathWorks, Inc.

if ischar(str)
    [l,c,m,msg]=colstyle(str);
    tf = isempty(msg) && ~isempty(c) && isempty(l) && isempty(m);
else
    tf = false;
end
    
end
