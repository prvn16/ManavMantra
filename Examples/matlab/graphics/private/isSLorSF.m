function slOrSf = isSLorSF(pj)
% Helper to check whether the handles in pj is Simulink/Stateflow
% -sramaswa

%   Copyright 2010-2015 The MathWorks, Inc.

    slOrSf = false;

    % No Simulink which means no stateflow either
    if(exist('open_system','builtin') == 0)
        return;
    end

    if(isempty(pj.Handles))
        return;
    end

    handles = pj.Handles{:};

    if(~all(ishandle(handles)))
       return; 
    end

    if(all(isslhandle(handles)))
        slOrSf = true;
    end

end

% [EOF]
