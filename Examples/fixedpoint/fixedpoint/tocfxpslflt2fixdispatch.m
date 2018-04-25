function tocfxpslflt2fixdispatch
% Show correct help based on whether Simulink license is available or not.

%   Copyright 2012 The MathWorks, Inc.

    if fidemo.hasSimulinkLicense
        help tocfxpslflt2fix
    else
        help tocfxpslflt2fixnosl
    end
end
