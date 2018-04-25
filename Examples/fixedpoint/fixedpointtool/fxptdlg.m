function varargout = fxptdlg(action, varargin)
%FXPTDLG   Fixed-Point Tool for Simulink.
%
%   FXPTDLG('MODEL') opens Fixed-Point Tool for Simulink with the specified
%   MODEL. The tool provides a user interface for converting floating point
%   models and subsystems to fixed-point.

% Copyright 1994-2017 The MathWorks, Inc.


if ~usejava('jvm')
    [msg, msg_ID] = fxptui.message('javaRequired');
    fpt_exception = MException(msg_ID, msg);
    throwAsCaller(fpt_exception);
    
end
narginchk(1,2);

%flag whether or not we are in the process of launching the tool
persistent islaunching;
%persistent startupObj;
%if we are called again while launching, return
if(islaunching);return;end
%set the flag (persists between calls as long as MATLAB is up)
islaunching = true; %#ok<NASGU>

%try to launch tool
try
    nargoutchk(0,1);
    varargout = {};
    if(isoldcallback(action))
        islaunching = false;
        return;
    end
    %get the model
    try
        [system, action] = parseSystem(action);
    catch e
        islaunching = false;
        throw(e);
    end
    
    if slfeature('FPTWeb')
        blk = get_param(action, 'Object');
        selectedSystem = blk.getFullName;
        fxptui.FixedPointTool.launch(selectedSystem);
        me = fxptui.FixedPointTool.getExistingInstance;
        % Before continuining, verify that that the FPT
        % instance has been fullyInitialized from the initControllers
        % callback above. From g1649793.
        waitfor(me, 'isReadyPostCallback', true)
    else
        me = fxptui.getexplorer;
        if isempty(me) || ~me.isFPTLaunchedOnSameModel(get_param(system,'Object'))
            me = fxptui.explorer(system);
        end
        blk = get_param(action, 'Object');
        if isa(blk,'Simulink.ModelReference')
            % Point to the referenced model if the model block is intended to
            % be the SUD. If not, retain the model block selection.
            if isempty(me.getSystemForConversion)
                selectedSystem = blk.ModelName;
            else
                selectedSystem = blk.getFullName;
            end
            
        else
            [b, maskedSubsys] = fxptui.isUnderMaskedSubsystem(blk);
            if b
                selectedSystem = maskedSubsys.getFullName;
            else
                selectedSystem = blk.getFullName;
            end
        end
        
        if isempty(me.getSystemForConversion)
            me.setSystemForConversion(selectedSystem,class(blk));
        end
        
        %display the tool.
        fxptui.showFPT;
        
        me.selectnode(system);
        blk = get_param(action, 'Object');
        if(isa(blk, 'Simulink.SubSystem'))
            me.selectnode(blk.getFullName);
        end
    end
    
    %remove version 1 instrumentation if it exists
    clearoldcallbacks(system);
    %return an output when requested.
    if nargout>0
        varargout{1} = me;
    end
    %reset flag so we can call in again later
    islaunching = false;
    
catch fpt_exception
    %reset flag so we can call in again later
    islaunching = false;
    %rethrow(fpt_exception);
    throwAsCaller(fpt_exception);
end

%--------------------------------------------------------------------------
function b = isoldcallback(arg)
b = false;
oldcallbacks = { ...
    'fxptdlg_presave_cb', ...
    'fxptdlg_close_cb', ...
    'fxptdlg_simInit_cb', ...
    'fxptdlg_sim_cb', ...
    'fxptdlg_store_cb'};
%make sure 'arg' isn't a handle to model or block
if(ischar(arg))
    b =  ismember(arg, oldcallbacks);
end
%--------------------------------------------------------------------------
function clearoldcallbacks(system)
expression = 'fxptdlg\(.*?\);';
repstring = '';
try
    bd =  get_param(system, 'Object');
    olddirt = bd.Dirty;
    bd.PreSaveFcn = regexprep(bd.PreSaveFcn, expression, repstring);
    bd.CloseFcn = regexprep(bd.CloseFcn, expression, repstring);
    bd.InitFcn = regexprep(bd.InitFcn, expression, repstring);
    bd.StartFcn = regexprep(bd.StartFcn, expression, repstring);
    bd.StopFcn = regexprep(bd.StopFcn, expression, repstring);
    bd.Dirty = olddirt;
catch
    %consume errors. we are trying to remove instrumentation transparently.
end

%--------------------------------------------------------------------------
function [rootSystem, parentPath, fullPath, action] = getPathsFromHandle(hdle)

% determine the parentPath and name.
if isnumeric(hdle)
    parentPath = get_param(hdle,'Parent');
    name = get_param(hdle,'Name');
else
    [t,r] = strtok(fliplr(hdle),'/');
    parentPath = fliplr(r);
    name = fliplr(t);
end

% We allow blocks to have '/' in their names. We need to escape the slash
% so that the block opens right
name = strrep(name,'/','//');

% get the rootSystem
if isempty(parentPath)
    rootSystem = name;
else
    rootSystem = strtok(parentPath,'/');
end

% get the full path
if isempty(parentPath)
    fullPath = name;
else
    if strcmp(parentPath(length(parentPath)),'/')
        fullPath = [parentPath,name];
    else
        fullPath = [parentPath,'/',name];
    end
end
if ~isnumeric(hdle)
    action = fullPath;
else
    action = hdle;
end



%--------------------------------------------------------------------------
function [system, action] = parseSystem(action)
% Input parsing copied from pre-R2006b code.  In this local function we
% perform error checking and open system

[rootSystem, ~, ~, action] = getPathsFromHandle(action);

% get the system name without the .mdl (just in case)
system = strtok(rootSystem,'.');

% Do some error checking.
if ~ischar(system)
    [msg, msg_ID] = fxptui.message('errorArgNotString');
    fpt_exception = MException(msg_ID, msg);
    throw(fpt_exception);
end
existcode = exist(system,'file');
if(existcode ~= 4 && existcode ~= 2)
    [msg, msg_ID] = fxptui.message('errorSysNotFound', system);
    fpt_exception = MException(msg_ID, msg);
    throw(fpt_exception);
end

% Get the list of all loaded block diagrams
blockList = find_system('type','block_diagram');
% If the system is found in the loaded system list, then do not change the
% current view in UE
% g1545818
if ~any(strcmp(blockList, system))
    % Open the model and prepare to initialize the dialog.
    open_system(system);
end

% If the block is commented or inactive system, launch the FPT on the
% top model
% g1551616
blk = get_param(action, 'Object');
if isprop(blk, 'Commented')
    if strcmpi(get_param(blk.getFullName,'Commented'), 'on')
        % launch fpt on top model
        action = get_param(system, 'Handle');
    end
end

% Don't allow the dialog on a library or locked model
%    This code MUST come after open_system.
%
if ~strcmpi(get_param(system,'BlockDiagramType'),'model')
    [msg,msg_ID] = fxptui.message('libraryOrLockedModelError');
    % Create a MException and throw the error to the calling function to terminate execution.
    fpt_exception = MException(msg_ID, msg);
    throw(fpt_exception);
end

% [EOF]

% LocalWords:  cb
