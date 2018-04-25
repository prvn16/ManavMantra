function prepForWSUpdate(state)
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2015 The MathWorks, Inc.
    persistent beepState;
    persistent L;
    if strcmp(state, 'off')
        beepState = beep();
        beep('off');
         L = lasterror; %#ok<*LERR>
    elseif strcmp(state, 'reset')
        beep(beepState);
        lasterror(L);
    end
end
