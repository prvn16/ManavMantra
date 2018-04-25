function [Gx, Gy] = imgradientxy(varargin)
%IMGRADIENTXY Find the directional gradients of an image.
%   [Gx, Gy] = IMGRADIENTXY(I) takes a grayscale or binary gpuArray image I
%   as input and returns the gradient along the X axis, Gx, and the Y axis,
%   Gy. X axis points in the direction of increasing column subscripts and
%   Y axis points in the direction of increasing row subscripts. Gx and Gy
%   are the same size as the input gpuArray image I.
%
%   [Gx, Gy] = IMGRADIENTXY(I, METHOD) calculates the directional gradients
%   of the gpuArray image I using the specified METHOD. 
%
%   Supported METHODs are:
%
%       'Sobel'                 : Sobel gradient operator (default)
%
%       'Prewitt'               : Prewitt gradient operator
%
%       'CentralDifference'     : Central difference gradient dI/dx = (I(x+1)- I(x-1))/ 2
%
%       'IntermediateDifference': Intermediate difference gradient dI/dx = I(x+1) - I(x)
%
%   Class Support 
%   ------------- 
%   The input gpuArray image I can be numeric or logical two-dimensional 
%   matrix. Both Gx and Gy are of class double, unless the input gpuArray 
%   image I is of class single, in which case Gx and Gy will be of class
%   single.
%
%   Notes
%   -----
%   1. When applying the gradient operator at the boundaries of the image,
%      values outside the bounds of the image are assumed to equal the
%      nearest image border value. This is similar to the 'replicate'
%      boundary option in IMFILTER.
% 
%   Example 1
%   ---------
%   This example computes and displays the directional gradients of the
%   image coins.png using Prewitt's gradient operator.
%
%   I = gpuArray(imread('coins.png'));
%   imshow(I)
%   
%   [Gx, Gy] = imgradientxy(I,'prewitt');
% 
%   figure, imshow(Gx, []), title('Directional gradient: X axis')
%   figure, imshow(Gy, []), title('Directional gradient: Y axis')
%
%   Example 2
%   ---------
%   This example computes and displays both the directional gradients and the
%   gradient magnitude and gradient direction for the image coins.png.
%
%   I = gpuArray(imread('coins.png'));
%   imshow(I)
%   
%   [Gx, Gy] = imgradientxy(I);
%   [Gmag, Gdir] = imgradient(Gx, Gy);
% 
%   figure, imshow(Gmag, []), title('Gradient magnitude')
%   figure, imshow(Gdir, []), title('Gradient direction')
%   figure, imshow(Gx, []), title('Directional gradient: X axis')
%   figure, imshow(Gy, []), title('Directional gradient: Y axis')
%
%   See also GPUARRAY/EDGE, FSPECIAL, GPUARRAY/IMGRADIENT, GPUARRAY.

% Copyright 2013-2016 The MathWorks, Inc. 

narginchk(1,2);

[I, method] = parse_inputs(varargin{:});

if ~isfloat(I)
    I = double(I);
end

