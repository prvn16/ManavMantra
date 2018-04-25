function b = isFixedPointType(dataTypeStr)
% ISFIXEDPOINTTYPE returns true if the data type string is a fixed-point type (fixdt or numerictype)

% Copyright 2013-2014 The MathWorks, Inc.


b = (strncmp(dataTypeStr, 'fixdt(',6) || strncmp(dataTypeStr, 'numerictype(',length('numerictype(')));
if (b) 
    % handle all cases of fixdt('double/single'... &
    % numerictype('double/single'... specifications
    % evaluate the data type and use the isdouble / issingle call to decide
    % if its a fixed point type or not instead of strcmp usage. 
    try
        nt = eval(dataTypeStr); 
    catch 
        % for errorneous type strings like fixdt('double', 'InvalidProp', 'InvalidVal')
        b = false;
        return;
    end
    if nt.isdouble || nt.issingle 
        b = false;
    end
end
    
