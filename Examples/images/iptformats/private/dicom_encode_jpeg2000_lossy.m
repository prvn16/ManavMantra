function [fragments, frames] = dicom_encode_jpeg2000_lossy(X, bits)
%DICOM_ENCODE_JPEG2000_LOSSY   Encode pixel cells using lossy JPEG.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG2000_LOSSY(X) compresses and
%   encodes the image X using lossy JPEG2000 compression.  FRAGMENTS is
%   a cell array containing the encoded frames (as UINT8 data) from the
%   compressor.  LIST is a vector of indices to the first fragment of
%   each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE, DICOM_ENCODE_JPEG2000_LOSSY.

%   Copyright 2010 The MathWorks, Inc.


% Use IMWRITE to create a JPEG2000 image.

numFrames = size(X,4);
fragments = cell(numFrames, 1);
frames = 1:numFrames;

for p = 1:numFrames
  
    tempfile = tempname;
    imwrite(X(:,:,:,p), tempfile, 'j2c', 'mode', 'lossy');

    % Read the image from the temporary file.
    fid = fopen(tempfile, 'r');
    fragments{p} = fread(fid, inf, 'uint8=>uint8');
    fclose(fid);

    % Remove the temporary file.
    try
        delete(tempfile)
    catch
        warning(message('images:dicom_encode_jpeg2000_lossy:tempFileDelete', tempfile));
    end

end
 
