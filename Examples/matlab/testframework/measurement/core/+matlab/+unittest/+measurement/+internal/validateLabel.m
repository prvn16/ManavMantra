function label = validateLabel(input, funcname)
% This function is undocumented and subject to change in a future release

% Copyright 2017 The MathWorks, Inc.
validateattributes(input,{'char','string'},{'scalartext'},funcname);
label = char(input);
if isempty(label)
    label = '_noLabel';
    return;
end
if ~isvarname(label)
    invalidLabelMessage = message(...
        'MATLAB:unittest:measurement:MeasurementBoundary:InvalidLabel',label);
    throwAsCaller(MException(invalidLabelMessage));
end
end