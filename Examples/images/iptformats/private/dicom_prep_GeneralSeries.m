function metadata = dicom_prep_GeneralSeries(metadata, dictionary)
%DICOM_PREP_DICOM_PREP_GENERALSERIES  Fill values for General Study module.
%
%   See PS 3.3 Sec. C.7.2.1

%   Copyright 1993-2010 The MathWorks, Inc.

name = dicom_name_lookup('0008', '0060', dictionary);
if (~isfield(metadata, name))
    metadata.(name) = 'OT';
end

name = dicom_name_lookup('0020', '000E', dictionary);
if (~isfield(metadata, name))
    metadata.(name) = dicomuid;
end
