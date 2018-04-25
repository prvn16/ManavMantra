function has_fmeta = dicom_has_fmeta(file)
%DICOM_HAS_FMETA  Determines whether a message contains file metadata.
%   TF = DICOM_HAS_FMETA(FILE) Returns 1 if FILE has file metadata, 0
%   otherwise.  File metadata are attributes whose groups are 2 - 7.

%   Copyright 1993-2010 The MathWorks, Inc.

fseek(file.FID, 128, 'bof');

if (ftell(file.FID) ~= 128)
    % File is too short to have 128 byte preamble: no file metadata.
    has_fmeta = false;
    fseek(file.FID, 0, 'bof');
    
    return
    
end

% Look for the format string 'DICM'.
fmt_string = fread(file.FID, 4, 'uchar');

has_fmeta = isequal(fmt_string, [68 73 67 77]');

% Very rarely a file will have file metadata but not a preamble.
if (~has_fmeta)
  
    has_fmeta = has_group0002_without_preamble(file);
    fseek(file.FID, 0, 'bof');
    
end



function tf = has_group0002_without_preamble(file)

fseek(file.FID, 0, 'bof');
group = fread(file.FID, 1, 'uint16=>uint16');

tf = ((group == 2) || (swapbytes(group) == 2));
