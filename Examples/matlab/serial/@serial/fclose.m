function fclose(obj)
%FCLOSE Disconnect serial port object from device.
%
%   FCLOSE(OBJ) disconnects the serial port object, OBJ, from the 
%   device. OBJ can be an array of serial port objects.
%
%   If OBJ was successfully disconnected from the device, OBJ's
%   Status property is configured to closed and the RecordStatus 
%   property is configured to off. OBJ can be reconnected to the 
%   device with the FOPEN function.
%
%   You cannot disconnect an object while data is being written 
%   asynchronously to the device. The STOPASYNC function can be
%   used to stop an asynchronous write.
%
%   If OBJ is an array of serial port objects and one of the objects
%   cannot be disconnected from the device, the remaining objects  
%   in the array will be disconnected from the device and a warning
%   will be displayed.
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
%   See also SERIAL/FOPEN, SERIAL/STOPASYNC.
%

%   MP 7-13-99
%   Copyright 1999-2011 The MathWorks, Inc. 
%   $Revision: 1.7.4.6 $  $Date: 2011/05/13 17:35:49 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call fclose on each java object.  Keep looping even 
% if one of the objects could not be closed.  
for i=1:length(jobject),
   try
      fclose(jobject(i));
   catch aException
   	  errorOccurred = true;	    
	  errmsg = aException.message;
   end   
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
   		error(message('MATLAB:serial:fclose:opfailed', errmsg));
    else
        warnState = warning('backtrace', 'off');
        warning(message('MATLAB:serial:fclose:invalid'));
        warning(warnState);
    end
end

