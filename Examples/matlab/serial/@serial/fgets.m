function varargout = fgets(obj)
%FGETS Read one line of text from device, keep terminator.
%
%   TLINE=FGETS(OBJ) reads one line of text from the device connected
%   to serial port object, OBJ and returns to TLINE. The returned data
%   does include the terminator with the text line. To exclude the
%   terminator, use FGETL.
%
%   FGETS blocks until one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property
%       3. The input buffer is filled.
%
%   The serial port object, OBJ, must be connected to the device with
%   the FOPEN function before any data can be read from the device
%   otherwise an error is returned. A connected serial port object has
%   a Status property value of open.
%
%   [TLINE,COUNT]=FGETS(OBJ) returns the number of values read to COUNT.
%   COUNT includes the terminator.
%
%   [TLINE,COUNT,MSG]=FGETS(OBJ) returns a message, MSG, if FGETS did
%   not complete successfully. If MSG is not specified a warning is
%   displayed to the command line.
%
%   OBJ's ValuesReceived property will be updated by the number of values
%   read from the device including the terminator.
%
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data received, TLINE, will be recorded in the file
%   specified by OBJ's RecordName property value.
%
%   Examples:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fgets(s);
%       fclose(s);
%       delete(s);
%
%   See also SERIAL/FGETL, SERIAL/FOPEN, SERIAL/RECORD.

%   Copyright 1999-2017 The MathWorks, Inc.
%   $Revision: 1.8.4.5 $  $Date: 2011/05/13 17:35:51 $

% Error checking.
if length(obj) > 1
    error(message('MATLAB:serial:fgets:invalidOBJ'));
end

if nargout > 3
    error(message('MATLAB:serial:fgets:invalidSyntax'));
end

% Call the jave fgets method.
try
    out = fgets(igetfield(obj, 'jobject'));
catch aException
    error(message('MATLAB:serial:fgets:opfailed', aException.message));
end

% Extract data from fgets java code
dataValues = out(1);
dataCount = out(2);
warningstr = out(3);

% Warn if the MSG output variable is not specified.
if ~isempty(warningstr)
    % Store the warning state.
    warnState = warning('backtrace', 'off');
    if isempty(dataValues)
        warningstr = instrument.internal.warningMessagesHelpers.getReadWarning(warningstr, obj.class, obj.DocIDNoData, 'nodata');
    else
        warningstr = instrument.internal.warningMessagesHelpers.getReadWarning(warningstr, obj.class, obj.DocIDSomeData, 'somedata');
    end
    if nargout < 3
        warning('MATLAB:serial:fgets:unsuccessfulRead', warningstr);
    end

    % Restore the warning state.
    warning(warnState);
end

% Construct the output.
varargout = {dataValues, dataCount, warningstr};
end