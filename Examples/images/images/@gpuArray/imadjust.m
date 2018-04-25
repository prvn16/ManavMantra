function out = imadjust(varargin)
%IMADJUST Adjust image intensity values or colormap.
%   J = IMADJUST(I) maps the values in gpuArray intensity image I to new
%   values in J such that 1% of data is saturated at low and high 
%   intensities of I. This increases the contrast of the output gpuArray 
%   image J.
%
%   J = IMADJUST(I,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT]) maps the values
%   in gpuArray intensity image I to new values in J such that values
%   between LOW_IN and HIGH_IN map to values between LOW_OUT and HIGH_OUT.
%   Values below LOW_IN and above HIGH_IN are clipped; that is, values
%   below LOW_IN map to LOW_OUT, and those above HIGH_IN map to HIGH_OUT.
%   You can use an empty matrix ([]) for [LOW_IN; HIGH_IN] or for [LOW_OUT;
%   HIGH_OUT] to specify the default of [0 1]. If you omit the argument,
%   [LOW_OUT; HIGH_OUT] defaults to [0 1].
%
%   J = IMADJUST(I,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA) maps the
%   values of I to new values in J as described in the previous syntax.
%   GAMMA specifies the shape of the curve describing the relationship
%   between the values in I and J. If GAMMA is less than 1, the mapping is
%   weighted toward higher (brighter) output values. If GAMMA is greater
%   than 1, the mapping is weighted toward lower (darker) output values. If
%   you omit the argument, GAMMA defaults to 1 (linear mapping).
%
%   NEWMAP = IMADJUST(MAP,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA)
%   transforms the colormap MAP associated with an indexed image. LOW_IN, 
%   HIGH_IN, LOW_OUT and HIGH_OUT must be 1-by-3 vectors. GAMMA can be a
%   1-by-3 vector that specifies a unique gamma value for each channel or 
%   a scalar that specifies the value used for all three channels. The 
%   rescaled colormap, NEWMAP, is the same size as MAP.
%
%   RGB2 = IMADJUST(RGB1,...) performs the adjustment on each image plane
%   (red, green, and blue) of the RGB image RGB1. As with the colormap
%   adjustment, you can apply unique mappings to each plane.
%
%   Note that IMADJUST(I) is equivalent to IMADJUST(I,STRETCHLIM(I)).
%
%   Note that if HIGH_OUT < LOW_OUT, the output image is reversed, as in a
%   photographic negative.
%
%   Class Support
%   -------------
%   For syntaxes that include an input image (rather than a colormap), the
%   input image can be uint8, uint16, int16, double, or single. The output
%   image has the same class as the input image. For syntaxes that include
%   a colormap, the input and output colormaps are double.
%
%   Examples
%   --------
%       I = gpuArray(imread('pout.tif'));
%       J = imadjust(I);
%       figure, imshow(I), figure, imshow(J)
%
%       K = imadjust(I,[0.3 0.7],[]);
%       figure, imshow(K)
%
%       RGB1 = gpuArray(imread('football.jpg'));
%       RGB2 = imadjust(RGB1,[.2 .3 0; .6 .7 1],[]);
%       figure, imshow(RGB1), figure, imshow(RGB2)
%
%   See also BRIGHTEN, DECORRSTRETCH, GPUARRAY/HISTEQ, IMCONTRAST,
%            IMHISTMATCH, GPUARRAY/STRETCHLIM, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

%   Input-output specs
%   ------------------
%   I,J          real, full matrix, 2-D
%                uint8, uint16, double, single, int16
%
%   RGB1,RGB2    real, full matrix
%                M-by-N-by-3
%                uint8, uint16, double, single, int16
%
%   MAP,NEWMAP   real, full matrix
%                M-by-3
%                double with values in the range [0,1].
%
%   [LOW_IN; HIGH_IN]    double, real, full matrix
%                        For I, size can only be 2 elements.
%                        For RGB or MAP, size can be 2 elements OR
%                        2-by-3 matrix.
%                        LOW_IN < HIGH_IN
%
%   [LOW_OUT; HIGH_OUT]  Same size restrictions as [LOW_IN; HIGH_IN]
%                        LOW_OUT can be less than HIGH_OUT
%
%   LOW_IN, HIGH_IN, LOW_OUT, HIGH_OUT all must be in the range [0,1];
%
%   GAMMA         real, double, nonnegative
%                 scalar for I
%                 scalar or 1-by-3 vector for RGB and MAP

