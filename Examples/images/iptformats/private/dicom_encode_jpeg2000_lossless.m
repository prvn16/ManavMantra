function [fragments, frames] = dicom_encode_jpeg2000_lossless(X, bits)
%DICOM_ENCODE_JPEG2000_LOSSLESS   Encode pixel cells using lossless JPEG.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG2000_LOSSLESS(X) compresses and
%   encodes the image X using lossless JPEG compression.  FRAGMENTS is
%   a cell array containing the encoded frames (as UINT 8data) from the
%   compressor.  LIST is a vector of indices to the first fragment of
%   each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE, DICOM_ENCODE_JPEG2000_LOSSY.

%   Copyright 2010 The MathWorks, Inc.


% Use IMWRITE to create a JPEG image.

numFrames = size(X,4);
fragments = cell(numFrames, 1);
frames = 1:numFrames;

for p = 1:numFrames
  
    tempfile = tempname;
    imwrite(X(:,:,:,p), tempfile, 'j2c', 'mode', 'lossless');

    % Read the image from the temporary file.
    fid = fopen(tempfile, 'r');
    fragments{p} = fread(fid, inf, 'uint8=>uint8');
    fclose(fid);

    % Remove the temporary file.
    try
        delete(tempfile)
    catch
        warning(message('images:dicom_encode_jpeg2000_lossless:tempFileDelete', tempfile));
    end

end
 
