function detailsTable = dicomCollection(source, varargin)
%dicomCollection   Gather details about related series of DICOM files.
%   COLLECTION = dicomCollection(DIRECTORY) gathers details about DICOM
%   files contained in DIRECTORY into COLLECTION. Details are aggregated by
%   DICOM series, which are logically related sets of images from imaging
%   operation.
%
%   COLLECTION = dicomCollection(DIRECTORY, 'IncludeSubfolders', TF)
%   recursively searches for DICOM files below DIRECTORY if TF is true (the
%   default). When false, only the named directory is examined.
%
%   COLLECTION = dicomCollection(DICOMDIR) gathers details about the DICOM
%   files referenced in a DICOMDIR file. This file can be referred to by
%   its absolute path, specified by a relative path location, or exist on
%   the MATLAB path.
%
%   Examples:
%   ---------
%   % 1 - Gather details from files shipping with Image Processing Toolbox.
%   details1 = dicomCollection(fullfile(matlabroot, 'toolbox/images/imdata'))
%
%   % 2 - Load details from a DICOMDIR file.
%   details2 = dicomCollection(fullfile(matlabroot, 'toolbox/images/imdata/DICOMDIR'))
%
%   See also dicomBrowser, dicominfo, dicomread, dicomreadVolume.

% Copyright 2016-2017 The MathWorks, Inc.

% Input validation...
source = matlab.images.internal.stringToChar(source);
parser = inputParser();
parser.addRequired('source', @sourceValidator)
parser.addParameter('IncludeSubfolders', true, @recursiveValidator)
parser.FunctionName = mfilename;
parser.parse(source, varargin{:});

recursive = parser.Results.IncludeSubfolders;

% Disable DICOM-related warnings.
origWarnState = warning;
warnCleaner = onCleanup(@() warning(origWarnState));
images.internal.app.dicom.disableDICOMWarnings()

% Create the table...
loader = images.internal.dicom.CollectionLoader(source, recursive);
detailsTable = loader.Collection;
if isempty(detailsTable)
    return
end

% Make the table more friendly.
detailsTable = convertCharToString(detailsTable);
detailsTable = addRowNames(detailsTable);
detailsTable = sortFilenames(detailsTable);

end


function tf = sourceValidator(source)

validateattributes(source, {'char', 'string'}, {'row', 'nonempty'}, mfilename, 'SOURCE', 1)

tf = true;

end


function tf = recursiveValidator(value)

validateattributes(value, {'logical', 'numeric'}, {'scalar'}, mfilename, 'IncludeSubfolders')

tf = true;

end


function detailsTable = convertCharToString(detailsTable)

detailsTable.PatientName = string(detailsTable.PatientName);
detailsTable.PatientSex = string(detailsTable.PatientSex);
detailsTable.Modality = string(detailsTable.Modality);
detailsTable.StudyDescription = string(detailsTable.StudyDescription);
detailsTable.SeriesDescription = string(detailsTable.SeriesDescription);
detailsTable.StudyInstanceUID = string(detailsTable.StudyInstanceUID);
detailsTable.SeriesInstanceUID = string(detailsTable.SeriesInstanceUID);

end


function detailsTable = addRowNames(detailsTable)

numRows = size(detailsTable,1);
rowNames = cell(numRows,1);
for idx = 1:numRows
    rowNames{idx} = sprintf('s%d', idx);
end
detailsTable.Properties.RowNames = rowNames;

end


function detailsTable = sortFilenames(detailsTable)

numRows = size(detailsTable,1);
for idx = 1:numRows
    filenames = detailsTable.Filenames{idx};
    try
        sortedFilenames = images.internal.dicom.getSeriesDetails(filenames);
        detailsTable.Filenames{idx} = sortedFilenames;
    catch
    end
end

end
