function metadata = dicom_prep_SCImageEquipment(metadata, dictionary)
%DICOM_PREP_SCIMAGEEQUIPMENT  Set necessary values for Image Pixel module
%
%   See PS 3.3 Sec C.8.1

%   Copyright 1993-2010 The MathWorks, Inc.

name = dicom_name_lookup('0008', '0064', dictionary);
if (~isfield(metadata, name))
    metadata(1).(name) = 'WSD';
end

name = dicom_name_lookup('0018', '1016', dictionary);
if (~isfield(metadata, name))
    metadata.(name) = 'MathWorks';
end

name = dicom_name_lookup('0018', '1018', dictionary);
if (~isfield(metadata, name))
    metadata.(name) = 'MATLAB';
end