if isa(varargin{1},'gpuArray')
    %Parse inputs and initialize variables
    [img,classImg,imageType,lowIn,highIn,lowOut,highOut,gamma] = ...
        parseInputs(varargin{:});
    
    validateLowHigh(lowIn,highIn,lowOut,highOut);
    gamma = validateGamma(gamma,imageType);
    
    
    if ~isfloat(img) && numel(img) > 65536
        % integer data type image with more than 65536 elements
        out = adjustWithLUT(img,classImg,lowIn,highIn,lowOut,highOut,gamma);
        
    else
        classChanged = false;
        if ~strcmp(classImg,'double') || ...
                ~strcmp(classImg,'single')
            classChanged = true;
            img = im2double(img);
        end
        
        if strcmp(imageType, 'intensity')
            out = adjustGrayscaleImage(img,lowIn,highIn,lowOut,highOut,gamma);
        elseif strcmp(imageType, 'indexed')
            out = adjustColormap(img,lowIn,highIn,lowOut,highOut,gamma);
        else
            out = adjustTruecolorImage(img,lowIn,highIn,lowOut,highOut,gamma);
        end
        
        if classChanged
            out = images.internal.changeClass(classImg,out);
        end
        
    end
else
    % Call CPU version
    args = gatherIfNecessary(varargin{:});
    out  = imadjust(args{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = adjustWithLUT(img,classImg,lowIn,highIn,lowOut,highOut,gamma)
        
        switch classImg
            case 'uint8'
                lutLength     = 256;
                conversionFcn = @im2uint8;
            case 'uint16'
                lutLength     = 65536;
                conversionFcn = @im2uint16;
            case 'int16'
                lutLength     = 65536;
                conversionFcn = @im2int16;
            otherwise
                error(message('images:imadjust:internalError'))
        end
        
        out = gpuArray.zeros(size(img),classImg);
        for p = 1:size(img,3)
            lut = gpuArray.linspace(0,1,lutLength);
            scalingFactor = 1;
            lut = adjustArray(lut,lowIn(p),highIn(p),lowOut(p),highOut(p), ...
                gamma(p),scalingFactor);
            lut = conversionFcn(lut);
            
            sIdx.type = '()';
            sIdx.subs = {':',':',p};
            imgp = subsref(img,sIdx);
            out  = subsasgn(out,sIdx,intlut(imgp,lut));
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = adjustColormap(cmap,lIn,hIn,lOut,hOut,g)
        % expansion factor that can expand a 1-by-3 range to the size of cmap.
        expansionFactor = ones(size(cmap,1), 1);
        out = adjustArray(cmap, lIn, hIn, lOut, hOut, g, expansionFactor);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = adjustGrayscaleImage(img,lIn,hIn,lOut,hOut,g)
        
        expansionFactor = 1;
        out = adjustArray(img, lIn, hIn, lOut, hOut, g, expansionFactor);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = adjustTruecolorImage(rgb,lIn,hIn,lOut,hOut,g)
        
        classRGB = classUnderlying(rgb);
        out = gpuArray.zeros(size(rgb), classRGB);
        expansionFactor = 1;
        
        for p = 1 : 3
            sIdx.type = '()';
            sIdx.subs = {':',':',p};
            
            rgbp = subsref(rgb,sIdx);
            out = subsasgn(out,sIdx, adjustArray(rgbp, lIn(p),hIn(p), lOut(p), ...
                hOut(p), g(p), expansionFactor));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = adjustArray(img,lIn,hIn,lOut,hOut,g,d)
        rangeIn  = hIn (d,:) - lIn (d,:);
        rangeOut = hOut(d,:) - lOut(d,:);
        out = arrayfun(@clipAndMapValues,img,lIn(d,:),hIn(d,:),...
            rangeIn,lOut(d,:),rangeOut,g(d,:));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = clipAndMapValues(pix,lIn,hIn,rangeIn,lOut,rangeOut,g)
        pix = max(lIn, min(hIn,pix));
        %MAPVALUES Map input from old range to new range with gamma correction.
        out = ((pix - lIn) ./ rangeIn ) .^ (g) .* rangeOut + lOut;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [img,classImg,imageType,low_in,high_in,low_out,high_out,gamma] = ...
            parseInputs(varargin)
        
        narginchk(1,4);
        img = varargin{1};
        
        % Default values
        lowhigh_in  = [0; 1];
        lowhigh_out = [0; 1];
        gamma = 1;
        
        classImg = classUnderlying(img);
        
        if nargin == 1
            % IMADJUST(I)
            if ~ismatrix(img)
                error(message('images:imadjust:oneArgOnlyGrayscale','IMADJUST(I)'))
            end
            hValidateAttributes(img,...
                {'double' 'uint8' 'uint16' 'int16' 'single'}, ...
                {'2d','nonsparse'},mfilename,'I',1);

            
            % If a user passes in a m-by-3 double array, assume it is an intensity
            % image (there is really no way to tell).
            imageType = 'intensity';
            
            if(isfloat(img))
                lowhigh_in = gather(stretchlim(img));
            else
                % CPU is faster for non-floating point
                
                % Turn off warning 'images:imhistc:inputHasNans' before calling STRETCHLIM and
                % restore afterwards. STRETCHLIM calls IMHIST/IMHISTC and the warning confuses
                % a user who calls IMADJUST with NaNs.
                s = warning('off','images:imhistc:inputHasNaNs');
                lowhigh_in = stretchlim(gather(img));
                warning(s);
            end
            
        else
            if nargin == 2
                % IMADJUST(I,[LOW_IN HIGH_IN])
                % IMADJUST(MAP,[LOW_IN HIGH_IN])
                % IMADJUST(RGB,[LOW_IN HIGH_IN])
                if ~isempty(varargin{2})
                    lowhigh_in = gather(varargin{2});
                end
                
            elseif nargin == 3
                % IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT])
                % IMADJUST(MAP,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT])
                % IMADJUST(RGB,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT])
                
                if ~isempty(varargin{2})
                    lowhigh_in = gather(varargin{2});
                end
                if ~isempty(varargin{3})
                    lowhigh_out = gather(varargin{3});
                end
            else
                % IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA)
                % IMADJUST(MAP,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA)
                % IMADJUST(RGB,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA)
                if ~isempty(varargin{2})
                    lowhigh_in = gather(varargin{2});
                end
                if ~isempty(varargin{3})
                    lowhigh_out = gather(varargin{3});
                end
                if ~isempty(varargin{4})
                    gamma = gather(varargin{4});
                end
            end
            imageType = findImageType(img, lowhigh_in, lowhigh_out);
            checkRange(lowhigh_in, imageType, 2,'[LOW_IN; HIGH_IN]');
            checkRange(lowhigh_out, imageType, 3,'[LOW_OUT; HIGH_OUT]');
        end
        
        [low_in, high_in]   = splitRange(lowhigh_in, imageType);
        [low_out, high_out] = splitRange(lowhigh_out, imageType);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imageType = findImageType(img, lowhigh_in, lowhigh_out)
        
        if (ndims(img)==3 && size(img,3)==3)
            % RGB image
            hValidateAttributes(img,...
                {'double' 'uint8' 'uint16' 'int16' 'single'}, ...
                {'nonsparse'},mfilename,'RGB1',1);
            
            imageType = 'truecolor';
            
        elseif (numel(lowhigh_in) == 2 && numel(lowhigh_out) == 2) || ...
                size(img,2) ~= 3
            % Assuming that a user passed in an intensity image if lowhigh_in and
            % lowhigh_out are 2-element vectors, e.g., imadjust(3 column image,
            % [1;2], [2;3]).
            hValidateAttributes(img,...
                {'double' 'uint8' 'uint16' 'int16' 'single'}, ...
                {'2d','nonsparse'},mfilename,'I',1);
            
            imageType = 'intensity';
            
        else
            %Colormap
            iptcheckmap(img,mfilename,'MAP',1);
            imageType = 'indexed';
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function checkRange(range, imageType, argumentPosition, variableName)
        
        if strcmp(imageType, 'intensity')
            if numel(range) ~= 2
                error(message('images:imadjust:InputMustBe2ElVec', mfilename, ...
                    iptnum2ordinal( argumentPosition ), variableName))
            end
        else
            if ~(numel(range) == 2 || isequal(size(range), [2 3]))
                error(message('images:imadjust:InputMustBe2ElVecOr2by3Matrix', ...
                    mfilename, iptnum2ordinal( argumentPosition ), variableName));
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rangeMin, rangeMax] = splitRange(range, imageType)
        
        if numel(range) == 2
            if strcmp(imageType, 'intensity')
                rangeMin = range(1);
                rangeMax = range(2);
            else
                % Create triples for RGB image or Colormap
                rangeMin = range(1) * ones(1,3);
                rangeMax = range(2) * ones(1,3);
            end
        else
            % range is a 2 by 3 array
            rangeMin = range(1,:);
            rangeMax = range(2,:);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function validateLowHigh(lowIn,highIn,lowOut,highOut)
        
        if any(lowIn >= highIn)
            error(message('images:imadjust:lowMustBeSmallerThanHigh'))
        end
        
        if isInvalidRange(lowIn) || isInvalidRange(highIn) ...
                || isInvalidRange(lowOut) || isInvalidRange(highOut)
            error(message('images:imadjust:parametersAreOutOfRange'))
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isInvalid = isInvalidRange(range)
        
        isInvalid = min(range) < 0 || max(range) > 1;
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function gamma = validateGamma(gamma,image_type)
        
        if strcmp(image_type,'intensity')
            validateattributes(gamma,{'double'},{'scalar', 'nonnegative'}, ...
                mfilename, 'GAMMA', 4)
        else
            validateattributes(gamma,{'double'},{'nonnegative','2d'},...
                mfilename, 'GAMMA', 4)
            if numel(gamma) == 1,
                gamma = gamma*ones(1,3);
            elseif numel(gamma) ~=3,
                error(message('images:imadjust:invalidGamma'));
            end
        end
        
    end

end
