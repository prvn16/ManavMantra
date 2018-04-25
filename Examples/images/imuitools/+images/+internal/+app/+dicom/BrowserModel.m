classdef BrowserModel < handle
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = private)
        Collection
        StudyDetails
        AllSeriesDetailsCell
        CurrentVolume
    end
    
    properties
        CurrentStudy
        CurrentSeries
    end
    
    methods
        function obj = BrowserModel()
        end
        
        function loadNewCollection(obj, source)
            if istable(source)
                obj.Collection = source;
            else
                origWarn = warning();
                warning('off', 'images:dicomread:dirNotReadable')
                warnCleanup = onCleanup(@() warning(origWarn));
                collection = dicomCollection(source, 'IncludeSubfolders', true);
                if isempty(collection)
                    % No data or cancelled.
                    return
                else
                    obj.Collection = collection;
                end
            end
            
            [obj.StudyDetails, obj.AllSeriesDetailsCell] = getStudyDetails(obj.Collection);
            
            obj.CurrentStudy = [];
            obj.CurrentSeries = [];
            obj.updateCurrentVolume([]);
            
            evtData = images.internal.app.dicom.CollectionChangeEventData(obj.StudyDetails, makeEmptySeriesTable());
            obj.notify('CollectionChange', evtData)
        end
        
        function [V, spatialDetails, dim] = loadVolume(obj, studyIndex, seriesIndex)
            if obj.currentHasLoadedVolume(studyIndex, seriesIndex)
                V = obj.CurrentVolume.Volume;
                spatialDetails = obj.CurrentVolume.SpatialDetails;
                dim = obj.CurrentVolume.SliceDim;
            else
                theSeries = obj.AllSeriesDetailsCell{studyIndex}(seriesIndex,:);
                filenames = theSeries.Filenames{1};
                try
                    [V, spatialDetails, dim] = dicomreadVolume(filenames);
                catch
                    V = images.internal.dicom.loadImagesByFilename(filenames);
                    spatialDetails = struct([]);
                    dim = 3;
                end
                
                map = obj.loadColormap(studyIndex, seriesIndex);
                obj.updateCurrentVolume(images.internal.app.dicom.LoadVolumeEventData(...
                    V, spatialDetails, dim, map))
            end
        end
        
        function map = loadColormap(obj, studyIndex, seriesIndex)
            if obj.currentHasLoadedVolume(studyIndex, seriesIndex)
                map = obj.CurrentVolume.Colormap;
            else
                theSeries = obj.AllSeriesDetailsCell{studyIndex}(seriesIndex,:);
                filenames = theSeries.Filenames{1};
                
                if ischar(filenames)
                    filenames = string(filenames);
                end
                
                firstFilename = filenames(1);
                
                map = getColormap(firstFilename);
            end
        end
        
        function seriesDetails = getSeriesDetailsForStudy(obj, studyIndex)
            seriesDetails = obj.AllSeriesDetailsCell{studyIndex};
        end
        
        function loadCollection(obj, directoryName)
            oldCollection = obj.Collection;
            oldStudyDetails = obj.StudyDetails;
            oldAllSeriesDetailsCell = obj.AllSeriesDetailsCell;
            
            try
                obj.loadNewCollection(directoryName)
            catch ME
                obj.Collection = oldCollection;
                obj.StudyDetails = oldStudyDetails;
                obj.AllSeriesDetailsCell = oldAllSeriesDetailsCell;
                rethrow(ME)
            end
        end
        
        function updateCurrentVolume(obj, volumeDetails)
            obj.CurrentVolume = volumeDetails;
        end
        
        function oneTableRow = getFullDetailsForSeries(obj, studyIndex, seriesIndex)
            studySeriesDetails = obj.getSeriesDetailsForStudy(studyIndex);
            theSeriesDetails = studySeriesDetails(seriesIndex,:);
            rowName = theSeriesDetails.Properties.RowNames{1};
            oneTableRow = obj.Collection(rowName, :);
        end
    end
    
    methods (Access = private)
        function tf = currentHasLoadedVolume(obj, studyIndex, seriesIndex)
            tf = ~isempty(obj.CurrentStudy) && ...
                ~isempty(obj.CurrentSeries) && ...
                obj.CurrentStudy == studyIndex && ...
                obj.CurrentSeries == seriesIndex && ...
                ~isempty(obj.CurrentVolume);
        end
    end
    
    events
        CollectionChange
    end
end


function [studyDetails, seriesDetailsCell] = getStudyDetails(collection)

dataTable = collection;

try
    dataTable.SeriesDateTime = datestr(dataTable.SeriesDateTime);
catch
end

allStudiesUIDs = dataTable{:, 'StudyInstanceUID'};
[~, forwardIndices, backwardIndices] = unique(allStudiesUIDs);

studyDetails = dataTable(forwardIndices, images.internal.app.dicom.getStudyColumnNames());

numberOfSeries = numel(forwardIndices);
seriesDetailsCell = cell([numberOfSeries 1]);
for seriesIndex = 1:numberOfSeries
    rows = backwardIndices == seriesIndex;
    columnNames = [images.internal.app.dicom.getSeriesColumnNames(), {'Filenames'}];
    seriesDetailsCell{seriesIndex} = dataTable(rows, columnNames);
end

try
    studyDetails.StudyDateTime = datestr(studyDetails.StudyDateTime);
catch
end

end

        
function emptyTable = makeEmptySeriesTable

emptyCells = cell(0, numel(images.internal.app.dicom.getSeriesColumnNames()));
emptyTable = cell2table(emptyCells);

end


function map = getColormap(filename)

fileMetadata = images.internal.dicom.DICOMFile(filename);

% See PS 3.3-2000 Sec. C.7.6.3.1.5 and C.7.6.3.1.6.

% If there are no descriptors, there is no colormap.
redPaletteLUTDescriptor = fileMetadata.getAttribute(40, 4353);  % (0028,1101)
if (isempty(redPaletteLUTDescriptor))
    map = [];
    return
else
    greenPaletteLUTDescriptor = fileMetadata.getAttribute(40, 4354);  % (0028,1102)
    bluePaletteLUTDescriptor = fileMetadata.getAttribute(40, 4355);  % (0028,1103)
    redPaletteLUTData = fileMetadata.getAttribute(40, 4609);  % (0028,1201)
    greenPaletteLUTData = fileMetadata.getAttribute(40, 4610);  % (0028,1202)
    bluePaletteLUTData = fileMetadata.getAttribute(40, 4611);  % (0028,1203)
end

% Reconstitute the MATLAB-style colormap from the color data and
% descriptor values.
red = double(redPaletteLUTData) ./ ...
    (2 ^ double(redPaletteLUTDescriptor(3)) - 1);

green = double(greenPaletteLUTData) ./ ...
    (2 ^ double(greenPaletteLUTDescriptor(3)) - 1);

blue = double(bluePaletteLUTData) ./ ...
    (2 ^ double(bluePaletteLUTDescriptor(3)) - 1);

map = [red green blue];

end
