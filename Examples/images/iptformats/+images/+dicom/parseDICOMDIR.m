function dicomdir = parseDICOMDIR(filename)
%parseDICOMDIR Extract metadata from DICOMDIR file.
%   DICOMDIR = parseDICOMDIR(FILENAME) extracts the metadata from the
%   DICOMDIR file named in FILENAME. If FILENAME is not a DICOMDIR, an
%   error is issued.
%
%   Example:
%   --------
%   detailsStruct = images.dicom.parseDICOMDIR('DICOMDIR');
%
%   See also dicominfo.

% Copyright 2016-2017 The MathWorks, Inc.

% HOW THIS FUNCTION WORKS:
% ========================
% DICOMDIR metadata is contained inside a DirectoryRecordSequence (0004,1220)
% attribute at the root level of the DICOM file. Each item within that
% (flattened) sequence is a node in the tree that describes the patients,
% studies, series, images/files, etc.
%
% These items have a DirectoryRecordType (0004,1430) attribute that tells
% the kind of node as well as other details about the node. These values go
% into the "Payload" field of the output structure. The overall hierarchy
% is represented in the Patients, Studies, Series, Images, etc. fields of
% the output structure. Each of these fields can be an array of structs.

validateattributes(filename, {'cell','char','string'}, {'nonempty','scalartext'})

filename = matlab.images.internal.stringToChar(filename);
metadataObj = images.internal.dicom.DICOMFile(filename);

dicomdir = convertMetadata(metadataObj);

end


function dicomdir = convertMetadata(metadataObj)

directorySQ = metadataObj.getAttribute(4, 4640);  % (0004,1220) - DirectoryRecordSequence

if isempty(directorySQ)
    error(message('images:parseDICOMDIR:missingDirectorySequence'))
end

numEntries = numel(fieldnames(directorySQ));
dicomdir = struct([]);

for index = 1:numEntries
    itemName = sprintf('Item_%d', index);
    thisEntry = directorySQ.(itemName);
    dicomdir = addEntryToDirectory(dicomdir, thisEntry);
end
end


function dicomdir = addEntryToDirectory(dicomdir, thisEntry)

persistent attributeName
if isempty(attributeName)
    attributeName = images.internal.dicom.lookupActions(4, 5168, dicomdict('get'));  % (0004,1430) - DirectoryRecordType
end
recordType = thisEntry.(attributeName);

if strcmp(recordType, 'PRIVATE')
    return
end

dicomdir = allocateFieldsRecursively(dicomdir, recordType);

[structFieldName, parentType] = findInTypeCatalog(recordType);

if isempty(parentType)
    dicomdir.(structFieldName)(end+1).Payload = thisEntry;
else
    switch (parentType)
        case 'PATIENT'
            dicomdir.Patients(end).(structFieldName)(end+1).Payload = thisEntry;
        case 'STUDY'
            dicomdir.Patients(end).Studies(end).(structFieldName)(end+1).Payload = thisEntry;
        case 'SERIES'
            dicomdir.Patients(end).Studies(end).Series(end).(structFieldName)(end+1).Payload = thisEntry;
        otherwise
            % Treat as unknown/private.
            return
    end
end

% Preallocate subdirectories we care about.
switch (recordType)
    case 'PATIENT'
        dicomdir.Patients(end).Studies = struct([]);
    case 'STUDY'
        dicomdir.Patients(end).Studies(end).Series = struct([]);
    case 'SERIES'
        dicomdir.Patients(end).Studies(end).Series(end).Images = struct([]);
end
end


function dicomdir = allocateFieldsRecursively(dicomdir, thisType)

[structFieldName, parent] = findInTypeCatalog(thisType);

if isempty(parent)
    if ~isfield(dicomdir, structFieldName)
        dicomdir(1).(structFieldName) = struct([]);
    end
    return
end

dicomdir = allocateFieldsRecursively(dicomdir, parent);

