function updateAcceptFlag(~, result, value)
%% UPDATEACCEPTFLAG function changes result's accept field to input value 
%
% result is an instance of fxptds.AbstractResult type
%
% value is boolean indicating the Accept check boxes state

%   Copyright 2016 The MathWorks, Inc.

    if result.hasProposedDT
        result.setAccept(value);
        result.firePropertyChange;
    end
end

    