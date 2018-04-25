function tf = isenum(e)
%ISENUM True for enumerations.
%   ISENUM(E) returns logical 1 (true) if E is a enumeration.
%   and logical 0 (false) otherwise.
%
%   See also ISSTRUCT, ISNUMERIC, ISOBJECT, ISLOGICAL.

%   Copyright 2014 The MathWorks, Inc.
 

    m = metaclass(e);

    if(~isempty(m))    
        tf = m.Enumeration;
    else
        tf = false; 
    end
end
