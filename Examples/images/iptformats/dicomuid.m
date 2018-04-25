function uid = dicomuid
%DICOMUID   Generate DICOM Unique Identifier.
%   UID = DICOMUID creates a character vector, UID, containing a new DICOM unique
%   identifier.
%
%   Multiple calls to DICOMUID will produce globally unique values.  Two
%   calls to DICOMUID will always return different values.
%
%   See also dicomwrite, dicomanon, dicominfo, images.dicom.decodeUID.

%   Copyright 1993-2017 The MathWorks, Inc.
%   

uid = dicom_generate_uid('instance');
