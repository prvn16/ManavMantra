function [X, spatialInfo, sliceDim] = dicomreadVolume(inputSource, varargin)
%dicomreadVolume   Construct volume from directory of DICOM images/slices.
%   [V, SPATIAL, DIM] = dicomreadVolume(SOURCE) loads the 4D DICOM volume V
%   from SOURCE, which can be the name of a directory containing DICOM
%   files, an string array of filenames comprising the volume, or a cell
%   array of char vectors containing filenames. SPATIAL is a struct
%   describing the location, resolution, and orientation of slices in the
%   volume. DIM specifies which real world dimension has the largest
%   amount of offset from the previous slice. (X = 1, Y = 2, Z = 3)
%
%   [___] = dicomreadVolume(SOURCETABLE) loads the volume from SOURCETABLE,
%   which is a table returned by dicomCollection. SOURCETABLE must contain
%   only one row.
%
%   [___] = dicomreadVolume(SOURCETABLE, ROWNAME) loads the volume with the
%   specified ROWNAME from the multi-row table SOURCETABLE returned by
%   dicomCollection. Use this syntax when SOURCETABLE contains multiple
%   rows.
%   
%   Example:
%   --------
%   X = dicomreadVolume(fullfile(matlabroot, 'toolbox/images/imdata/dog'));
%   volumeViewer(squeeze(X))
%   
%   Notes:
%   ------
%   The dimensions of V are [rows, columns, samples, slices] where
%   "samples" is the number of color channels per voxel. For example,
%   grayscale volumes have one sample, and RGB volumes have three. Use the
%   SQUEEZE function to remove any singleton dimensions (such as when
%   samples is 1).
%
%   See also dicomCollection, dicominfo, dicomread, dicomBrowser.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2)
validateattributes(inputSource, {'string', 'char', 'table', 'cell'}, {'nonempty'})

if ischar(inputSource)
    validateNargin(nargin)
    filenames = getFilenames(inputSource);
elseif iscellstr(inputSource)
    validateNargin(nargin)
    filenames = inputSource;
elseif isstring(inputSource)
    validateNargin(nargin)
    if numel(inputSource) == 1
        filenames = getFilenames(matlab.images.internal.stringToChar(inputSource));
    else
        filenames = cellstr(inputSource);
    end
elseif istable(inputSource)
    switch nargin
    case 1
        filenames = getFilenamesFromTable(inputSource);
    case 2
        row = varargin{1};
        filenames = getFilenamesFromTable(inputSource, row);
    end
end

[seriesFilenames, spatialInfo, sliceDim] = images.internal.dicom.getSeriesDetails(filenames);

if numel(seriesFilenames) == 1
    X = dicomread(seriesFilenames{1});
else
    X = images.internal.dicom.loadImagesByFilename(seriesFilenames);
end
end


function filenames = getFilenames(dirName)

detailsStruct = dir(dirName);
if isempty(detailsStruct)
    error(message('images:dicomread:dirNotReadable'))
else
    numberOfResultsFromDir = numel(detailsStruct);
end

isDirectory = [detailsStruct.isdir];
detailsStruct(isDirectory) = [];

if numberOfResultsFromDir == 1 && ~detailsStruct.isdir
    filenames = {dirName};
elseif ~isempty(detailsStruct)
    filenames = {detailsStruct.name};
    for idx = 1:numel(filenames)
        filenames{idx} = fullfile(dirName, filenames{idx});
    end
else
    filenames = {};
end
end


function filenames = getFilenamesFromTable(inputTable, row)

switch nargin
case 1
    if size(inputTable, 1) == 1
        filenames = inputTable.Filenames{1};
    else
        error(message('images:dicomread:numTableRows'))
    end
case 2
    row = matlab.images.internal.stringToChar(row);
    validateattributes(row, {'char'}, {'nonempty'})
    rowNames = inputTable.Row;
    if ~isempty(rowNames)
        row = validatestring(row, rowNames);
    else
        error(message('images:dicomread:missingRowNames'))
    end
    
    filenames = inputTable.Filenames{row};
otherwise
    assert(false, 'Coding error: Too many inputs.')
end

end


function validateNargin(numInputs)

if numInputs ~= 1
    error(message('images:dicomread:inputNotTable'))
end
end
