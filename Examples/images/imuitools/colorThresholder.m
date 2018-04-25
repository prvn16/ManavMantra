function colorThresholder(RGB)
%colorThresholder Threshold color image.
%   colorThresholder opens a color image thresholding app. The app can be
%   used to create a segmentation mask to a color image based on the
%   exploration of different color spaces.
%
%   colorThresholder(RGB) loads the truecolor image RGB into a color
%   thresholding app.
%
%   colorThresholder CLOSE closes all open color thresholder apps.
%
%   Class Support
%   -------------
%   RGB is a truecolor image of class uint8, uint16, single, or double.
%
%   See also imcontrast

%   Copyright 2013-2016 The MathWorks, Inc.

if nargin > 0
    RGB = convertStringsToChars(RGB);
end

if nargin == 0
    % Create a new Color Segmentation app.
    iptui.internal.ColorSegmentationTool();
else
    if ischar(RGB)
        % Handle the 'close' request
        validatestring(RGB, {'close'}, mfilename);
        iptui.internal.ColorSegmentationTool.deleteAllTools(); 
    else
        supportedImageClasses = {'uint8','uint16','single','double'};
        supportedImageAttributes = {'real','nonsparse','nonempty','ndims',3};
        validateattributes(RGB,supportedImageClasses,supportedImageAttributes,'colorSegmentor','RGB');
        
        if size(RGB,3) ~= 3
            error(message('images:colorSegmentor:requireRGBInput'));
        end
        
        iptui.internal.ColorSegmentationTool(RGB);
    end
        
end
