classdef CollectionLoader < handle

    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Collection = [];
    end
    
    properties (Access = private)
        Waitbar
        TotalFiles
        ExaminedFiles
        FilesProcessedListener
    end
    
    events
        FilesProcessed
    end
    
    methods
        function obj = CollectionLoader(source, includeSubdir)
            obj.TotalFiles = images.internal.dicom.countNumFiles(source, includeSubdir);
            obj.ExaminedFiles = 0;
            
            titleText = getString(message('images:dicomCollection:dialogTitle'));
            insideText = getString(message('images:dicomCollection:dialogBody'));
            obj.Waitbar = iptui.cancellableWaitbar(titleText, insideText, obj.TotalFiles, 0);
            oc = onCleanup(@obj.destroyWaitbar);
            obj.Waitbar.refreshWaitbar()
            
            obj.FilesProcessedListener = addlistener(obj, 'FilesProcessed', ...
                @(hObj, evtData) obj.updateWaitbar());
            
            obj.describeSource(source, includeSubdir);
        end
    end
    
    methods (Access = private)
        function updateWaitbar(obj)
            obj.Waitbar.update(obj.ExaminedFiles)
        end
        
        function destroyWaitbar(obj)
            obj.Waitbar.destroy()
        end
        
        function describeSource(obj, source, includeSubdir)
            if ~exist(source, 'file')
                error(message('images:dicomCollection:badLocation'))
            end
            
            if ~isdir(source)
                fid = fopen(source, 'r');
                source = fopen(fid);
                fclose(fid);
                
                if isdicom(source)
                    % DICOMDIR or single DICOM file.
                    fileIsDICOMDIR = isDICOMDIR(source);
                    [pathToDICOMDIR,~,~] = fileparts(source);
                    if fileIsDICOMDIR
                        rawDetails = images.dicom.parseDICOMDIR(source);
                        fileDetails = convertRawDICOMDIR(rawDetails, pathToDICOMDIR);
                        fileDetails = rmfield(fileDetails, 'InstanceUID');
                        obj.Collection = convertToTable(fileDetails);
                        return
                    else
                        details = dir(source);
                        fileDetails = obj.getFileDetails(pathToDICOMDIR, details);
                    end
                else
                    error(message('images:dicomCollection:notDICOM'))
                end
            else
                % Directory name (or non-DICOM file)
                if includeSubdir
                    fileDetails = obj.recurseDirectories(source);
                else
                    dirDetails = getFileDirectoryDetails(source);
                    fileDetails = obj.getFileDetails(source, dirDetails);
                end
            end
            
            if ~isempty(fileDetails)
                fileDetails = removeDuplicateImages(fileDetails);
                fileDetails = rmfield(fileDetails, 'InstanceUID');
                seriesDetails = aggregateBySeries(fileDetails);
                obj.Collection = convertToTable(seriesDetails);
            else
                obj.Collection = table([]);
            end
        end
        
        function fileDetails = recurseDirectories(obj, dirName)
            if (obj.Waitbar.cancelPressed)
                fileDetails = struct([]);
                return
            end
            
            dirDetails = getFileDirectoryDetails(dirName);
            if ~isempty(dirDetails)
                fileDetails = obj.getFileDetails(dirName, dirDetails);
            else
                fileDetails = struct([]);
            end
            
            subDirNames = getSubdirectoryNames(dirName);
            for idx = 1:numel(subDirNames)
                tmpFileDetails = obj.recurseDirectories(subDirNames{idx});
                fileDetails = cat(2, fileDetails, tmpFileDetails);
            end
            
            if (obj.Waitbar.cancelPressed)
                fileDetails = struct([]);
                return
            end
        end
        
        function fileDetails = getFileDetails(obj, dirName, details)
            if isempty(details)
                fileDetails = struct([]);
                return
            end
            
            numFiles = numel(details);
            fileDetails = makeStructTemplate(numFiles);
            
            currentIndex = 1;
            successfulReads = 0;
            startCount = obj.ExaminedFiles;
            
            for idx = 1:numel(details)
                % Put this at the head of the loop, since several
                % conditions cause the loop to short-circuit.
                obj.ExaminedFiles = startCount + idx;
                notify(obj, 'FilesProcessed')
                
                filename = details(idx).name;
                
                try
                    thisFilename = fullfile(dirName,filename);
                    thisFile = images.internal.dicom.DICOMFile(thisFilename);
                    
                    if isDICOMDIR(thisFile)
                        % Ignore DICOMDIR files to prevent double counting.
                        continue
                    end
                    
                    fileDetails(currentIndex).Filenames = string({thisFilename});
                    
                    studyDate  = thisFile.getAttribute(8, 32);   % (0008,0020)
                    seriesDate = thisFile.getAttribute(8, 33);   % (0008,0021)
                    studyTime  = thisFile.getAttribute(8, 48);   % (0008,0030)
                    seriesTime = thisFile.getAttribute(8, 49);   % (0008,0031)
                    
                    fileDetails(currentIndex).StudyDateTime     = getDateTimeFromParts(studyDate, studyTime);
                    fileDetails(currentIndex).SeriesDateTime    = getDateTimeFromParts(seriesDate, seriesTime);
                    fileDetails(currentIndex).Modality          = handleEmpty(thisFile.getAttribute(8, 96));   % (0008,0060)
                    fileDetails(currentIndex).StudyDescription  = handleEmpty(thisFile.getAttribute(8, 4144)); % (0008,1030)
                    fileDetails(currentIndex).SeriesDescription = handleEmpty(thisFile.getAttribute(8, 4158)); % (0008,103E)
                    fileDetails(currentIndex).PatientName       = handleEmpty(thisFile.getAttribute(16, 16));  % (0010,0010)
                    fileDetails(currentIndex).PatientSex        = handleEmpty(thisFile.getAttribute(16, 64));  % (0010,0040)
                    fileDetails(currentIndex).StudyInstanceUID  = handleEmpty(thisFile.getAttribute(32, 13));  % (0020,000D)
                    fileDetails(currentIndex).SeriesInstanceUID = handleEmpty(thisFile.getAttribute(32, 14));  % (0020,000E)
                    fileDetails(currentIndex).InstanceUID       = getInstanceUID(thisFile);
                    
                    sizes = getSizes(thisFile);
                    fileDetails(currentIndex).Rows = sizes(1);
                    fileDetails(currentIndex).Columns = sizes(2);
                    fileDetails(currentIndex).Channels = sizes(3);
                    fileDetails(currentIndex).Frames = sizes(4);
                catch
                    % Ignore files that fail.
                    continue
                end
                
                currentIndex = currentIndex + 1;
                successfulReads = successfulReads + 1;
            end
            
            if successfulReads == 0
                fileDetails = struct([]);
            else
                fileDetails = fileDetails(1:successfulReads);
            end
        end
    end
