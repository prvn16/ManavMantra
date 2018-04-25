function metadata = dicom_prep_MRMultiFrame(metadata, X, txfr, dictionary)
%DICOM_PREP_MRMULTIFRAME  Set multi-frame frame pointer, etc.
%
%   See PS 3.3 Sec C.8.13.6

%   Copyright 2010 The MathWorks, Inc.

% Make sure that the Shared Functional Groups Sequnece and
% Per-frame Functional Groups Sequence attributes are provided.
% We can't make these values out of whole cloth.
if (~isfield(metadata, dicom_name_lookup('5200','9229', dictionary)))
  
    error(message('images:dicom_prep_MRMultiFrame:missingSharedSequence', dicom_name_lookup( '5200', '9229', dictionary )))
    
elseif (~isfield(metadata, dicom_name_lookup('5200','9230', dictionary)))
  
    error(message('images:dicom_prep_MRMultiFrame:missingPerFrameSequence', dicom_name_lookup( '5200', '9230', dictionary )))

elseif (~isfield(metadata, dicom_name_lookup('0008','0008', dictionary)))
  
    error(message('images:dicom_prep_MRMultiFrame:missingImageType', dicom_name_lookup( '0008', '0008', dictionary )))
    
end


numFrames = size(X,4);
% MultiFrame - C.7.6.6
if (numFrames > 1)
    metadata.(dicom_name_lookup('0028', '0008', dictionary)) = size(X,4);
end


% Make sure that (0028,0009) has a value.
framePointerName = dicom_name_lookup('0028', '0009', dictionary);
if (~isfield(metadata, framePointerName))

    % To Do.  Fill this.

end


% Fill what values we can invent if they're missing.
if (~isfield(metadata, dicom_name_lookup('0020','0013', dictionary)))  % Instance number

    metadata.(dicom_name_lookup('0020','0013', dictionary)) = '1';
  
end

when = now;

if (~isfield(metadata, dicom_name_lookup('0008','0023', dictionary)))  % Content date

    metadata.(dicom_name_lookup('0008','0023', dictionary)) = datestr(when, 'yyyymmdd');
    
end

if (~isfield(metadata, dicom_name_lookup('0008','0033', dictionary)))  % Content time

    metadata.(dicom_name_lookup('0008','0033', dictionary)) = datestr(when, 'HHMMSS');
  
end

details = dicom_uid_decode(txfr);
if (hasLossyCompression(details, metadata, dictionary))
  
    metadata.(dicom_name_lookup('0028','2110', dictionary)) = '01';
    metadata.(dicom_name_lookup('0028','2114', dictionary)) = details.CompressionType;
    
else
  
    metadata.(dicom_name_lookup('0028','2110', dictionary)) = '00';
    
end


if (isequal(metadata.(dicom_name_lookup('0028','0004', dictionary)), ...
            'MONOCHROME2'))
  
    metadata.(dicom_name_lookup('2050', '0020', dictionary)) = 'IDENTITY';
    
end



function tf = hasLossyCompression(details, metadata, dictionary)

lossyAttrName = dicom_name_lookup('0028','2110', dictionary);

if (details.LossyCompression)
  
  % This compression will be lossy.
  tf = true;
  
elseif (isfield(metadata, lossyAttrName))
  
  % Lossy-ness can't be shaken.  It has to be passed along.
  tf = isequal(metadata.(lossyAttrName), '01');
       
else
  
  tf = false;
  
end
 
