function varargout = imrotate_old(varargin)
%IMROTATE_OLD Rotate image (old version).
%   This function provides the IMROTATE function as computed by versions
%   9.2 (R2015a) and earlier of the Image Processing Toolbox.
%
%   B = IMROTATE_OLD(A,ANGLE) rotates image A by ANGLE degrees in a 
%   counterclockwise direction around its center point. To rotate the image
%   clockwise, specify a negative value for ANGLE. IMROTATE_OLD makes the output
%   image B large enough to contain the entire rotated image. IMROTATE_OLD uses
%   nearest neighbor interpolation, setting the values of pixels in B that 
%   are outside the rotated image to 0 (zero).
%
%   B = IMROTATE_OLD(A,ANGLE,METHOD) rotates image A, using the interpolation
%   method specified by METHOD. METHOD is a string that can have one of the
%   following values. The default value is enclosed in braces ({}).
%
%        {'nearest'}  Nearest neighbor interpolation
%
%        'bilinear'   Bilinear interpolation
%
%        'bicubic'    Bicubic interpolation. Note: This interpolation
%                     method can produce pixel values outside the original
%                     range.
%
%   B = IMROTATE_OLD(A,ANGLE,METHOD,BBOX) rotates image A, where BBOX specifies 
%   the size of the output image B. BBOX is a text string that can have 
%   either of the following values. The default value is enclosed in braces
%   ({}).
%
%        {'loose'}    Make output image B large enough to contain the
%                     entire rotated image. B is generally larger than A.
%
%        'crop'       Make output image B the same size as the input image
%                     A, cropping the rotated image to fit. 
%
%   Class Support
%   -------------
%   The input image can be numeric or logical.  The output image is of the
%   same class as the input image.
%
%   Performance Note
%   ----------------
%   This function may take advantage of hardware optimization for datatypes
%   uint8, uint16, single, and double to run faster.
%
%   Example
%   -------
%        % This example brings image I into horizontal alignment by
%        % rotating the image by -1 degree.
%        
%        I = fitsread('solarspectra.fts');
%        I = rescale(I);
%        J = imrotate_old(I,-1,'bilinear','crop');
%        figure, imshow(I), figure, imshow(J)
%
%   See also IMROTATE, IMCROP, IMRESIZE, IMTRANSFORM, TFORMARRAY.

%   Copyright 1992-2017 The MathWorks, Inc.

% Grandfathered:
%   Without output arguments, IMROTATE_OLD(...) displays the rotated
%   image in the current axis.  

[A,ang,method,bbox] = parse_inputs(varargin{:});

if (isempty(A)) 
    
    B = A; % No rotation needed    
    
else
    so = size(A);
    twod_size = so(1:2);
    
    if rem(ang,90) == 0
        % Catch and speed up 90 degree rotations
        
        % determine if angle is +- 90 degrees or 0,180 degrees.
        multiple_of_ninety = mod(floor(ang/90), 4);
        
        % initialize array of subscripts
        v = repmat({':'},[1 ndims(A)]);
        
        switch multiple_of_ninety
            
            case 0
                % 0 rotation;
                B = A;
                
            case {1,3}
                % +- 90 deg rotation
                
                thirdD = prod(so(3:end));
                A = reshape(A,[twod_size thirdD]);
                
                not_square = twod_size(1) ~= twod_size(2);
                if strcmpi(bbox, 'crop') && not_square
                    % center rotated image and preserve size
                    
                    imbegin = (max(twod_size) == so)*abs(diff(floor(twod_size/2)));
                    vec = 1:min(twod_size);
                    v(1) = {imbegin(1)+vec};
                    v(2) = {imbegin(2)+vec};
                    
                    new_size = [twod_size thirdD];
                    
                else
                    % don't preserve original size
                    new_size = [fliplr(twod_size) thirdD];
                end
                
                % pre-allocate array
                if islogical(A)
                    B = false(new_size);
                else
                    B = zeros(new_size, 'like', A);
                end
                
                B(v{1},v{2},:) = rot90(A(v{1},v{2},:), multiple_of_ninety);
                
                B = reshape(B,[new_size(1) new_size(2) so(3:end)]);
                
            case 2
                % 180 rotation
                
                v(1) = {twod_size(1):-1:1};
                v(2) = {twod_size(2):-1:1};
                B = A(v{:});
        end
        
    else % Perform general rotation
        
        phi = ang*pi/180; % Convert to radians
        
        rotate = maketform('affine',[ cos(phi)  sin(phi)  0; ...
            -sin(phi)  cos(phi)  0; ...
            0       0       1 ]);
        
        [loA,hiA,loB,hiB,outputSize] = getOutputBound(rotate,twod_size,bbox);
        
        if useIPP(A)
            % The library routine has different edge behavior than our code.
            % This difference can be worked around with zero padding.
            A = padarray(A,[2 2],0,'both');
            
            if isreal(A)
                B = imrotatemex(A,ang,outputSize,method);
            else
                % If input is complex valued, call imrotatemex on real and
                % imaginary parts separately then combine results.
                B = complex(imrotatemex(real(A),ang,outputSize,method),...
                            imrotatemex(imag(A),ang,outputSize,method));
            end
            
        else % rotate using tformarray
            
            boxA = maketform('box',twod_size,loA,hiA);
            boxB = maketform('box',outputSize,loB,hiB);
            T = maketform('composite',[fliptform(boxB),rotate,boxA]);
            
            if strcmp(method,'bicubic')
                R = makeresampler('cubic','fill');
            elseif strcmp(method,'bilinear')
                R = makeresampler('linear','fill');
            else
                R = makeresampler('nearest','fill');
            end
            
            B = tformarray(A, T, R, [1 2], [1 2], outputSize, [], 0);
            
        end
    end
    
