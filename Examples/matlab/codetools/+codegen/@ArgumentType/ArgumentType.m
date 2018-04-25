classdef ArgumentType
    % Copyright 2016 The MathWorks, Inc.
    enumeration
        % Add enumeration type to describe the ArgumentType
        % This is needed for ArgumentType that can be expressed several
        % different ways in m-code (i.e. char array). This enumeration
        % allows the client object to specify how to express the code
        PropertyName,PropertyValue,None
    end
end

