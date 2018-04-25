classdef DataTypeDescriptor
    % Copyright 2016 The MathWorks, Inc.
    enumeration
        % Add enumeration type to describe the datatype
        % This is needed for datatypes that can be expressed several
        % different ways in m-code (i.e. char array). This enumeration
        % allows the client object to specify how to express the code
        Auto,CharNoNewLine,CharNoNewLineNoDeblank
    end
end

