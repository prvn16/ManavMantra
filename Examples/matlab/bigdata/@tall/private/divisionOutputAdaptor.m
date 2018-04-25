function out = divisionOutputAdaptor(numerator, denominator)
%divisionOutputAdaptor calculate output adaptor for LDIVIDE and RDIVIDE

% Copyright 2016 The MathWorks, Inc.

% Type combination rules for division are complicated by the presence of
% 'duration'. 
cX = tall.getClass(numerator);
cY = tall.getClass(denominator);

if strcmp(cX, 'duration')
    if strcmp(cY, 'duration')
        cZ = 'double';
    else
        cZ = 'duration';
    end
elseif strcmp(cY, 'duration')
    % non-duration ./ duration is not permitted
    throwAsCaller(MException(message('MATLAB:bigdata:array:DurationAsDenominator')));
else
    cZ = calculateArithmeticOutputType(cX, cY);
end

out = matlab.bigdata.internal.adaptors.getAdaptorForType(cZ);
end
