function varargout = imrotate(varargin)
%IMROTATE Rotate image.
%   B = IMROTATE(A, ANGLE) rotates the image in gpuArray A by ANGLE degrees
%   in a counterclockwise direction around its center point. To rotate the
%   image clockwise, specify a negative value for ANGLE. IMROTATE makes the
%   output gpuArray B large enough to contain the entire rotated image.
%   IMROTATE uses nearest neighbor interpolation, setting the values of
%   pixels in B that are outside the rotated image to 0 (zero).
%
%   B = IMROTATE(A,ANGLE,METHOD) rotates the image in gpuArray A, using the
%   interpolation method specified by METHOD. METHOD is a string that can
%   have one of the following values. The default value is enclosed in
%   braces ({}).
%
%        {'nearest'}  Nearest neighbor interpolation
%
%        'bilinear'   Bilinear interpolation
%
%        'bicubic'    Bicubic interpolation. Note: This interpolation
%                     method can produce pixel values outside the original
%                     range.
%
%   B = IMROTATE(A,ANGLE,METHOD,BBOX) rotates image in gpuArray A, where
%   BBOX specifies the size of the output gpuArray B. BBOX is a text string
%   that can have either of the following values. The default value is
%   enclosed in braces
%   ({}).
%
%        {'loose'}    Make output gpuArray B large enough to contain the
%                     entire rotated image. B is generally larger than A.
%
%        'crop'       Make output gpuArray B the same size as the input
%                     gpuArray A, cropping the rotated image to fit.
%
%   Class Support
%   -------------
%   The input gpuArray image can contain uint8, uint16, single-precision
%   floating-point, or logical pixels.  The output image is of the same
%   class as the input image.
%
%   Note
%   ----
%   The function IMROTATE changed in version 9.3 (R2015b).  Previous 
%   versions of the Image Processing Toolbox use different spatial 
%   conventions.  If you need the same results produced by the previous 
%   implementation, use the function IMROTATE_OLD.
%
%   The 'bicubic' interpolation mode used in the GPU implementation of this
%   function differs from the default (CPU) bicubic mode.  The GPU and CPU
%   versions of this function are expected to give slightly different
%   results.
%
%   Example
%   -------
%   X = gpuArray(imread('pout.tif'));
%   Y = imrotate(X, 37, 'loose', 'bilinear');
%   figure; imshow(Y)
%
%   See also GPUARRAY/IMROTATE_OLD, IMCROP, GPUARRAY/IMRESIZE, IMTRANSFORM, TFORMARRAY, GPUARRAY.

% Copyright 2012-2017 The MathWorks, Inc.

nargoutchk(0,1);

A = varargin{1};

if (isempty(A))
    
    B = A; % No rotation needed
    
elseif ~isa(A,'gpuArray')
    % Call CPU version
    args = gatherIfNecessary(varargin{:});
    B  = imrotate(args{:});
    
else
    [A,angle,method,bbox] = parse_inputs(varargin{:});
    
    so = size(A);
    twod_size = so(1:2);
    thirdD = prod(so(3:end));
    
    r = rem(angle, 360);
    switch (r)
        case {0}
            
            B = A;
            
        case {90, 270, -90, -270}
            
            A = reshape(A,[twod_size thirdD]);
            
            not_square = twod_size(1) ~= twod_size(2);
            
            multiple_of_ninety = mod(floor(angle/90), 4);
            
            if strcmpi(bbox, 'crop') && not_square
                % center rotated image and preserve size
                
                if ndims(A)>2 %#ok<ISMAT>
                    dim = 3;
                else
                    dim = ndims(A);
                end
                
                v = repmat({':'},[1 dim]);
                
                imbegin = (max(twod_size) == so)*abs(diff(floor(twod_size/2)));
                vec = 1:min(twod_size);
                v(1) = {imbegin(1)+vec};
                v(2) = {imbegin(2)+vec};
                
                new_size = [twod_size thirdD];
                
                % pre-allocate array
                if islogical(A)
                    B = gpuArray.false(new_size);
                else
                    B = gpuArray.zeros(new_size,classUnderlying(A));
                end
                
                
                s.type = '()';
                s.subs = v;
                
                for k = 1:thirdD
                    s.subs{3} = k;
                    % B(:,:,k) = rot90(A(:,:,k),multiple_of_ninety);
                    B = subsasgn(B, s, rot90(subsref(A, s), multiple_of_ninety));
                end
            else
                % don't preserve original size
                new_size = [fliplr(twod_size) thirdD];
                
                B = pagefun(@rot90,A,multiple_of_ninety);
            end
            
            B = reshape(B,[new_size(1) new_size(2) so(3:end)]);
            
        case {180,-180}
            
            v = repmat({':'},[1 ndims(A)]);
            v(1) = {twod_size(1):-1:1};
            v(2) = {twod_size(2):-1:1};
            
            s.type = '()';
            s.subs = v;
            
            B = subsref(A, s);
            
        otherwise
            
            padSize = [2 2];
            if (~ismatrix(A))
                padSize(ndims(A)) = 0;
            end
            
            %pad input gpuArray to overcome different edge behavior in NPP.
            A = padarray_algo(A, padSize, 'constant', 0, 'both');
            
            
            outputSize = getOutputSize(angle,twod_size,bbox);
            
            if (isreal(A))
                B = images.internal.gpu.imrotate(A, angle, method, outputSize);
            else
                B = complex(images.internal.gpu.imrotate(real(A), angle, method, outputSize),...
                    images.internal.gpu.imrotate(imag(A), angle, method, outputSize));
            end
    end
