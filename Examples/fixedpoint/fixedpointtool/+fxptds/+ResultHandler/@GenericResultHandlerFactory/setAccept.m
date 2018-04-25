function setAccept(~, result, value)
%% SETACCEPT function sets accept field of a result to value 
% result is an instance of fxptds.AbstractResult whose accept value has
% been changed
%
% value is a boolean indicating the state of Accept check box for result in
% FPT GUI
%

%   Copyright 2016 The MathWorks, Inc.

    result.setAccept(value);
    result.firePropertyChange;
end