function imageSegmenter(I)
%imageSegmenter Segment 2D grayscale or RGB image.
%   imageSegmenter opens an image segmentation app. The app can be used to
%   create and refine a segmentation mask to a 2D grayscale or RGB image
%   using techniques like thresholding, flood-filling, active contours,
%   graph cuts and morphological processing.
%
%   imageSegmenter(I) loads the grayscale or RGB image I into an image
%   segmentation app.
%
%   imageSegmenter CLOSE closes all open image segmentation apps.
%
%   Class Support
%   -------------
%   I is an image of class uint8, int16, uint16, single, or double.
%
%   See also imbinarize, activecontour, grayconnected, lazysnapping.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin == 0
    % Create a new Image Segmentation app.
    iptui.internal.segmenter.ImageSegmentationTool();
else
    I = matlab.images.internal.stringToChar(I);
    if ischar(I)
        % Handle the 'close' request
        validatestring(I, {'close'}, mfilename);
        iptui.internal.segmenter.ImageSegmentationTool.deleteAllTools();
    else
        supportedImageClasses    = {'uint8','int16','uint16','single','double'};
        supportedImageAttributes = {'real','nonsparse','nonempty'};
        validateattributes(I,supportedImageClasses,supportedImageAttributes,mfilename,'I');
        
        % If image is RGB, issue warning and convert to grayscale.
        isRGB = ndims(I)==3 && size(I,3)==3;
        if ~isRGB && ~ismatrix(I)
            % If image is not 2D grayscale or RGB, error.    
            error(message('images:imageSegmenter:expectedGray'));
        end
        
        if isa(I,'int16') && isRGB
            error(message('images:imageSegmenter:nonGrayErrorDlgMessage'));
        end
        
        iptui.internal.segmenter.ImageSegmentationTool(I,isRGB);
    end
        
end
