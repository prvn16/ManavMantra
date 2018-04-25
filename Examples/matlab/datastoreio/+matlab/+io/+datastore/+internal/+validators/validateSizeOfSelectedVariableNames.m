function locb = validateSizeOfSelectedVariableNames(selectedNames, variableNames)
%VALIDATESIZEOFSELECTEDVARIABLENAMES Validates size of SelectedVariableNames 
%   This is a helper function that validates the size of SelectedVariableNames
%   against the size of VariableNames. It checks for the membership of
%   SelectedVariableNames in VariableNames and uniqueness of SelectedVariableNames.
%   It returns the location indexes of the given SelectedVariableNames within
%   VariableNames after finding the membership.

%   Copyright 2016 The MathWorks, Inc.

% lengths have to match
if length(selectedNames) > length(variableNames)
    error(message('MATLAB:datastoreio:tabulartextdatastore:invalidActiveVariableNames'));
end

% check for membership and uniqueness
[lia, locb] = ismember(selectedNames, variableNames);
uniquesVarNames = unique(selectedNames);
if ~all(lia) || (numel(uniquesVarNames) ~= numel(selectedNames))
    error(message('MATLAB:datastoreio:tabulartextdatastore:invalidActiveVariableNames'));
end
