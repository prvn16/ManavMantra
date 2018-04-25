function varargout = fgetl(obj)
%FGETL Read one line of text from device, discard terminator.
%
%   TLINE=FGETL(OBJ) reads one line of text from the device connected
%   to serial port object, OBJ and returns to TLINE. The returned data
%   does not include the terminator with the text line. To include the
%   terminator, use FGETS.
%
%   FGETL blocks until one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property
%       3. The input buffer is filled
%
%   The serial port object, OBJ, must be connected to the device with
%   the FOPEN function before any data can be read from the device
%   otherwise an error is returned. A connected serial port object has
%   a Status property value of open.
%
%   [TLINE,COUNT]=FGETL(OBJ) returns the number of values read to COUNT.
%   COUNT includes the terminator.
%
%   [TLINE,COUNT,MSG]=FGETL(OBJ) returns a message, MSG, if FGETL did
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
%       idn = fgetl(s);
%       fclose(s);
%       delete(s);
%
%   See also SERIAL/FGETS, SERIAL/FOPEN, SERIAL/RECORD.
%

%   Copyright 1999-2017 The MathWorks, Inc.

% Error checking.
if length(obj) > 1
    error(message('MATLAB:serial:fgetl:invalidOBJ'));
end

if nargout > 3
    error(message('MATLAB:serial:fgetl:invalidSyntax'));
end

% Call the java fgetl method.
try
    out = fgetl(igetfield(obj, 'jobject'));
catch aException
    error(message('MATLAB:serial:fgetl:opfailed', aException.message));
end

% Extract data from fgetl java code
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
        warning('MATLAB:serial:fgetl:unsuccessfulRead', warningstr);
    end

    % Restore the warning state.
    warning(warnState);
end

% Construct the output.
varargout = {dataValues, dataCount, warningstr};
end