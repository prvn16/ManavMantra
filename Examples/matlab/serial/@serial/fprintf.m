function fprintf(obj, varargin)
%FPRINTF Write text to device.
%
%   FPRINTF(OBJ,'CMD') writes the string, CMD, to the device connected
%   to serial port object, OBJ. OBJ must be a 1-by-1 serial port object.
%
%   The serial port object must be connected to the device with the 
%   FOPEN function before any data can be written to the device otherwise
%   an error is returned. A connected serial port object has a Status
%   property value of open.
%
%   FPRINTF(OBJ,'FORMAT','CMD') writes the string CMD, to the device
%   connected to serial port object, OBJ, with the format, FORMAT. By
%   default, the %s\n FORMAT string is used. The SPRINTF function is 
%   used to format the data written to the instrument.
% 
%   Each occurrence of \n in CMD is replaced with OBJ's Terminator
%   property value. When using the default FORMAT, %s\n, all commands 
%   written to the device will end with the Terminator value.
%
%   FORMAT is a string containing C language conversion specifications. 
%   Conversion specifications involve the character % and the conversion 
%   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. Refer to the 
%   SPRINTF format specification section for more details.
%
%   FPRINTF(OBJ, 'CMD', 'MODE')
%   FPRINTF(OBJ, 'FORMAT', 'CMD', 'MODE') writes data asynchronously
%   to the device when MODE is 'async' and writes data synchronously
%   to the device when MODE is 'sync'. By default, the data is written
%   with the 'sync' MODE, meaning control is returned to the MATLAB
%   command line after the specified data has been written to the device
%   or a timeout occurs. When the 'async' MODE is used, control is
%   returned to the MATLAB command line immediately after executing 
%   the FPRINTF function. 
%
%   OBJ's TransferStatus property will indicate if an asynchronous 
%   write is in progress.
%
%   OBJ's ValuesSent property will be updated by the number of values 
%   written to the device.
%
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data written to the device will be recorded in the
%   file specified by OBJ's RecordName property value.
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, 'Freq 2000');
%       fclose(s);
%       delete(s);
%
%   See also SERIAL/FOPEN, SERIAL/FWRITE, SERIAL/STOPASYNC, SERIAL/RECORD,
%   SPRINTF.
%    

%   Copyright 1999-2017 The MathWorks, Inc.

% Error checking.
if ~isa(obj, 'icinterface')
    error(message('MATLAB:serial:fprintf:invalidOBJInterface'));
end

if length(obj)>1
    error(message('MATLAB:serial:fprintf:invalidOBJDim'));
end

% convert to char in order to accept string datatype
varargin = instrument.internal.stringConversionHelpers.str2char(varargin);

% Parse the input.
switch (nargin)
case 1
   error(message('MATLAB:serial:fprintf:invalidSyntaxCmd'));
case 2
   % Ex. fprintf(obj, cmd); 
   cmd = varargin{1};
   format = '%s\n';
   mode = 0;
case 3
   % Original assumption: fprintf(obj, format, cmd); 
   [format, cmd] = deal(varargin{1:2});
   mode = 0;
   if ~(isa(cmd, 'char') || isa(cmd, 'double'))
	   error(message('MATLAB:serial:fprintf:invalidArg'));
   end
   
   if strcmpi(cmd, 'sync') 
       % Actual: fprintf(obj, cmd, mode);
       mode = 0;
       cmd = format;
       format = '%s\n';
   elseif strcmpi(cmd, 'async') 
       % Actual: fprintf(obj, cmd, mode);
       mode = 1;
       cmd = format;
       format = '%s\n';
   end
   if any(strcmp(format, {'%c', '%s'}))
       % Check if cmd contains elements greater than one byte.
       if any(cmd(:) > 255)
           % Turn off backtrace momentarily and warn user
           warning('off', 'backtrace');
           warning(message('MATLAB:serial:fprintf:DataGreaterThanOneByte'));
           warning('on', 'backtrace');
           % Upper limit of cmd values should be 255.
           cmd(cmd > 255) = 255;
       end
   end
case 4
   % Ex. fprintf(obj, format, cmd, mode); 
   [format, cmd, mode] = deal(varargin{1:3}); 
   
   if ~ischar(mode)
	   error(message('MATLAB:serial:fprintf:invalidMODE'));
   end
   
   switch lower(mode)
   case 'sync'
       mode = 0;
   case 'async'
       mode = 1;
   otherwise
	   error(message('MATLAB:serial:fprintf:invalidMODE'));
   end
otherwise
   error(message('MATLAB:serial:fprintf:invalidSyntaxArgv'));
end   

% Error checking.
if ~isa(format, 'char')
	error(message('MATLAB:serial:fprintf:invalidFORMATstring'));
end
if ~(isa(cmd, 'char') || isa(cmd, 'double'))
	error(message('MATLAB:serial:fprintf:invalidCMD'));
end

% Format the string.
[formattedCmd, errmsg] = sprintf(format, cmd);
if ~isempty(errmsg)
    error(message('MATLAB:serial:fprintf:invalidFormat', errmsg));
end

% error if flowcontrol is enabled and the other side does not assert CTS2
if(isvalid(obj))
    serialPinStats = get(obj,'PinStatus');
    if strcmpi(get(obj,'FlowControl'),'hardware') && strcmpi(serialPinStats.ClearToSend,'off')
        error(message('MATLAB:serial:fprintf:invalidState'));
    end
end

% Call the fprintf java method.
try
   fprintf(igetfield(obj, 'jobject'), formattedCmd, mode);
catch aException
   error(message('MATLAB:serial:fprintf:opfailed', aException.message));
end
