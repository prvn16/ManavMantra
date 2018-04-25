function varargout = tsfcncallrouter(fcnName, inputArgs)
% TSFCNCALLROUTER handles the logic to check if ThingSpeak Support Toolbox
% is installed. If the Toolbox is installed then the appropriate function
% is called. Else an error is generated with the information to install the
% ThingSpeak Support Toolbox.

% Copyright 2016, The MathWorks Inc.


% Using strfind instead of contains since getappdata might return an empty
% array. contains() generates an error in this case.
isDesktop = isempty(strfind(getappdata(0, 'MATLAB_SERVER_ROOT'), 'mlsedu')); %#ok<STREMP>

% If function is being called from Desktop MATLAB
if isDesktop
    % Find the present path and split it into a cell array
    mpath = path;
    mlpath = strsplit(mpath, pathsep);
    % Check if ThingSpeak Support Toolbox is already on path
    
    pathindx = find(contains(mlpath, ...
        fullfile('Toolboxes', 'ThingSpeak Support Toolbox')), 1);
    
    % If ThingSpeak Support Toolbox isn't on path, then
    if isempty(pathindx)
        % If toolbox isn't installed then generate appropriate error
        (error(getString(message('MATLAB:hwstubs:general:tsMLTBXNotInstalled', fcnName))));
    else
        % If ThingSpeak Support Toolbox is on MATLAB Path already then call
        % the function
        tbxPath = mlpath{pathindx};
        [varargout{1}, varargout{2}, varargout{3}] = fcnEvalWithPath(tbxPath, fcnName, inputArgs, isDesktop);
    end
else
    % If the function is called on MATLAB Online, then the functions are
    % already baked in and will live in the folder below:    
    tbxPath = fullfile(matlabroot, 'toolbox', 'matlab', 'iot');
    [varargout{1}, varargout{2}, varargout{3}] = fcnEvalWithPath(tbxPath, fcnName, inputArgs, isDesktop);
end

    function varargout = fcnEvalWithPath(pathInpt, fcnName, inputArgs, isDesktop) %#ok<INUSL>
        % Function to handle the call rerouting to the installed thingSpeak
        % connectivity or visualization functions.
        
        % Only for MATLAB Online call the addpath(genpath()) command to add
        % the directory with both connectivity and visualization function
        % sub folders
        if ~isDesktop
            addpath(genpath(pathInpt));
        end
        
        cd(pathInpt);
        
        if strcmpi(fcnName, 'thingSpeakRead')
            eval(['[varargout{1}, varargout{2}, varargout{3}] = feval(@' fcnName ', inputArgs{:});']);
        elseif strcmpi(fcnName, 'thingSpeakWrite') || ...            
                strcmpi(fcnName, 'urlfilter')
            eval(['varargout{1} = feval(@' fcnName ', inputArgs{:});']);
            varargout{2} = [];
            varargout{3} = [];
        elseif strcmpi(fcnName, 'thingSpeakAuthenticatedList')
            eval(['varargout{1} = feval(@' fcnName ');']);
            varargout{2} = [];
            varargout{3} = [];
        elseif (strcmpi(fcnName, 'thingSpeakClearAuthentication') && ...
                isempty(inputArgs))
            eval(['feval(@' fcnName ');']);
            varargout{1} = [];
            varargout{2} = [];
            varargout{3} = [];
        else
            eval(['feval(@' fcnName ', inputArgs{:});']);
            varargout{1} = [];
            varargout{2} = [];
            varargout{3} = [];
        end
    end
end