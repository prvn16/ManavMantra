function writeImage(imgFilename,imageFormat,myFrame,imHeight,imWidth,comment)

% Copyright 1984-2015 The MathWorks, Inc.

x = myFrame.cdata;
map = myFrame.colormap;

% Removing 3rd argument changes behavior of SIZE.
[height,width,~] = size(x);

if ~isempty(imHeight) && (height > imHeight) || ...
        ~isempty(imWidth) && (width > imWidth)
    if ~isempty(map)
        % Convert indexed images to RGB before resizing.
        x = ind2rgb(x,map);
        map = [];
    end
    if ~isempty(imHeight) && (height > imHeight)
        width = width*(imHeight/height);
        height = imHeight;
    end
    if ~isempty(imWidth) && (width > imWidth)
        height = height*(imWidth/width);
        width = imWidth;
    end
    if isequal(class(x),'double')
        x = uint8(floor(x*255));
    end
    newDims = max(floor([height width]),[1 1]);
    x = internal.matlab.publish.make_thumbnail(x,newDims);
end

if exist('comment','var') && ~isempty(comment) && isequal(imageFormat,'png')
    if isempty(map)
        imwrite(x,imgFilename,imageFormat,'Comment', comment);
    else
        imwrite(x,map,imgFilename,imageFormat,'Comment', comment);
    end
else
    if isempty(map)
        imwrite(x,imgFilename,imageFormat);
    else
        imwrite(x,map,imgFilename,imageFormat);
    end
end
end