end


% Output
switch nargout,
case 0,
  % Need to set varargout{1} so ans gets populated even if user doesn't ask for output
  varargout{1} = B;  
case 1,
  varargout{1} = B;
case 3,
  error(message('images:removed:syntax','[R,G,B] = IMROTATE_OLD(RGB)','RGB2 = IMROTATE_OLD(RGB1)'))
otherwise,
  error(message('images:imrotate:tooManyOutputs'))
end
end

function [loA,hiA,loB,hiB,outputSize] = getOutputBound(rotate,twod_size,bbox)

% Coordinates from center of A
hiA = (twod_size-1)/2;
loA = -hiA;
if strcmpi(bbox, 'loose')  % Determine limits for rotated image
    hiB = ceil(max(abs(tformfwd([loA(1) hiA(2); hiA(1) hiA(2)],rotate)))/2)*2;
    loB = -hiB;
    outputSize = hiB - loB + 1;
else % Cropped image
    hiB = hiA;
    loB = loA;
    outputSize = twod_size;
end
end

function TF = useIPP(A)
    
    % We enable acceleration for uint8, uint16, and single or double precision
    % floating point inputs.
    supportedType = isa(A,'uint8') || isa(A,'uint16') || isa(A,'float');
    TF =  ippl() && supportedType && ~isProblemSizeTooBig(A);
end

    function TF = isProblemSizeTooBig(A)

    % IPP cannot handle double-precision inputs that are too big. Switch to
    % using tform when the image is double-precision and is too big.
    
    imageIsDoublePrecision = isa(A,'double');
    
    padSize = 2;
    numel2DInputImage = (size(A,1) + 2*padSize) * (size(A,2) + 2*padSize);
    
    % The size threshold is double(intmax('int32'))/8. The double-precision 
    % IPP routine can only handle images that have fewer than this many pixels.
    % This is hypothesized to be because they use an int to hold a pointer 
    % offset for the input image. This overflows when the offset becomes large 
    % enough that ptrOffset*sizeof(double) exceeds intmax.
    sizeThreshold = 2.6844e+08;
    TF = imageIsDoublePrecision && (numel2DInputImage>=sizeThreshold);
    
        
end

function [A,ang,method,bbox] = parse_inputs(varargin)

narginchk(2,4);

% validate image
A = varargin{1};
validateattributes(A,{'numeric','logical'},{},mfilename,'input image',1);

% validate angle
ang = double(varargin{2});
validateattributes(ang,{'numeric'},{'real','scalar'},mfilename,'ANGLE',2);

method = 'nearest';
bbox   = 'loose';
strings  = {'nearest','bilinear','bicubic','crop','loose'};
isBBox   = [ false   ,false     ,false    ,true  ,true   ];
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
    idx1 = stringmatch(lower(arg1),strings);
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

function idx = stringmatch(str,cellOfStrings)
idx = find(strncmpi(str, cellOfStrings, numel(str)));
end

function checkStringValidity(idx,arg)
if isempty(idx)
    error(message('images:imrotate:unrecognizedInputString', arg));
elseif numel(idx)>1
    error(message('images:imrotate:ambiguousInputString', arg));
end
end
