function tf = isDicomCollection(candidate)

% Copyright 2017 The MathWorks, Inc.

% NOTE: This function requires the input to be a table.

expectedVariableNames = {'StudyDateTime', 'SeriesDateTime', 'PatientName', ...
    'PatientSex', 'Modality', 'Rows', 'Columns', 'Channels', 'Frames', ...
    'StudyDescription', 'SeriesDescription', 'StudyInstanceUID', ...
    'SeriesInstanceUID', 'Filenames'};

actualVariableNames = candidate.Properties.VariableNames;
diffVariables = setdiff(expectedVariableNames, actualVariableNames);

tf = isempty(diffVariables);

end