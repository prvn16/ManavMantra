function showDerivedDiagnosticInMV(diagnosticMessage, title, srcObj)
%SHOWDERIVEDDIAGNOSTICINMV display derived related error message in Message
%Viewer using stage interfaces

%   Copyright 2016 The MathWorks, Inc.

model = srcObj.getFullName; 

% Follow the Cookbook
% Create a Stage to display all the messages
rangeDeriveStage = Simulink.output.Stage(fxptui.message('titleFPTRangeDerivation'), 'ModelName', model, 'UIMode', true); %#ok<NASGU>

% Report the failure exception as error
msldiag =  MSLDiagnostic(diagnosticMessage);
msldiag.metaData( 'COMPONENT',fxptui.message('titleFPTool'), 'CATEGORY', title);
msldiag.reportAsError(model, true);
% The stage will be closed once “rangeDeriveStage” variable goes out of scope or is explicitly cleared.

end

