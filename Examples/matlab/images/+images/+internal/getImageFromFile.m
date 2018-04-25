function [img,map] = getImageFromFile(filename)
%getImageFromFile retrieves image from file

%   Copyright 2006-2017 The MathWorks, Inc.  

filename = matlab.images.internal.stringToChar(filename);

if ~ischar(filename)
  error('images:getImageFromFile:invalidType', '%s',getString(message('MATLAB:images:getImageFromFile:invalidType')))
end

if ~exist(filename, 'file')
  error('images:getImageFromFile:fileDoesNotExist', '%s',getString(message('MATLAB:images:getImageFromFile:fileDoesNotExist', filename)))
end

try
  img_info = [];  % Assign empty, so that it's initialized if imfinfo fails.
  img_info = imfinfo(filename);
  [img,map] = imread(filename);
  if numel(img_info) > 1
      warning('images:getImageFromFile:multiframeFile', '%s',getString(message('MATLAB:images:getImageFromFile:multiframeFile', filename)))
  end
  
catch ME
        
    is_tif = ~isempty(img_info) && ...
            isfield(img_info(1),'Format') && ...
            strcmpi(img_info(1).Format,'tif');
        
    % Two different exceptions may be thrown as a result of an out of
    % memory state when reading a TIF file.
    % If rtifc fails in mxCreateNumericArray, MATLAB:nomem is thrown. If rtifc
    % fails in mxCreateUninitNumericArray, then MATLAB:pmaxsize is thrown.
    tif_out_of_memory = is_tif &&...
            ( strcmp(ME.identifier,'MATLAB:nomem') ||...
              strcmp(ME.identifier,'MATLAB:pmaxsize'));
    
    % suggest rsets if they ran out of memory with a tif file    
    if tif_out_of_memory && images.internal.isIPTInstalled

        outOfMemTifException = MException('images:getImageFromFile:OutOfMemTif',...
            getString(message('MATLAB:images:getImageFromFile:OutOfMemTif')));
        throw(outOfMemTifException);
    end
    
    if (isdicom(filename))
        if(images.internal.isIPTInstalled)
            img_info = dicominfo(filename);
            if isfield(img_info,'NumberOfFrames')
                [img,map] = dicomread(img_info,'Frames',1);
                warning('images:getImageFromFile:multiframeFile', '%s',getString(message('MATLAB:images:getImageFromFile:multiframeFile', filename)))
            else
                [img,map] = dicomread(img_info);
            end
        else
            error('images:imshow:requiresIPT', '%s',getString(message('MATLAB:images:imshow:requiresIPT')));
        end
        
    elseif (isnitf(filename))
        if(images.internal.isIPTInstalled)
            [tf, eid, msg] = iptui.isNitfSupported(filename);
            if (~tf)
                throw(MException(eid, msg));
            end
            
            img = nitfread(filename);
            map = [];
        else
            error('images:imshow:requiresIPT', '%s',getString(message('MATLAB:images:imshow:requiresIPT')));
        end
    else
        
        % unknown error, re-throw original exception from imfinfo/imread
        rethrow(ME);
        
    end

end    

