classdef PublishSimulinkSystems < internal.matlab.publish.PublishExtension
% Copyright 1984-2017 The MathWorks, Inc.

    properties
        savedState = [];
    end
    
    methods
        
        function obj = PublishSimulinkSystems(options)
            obj = obj@internal.matlab.publish.PublishExtension(options);
            % Sometimes leavingCell will be called before enteringCell is
            % ever called, like when a cell loads Simulink for the first
            % time in a MATLAB session.
            obj.savedState.id = {};
            obj.savedState.data = [];
        end
       
        function enteringCell(obj,~)
            obj.savedState = captureSystems;
        end
        
        function newFiles = leavingCell(obj,~)   
            % Determine which systems need a snapshot.
            newSystems = captureSystems;
            systemsToSnap = internal.matlab.publish.compareFigures(obj.savedState, newSystems);
            
            % Take a snapshot of each system that needs it.
            newFiles = cell(size(systemsToSnap));
            for systemNumber = 1:length(systemsToSnap)
                s = systemsToSnap{systemNumber};
                imgFilename = snapSystem(s,obj.options.filenameGenerator(),obj.options);
                newFiles{systemNumber} = imgFilename;
            end
            
            % Update SNAPNOW's view of the current state of systems.
            obj.savedState = newSystems;
        end
        
    end
end    

%===============================================================================
function oldOpenSystems = captureSystems
openSystemList = findopensystems;
oldOpenSystems.id = openSystemList(:)';
oldOpenSystems.data = zeros(size(oldOpenSystems.id));
end

%===============================================================================
function sys = findopensystems
%FINDOPENSYSTEMS - Returns the names of open Simulink systems/Stateflow subviewers
%
% sys = findopensystems
%
% sys is a cell array of Simulink SIDs of open (i.e. visible) Simulink systems or
% Stateflow subviewers.

studios = DAS.Studio.getAllStudios();
nStudios = numel(studios);

sys = cell(nStudios, 1);
for i = 1:nStudios
    ue = studios{i}.App.getActiveEditor();
    hid = ue.getHierarchyId();
    sysH = resolveHID(hid);
    if ~isempty(sysH)
        sys{i} = Simulink.ID.getSID(sysH);
    end
end
end

%===============================================================================
function backingH = resolveHID(hid)
    hs = GLUE2.HierarchyService;
    scopedM3IObj = hs.getM3IObject(hid);
    m3iobj = scopedM3IObj.temporaryObject;

    if isa(m3iobj, 'SLM3I.Diagram')
        backingH = m3iobj.handle;
    elseif isa(m3iobj, 'StateflowDI.Subviewer')
        r = slroot();
        backingH = r.idToHandle(double(m3iobj.backendId));
    else
        backingH = [];
    end
end

%===============================================================================
function imgFilename = snapSystem(s,imgNoExt,opts)

% Nail down the image format.
if isempty(opts.imageFormat)
    imageFormat = internal.matlab.publish.getDefaultImageFormat(opts.format,'print');
else
    imageFormat = opts.imageFormat;
end

% Nail down the image filename.
imgFilename = internal.matlab.publish.getPrintOutputFilename(imgNoExt,imageFormat);

% Look for web blocks (MWDashbobard) blocks and give them a chance to render themselves.
% This is a workaround for g1623490
r = slroot;
% Only execute this code for Simulink models (ie not StateFlow charts)
if r.isValidSlObject(s)
    hndl = get_param(s,'Handle');
    hmiblks = find_system(hndl,'SearchDepth',1,'MaskType','MWDashboardBlock');
    if ~isempty(hmiblks)
        % The performance regression is being investigated in g1625069
        pause(30);
    end
end

% Map to equivalencies or close equivalencies.
switch imageFormat
    case 'meta'
        imageFormat = 'emf';
    case 'eps2'
        imageFormat = 'eps';
    case 'epsc2'
        imageFormat = 'epsc';
end

% Print it.
snapshot = SLPrint.Snapshot; 
snapshot.Target = Simulink.ID.getHandle(s);
snapshot.Format = imageFormat;
snapshot.FileName = imgFilename;
snapshot.Scale = internal.matlab.publish.getImageScale();
snapshot.ScaledMaxSize = [100000 100000];
snapshot.snap();

internal.matlab.publish.resizeIfNecessary(imgFilename,imageFormat,opts.maxWidth,opts.maxHeight)
end
