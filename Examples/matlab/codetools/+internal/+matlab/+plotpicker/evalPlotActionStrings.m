function applicableToSelectionArray = evalPlotActionStrings(evalFunctions,allowWorkspaceListenerSuspend, selectedVars)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2012 The MathWorks, Inc.

% Evaluate each MATLAB expression in the evalFunctions and return the result
% as a logical array.

if allowWorkspaceListenerSuspend % Allow tests to turn off listener suspension
   swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
   cleaner = getCleanupHandler(swl); %#ok<NASGU>
end

try
    inputs = evalin('caller', selectedVars);
catch
    inputs = [];
end

applicableToSelectionArray = false(length(evalFunctions),1);
for k=1:length(evalFunctions)
    try
        fcn = str2func(evalFunctions{k});

        %applicableToSelectionArray(k) = evalin('caller',evalFunctions{k});
        applicableToSelectionArray(k) = feval(fcn, inputs);
    catch me %#ok<NASGU>
        applicableToSelectionArray(k) = false;
    end
end
    
function cleaner = getCleanupHandler(swl)
cleaner = onCleanup(@(~,~) com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(swl));
