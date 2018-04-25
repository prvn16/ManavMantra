function openvar(~, obj) 
%OPENVAR Open a serial port object for graphical editing.
%
%   OPENVAR(NAME, OBJ) open a serial port object, OBJ, for graphical 
%   editing. NAME is the MATLAB variable name of OBJ.
%
%   See also SERIAL/SET, SERIAL/GET.
%

%   Copyright 1999-2015 The MathWorks, Inc.

if ~isa(obj, 'instrument')
    mustBeInstrumentObjectMessage = getString(message('MATLAB:serial:openvar:mustBeInstrumentObjectMessage'));
    mustBeInstrumentObjectTitle = getString(message('MATLAB:serial:openvar:mustBeInstrumentObjectTitle'));
    errordlg(mustBeInstrumentObjectMessage, mustBeInstrumentObjectTitle, 'modal');
    return;
end

if ~isvalid(obj)
    invalidInstrumentObjectMessage = getString(message('MATLAB:serial:openvar:invalidInstrumentObjectMessage'));
    invalidInstrumentObjectTitle = getString(message('MATLAB:serial:openvar:invalidInstrumentObjectTitle'));
    errordlg(invalidInstrumentObjectMessage, invalidInstrumentObjectTitle, 'modal');
    return;
end

try
    inspect(obj);
catch aException
    out = localFixMessage(aException.message);
    inspectionErrorTitle = getString(message('MATLAB:serial:openvar:inspectionErrorTitle'));
    errordlg(out, inspectionErrorTitle, 'modal');
end

% *******************************************************************
% Fix the error message.
function msg = localFixMessage(msg)

% Initialize variables.

% Remove the trailing carriage returns from errmsg.
while msg(end) == sprintf('\n')
   msg = msg(1:end-1);
end


