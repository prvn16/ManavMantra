function [fragments, frames] = dicom_encode_jpeg_lossy(X, bits)
%DICOM_ENCODE_JPEG_LOSSY   Encode pixel cells using lossy JPEG compression.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG_LOSSY(X) compresses and encodes
%   the image X using baseline lossy JPEG compression.  FRAGMENTS is a
%   cell array containing the encoded frames (as UINT8 data) from the
%   compressor.  LIST is a vector of indices to the first fragment of
%   each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE, DICOM_ENCODE_JPEG_LOSSLESS.

%   Copyright 1993-2011 The MathWorks, Inc.

% Because lossy JPEG compression of signed data doesn't make sense,
% error.  See PS 3.5 Sec. 8.2.1.
X = convertSigned(X);

% Use IMWRITE to create a JPEG image, but don't warn about signed data.

numFrames = size(X,4);
fragments = cell(numFrames, 1);
frames = 1:numFrames;

% The maximum bit-depth for lossy JPEG is 12 bits/sample.
if (bits > 12)
    bits = 12;
end

if (max(X(:)) >= 4096)
    warning(message('images:dicom_encode_jpeg_lossy:sampleTooLarge', sprintf( '%ld', max( X( : ) ) )))
end

% Write each frame.
for p = 1:numFrames

    tempfile = tempname;
    imwrite(X(:,:,:,p), tempfile, 'jpeg', 'bitdepth', bits);
    
    % Read the image from the temporary file.
    fid = fopen(tempfile, 'r');
    fragments{p} = fread(fid, inf, 'uint8=>uint8');
    fclose(fid);

    % Remove the temporary file.
    try
        delete(tempfile)
    catch  %#ok<CTCH>
        warning(message('images:dicom_encode_jpeg_lossy:tempFileDelete', tempfile));
    end

end


function X = convertSigned(X)
% Image has signed data.

if (~isConvertible(X))
      
    error(message('images:dicom_encode_jpeg_lossy:signedData'))
    
end

switch (class(X))
case 'int8'
    
    X = uint8(X);
    
case 'int16'
    
    X = uint16(X);
    
case 'int32'
    
    X = uint32(X);
    
case 'int64'
    
    X = uint8(X);
    
otherwise
    
    % No op.
        
end



function tf = isConvertible(X)

%We can silently convert any type where all of the values are nonnegative.
tf = ~(any(X(:) < 0));