function dbmex(arg)
%DBMEX Enable MEX-file debugging (on UNIX platforms)
%   DBMEX ON enables MEX-file debugging.
%   DBMEX OFF disables MEX-file debugging.
%   DBMEX STOP returns to debugger prompt.
%
%   DBMEX doesn't work on the PC.

%   Copyright 1984-2008 The MathWorks, Inc. 

if ispc
  disp(sprintf(['DBMEX doesn''t work on the PC.  See the MATLAB External\n',...
        'Interfaces Guide for details on how to debug MEX-files.']));
  
elseif ~isempty(getenv('MATLAB_DEBUG'))
    if nargin < 1, arg = 'on'; end
    
    switch lower(arg)
        case 'stop'
            system_dependent(9);
            
        case 'print'
            % The 'print' option to dbmex is grandfathered
            system_dependent(8, 2);
            
        case 'on'
            system_dependent(8, 1);
            
        case 'off'
            system_dependent(8, 0);
            
        otherwise
            error(message('MATLAB:dbmex:badInput', arg));
    end
else
    disp(' ')
    disp(getString(message('MATLAB:dbmex:DebugMEXfiles')));
    disp(' ')
    disp(getString(message('MATLAB:dbmex:ToRunMATLABWithinADebuggerStartItByTyping')));
    disp(getString(message('MATLAB:dbmex:MatlabDdebugger')));
    disp(getString(message('MATLAB:dbmex:NameOfTheDebugger')));
    disp(' ')
end
