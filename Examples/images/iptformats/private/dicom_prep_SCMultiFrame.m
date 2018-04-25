function metadata = dicom_prep_SCMultiFrame(metadata, X, dictionary)
%DICOM_PREP_SCMULTIFRAME  Set multi-frame frame pointer, etc.
%
%   See PS 3.3 Sec C.8.6.4

%   Copyright 2010 The MathWorks, Inc.

numFrames = size(X,4);
% MultiFrame - C.7.6.6
if (numFrames > 1)
    metadata.(dicom_name_lookup('0028', '0008', dictionary)) = size(X,4);
end


% Make sure that (0028,0009) has a value.
framePointerName = dicom_name_lookup('0028', '0009', dictionary);
if (~isfield(metadata, framePointerName))
  
    % The most generic thing we can do is create values for
    % (0018,2002) "Frame Label Vector."
    value = sprintf('Frame %d\\', 1:numFrames);
    value(end) = '';  % Remove trailing slash.

    metadata.(dicom_name_lookup('0018', '2002', dictionary)) = value;
    
    % Make (0028,0009) point at (0018,2002).
    metadata.(framePointerName) = uint16(sscanf('0018,2002', '%x,%x'));
    
end
 
