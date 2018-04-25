function mcoderegister(~,h, ~,hTarget, ~,fname)

% This internal function is deprecated. Please replace with
% MAKEMCODE('RegisterHandle',h1,'IgnoreHandle',h2,'FunctionName',myfunction)

% Copyright 2003-2017 The MathWorks, Inc.

if ~isdeployed
    makemcode('RegisterHandle',h,'IgnoreHandle',hTarget,'FunctionName',fname);
end
