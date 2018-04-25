function autofixwordlength(varargin)
%AUTOFIXWORDLENGTH  Automatically scales the fixed point blocks in a model for the given fraction length.
%
%This script automatically changes the word length of fixed-point 
%data types associated with Simulink blocks and Stateflow data objects 
%that do not have their fixed-point data type locked. 
%
% This function is for internal use. 
 
% Copyright 1994-2016 The MathWorks, Inc.

% check license availability
if ~hasFixedPointDesigner()
    DAStudio.error('SimulinkFixedPoint:autoscaling:licenseCheck');
end

switch nargin
    case 0
        try
            curBlkDiagramToScale = get_param(gcs, 'Object');
        catch e 
            DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
        end
    case 1
        if ischar(varargin{1})
            try 
                curBlkDiagramToScale = get_param(varargin{1}, 'Object');
            catch e
                DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
            end
        else
            DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
        end
    otherwise
        DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
end

appData = SimulinkFixedPoint.getApplicationData(bdroot(curBlkDiagramToScale.getFullName));
% Set the flag to autoscale word length
appData.AutoscalerProposalSettings.isWLSelectionPolicy = true;

fxpscale(curBlkDiagramToScale, 'Propose'); 
setAcceptAll(appData);
fxpscale(curBlkDiagramToScale, 'Apply'); 

appData.AutoscalerProposalSettings.isWLSelectionPolicy = false;
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setAcceptAll(appData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

result = appData.dataset.getRun(appData.ScaleUsing).getResults;

for i = 1:length(result)
    result(i).setAccept(true);
end