end

varargout{1} = B;
end


function [A,ang,method,bbox] = parse_inputs(varargin)

narginchk(2,4);

varargin = matlab.images.internal.stringToChar(varargin);

% validate image
A = varargin{1};
hValidateAttributes(A,{'uint8','uint16','logical','single'},{'nonsparse'},mfilename,'input image',1);

% validate angle
ang = double(varargin{2});
validateattributes(ang,{'numeric'},{'real','scalar'},mfilename,'ANGLE',2);

method = 'nearest';
bbox   = 'loose';
strings = {'nearest','bilinear','bicubic','crop','loose'};
isBBox  = [ false   ,false     ,false    ,true  ,true   ];

if nargin==3
    
    arg = varargin{3};
    if ~ischar(arg)
        error(message('images:imrotate:expectedString'));
    end
    idx = stringmatch(lower(arg),strings);
    checkStringValidity(idx,arg);
    arg = strings{idx};
    
    if isBBox(idx)
        bbox = arg;
    else
        method = arg;
    end
    
elseif nargin==4
    
    arg1 = varargin{3};
    if ~ischar(arg1)
        error(message('images:imrotate:expectedString'));
    end
    idx1 = stringmatch(lower(arg1),strings); %#ok<*MATCH2>
    checkStringValidity(idx1,arg1);
    arg1 = strings{idx1};
    
    arg2 = varargin{4};
    if ~ischar(arg2)
        error(message('images:imrotate:expectedString'));
    end
    idx2 = stringmatch(lower(arg2),strings);
    checkStringValidity(idx2,arg2);
    arg2 = strings{idx2};
    
    if isBBox(idx1)
        bbox = arg1;
    else
        method = arg1;
    end
    
    if isBBox(idx2)
        bbox = arg2;
    else
        method = arg2;
    end
end
end

function checkStringValidity(idx,arg)
if isempty(idx)
    error(message('images:imrotate:unrecognizedInputString', arg));
elseif numel(idx)>1
    error(message('images:imrotate:ambiguousInputString', arg));
end
end

function idx = stringmatch(str,cellOfStrings)
idx = find(strncmpi(str, cellOfStrings, numel(str)));
end

function outputSize = getOutputSize(angle,twod_size,bbox)

if strcmpi(bbox, 'loose')  % Determine limits for rotated image
    
    % Compute bounding box of rotated image
    sinPhi = sind(angle);
    cosPhi = cosd(angle);
    T = [ cosPhi  sinPhi   0
        -sinPhi  cosPhi   0
        0       0     1 ];
    tform = affine2d(T);
    
    XWorldLimits = [0.5 twod_size(2)+0.5];
    YWorldLimits = [0.5 twod_size(1)+0.5];
    
    [XWorldLimitsOut,YWorldLimitsOut] = outputLimits(tform,XWorldLimits,YWorldLimits);
    
    % Use ceil to provide grid that will accommodate world limits at roughly the
    % target resolution.
    numCols = ceil(diff(XWorldLimitsOut));
    numRows = ceil(diff(YWorldLimitsOut));
    
    % Construct output referencing object with desired outputImageSize and
    % world limits.
    outputSize = [numRows numCols];
    
else % Cropped image
    outputSize = twod_size;
end
end
