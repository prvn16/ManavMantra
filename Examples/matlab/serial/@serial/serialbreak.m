function serialbreak(obj, time)
%SERIALBREAK Send break to device.
%
%   SERIALBREAK(OBJ) sends a break of 10 milliseconds to the device
%   connected to object, OBJ. OBJ must be a 1-by-1 serial port object.
%
%   The object, OBJ, must be connected to the device with the FOPEN
%   function before the SERIALBREAK function is issued otherwise an 
%   error will be returned. A connected object has a Status property 
%   value of open.
%
%   SERIALBREAK(OBJ, TIME) sends a break of TIME milliseconds to the
%   device connected to object, OBJ.
%
%   SERIALBREAK is a synchronous function and will block the MATLAB
%   command line until execution is completed.
%
%   An error will be returned if SERIALBREAK is called while an
%   asynchronous write is in progress. In this case, you can call the
%   STOPASYNC function to stop the asynchronous write operation or you
%   can wait for the write operation to complete.
%
%   Note that the duration of the break may be inaccurate under some
%   operating systems. 
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       serialbreak(s);
%       serialbreak(s, 50);
%       fclose(s);
%
%   See also SERIAL/FOPEN, SERIAL/STOPASYNC.
%

%   Copyright 1999-2013 The MathWorks, Inc. 

% Error checking.
if (length(obj) > 1)
    error(message('MATLAB:serial:serialbreak:invalidOBJDim'));
end

% Parse the input.
switch nargin
case 1
    time = 10;
case 2
    if ~isa(time, 'double')
        error(message('MATLAB:serial:serialbreak:invalidTIME'));
    end
end

% Call java method.
try
	serialbreak(obj.jobject, time);
catch aException
   error(message('MATLAB:serial:serialbreak:opfailed', aException.message));
end	