switch method
    case 'sobel'
        h = -fspecial('sobel'); % Align mask correctly along the x- and y- axes
        Gx = imfilter(I,h','replicate');
        if nargout > 1
            Gy = imfilter(I,h,'replicate');
        end
        
    case 'prewitt'
        h = -fspecial('prewitt'); % Align mask correctly along the x- and y- axes
        Gx = imfilter(I,h','replicate');
        if nargout > 1
            Gy = imfilter(I,h,'replicate');
        end        
        
    case 'centraldifference' 
        if isrow(I)            
            Gx = gradient2(I);
            if nargout > 1
                Gy = gpuArray.zeros(size(I),classUnderlying(I));
            end            
        elseif iscolumn(I)            
            Gx = gpuArray.zeros(size(I),classUnderlying(I));
            if nargout > 1
                Gy = gradient2(I);
            end                
        else            
            [Gx, Gy] = gradient2(I);
        end
   
    case 'intermediatedifference' 
        Gx = gpuArray.zeros(size(I),classUnderlying(I));
        if (size(I,2) > 1)   
            subsRight(1).type = '()';
            subsRight(1).subs = {':',2:size(I,2)};
            subsLeft(1).type = '()';
            subsLeft(1).subs = {':',1:size(I,2)-1};
            subsGx(1).type = '()';
            subsGx(1).subs = {':',1:size(Gx,2)-1};
            
            Gx = subsasgn(Gx,...
                          subsGx,...
                          subsref(I,subsRight) - subsref(I,subsLeft));
        end
            
        if nargout > 1
            Gy = gpuArray.zeros(size(I),classUnderlying(I));
            if (size(I,1) > 1)
                subsLower(1).type = '()';
                subsLower(1).subs = {2:size(I,1),':'};
                subsUpper(1).type = '()';
                subsUpper(1).subs = {1:size(I,1)-1,':'};
                subsGy(1).type = '()';
                subsGy(1).subs = {1:size(I,1)-1,':'};
                
                Gy = subsasgn(Gy,...
                              subsGy,...
                              subsref(I,subsLower) - subsref(I,subsUpper));
            end
        end
  
end

end
%======================================================================
function [I, method] = parse_inputs(varargin)

I = varargin{1};

hValidateAttributes(I,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
    {'2d','real','nonsparse'},mfilename,'I',1);

method = 'sobel'; % Default method
if (nargin > 1)
    methodstrings = {'sobel','prewitt','centraldifference', ...
        'intermediatedifference'};
    validateattributes(varargin{2},{'char','string'}, ...
        {'scalartext'},mfilename,'METHOD',2);
    method = validatestring(varargin{2}, methodstrings, ...
        mfilename, 'METHOD', 2);
end

end
%----------------------------------------------------------------------

%======================================================================
function varargout = gradient2(in_0)
%Approximate 2d gradient.

narginchk(1,1);
nargoutchk(1,2);

if iscolumn(in_0)
    in = in_0';
else
    in = in_0;
end

[m,n] = size(in);

out = gpuArray.zeros([m,n],classUnderlying(in));

% Take forward differences on left and right edges
if n > 1
    %out(:,1)     = in(:,2)-in(:,1);
    out = subsasgn(out,substruct('()',{':',1}),...
                    subsref(in,substruct('()',{':',2}))-subsref(in,substruct('()',{':',1})));
    %out(:,n)     = in(:,n) - in(:,n-1);
    out = subsasgn(out,substruct('()',{':',n}),...
                    subsref(in,substruct('()',{':',n}))-subsref(in,substruct('()',{':',n-1})));
end

% Take centered differences on interior points
if n > 2
    %out(:,2:n-1) = ( in(:,3:n)-in(:,1:n-2) )./2;
    out = subsasgn(out,substruct('()',{':',2:n-1}),...
                    ( subsref(in,substruct('()',{':',3:n}))-subsref(in,substruct('()',{':',1:n-2})) )./2);
end

if iscolumn(in_0)
    varargout{1} = out';
else
    varargout{1} = out;
end
    
if nargout == 2
    out2 = gpuArray.zeros([m,n],classUnderlying(in));
    
    % Take forward differences on top and bottom edges
    if m > 1
        %out2(1,:)     = in(2,:)-in(1,:);
        out2 = subsasgn(out2,substruct('()',{1,':'}),...
                    subsref(in,substruct('()',{2,':'}))-subsref(in,substruct('()',{1,':'})));
        %out2(m,:)     = in(m,:)-in(m-1,:);
        out2 = subsasgn(out2,substruct('()',{m,':'}),...
                    subsref(in,substruct('()',{m,':'}))-subsref(in,substruct('()',{m-1,':'})));
    end
    
    % Take centered differences on interior points
    if m > 2
        %out2(2:m-1,:) = ( in(3:m,:)-in(1:m-2,:) )./2;
        out2 = subsasgn(out2,substruct('()',{2:m-1,':'}),...
                    ( subsref(in,substruct('()',{3:m,':'}))-subsref(in,substruct('()',{1:m-2,':'})) )./2);
    end
    varargout{2} = out2;
end
end

%----------------------------------------------------------------------