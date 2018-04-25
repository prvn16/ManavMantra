function h = abstractRoot(varargin) 

%   Copyright 2012 The MathWorks, Inc.
h = fxptui.abstractRoot;

if nargin ~= 0
    h.populate(varargin{:});
else
    h.populate;
end
    
