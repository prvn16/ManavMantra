function im = getimagemodel(hImage)
%GETIMAGEMODEL Get image model object from image object.
%   IMGMODEL = GETIMAGEMODEL(HIMAGE) returns the image model 
%   object associated with HIMAGE. HIMAGE must be a handle to 
%   an image object or an array of handles to image objects. 
%
%   The return value IMGMODEL is an image model object. If 
%   HIMAGE is an array of handles to image objects, IMGMODEL
%   is an array of image models. 
%
%   If HIMAGE does not have an associated image model object,
%   GETIMAGEMODEL creates one.
%
%   Example
%   -------
%
%       h = imshow('bag.png');
%       imgmodel = getimagemodel(h);
%  
%   See also IMAGEMODEL.

%   Copyright 1993-2005 The MathWorks, Inc.
%   
  
numHandles = length(hImage);
im = repmat(imagemodel,1,numHandles);

for k = 1:numHandles
  oneim = getappdata(hImage(k),'imagemodel');
  if isempty(oneim)
    oneim = imagemodel(hImage(k));
    setappdata(hImage(k),'imagemodel',oneim);
  end
  im(k) = oneim;
end
