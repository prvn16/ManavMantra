function [C,RC] = imfuse(varargin)
%IMFUSE Composite of two images.
%   C = IMFUSE(A,B) creates a composite image of two images A and B. If A
%   and B are different sizes, the smaller dimensions are padded with zeros
%   such that the two images are the same size before computing the
%   composite. The output, C, is a numeric matrix containing a fused
%   version of images A and B.
%
%   [C,RC] = IMFUSE(A,RA,B,RB) creates a fused image C from the images A
%   and B using the spatial referencing information provided in RA and RB.
%   RA, RB, and RC are spatial referencing objects of class imref2d. The
%   output RC defines the spatial referencing information for the output
%   fused image C.
%
%   C = IMFUSE(___,METHOD) creates a fused image C from the images A
%   and B using the algorithm specified by METHOD.  Values of METHOD can
%   be:
%
%      'falsecolor'   : Create a composite RGB image showing A and B overlayed
%                       in different color bands. This is the default.
%      'blend'        : Overlay A and B using alpha blending.
%      'checkerboard' : Create image with alternating rectangular regions 
%                       from A and B.
%      'diff'         : Difference image created from A and B.
%      'montage'      : Put A and B next to each other in the same image.
%
%   IMFUSE(___,PARAM1,VAL1,PARAM2,VAL2,...) display the images,
%   specifying parameters and corresponding values that control various
%   aspects of display and blending.  Parameter name case does not matter.
%
%   Parameters include:
%
%   'Scaling'       Both images are converted to a common data type before
%                   being displayed.  Additional scaling of image data is
%                   controled by the 'Scaling' parameter of IMSHOWPAIR.
%
%                   Valid 'Scaling' values are:
%                      'independent' :  Images are scaled independently from
%                                       each other.
%                      'joint'       :  Images are scaled as a single data set.
%                                       This option can be useful when
%                                       visualizing registrations of
%                                       monomodal images in which one image
%                                       has a large amount of fill values
%                                       outside the dynamic range of your
%                                       images.
%                      'none'        :  No additional scaling.
%
%                                       Default value: 'independent'
%
%   'ColorChannels' Assign each image to specific color channels in the
%                   output image.  This method can only be used with the
%                   'falsecolor' method.
%
%                   Valid 'ColorChannels' values are:
%                      [R G B]        :  A three element vector that
%                                         specifies which image to assign
%                                         to the red, green, and blue
%                                         channels.  The R, G, and B values
%                                         must be 1 (for the first input
%                                         image), 2 (for the second input
%                                         image), and 0 (for neither image).
%                      'red-cyan'      :  A shortcut for the vector [1 2 2],
%                                         which is suitable for red/cyan
%                                         stereo anaglyphs.
%                      'green-magenta' :  A shortcut for the vector [2 1 2],
%                                         which is a high contrast option
%                                         ideal for people with many kinds
%                                         of color blindness.
%
%                                         Default value: 'green-magenta'
%
%   Class Support
%   -------------
%   A and B are numeric arrays. The output C is a numeric array of class
%   uint8. RA, RB, and RC are spatial referencing objects of class imref2d.
%
%   Tips
%   ----
%   Use imfuse to create composite visualizations that you can save to a
%   file.  Use imshowpair to display composite visualizations to the
%   screen.
%
%   Examples
%   --------
%   % Two images with a rotation offset
%   A = imread('cameraman.tif');
%   B = imrotate(A,5,'bicubic','crop');
%   C = imfuse(A,B,'blend','Scaling','joint');
%   % Create a PNG file containing blended overlay image
%   imwrite(C,'my_blend_overlay.png');
%
%   % Use red for one image, green for the other, and yellow for areas of
%   % similar intensity between the two images.
%   A = imread('cameraman.tif');
%   B = imrotate(A,5,'bicubic','crop');
%   C = imfuse(A,B,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
%   % Create a PNG file containing the red/green/yellow image
%   imwrite(C,'my_blend_red-green.png');
%
%   % Create fused image of two spatially referenced images.
%   A = dicomread('knee1.dcm');
%   RA = imref2d(size(A));
%   B = imresize(A,2);
%   RB = imref2d(size(B));
%   RB.XWorldLimits = RA.XWorldLimits
%   RB.YWorldLimits = RA.YWorldLimits
%   % Images align even though B is twice the size of A because
%   % RA and RB define A and B as having the same extent in the world
%   % coordinate system
%   [C,RC] = imfuse(A,RA,B,RB);
%
%   See also IMREF, IMREGISTER, IMSHOWPAIR, IMTRANSFORM.

%   Copyright 2011-2016 The MathWorks, Inc.

% basic input validation
[A,B,RA,RB,method,options] = parse_inputs(varargin{:});

% pull P/V pairs out of options struct
scaling = options.Scaling;

AisRGB = size(A,3) > 1;
BisRGB = size(B,3) > 1;

[A,B,A_mask,B_mask,RC] = calculateOverlayImages(A,RA,B,RB);

% compute final image for display
switch (method)
    case 'blend'
        C = local_createBlend;
    case 'falsecolor'
        C = local_createRGB(options.ColorChannels);
    case 'diff'
        C = local_createDiff;
    case 'checkerboard'
        C = local_createCheckerboard;
    otherwise
        % montage
        C = local_createSideBySide;
        % Return empty spatial referencing object as signal to imshowpair to
        % ignore spatial referencing information.
        RC = imref2d.empty();
end

%-------------------------------------
%--------- Nested Function -----------
%-------------------------------------

    function result = local_createBlend
        % Creates a transparent overlay image
        
        % make the images similar in size and type
        [A,B] = makeSimilar(A,B,AisRGB,BisRGB,scaling);
        
        % compute regions of overlap
        onlyA = A_mask & ~B_mask;
        onlyB = ~A_mask & B_mask;
        bothAandB = A_mask & B_mask;
        
        % weight each image equally
        weight1 = 0.5;
        weight2 = 0.5;
        
        % allocate result image
        result = zeros([size(A,1) size(A,2) size(A,3)], class(A));
        
        % for each color band, compute blended output band
        for i = 1:size(A,3)
            a = A(:,:,i);
            b = B(:,:,i);
            r = result(:,:,i);
            r(onlyA) = a(onlyA);
            r(onlyB) = b(onlyB);
            r(bothAandB) = uint8( weight1 .* single(a(bothAandB)) + weight2 .* single(b(bothAandB)));
            result(:,:,i) = r;
        end
        
    end % local_createBlend


    function result = local_createRGB(channels)
        
        % convert any RGB images to grayscales
        if size(A,3) > 1
            A = rgb2gray(A);
        end
        if size(B,3) > 1
            B = rgb2gray(B);
        end
        
        switch lower(scaling)
            case 'none'
            case 'joint'
                [A,B] = scaleTwoGrayscaleImages(A,B);
            case 'independent'
                A = scaleGrayscaleImage(A);
                B = scaleGrayscaleImage(B);
        end
        A = im2uint8(A);
        B = im2uint8(B);
        
        % create anaglyph image
        result = zeros([size(A,1) size(A,2) 3], class(A));
        
        for p = 1:3
            if (channels(p) == 1)
                result(:,:,p) = A;
            elseif (channels(p) == 2)
                result(:,:,p) = B;
            end
        end
        
    end % local_createRGB


    function result = local_createDiff
        
        % convert any RGB images to grayscales
        if size(A,3) > 1
            A = rgb2gray(A);
        end
        if size(B,3) > 1
            B = rgb2gray(B);
        end
        
        switch lower(scaling)
            case 'none'
            case 'joint'
                [A,B] = scaleTwoGrayscaleImages(A,B);
            case 'independent'
                A = scaleGrayscaleImage(A);
                B = scaleGrayscaleImage(B);
        end
        
        % create difference image
        result = scaleGrayscaleImage(imabsdiff(single(A),single(B)));
        result = im2uint8(result);
        
    end % local_createDiff

    function result = local_createCheckerboard
        
        [A,B] = makeSimilar(A,B,AisRGB,BisRGB,scaling);
        
        sz = size(A);
        result = zeros(sz,'like',A);
        
        check = [1 0; 0 1];
        check = repmat(check,8);
        maskA = logical(imresize(check,sz(1:2),'nearest'));
        
        if size(A,3) > 1
            maskA = repmat(maskA,[1 1 3]);
        end
        maskB = ~maskA;
        
        result(maskA) = A(maskA);
        result(maskB) = B(maskB);
        
    end % local_createCheckerboard


    function result = local_createSideBySide
        
        % make the images similar in size and type
        [A,B] = makeSimilar(A,B,AisRGB,BisRGB,scaling);
        
        % create side by side image
        result = [A B];
        
    end


end % imshowpair


function [A,B] = makeSimilar(A,B,AisRGB,BisRGB,scaling)

% scale the images
if ~AisRGB && ~BisRGB
    % both are grayscale
    switch lower(scaling)
        case 'none'
        case 'joint'
            [A,B] = scaleTwoGrayscaleImages(A,B);
        case 'independent'
            A = scaleGrayscaleImage(A);
            B = scaleGrayscaleImage(B);
    end
    
elseif AisRGB && BisRGB
    % both are RGB
    
elseif AisRGB && ~BisRGB
    % convert B to pseudo RGB "gray" image
    if strcmpi(scaling,'None')
        B = repmat(im2uint8(B),[1 1 3]);
    else
        % Scale the sole grayscale image alone
        B = scaleGrayscaleImage(B);
        B = repmat(im2uint8(B),[1 1 3]);
    end
    
elseif ~AisRGB && BisRGB
    % convert A to pseudo RGB "gray" image
    if strcmpi(scaling,'None')
        A = repmat(im2uint8(A),[1 1 3]);
    else
        % Scale the sole grayscale image alone
        A = scaleGrayscaleImage(A);
        A = repmat(im2uint8(A),[1 1 3]);
    end
end

% convert to uint8
A = im2uint8(A);
B = im2uint8(B);

end % makeSimilar


%----------------------------------------------------
function image_data = scaleGrayscaleImage(image_data)

if (islogical(image_data))
    return
end

% convert to floating point
image_data = single(image_data);

% translate to put minimum at zero
image_data = image_data - min(image_data(:));

% scale to range [0 1]
image_data = image_data / max(image_data(:));

end % scaleGrayscaleImage


%--------------------------------------------
function [A, B] = scaleTwoGrayscaleImages(A,B)
% takes 2 same size images and scales them as a single dataset

% convert to floating point composite image
image_data = [single(A) single(B)];

% scale as a single image
image_data = scaleGrayscaleImage(image_data);

% split images
A = image_data(:,1:size(A,2),:);
B = image_data(:,size(A,2)+1:end,:);

end % scaleTwoGrayscaleImages



function [A_padded,B_padded,A_mask,B_mask,R_output] = calculateOverlayImages(A,RA,B,RB)

% First calculate output referencing object. World limits are minimum
% bounding box that contains world limits of both images. Resolution is the
% minimum resolution in each dimension. We don't want to down sample either
% image.
outputWorldLimitsX = [min(RA.XWorldLimits(1),RB.XWorldLimits(1)),...
                      max(RA.XWorldLimits(2),RB.XWorldLimits(2))];
                  
outputWorldLimitsY = [min(RA.YWorldLimits(1),RB.YWorldLimits(1)),...
                      max(RA.YWorldLimits(2),RB.YWorldLimits(2))];                 
                  
goalResolutionX = min(RA.PixelExtentInWorldX,RB.PixelExtentInWorldX);
goalResolutionY = min(RA.PixelExtentInWorldY,RB.PixelExtentInWorldY);

widthOutputRaster  = ceil(diff(outputWorldLimitsX) / goalResolutionX);
heightOutputRaster = ceil(diff(outputWorldLimitsY) / goalResolutionY);

R_output = imref2d([heightOutputRaster, widthOutputRaster]);
R_output.XWorldLimits = outputWorldLimitsX;
R_output.YWorldLimits = outputWorldLimitsY;

fillVal = 0;
A_padded = images.spatialref.internal.resampleImageToNewSpatialRef(A,RA,R_output,'bilinear',fillVal);
B_padded = images.spatialref.internal.resampleImageToNewSpatialRef(B,RB,R_output,'bilinear',fillVal);

[outputIntrinsicX,outputIntrinsicY] = meshgrid(1:R_output.ImageSize(2),1:R_output.ImageSize(1));
[xWorldOverlayLoc,yWorldOverlayLoc] = intrinsicToWorld(R_output,outputIntrinsicX,outputIntrinsicY);
A_mask = contains(RA,xWorldOverlayLoc,yWorldOverlayLoc);
B_mask = contains(RB,xWorldOverlayLoc,yWorldOverlayLoc);

end



function [Aref,Bref,varargin] = preparseSpatialRefObjects(varargin)

spatialRefPositions   = cellfun(@(c) isa(c,'imref2d'), varargin);

Aref = [];
Bref = [];

if ~any(spatialRefPositions)
    return
end

if ~isequal(find(spatialRefPositions), [2 4])
    error(message('images:imfuse:invalidSpatiallyReferencedSyntax','imref2d'));
end

spatialRef3DPositions   = cellfun(@(c) isa(c,'imref3d'), varargin);
if any(spatialRef3DPositions)
    error(message('images:imfuse:imref3dSpecified','imref3d'));
end

Aref = varargin{2};
Bref = varargin{4};
varargin([2 4]) = [];

end

%---------------------------------------------------------
function [A,B,A_ref,B_ref,method,options] = parse_inputs(varargin)

% We pre-parse spatial referencing objects before we start input parsing so that
% we can separate spatially referenced syntax from other syntaxes. 
[A_ref,B_ref,varargin] = preparseSpatialRefObjects(varargin{:});

checkStringInput = @(x,name) validateattributes(x, ...
    {'char','string'},{'scalartext'},mfilename,name);
parser = inputParser();
parser.addRequired('A',@checkA);
parser.addRequired('B',@checkB);
parser.addOptional('method','falsecolor',@checkMethod);
parser.addParameter('Scaling', 'independent', @(x) checkStringInput(x,'Scaling'));
parser.addParameter('ColorChannels', '', @checkColorChannels1);


% parse input
% Put method at function scope so that we can modify partial string matches
% and replace them with the full string when @checkMethod runs.
method = 'falsecolor';
parser.parse(varargin{:});

options.Scaling = checkScaling(parser.Results.Scaling);
options.ColorChannels = checkColorChannels2(parser.Results.ColorChannels);
A = parser.Results.A;
B = parser.Results.B;

% After parseing inputs, check consistency.
if (~isempty(options.ColorChannels) && ~strcmp(method, 'falsecolor'))
    error(message('images:imfuse:methodColorChannelCombo'))
end

% Use green-magenta as a default false-coloring.
if isempty(options.ColorChannels)
    options.ColorChannels = [2 1 2];
end

isSpatiallyReferencedSyntax = ~isempty(A_ref);

if isSpatiallyReferencedSyntax
    % If spatial referencing objects are user specified, make sure sizes
    % match the input image data.
    A_ref.sizesMatch(A);
    B_ref.sizesMatch(B);
else
    A_ref = imref2d(size(A));
    B_ref = imref2d(size(B));
end

    function TF = checkA(A)
        
        validateattributes(A,{'numeric','logical'},{'real','nonsparse','nonempty'},mfilename,'A')
        TF = true;
        
        A_bands = size(A,3);
        if (ndims(A) > 3) || ((A_bands ~= 1) && (A_bands ~= 3))
            error(message('images:imfuse:unsupportedDimension'));
        end
        
    end

    function TF = checkB(B)
        
        validateattributes(B,{'numeric','logical'},{'real','nonsparse','nonempty'},mfilename,'B')
        TF = true;
        
        B_bands = size(B,3);
        if (ndims(B) > 3) || ((B_bands ~= 1) && (B_bands ~= 3))
            error(message('images:imfuse:unsupportedDimension'));  
        end
        
    end


    function str = checkScaling(user_param)
        str = validatestring(user_param, ...
            {'joint','independent','none'},mfilename,'Scaling');
    end

    function TF = checkMethod(methodArg)
        
        valid_methods = {'falsecolor','diff','blend','montage','checkerboard'};
        method = validatestring(methodArg,valid_methods,mfilename,'METHOD');
        
        TF = true;
        
    end

    function checkColorChannels1(arg)
        % Check numeric values
        if ~ischar(arg) && ~isstring(arg)
            % First-pass validation using validateattributes().
            attributes = {'>=', 0, '<=', 2, 'finite', 'integer', 'vector', 'nonsparse', 'numel', 3};
            validateattributes(arg, {'numeric'}, attributes, mfilename, 'ColorChannels')

            % Validate that both 1 and 2 appear in the P-V value.
            if ((numel(find(arg == 1)) > 2) || (numel(find(arg == 1)) < 1) || ...
                (numel(find(arg == 2)) > 2) || (numel(find(arg == 2)) < 1))
                error(message('images:imfuse:invalidColorChannels'))
            end
        end
    end

    function out = checkColorChannels2(in)
        % Check char/string input
        if ischar(in) || isstring(in)
            str = validatestring(in, ...
                {'red-cyan','green-magenta',''}, ...
                mfilename, 'ColorChannels');
            switch (str)
                case 'green-magenta'
                    out = [2 1 2];
                case 'red-cyan'
                    out = [1 2 2];
                otherwise
                    out = [];
            end
        else
            out = in;
        end
    end

end % parse_inputs
