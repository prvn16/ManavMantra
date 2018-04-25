function out = fieldnames(obj, flag) %#ok<INUSD>
%FIELDNAMES Get serial port object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with serial port object, OBJ.
%   OBJ can be an array of serial port objects.
%

%   Copyright 1999-2013 The MathWorks, Inc. 

% Error if invalid.
if ~all(isvalid(obj))
   error(message('MATLAB:serial:fieldnames:invalidOBJ'));
end

try
    out = fieldnames(get(obj));
catch %#ok<CTCH>
    error(message('MATLAB:serial:fieldnames:invalidOBJType'));
end
