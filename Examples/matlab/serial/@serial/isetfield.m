function obj = isetfield(obj, field, value)
%ISETFIELD Set serial port object internal fields.
%
%   OBJ = ISETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD 
%   to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of serial port object arrays. This function should
%   not be used directly by users.
%

%   Copyright 1999-2013 The MathWorks, Inc. 

% Assign the specified field information.
obj.(field) = value;