end

function fileDetails = convertRawDICOMDIR(rawDetails, pathToDICOMDIR)

if isempty(rawDetails)
    fileDetails = struct([]);
    return
end

numSeries = countSeriesInDICOMDIR(rawDetails);
fileDetails = makeStructTemplate(numSeries);

if numSeries == 0
    return
end

outputIndex = 1;

numPatients = numel(rawDetails.Patients);
for patientIndex = 1:numPatients
    thisPatient = rawDetails.Patients(patientIndex);
    if ~isfield(thisPatient, 'Studies')
        continue
    end
    
    numStudies = numel(thisPatient.Studies);
    for studiesIndex = 1:numStudies
        thisStudy = thisPatient.Studies(studiesIndex);
        
        if ~isfield(thisStudy, 'Series')
            continue
        end
        
        numSeries = numel(thisStudy.Series);
        for seriesIndex = 1:numSeries
            thisSeries = thisStudy.Series(seriesIndex);
            
            if ~isempty(thisSeries.Images)
                fileDetails(outputIndex).Filenames = string(getFilenamesFromDICOMDIR(thisSeries, pathToDICOMDIR));
                
                fileDetails(outputIndex).StudyDateTime = getFieldFromDICOMDIR(thisStudy, 'StudyDateTime');
                fileDetails(outputIndex).SeriesDateTime = getFieldFromDICOMDIR(thisSeries, 'SeriesDateTime');
                fileDetails(outputIndex).Modality = getFieldFromDICOMDIR(thisSeries, 'Modality');
                fileDetails(outputIndex).StudyDescription = getFieldFromDICOMDIR(thisStudy, 'StudyDescription');
                fileDetails(outputIndex).SeriesDescription = getFieldFromDICOMDIR(thisSeries, 'SeriesDescription');
                fileDetails(outputIndex).PatientName = getFieldFromDICOMDIR(thisPatient, 'PatientName');
                fileDetails(outputIndex).PatientSex = getFieldFromDICOMDIR(thisPatient, 'PatientSex');
                fileDetails(outputIndex).StudyInstanceUID = getStudyInstanceUID(thisStudy);
                fileDetails(outputIndex).SeriesInstanceUID = getFieldFromDICOMDIR(thisSeries, 'SeriesInstanceUID');
                try
                    fileDetails(outputIndex) = addSizesFromDICOMDIR(fileDetails(outputIndex), thisSeries, pathToDICOMDIR);
                catch
                end
                
                outputIndex = outputIndex + 1;
            end
        end
    end
