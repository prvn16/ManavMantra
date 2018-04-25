function shareEngine(engineName)
%matlab.engine.shareEngine Convert current MATLAB session to shared session
%
%  matlab.engine.shareEngine converts a non-shared MATLAB session into
%  a shared with a default name.  The default name is a character array
%  concatenated from 'MATLAB_' and the process id of the current MATLAB
%  session: 'MATLAB_<process ID>'.
%
%  matlab.engine.shareEngine(ENGINENAME) converts a non-shared MATLAB
%  session into a shared session with a name specified by ENGINENAME.  
%  ENGINENAME needs to be a valid MATLAB variable name. If there is already a
%  MATLAB session shared with name ENGINENAME on local machine, the current 
%  MATLAB session is converted into a shared session with a default name.
%
%  Examples
%
%  % convert the current MATLAB into a shared session with a default name
%  matlab.engine.shareEngine
%
%  % convert the current MATLAB into shared session with the name 'Matt'
%  matlab.engine.shareEngine('Matt')
%
%  See also matlab.engine.isEngineShared, matlab.engine.engineName.

% Copyright 2015-2017 The MathWorks, Inc.

if nargin==1 && (~isvarname(engineName))
    error(message('MATLAB:engineAPI:StringInput'))
end

try
    if nargin==0
        make_attachable
    else
        make_attachable(convertStringsToChars(engineName))
    end
catch ME
    if strcmp(ME.identifier, 'MATLAB:mvm_server:AlreadyAttachable')
        error(message('MATLAB:engineAPI:SessionSharedAlready'))
    elseif strcmp(ME.identifier, 'MATLAB:mvm_server:NameAlreadyExists')
        error(message('MATLAB:engineAPI:SessionNameConflict', engineName, attach_name))
    else
        error(message('MATLAB:engineAPI:SharingFailed'))
    end
end

end