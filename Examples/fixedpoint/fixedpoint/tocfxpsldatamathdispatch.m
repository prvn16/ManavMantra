function tocfxpsldatamathdispatch
% Show correct help based on whether Simulink license is available or not.

%   Copyright 2012 The MathWorks, Inc.

    if fidemo.hasSimulinkLicense
        help tocfxpsldatamath
    else
        help tocfxpsldatamathnosl
    end
end
