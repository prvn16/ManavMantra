function out = openmdl(filename)
%OPENMDL   Open MDL or SLX file in Simulink.  Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2016 The MathWorks, Inc.

if nargout, out = []; end

if exist('open_system','builtin')
    % Simulink is installed.  Open the model, first checking
    % whether it is part of a Simulink Project and, if so,
    % prompting the user to open that too.
    filename_escaped = strrep(filename, '''','''''');
    fcn = 'SLStudio.Utils.openModelWithProjectCheck';
    cmd = sprintf('%s(''%s'');',fcn,filename_escaped);
    evalin('base', cmd);
else
    % Simulink not installed.
    error(message('MATLAB:openmdl:ExecutionError'))
end