end
end

function numSeries = countSeriesInDICOMDIR(rawDetails)

numSeries = 0;

if ~isfield(rawDetails, 'Patients')
    return
end

numPatients = numel(rawDetails.Patients);
for patientIndex = 1:numPatients
    if ~isfield(rawDetails.Patients, 'Studies')
        break
    end
    
    numStudies = numel(rawDetails.Patients(patientIndex));
    for studiesIndex = 1:numStudies
        if isfield(rawDetails.Patients(patientIndex).Studies, 'Series')
            numSeries = numSeries + numel(rawDetails.Patients(patientIndex).Studies(studiesIndex));
        end
    end
end
end

function filenamesCell = getFilenamesFromDICOMDIR(oneSeries, pathToDICOMDIR)

whatStruct = what(pathToDICOMDIR);
fullPathToDICOMDIR = whatStruct.path;

numImages = numel(oneSeries.Images);
filenamesCell = cell(1, numImages);
for index = 1:numImages
    filenameFromDICOMDIR = oneSeries.Images(index).Payload.ReferencedFileID;
    filenameFromDICOMDIR = convertFileSeparators(filenameFromDICOMDIR);
    filenamesCell{index} = fullfile(fullPathToDICOMDIR, filenameFromDICOMDIR);
end
end

function outLocation = convertFileSeparators(inLocation)

