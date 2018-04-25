function setAccept(~, result, value)
% Set
%   Copyright 2016 The MathWorks, Inc.
    result.setAccept(value);
    result.firePropertyChange;
end
