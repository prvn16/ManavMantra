function tf = isLineSpec(str)
% This function is undocumented and may change in a future release.

%   Copyright 2016 The MathWorks, Inc.

if ischar(str)
    [~,~,~,msg]=colstyle(str);
    tf = isempty(msg);
else
    tf = false;
end

end
