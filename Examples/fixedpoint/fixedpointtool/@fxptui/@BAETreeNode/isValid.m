function b = isValid(this)
% ISVALID Evaluate if the identifier contains valid information

% Copyright 2015 The MathWorks, Inc.

% Check if the object is valid. In cases where blocks go out of
% scope due to termination of the engine interface or when blocks
% are being deleted from the graph, you can run into situations
% where the object is still a DAObject, but is not in a valid graph
% and cannot be resolved.
slObj = this.daobject;
b = isa(slObj, 'DAStudio.Object');
if b
    bstr = 'built-in/';
    len = length(bstr);
    fullName = slObj.getFullName;
    b = ~strncmp(fullName,bstr,len);
end
end
