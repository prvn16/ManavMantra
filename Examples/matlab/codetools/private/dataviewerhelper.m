function varargout = dataviewerhelper(whichcall, varargin)
%DATAVIEWERHELPER Helper functions for Workspace, Variable Editor, and other tools

%   Copyright 2008 The MathWorks, Inc.

switch whichcall
    case 'upconvertIntegralType',
        varargout = {upconvertIntegralType(varargin{:})};
    case 'isUnsignedIntegralType',
        varargout = {isUnsignedIntegralType(varargin{:})};
    otherwise
        error(message('MATLAB:dataviewerhelper:unknownOption'));
end

%********************************************************************
function converted = upconvertIntegralType(value)
converted = value;
if ~isfloat(value)
    
     if isa(value, 'uint8')
        converted = uint16(value);
    elseif isa(value, 'uint16')
        converted = uint32(value);
    elseif isa(value, 'uint32')
        converted = uint64(value);
    elseif isa(value, 'uint64')
        converted = uint64(value);
    elseif isa(value, 'int8')
        converted = int16(value);
    elseif isa(value, 'int16')
        converted = int32(value);
    elseif isa(value, 'int32')
        converted = int64(value);
    elseif isa(value,'int64') 
    %Necessary for referring to the parent class when passing through the
    %JAVA interface
        converted = int64(value);
    end
    
end

%********************************************************************
function unsigned = isUnsignedIntegralType(value)
unsigned = false;
if ~isfloat(value)
    unsigned = isa(value, 'uint8') || isa(value, 'uint16') || ...
        isa(value, 'uint32') || isa(value, 'uint64');
end