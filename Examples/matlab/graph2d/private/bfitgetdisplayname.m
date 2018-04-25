function displayName = bfitgetdisplayname(fit)
% BFITGETDISPLAYNAME Returns the display name based on the fit. This
% private method is used by the Data Stats and Basic Fitting GUIs.

%   Copyright 2011 The MathWorks, Inc.

switch fit
    case 0
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameSpline'));
    case 1
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameShapePreserving'));
    case 2
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameLinear'));
    case 3
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameQuadratic'));
    case 4
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameCubic'));
    otherwise
        displayName = getString(message('MATLAB:graph2d:bfit:DisplayNameNthDegree', num2str(fit-1)));
end
        
