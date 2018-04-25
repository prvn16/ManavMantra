function output = instrfindall(varargin)
%INSTRFINDALL Find all communication interface objects with specified
%property values.
%
%   OUT = INSTRFINDALL returns all communication interface objects that
%   exist in memory regardless of the object's ObjectVisibility property
%   value. The communication interface  objects are returned as an array to
%   OUT.
%
%   OUT = INSTRFINDALL('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   communication interface objects whose property names and property
%   values match those passed as param-value pairs, P1, V1, P2, V2,... The
%   param-value pairs can be specified as a cell array.
%
%   OUT = INSTRFINDALL(S) returns an array, OUT, of communication interface
%   objects whose property values match those defined in structure S whose
%   field names are communication interface object property names and the
%   field values are the requested property values.
%
%   OUT = INSTRFINDALL(OBJ, 'P1', V1, 'P2', V2,...) restricts the search
%   for matching param-value pairs to the communication interface objects
%   listed in OBJ. OBJ can be an array of communication interface objects.
%
%   Note that it is permissible to use param-value string pairs,
%   structures, and param-value cell array pairs in the same call to
%   INSTRFIND.
%
%   When a property value is specified, it must use the same format as GET
%   returns. For example, if GET returns the Name as 'MyObject', INSTRFIND
%   will not find an object with a Name property value of 'myobject'.
%   However, properties which have an enumerated list data type will not be
%   case sensitive when searching for property values. For example,
%   INSTRFIND will find an object with a Parity property value of 'Even' or
%   'even'.
%
%   Example:
%       s1 = serial('COM1', 'Tag', 'Oscilloscope'); 
%       s2 = serial('COM2',
%       'Tag', 'FunctionGenerator'); 
%       set(s1, 'ObjectVisibility', 'off');
%       out1 = instrfind('Type', 'serial') 
%       out2 = instrfindall('Type', 'serial');
%
%   See also SERIAL/GET, SERIAL/INSTRFIND.

%
%   Copyright 1999-2013 The MathWorks, Inc.

% Find all the objects.
objs = localFindAllObjects;

try
    if isempty(objs)
        output = instrfind(varargin{:});
    else
        output = instrfind(objs, varargin{:});
    end
catch aException
    error(strrep(aException.identifier, 'instrfind', 'instrfindall'), aException.message);
end

% ************************************************************************
% Find all the objects.
function output = localFindAllObjects

out1 = com.mathworks.toolbox.instrument.Instrument.jinstrfindall;
out2 = com.mathworks.toolbox.instrument.device.icdevice.ICDevice.jinstrfindall;

if isempty(out1) && isempty(out2)
    output = [];
    return;
else
    output1 = javaToMATLAB(out1);
    output2 = javaToMATLAB(out2);
    output = [output1 output2];
end

% ************************************************************************
% Convert objects to their appropriate MATLAB object type.
function obj = javaToMATLAB(allObjects)

obj = [];

if isempty(allObjects)
    return;
end

for i = 0:allObjects.size-1
    inputObj  = allObjects.elementAt(i);
    className = class(inputObj);
    
    
    try
        obj = [obj feval(char(getMATLABClassName(inputObj)), inputObj)]; %#ok<AGROW>
    catch %#ok<CTCH>     
        if isa(inputObj, 'com.mathworks.toolbox.instrument.SerialComm')
            obj = [obj serial(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.I2C')
            obj = [obj i2c(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.Bluetooth')
            obj = [obj Bluetooth(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.SerialVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.GpibVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.VxiGpibVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.VxiVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.PxiVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.TCPIP')
            obj = [obj tcpip(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.UDP')
            obj = [obj udp(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.RsibVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.GenericVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.TcpipVisa')
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif isa(inputObj, 'com.mathworks.toolbox.instrument.UsbVisa')
            obj = [obj visa(inputObj)];         %#ok<AGROW>
        elseif findstr(className, 'ICDevice')
            obj = [obj icdevice(inputObj)]; %#ok<AGROW>
        else
            obj= [obj gpib(inputObj)]; %#ok<AGROW>
        end
    end
    
end