switch (parent)
    case 'PATIENT'
        if ~isfield(dicomdir.Patients(end), structFieldName)
            dicomdir.Patients(end).(structFieldName) = struct([]);
        end
    case 'STUDY'
        if ~isfield(dicomdir.Patients(end).Studies(end), structFieldName)
            dicomdir.Patients(end).Studies(end).(structFieldName) = struct([]);
        end
    case 'SERIES'
        if ~isfield(dicomdir.Patients(end).Studies(end).Series(end), structFieldName)
            dicomdir.Patients(end).Studies(end).Series(end).(structFieldName) = struct([]);
        end
    otherwise
end
end


function [structFieldName, parent] = findInTypeCatalog(thisType)

typeCatalog = getTypeCatalog();
allTypes = typeCatalog(:,1);

rowIndex = strmatch(thisType, allTypes); %#ok<MATCH2>
if isempty(rowIndex)
    structFieldName = '';
    parent = '';
else
    structFieldName = typeCatalog{rowIndex, 2};
    parent = typeCatalog{rowIndex, 3};
end
end


function typeCatalog = getTypeCatalog

persistent localTypeCatalog
if isempty(localTypeCatalog)

    typeCatalogStandard = {... % Based on PS3.3 2016e Table F.4-1.
        'PATIENT', 'Patients', []
        'STUDY', 'Studies', 'PATIENT'
        'SERIES', 'Series', 'STUDY'
        'IMAGE', 'Images', 'SERIES'
        'RT DOSE', 'RTDoses', 'SERIES'
        'RT STRUCTURE SET', 'RTStructureSets', 'SERIES'
        'RT PLAN', 'RTPlans', 'SERIES'
        'RT TREAT RECORD', 'RTTreatRecords', 'SERIES'
        'PRESENTATION', 'Presentations', 'SERIES'
        'WAVEFORM', 'Waveforms', 'SERIES'
        'SR DOCUMENT', 'SRDocuments', 'SERIES'
        'KEY OBJECT DOC', 'KeyObjectDocs', 'SERIES'
        'SPECTROSCOPY', 'Spectroscopy', 'SERIES'
        'RAW DATA', 'RawData', 'SERIES'
        'REGISTRATION', 'Registrations', 'SERIES'
        'FIDUCIAL', 'Fiducials', 'SERIES'
        'HANGING PROTOCOL', 'HangingProtocols', []
        'ENCAP DOC', 'EncapDocs', 'SERIES'
        'HL7 STRUC DOC', 'HL7StrucDocs', 'PATIENT'
        'VALUE MAP', 'ValueMaps', 'SERIES'
        'STEREOMETRIC', 'Stereometrics', 'SERIES'
        'PALETTE', 'Palettes', []
        'IMPLANT', 'Implants', []
        'IMPLANT ASSY', 'ImplantAssemblies', []
        'IMPLANT GROUP', 'ImplantGroups', []
        'PLAN', 'Plans', 'SERIES'
        'MEASUREMENT', 'Measurements', 'SERIES'
        'SURFACE', 'Surfaces', 'SERIES'
        'SURFACE SCAN', 'SurfaceScans', 'SERIES'
        'TRACT', 'Tracts', 'SERIES'
        'ASSESSMENT', 'Assessments', 'SERIES'
        };

    % Older enumerated values from the same table in early revisions of the
    % standard.
    typeCatalogAdditional = {...
        'TOPIC', 'Topics', []
        'VISIT', 'Visits', 'STUDY'
        'STUDY COMPONENT', 'StudyComponents', 'STUDY'
        'OVERLAY', 'Overlays', 'SERIES'
        'MODALITY LUT', 'ModalityLUTs', 'SERIES'
        'VOI LUT', 'VOILUTs', 'SERIES'
        'CURVE', 'Curves', 'SERIES'
        'STORED PRINT', 'StoredPrints', 'SERIES'
        };
    
    localTypeCatalog = vertcat(typeCatalogStandard, typeCatalogAdditional);
end

typeCatalog = localTypeCatalog;

end
