function resizeIfNecessary(imgFilename,imageFormat,imWidth,imHeight,myFrame,comment)
% Copyright 1984-2017 The MathWorks, Inc.

% Resize the image.
switch imageFormat
    case internal.matlab.publish.getVectorFormats
        % Skip it.  PUBLISH throws a warning about this case.
    otherwise
        if nargin < 5 || isempty(myFrame)
           [myFrame.cdata, myFrame.colormap] = imread(imgFilename);
        end
        imgData = myFrame.cdata;
        scale = internal.matlab.publish.getImageScale();
        if scale > 1
            myFrame.cdata = imresize(imgData, 1/scale);
        end
        if nargin < 6
            comment = '';
        end
        internal.matlab.publish.writeImage(imgFilename,imageFormat,myFrame,imHeight,imWidth,comment);
end
end

