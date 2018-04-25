function [all_attrs, status] = dicom_copy_IOD(X, map, metadata, options, specificCharacterSet)
%DICOM_COPY_IOD  Copy attributes from metadata to an arbitrary IOD.
%   [ATTRS, STATUS] = DICOM_COPY_IOD(X, MAP, METADATA, OPTIONS) creates
%   a structure array of DICOM attributes for an arbitrary SOP class
%   corresponding to the class contained in the metadata structure.  The
%   value of image pixel attributes are derived from the image X and the
%   colormap MAP.  Non-image attributes are derived from the METADATA
%   struct (typically given by DICOMINFO) and the transfer syntax UID
%   (OPTIONS.txfr).
%
%   NOTE: This routine does not verify that attributes in METADATA belong
%   in the information object.  A risk exists that invalid data passed to
%   this routine will lead to formally correct DICOM files that contain
%   incomplete or nonsensical data.
%
%   See also: DICOMWRITE, DICOM_CREATE_IOD.

%   Copyright 1993-2015 The MathWorks, Inc.

dictionary = dicomdict('get_current');

all_attrs = [];
status = [];

% Determine what kind of object to write.
IOD_UID = getIOD(metadata, options, dictionary);

% Update the instance-specific and required metadata.
metadata = dicom_prep_SOPCommon(metadata, IOD_UID, dictionary);
metadata = dicom_prep_FileMetadata(metadata, IOD_UID, options.txfr, dictionary);
metadata = dicom_prep_ImagePixel(metadata, X, map, options.txfr, options.usemetadatabitdepths, dictionary);

% Get the metadata fields that need to be processed.
metadata_fields = fieldnames(metadata);
fields_to_write = remove_dicominfo_fields(metadata_fields);

% Process all of the remaining metadata
for p = 1:numel(fields_to_write)
    
    attr_name = fields_to_write{p};
    
    % Private tags have an odd group number.  Only write them if the
    % 'WritePrivate' option was true.
    tag = images.internal.dicom.tagLookup(attr_name, dictionary);
    if (isempty(tag)) || ((~options.writeprivate) && (rem(tag(1), 2) == 1))
        continue;
    end
    
    new_attr = dicom_convert_meta_to_attr(attr_name, metadata, dictionary, options.txfr, specificCharacterSet);
    all_attrs = cat(2, all_attrs, new_attr);
    
end



function fields_out = remove_dicominfo_fields(metadata_fields)
%REMOVE_DICOMINFO_FIELDS  Strip DICOMINFO-specific fields from metadata.

dicominfo_fields = get_dicominfo_fields;
fields_out = setdiff(metadata_fields, dicominfo_fields);



function fields = get_dicominfo_fields
%GET_DICOMINFO_FIELDS  Get a cell array of field names specific to DICOMINFO.

fields = {'Filename'
          'FileModDate'
          'FileSize'
          'Format'
          'FormatVersion'
          'Width'
          'Height'
          'BitDepth'
          'ColorType'
          'SelectedFrames'
          'FileStruct'
          'StartOfPixelData'};

      

function uidValue = getIOD(metadata, options, dictionary)

% A field containing the SOP Class UID is necessary for writing.
% Look for the fields (0002,0002) and/or (0008,0016) in the metadata
% and/or options.

% (0002,0002) is usually called "Media Storage SOP Class UID."  It's the
% file metadata version of (0008,0016).
MediaStorageUID_name = dicom_name_lookup('0002', '0002', dictionary);

if (isfield(metadata, MediaStorageUID_name))
    uidValue_0002_0002 = metadata.(MediaStorageUID_name);
else
    uidValue_0002_0002 = '';
end

% (0008,0016) is usually known as "SOP Class UID."
SOPClassUID_name = dicom_name_lookup('0008', '0016', dictionary);
if (isfield(options, 'sopclassuid'))
    
    uidValue_0008_0016 = options.sopclassuid;
    
else
    
    % Look for the SOP Class UID in the metadata under a different name.
    if (isfield(metadata, SOPClassUID_name))
        uidValue_0008_0016 = metadata.(SOPClassUID_name);
    else
        uidValue_0008_0016 = '';
    end
    
end

% Pick the value of the UID.
if (~isempty(uidValue_0002_0002) && isempty(uidValue_0008_0016))
    
    % Use the value of (0002,0002).
    uidValue = uidValue_0002_0002;
    
elseif (isempty(uidValue_0002_0002) && ~isempty(uidValue_0008_0016))
    
    % Use the value of (0008, 0016).
    uidValue = uidValue_0008_0016;
    
elseif (~isempty(uidValue_0002_0002) && ~isempty(uidValue_0008_0016))
    
    % If both Media Storage Class UID and SOP Class UID are present, they
    % must match.
    if isequal(uidValue_0002_0002, uidValue_0008_0016)
        uidValue = uidValue_0002_0002;
    else
        error(message('images:dicom_copy_IOD:iodMismatch', SOPClassUID_name, MediaStorageUID_name))
    end
    
else
    
    error(message('images:dicom_copy_IOD:missingSOPClassUID', SOPClassUID_name));
    
end
 
