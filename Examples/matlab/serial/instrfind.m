function output = instrfind(varargin)
%INSTRFIND Find communication interface objects with specified property values.
%
%   OUT = INSTRFIND returns all communication interface objects that exist in memory.
%   The communication interface objects are returned as an array to OUT.
%
%   OUT = INSTRFIND('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   communication interface objects whose property names and property values match 
%   those passed as param-value pairs, P1, V1, P2, V2,... The param-value
%   pairs can be specified as a cell array. 
%
%   OUT = INSTRFIND(S) returns an array, OUT, of communication interface objects whose
%   property values match those defined in structure S whose field names 
%   are communication interface object property names and the field values are the 
%   requested property values.
%   
%   OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the communication interface objects listed in OBJ. 
%   OBJ can be an array of communication interface objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to INSTRFIND.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   INSTRFIND will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, INSTRFIND will find an object with a Parity property value
%   of 'Even' or 'even'. 
%
%   Example:
%       s1 = serial('COM1', 'Tag', 'Oscilloscope');
%       s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%       out1 = instrfind('Type', 'serial')
%       out2 = instrfind('Tag', 'Oscilloscope')
%       out3 = instrfind({'Port', 'Tag'}, {'COM2', 'FunctionGenerator'})
%
%   See also SERIAL/GET.
%

%   Copyright 1999-2016 The MathWorks, Inc. 

% Find all the objects.
output = localFindAllObjects;

% convert to char in order to accept string datatype
varargin = instrument.internal.stringConversionHelpers.str2char(varargin);

% Return results.
switch nargin
case 0
    return;
otherwise
    firstInput = varargin{1};
    if (nargin == 1) && ~isa(firstInput, 'struct')
        error(message('instrument:instrfind:invalidPVPair'));
    end
    
    if ~isa(output,'double')
        try
            output = instrfind(output, varargin{:});
        catch aException
            localFixError(aException);
        end
    end
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
        if ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.SerialComm'))
            obj = [obj serial(inputObj)]; %#ok<AGROW>
        elseif strfind(className, 'I2C')
            obj = [obj i2c(inputObj)]; %#ok<AGROW>    
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.Bluetooth'))
            obj = [obj Bluetooth(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.I2C'))
            obj = [obj i2c(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.I2CTEST'))
            obj = [obj i2c(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.SerialVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.GpibVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.VxiGpibVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.VxiVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.PxiVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.TCPIP'))
            obj = [obj tcpip(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.UDP'))
            obj = [obj udp(inputObj)]; %#ok<AGROW>de
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.RsibVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.GenericVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.TcpipVisa'))
            obj = [obj visa(inputObj)]; %#ok<AGROW>
        elseif ~isempty(strfind(className, 'com.mathworks.toolbox.instrument.UsbVisa'))
            obj = [obj visa(inputObj)];         %#ok<AGROW>
        elseif findstr(className, 'ICDevice')
            obj = [obj icdevice(inputObj)]; %#ok<AGROW>
        else
            obj= [obj gpib(inputObj)]; %#ok<AGROW>
        end
    end
end

% ************************************************************************
% Find all the objects.
function output = localFindAllObjects

out1 = com.mathworks.toolbox.instrument.Instrument.getNonLockedObjects;
out2 = com.mathworks.toolbox.instrument.device.icdevice.ICDevice.getNonLockedObjects;

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
function localFixError(aException)

errmsg = aException.message;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

throwAsCaller(MException(aException.identifier,errmsg));

