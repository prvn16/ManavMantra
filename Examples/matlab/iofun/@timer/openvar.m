function openvar(name, obj)
%OPENVAR Open a timer object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a timer object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%
%    See also TIMER/SET, TIMER/GET.
%

%    RDD 03-13-2002
%    Copyright 2002-2007 The MathWorks, Inc.

if ~isa(obj, 'timer')
    errordlg(getString(message('MATLAB:timer:noTimerObj')), getString(message('MATLAB:timer:dlg_InvalidObject')), 'modal');
    return;
end

if ~isvalid(obj)
    errordlg(getString(message('MATLAB:timer:dlg_TimerObjectIsInvalid')), getString(message('MATLAB:timer:dlg_InvalidObject')), 'modal');
    return;
end

try
    inspect(obj);
catch exception
    exception = fixexception(exception);
    errordlg(exception.message, getString(message('MATLAB:timer:dlg_InspectionError')), 'modal');
end
