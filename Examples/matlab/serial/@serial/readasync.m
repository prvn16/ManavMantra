function readasync(obj, varargin)
%READASYNC Read data asynchronously from device.
%
%   READASYNC(OBJ) reads data asynchronously from the device connected
%   to serial port object, OBJ. READASYNC returns control to MATLAB 
%   immediately.  
%
%   The data read is stored in the input buffer. The BytesAvailable
%   property indicates the number of bytes stored in the input
%   buffer. 
%
%   READASYNC will stop reading data when one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property 
%       3. The input buffer has been filled
% 
%   The serial port object must be connected to the device with the 
%   FOPEN function before any data can be read from the device otherwise
%   an error is returned. A connected serial port object has a Status
%   property value of open.
%
%   READASYNC(OBJ, SIZE) reads at most SIZE bytes from the device.
%   If SIZE is greater than the difference between OBJ's InputBufferSize
%   property value and OBJ's BytesAvailable property value an error will
%   be returned.
%
%   The TransferStatus property indicates the type of asynchronous 
%   operation that is in progress.
%
%   An error is returned if READASYNC is called while an asynchronous 
%   read is in progress. However, an asynchronous write can occur while  
%   an asynchronous read is in progress.
%
%   The STOPASYNC function can be used to stop an asynchronous read
%   operation.
%
%   Example:
%       s = serial('COM1', 'InputBufferSize', 5000);
%       fopen(s);
%       fprintf(s, 'Curve?');
%       readasync(s);
%       data = fread(s, 2500);
%       fclose(s);
%      
%   See also SERIAL/FOPEN, SERIAL/STOPASYNC.
%

%   MP 12-30-99
%   Copyright 1999-2011 The MathWorks, Inc. 
%   $Revision: 1.6.4.5 $  $Date: 2011/05/13 17:36:20 $

% Error checking.
if (nargin > 2)
    error(message('MATLAB:serial:readasync:invalidSyntax'));
end

if ~isa(obj, 'icinterface')
    error(message('MATLAB:serial:readasync:invalidOBJ'));
end

if length(obj) > 1
    error(message('MATLAB:serial:readasync:invalidOBJ'));
end

switch nargin
case 2
    numBytes = varargin{1};
    if ~isa(numBytes, 'double')
        error(message('MATLAB:serial:readasync:invalidSIZEdouble'));
    elseif length(numBytes) > 1
        error(message('MATLAB:serial:readasync:invalidSIZEscalar'));
    elseif (numBytes <= 0)
        error(message('MATLAB:serial:readasync:invalidSIZEpos'));
    elseif (isinf(numBytes))
        error(message('MATLAB:serial:readasync:invalidSIZEinf'));
    elseif (isnan(numBytes))
        error(message('MATLAB:serial:readasync:invalidSIZEnan'));
    end
end

% Get the java object.
jobject = igetfield(obj, 'jobject');

% Call the java readasync method.
try
    readasync(jobject, varargin{:});
catch aException
   error(message('MATLAB:serial:readasync:opfailed', aException.message));
end
