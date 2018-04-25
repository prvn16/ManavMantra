function [fragments, frames] = dicom_encode_jpeg_lossless(X, bits)
%DICOM_ENCODE_JPEG_LOSSLESS   Encode pixel cells using lossless JPEG.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG_LOSSLES(X) compresses and
%   encodes the image X using baseline lossles JPEG compression.
%   FRAGMENTS is a cell array containing the encoded frames (as UINT8
%   data) from the compressor.  LIST is a vector of indices to the first
%   fragment of each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE, DICOM_ENCODE_JPEG_LOSSY.

%   Copyright 1993-2010 The MathWorks, Inc.


% Use IMWRITE to create a JPEG image.

classname = class(X);

switch (classname)
case {'int8', 'int16'}
    tmp = images.internal.dicom.typecast(X(:), ['u' classname]);
    X = reshape(tmp, size(X));
end

numFrames = size(X,4);
fragments = cell(numFrames, 1);
frames = 1:numFrames;

for p = 1:numFrames
  
    tempfile = tempname;
    imwrite(X(:,:,:,p), tempfile, 'jpeg', 'mode', 'lossless', 'bitdepth', bits);

    % Read the image from the temporary file.
    fid = fopen(tempfile, 'r');
    fragments{p} = fread(fid, inf, 'uint8=>uint8');
    fclose(fid);

    % Remove the temporary file.
    try
        delete(tempfile)
    catch
        warning(message('images:dicom_encode_jpeg_lossless:tempFileDelete', tempfile));
    end

end
 