switch filesep
    case '/'
        outLocation = strrep(inLocation, '\', '/');
    case '\'
        outLocation = inLocation;
    otherwise
        assert(false)
end
end

function value = getFieldFromDICOMDIR(source, fieldname)

switch fieldname
    case 'StudyDateTime'
        [dateFieldname, timeFieldname] = getDateTimeFieldnames('study');
        studyDate = getFieldByName(source, dateFieldname);
        studyTime = getFieldByName(source, timeFieldname);
        value = getDateTimeFromParts(studyDate, studyTime);
    case 'SeriesDateTime'
        [dateFieldname, timeFieldname] = getDateTimeFieldnames('series');
        seriesDate = getFieldByName(source, dateFieldname);
        seriesTime = getFieldByName(source, timeFieldname);
        value = getDateTimeFromParts(seriesDate, seriesTime);
    case 'Modality'
        value = getField(source, 8, 96); % (0008,0060)
    case 'StudyDescription'
        value = getField(source, 8, 4144); % (0008,1030)
    case 'SeriesDescription'
        value = getField(source, 8, 4158); % (0008,103E)
    case 'PatientName'
        value = getField(source, 16, 16);  % (0010,0010)
    case 'PatientSex'
        value = string(getField(source, 16, 64));  % (0010,0040)
    case 'StudyInstanceUID'
        value = getField(source, 32, 13);  % (0020,000D)
    case 'SeriesInstanceUID'
        value = getField(source, 32, 14);  % (0020,000E)
    otherwise
end

if isempty(value)
    value = '';
end
end

function [dateFieldname, timeFieldname] = getDateTimeFieldnames(kind)

persistent studyDate studyTime seriesDate seriesTime
if isempty(studyDate)
    studyDate = dicomlookup('0008','0020');
    studyTime = dicomlookup('0008','0030');
    seriesDate = dicomlookup('0008','0021');
    seriesTime = dicomlookup('0008','0031');
end

switch kind
    case 'study'
        dateFieldname = studyDate;
        timeFieldname = studyTime;
    case 'series'
        dateFieldname = seriesDate;
        timeFieldname = seriesTime;
    otherwise
        assert(false, 'Internal error.')
        
end
end

function value = getField(source, group, element)

attributeName = dicomlookup(group, element);
value = getFieldByName(source, attributeName);

end

function value = getFieldByName(source, attributeName)

if isfield(source.Payload, attributeName)
    value = source.Payload.(attributeName);
else
    value = [];
end
end

function value = getStudyInstanceUID(source)

value = getFieldFromDICOMDIR(source, 'StudyInstanceUID');

end

function details = addSizesFromDICOMDIR(details, source, pathToDICOMDIR)

imageFilename = convertFileSeparators(source.Images(1).Payload.ReferencedFileID);
filenameForOneImage = fullfile(pathToDICOMDIR, imageFilename);

oneFileDetails = images.internal.dicom.DICOMFile(filenameForOneImage);

details.Rows = oneFileDetails.getAttribute(40, 16); % (0028,0010)
details.Columns = oneFileDetails.getAttribute(40, 17); % (0028,0011)
details.Channels = oneFileDetails.getAttribute(40,2);  % (0028,0002)

numFrames = oneFileDetails.getAttribute(40,8);  % (0028,0008)
if ~isempty(numFrames)
    details.Frames = numFrames;
else
    details.Frames = numel(details.Filenames);
end
end

function subDirNames = getSubdirectoryNames(dirName)

details = dir(dirName);
if isempty(details)
    warning(message('images:dicomread:dirNotReadable'))
    subDirNames = cell(0);
    return
end

isDirectory = [details.isdir];
details(~isDirectory) = [];

subDirNames = cell(numel(details) - 2, 1);
outputIndex = 1;
for idx = 1:numel(details)
    thisSubdirName = details(idx).name;
    switch thisSubdirName
    case {'.', '..'}
        continue
    otherwise
        subDirNames{outputIndex} = fullfile(dirName, thisSubdirName);
        outputIndex = outputIndex + 1;
    end
end
end

function details = getFileDirectoryDetails(dirName)

details = dir(dirName);
if isempty(details)
    warning(message('images:dicomread:dirNotReadable'))
    details = struct([]);
    return
end

isDirectory = [details.isdir];
details(isDirectory) = [];

end

function detailsStruct = makeStructTemplate(numEntries)

detailsStruct = struct('StudyDateTime', '', ...
    'SeriesDateTime', '', ...
    'PatientName', '', ...
    'PatientSex', '', ...
    'Modality', '', ...
    'Rows', [], ...
    'Columns', [], ...
    'Channels', [], ...
    'Frames', [], ...
    'StudyDescription', '', ...
    'SeriesDescription', '', ...
    'StudyInstanceUID', '', ...
    'SeriesInstanceUID', '', ...
    'InstanceUID', '', ...
    'Filenames', {});

if (numEntries > 1)
    detailsStruct(numEntries).StudyDateTime = '';
end
end

function dateTimeObject = getDateTimeFromParts(datePart, timePart)

if isempty(datePart) && isempty(timePart)
    dateTimeObject = [];
    return
elseif isempty(datePart) || isempty(timePart)
    dateTimeStr = [datePart timePart];
else
    dateTimeStr = [datePart 'T' timePart];
end

possibleFormats = {'yyyyMMdd''T''HHmmss', ...
    'yyyyMMdd''T''HHmmss.S', ...
    'yyyyMMdd''T''HHmm', ...
    'yyyy.MM.dd''T''HH:mm:ss.S', ...
    'yyyy.MM.dd''T''HH:mm:ss', ...
    'yyyyMMdd', ...
    'HHmmss'};

dateTimeObject = dateTimeStr;
for fmt = possibleFormats
    try
        dateTimeObject = datetime(dateTimeStr, 'InputFormat', fmt{1});
        
        switch fmt
        case 'HHmmss'
            % Make time-only dateTimes occur on 1-Jan-0000 (not a real date).
            timePart = dateTimeObject - datetime('today');
            dateTimeObject = datetime(0,1,1) + timePart;
        end
        break
    catch
        continue
    end
end
end

function sizes = getSizes(thisFile)

rows = thisFile.getAttributeByName('Rows');
if isempty(rows)
    rows = 0;
end

columns = thisFile.getAttributeByName('Columns');
if isempty(columns)
    columns = 0;
end

channels = thisFile.getAttributeByName('SamplesPerPixel');
if isempty(channels)
    channels = 0;
end

try
    frames = thisFile.getAttributeByName('NumberOfFrames');
    if isempty(frames)
        frames = 1;
    end
catch
    frames = 1;
end

sizes = double([rows columns channels frames]);

end

function uid = getInstanceUID(theFile)

uid = handleEmpty(theFile.getAttribute(2,3));  % (0002,0003) MediaStorageSOPInstanceUID
if isempty(uid)
    uid = handleEmpty(theFile.getAttribute(8,24));  % (0008,0018) SOPInstanceUID
end
end

function fileDetails = removeDuplicateImages(fileDetails)

allUIDs = {fileDetails.InstanceUID};
[allUIDs, hasUID] = removeMissingUIDs(allUIDs);

fileDetailsWithoutUIDs = fileDetails(~hasUID);
fileDetailsWithUIDs = fileDetails(hasUID);

[~, uniqueIndices, ~] = unique(allUIDs);
fileDetails = cat(2, fileDetailsWithUIDs(uniqueIndices), fileDetailsWithoutUIDs);

end

function seriesDetails = aggregateBySeries(fileDetails)

% Do not aggregate files that do not have a SeriesInstanceUID value or that
% contain multiple frames within one file. (The latter is legitimate but
% rare, probably because it makes things like this difficult.)

allNumFrames = [fileDetails.Frames];
multiFrameInOneFile = allNumFrames ~= 1;

detailsToPassThroughUnchanged = fileDetails(multiFrameInOneFile);
fileDetails = fileDetails(~multiFrameInOneFile);

allSeriesInstanceUIDs = {fileDetails.SeriesInstanceUID};
[allSeriesInstanceUIDs, hasUID] = removeMissingUIDs(allSeriesInstanceUIDs);

detailsToPassThroughUnchanged = cat(2, detailsToPassThroughUnchanged, fileDetails(~hasUID));
filesToAggregate = fileDetails(hasUID);

[~, uniqueIndices, mapBackIndices] = unique(allSeriesInstanceUIDs);
uniqueIndices = reshape(uniqueIndices, 1, []);
mapBackIndices = reshape(mapBackIndices, 1, []);
seriesDetails = filesToAggregate(uniqueIndices);

seriesCount = 1;
for idx = uniqueIndices
    outputIndex = mapBackIndices(idx);
    partOfTheSeries = mapBackIndices == outputIndex;
    seriesDetails(outputIndex).Filenames = cat(1, filesToAggregate(partOfTheSeries).Filenames);
    
    seriesDetails(outputIndex).Frames = max(...
        seriesDetails(outputIndex).Frames, ...
        numel(seriesDetails(outputIndex).Filenames));
    
    seriesCount = seriesCount + 1;
end

seriesDetails = cat(2, seriesDetails, detailsToPassThroughUnchanged);

end

function detailsTable = convertToTable(seriesDetails)

detailsTable = struct2table(seriesDetails, 'AsArray', true);

end

function [allSeriesInstanceUIDs, hasUID] = removeMissingUIDs(allSeriesInstanceUIDs)

hasUID = true(size(allSeriesInstanceUIDs));
for idx = 1:numel(allSeriesInstanceUIDs)
    hasUID(idx) = ~isempty(allSeriesInstanceUIDs{idx});
end

allSeriesInstanceUIDs = allSeriesInstanceUIDs(hasUID);

end

function tf = isDICOMDIR(source)

if (isa(source, 'images.internal.dicom.DICOMFile'))
    fileObject = source;
else
    try
        fileObject = images.internal.dicom.DICOMFile(source);
    catch
        tf = false;
        return
    end
end

switch fileObject.getAttribute(2,2)  % MediaStorageSOPClassUID
case '1.2.840.10008.1.3.10'
    tf = true;
otherwise
    tf = false;
end
end

function out = handleEmpty(in)

if isempty(in)
    out = '';
else
    out = in;
end
end
