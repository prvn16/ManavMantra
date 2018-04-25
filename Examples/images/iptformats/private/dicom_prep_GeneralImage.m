function metadata = dicom_prep_GeneralImage(metadata, dictionary)
%DICOM_PREP_GENERALIMAGE  Set necessary values for General Image module
%
%   See PS 3.3 Sec C.7.6.1

%   Copyright 1993-2010 The MathWorks, Inc.
%   

image_time = now;

ImageDate_name = dicom_name_lookup('0008', '0023', dictionary);
ImageTime_name = dicom_name_lookup('0008', '0033', dictionary);

if (~isfield(metadata, ImageDate_name))
    metadata.(ImageDate_name) = convert_date(image_time, 'DA');
end

if (~isfield(metadata, ImageTime_name))
    metadata.(ImageTime_name) = convert_date(image_time, 'TM');
end



function dicomDate = convert_date(ML_date, formatString)
%CONVERT_DATE   Convert a MATLAB datenum to a DICOM date/time string
%
%   See PS 3.5 Sec. 6.2 for DICOM date/time formats.

vec = datevec(ML_date);

switch (formatString)
case 'DA'
    % YYYYMMDD
    dicomDate = sprintf('%04d%02d%02d', vec(1:3));
case 'DT'
    % YYYYMMDDHHMMSS.FFFFFF
    dicomDate = sprintf('%04d%02d%02d%02d%02d%09.6f', vec);
case 'TM'
    %HHMMSS.FFFFFF
    dicomDate = sprintf('%02d%02d%09.6f', vec(4:6));
end
