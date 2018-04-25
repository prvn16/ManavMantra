function varargout = autofixexp(varargin) %#ok<STOUT>
%AUTOFIXEXP  Automatically scales the fixed point blocks in a model.
%
%This script automatically changes the scaling of fixed-point 
%data types associated with Simulink blocks and Stateflow data objects 
%that do not have their fixed-point scaling locked. 
%
%The script executes the following autoscaling procedure:  
%
%  1. The script collects range data from model objects that specify 
%     design minimum and maximum values, e.g., by means of the 
%     "Output minimum" or "Output maximum" parameters.  If an 
%     object's design minimum and maximum values are unspecified, 
%     the script collects the logged minimum and maximum values that 
%     the object output during the previous simulation. 
%
%  2. The script uses the collected range data to calculate fraction 
%     lengths that maximize precision and cover the range. 
%
%  3. The script applies its fixed-point scaling recommendations to 
%     the objects in a model. 
 
% Copyright 1994-2017 The MathWorks, Inc.

% check license availability
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if ~hasFixedPointDesigner()
    DAStudio.error('SimulinkFixedPoint:autoscaling:licenseCheck');
end

try
    curBlockDiagram = get_param(gcs, 'Object');
catch e 
    DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
end

if nargin < 1 || ~ischar(varargin{1})

    iStart = 1;
    feval('autoscaler_legacy',varargin{iStart:end})
else
    action = varargin{1};
    fxpscale(curBlockDiagram, action);
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SafetyMargin = RangeFactor2SafetyMargin(RangeFactor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SafetyMargin = 100 * (RangeFactor - 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoscaler_legacy(FixPtVerbose,RangeFactor,curFixPtSimRanges,topSubSystemToScale) %#ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The legacy mode DETERMINES and SETS the scaling in one shot using new autoscaler.
%

% ignore the first arg 
if nargin < 1
    % do nothing
end

if nargin < 2
    RangeFactor = [];
end

if nargin < 3
    curFixPtSimRanges = [];
end

if nargin < 4
   topSubSystemToScale = gcs;
end


curBlkDiagramToScale = get_param(topSubSystemToScale, 'Object');
if isa(curBlkDiagramToScale, 'Simulink.SubSystem')
    mdlName = bdroot(curBlkDiagramToScale.getFullName);
else
    mdlName = curBlkDiagramToScale.getFullName;
end
if ~strcmpi(get_param(mdlName,'SimulationMode'),'normal')
    DAStudio.error('SimulinkFixedPoint:autoscaling:notNormalMode');
end
try 
    appData = SimulinkFixedPoint.getApplicationData(mdlName);
catch e 
    DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
end

if ~isempty(RangeFactor)
    appData.AutoscalerProposalSettings.SafetyMarginForSimMinMax = RangeFactor2SafetyMargin(RangeFactor);
end

if ~isempty(curFixPtSimRanges)
    % Clear all results in the run. This will also delete the run.
    appData.dataset.deleteRun(appData.ScaleUsing);
    runObj = appData.dataset.getRun(appData.ScaleUsing);
    for idx = 1:length(curFixPtSimRanges)
        runObj.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(curFixPtSimRanges{idx}));
    end
end

settingStruct = appData.settingToStruct(); 
fxpscale(curBlkDiagramToScale, 'Propose', settingStruct); 
setAcceptAll(mdlName)
fxpscale(curBlkDiagramToScale, 'Apply', settingStruct); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setAcceptAll(mdlName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    [refmdl, ~] = SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(mdlName); 
catch findrefFailed
    rethrow(findrefFailed);
end

for idx = 1:length(refmdl)
    appData = SimulinkFixedPoint.getApplicationData(bdroot(refmdl{idx}));
    result = appData.dataset.getRun(appData.ScaleUsing).getResults;
        
    for i = 1:length(result)
        result(i).setAccept(true);
    end
end

% LocalWords:  autoscaling autoscaler
