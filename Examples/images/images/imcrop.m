function varargout = imcrop(varargin)
%IMCROP Crop image.
%   I = IMCROP creates an interactive image cropping tool, associated with
%   the image displayed in the current figure, called the target image. The
%   tool is a moveable, resizable rectangle that is interactively placed
%   and manipulated using the mouse.  After positioning the tool, the user
%   crops the target image by either double clicking on the tool or
%   choosing 'Crop Image' from the tool's context menu.  The cropped image,
%   I, is returned.  The cropping tool can be deleted by pressing
%   backspace, escape, or delete, or via the 'Cancel' option from the
%   context menu.  If the tool is deleted, all return values are set to
%   empty.
%
%   I2 = IMCROP(I) displays the image I in a figure window and creates a
%   cropping tool associated with that image.  I can be a grayscale image,
%   an RGB image, or a logical array.  The cropped image returned, I2, is
%   of the same type as I.
%
%   X2 = IMCROP(X,MAP) displays the indexed image [X,MAP] in a figure
%   window and creates a cropping tool associated with that image.
%
%   I = IMCROP(H) creates a cropping tool associated with the image
%   specified by handle H.  H may be an image, axes, uipanel, or figure
%   handle.  If H is an axes, uipanel, or figure handle, the cropping tool
%   acts on the first image found in the container object.
%
%   The cropping tool blocks the MATLAB command line until the operation is
%   completed.
%
%   You can also specify the cropping rectangle non-interactively, using
%   these syntaxes:
%
%      I2 = IMCROP(I,RECT)
%      X2 = IMCROP(X,MAP,RECT)
%
%   RECT is a 4-element vector with the form [XMIN YMIN WIDTH HEIGHT];
%   these values are specified in spatial coordinates.
%
%   To use a non-default spatial coordinate system for the target image,
%   precede the other input arguments with two 2-element vectors specifying
%   the XData and YData:
%
%     [...] = IMCROP(X,Y,...)
%
%   [I2 RECT] = IMCROP(...) returns the cropping rectangle in addition to the
%   cropped image.
%
%   [X,Y,I2,RECT] = IMCROP(...) additionally returns the XData and YData of
%   the target image.
%
%   Remarks
%   -------
%   Because RECT is specified in terms of spatial coordinates, the WIDTH
%   and HEIGHT of RECT do not always correspond exactly with the size of
%   the output image. For example, suppose RECT is [20 20 40 30], using the
%   default spatial coordinate system. The upper left corner of the
%   specified rectangle is the center of the pixel (20,20) and the lower
%   right corner is the center of the pixel (50,60). The resulting output
%   image is 31-by-41, not 30-by-40, because the output image includes all
%   pixels in the input that are completely or partially enclosed by the
%   rectangle.
%
%   Class Support
%   -------------
%   If you specify RECT as an input argument, then the input image can be
%   logical or numeric, and must be real and nonsparse. RECT is double.
%
%   If you do not specify RECT as an input argument, then IMCROP calls
%   IMSHOW. IMSHOW expects I to be logical, uint8, uint16, int16, double,
%   or single. RGB can be uint8, int16, uint16, double, or single. X can be
%   logical, uint8, uint16, double, or single. The input image must be real
%   and nonsparse.
%
%   If you specify the image as an input argument, then the output image
%   has the same class as the input image.
%
%   If you don't specify the image as an input argument, i.e., you call
%   IMCROP with 0 input arguments or a handle, then the output image has
%   the same class as the target image except for the int16 or single data
%   type. The output image is double if the input image is int16 or single.
%
%   Example
%   -------
%   I = imread('circuit.tif');
%   I2 = imcrop(I,[60 40 100 90]);
%   figure, imshow(I)
%   figure, imshow(I2)
%
%   See also ZOOM, IMRECT.

%  Copyright 1993-2016 The MathWorks, Inc.

[x,y,a,cm,spatial_rect,h_image,placement_cancelled] = parseInputs(varargin{:});

% return empty if user cancels operation
if placement_cancelled
    varargout = repmat({[]},nargout,1);
    return;
end

% the hg properties may have changed during the crop operation (e.g.
% imcontrast), so we refresh them here
if ~isempty(h_image) && ishghandle(h_image)
    a = get(h_image,'CData');
    is_indexed_image = strcmpi(get(h_image,'CDataMapping'),'direct');
    cm = colormap(ancestor(h_image,'axes'));
end

m = size(a,1);
n = size(a,2);
xmin = min(x(:));
ymin = min(y(:));
xmax = max(x(:));
ymax = max(y(:));

% Transform rectangle into row and column indices.
if (m == 1)
    pixelsPerVerticalUnit = 1;
else
    pixelsPerVerticalUnit = (m - 1) / (ymax - ymin);
end
if (n == 1)
    pixelsPerHorizUnit = 1;
else
    pixelsPerHorizUnit = (n - 1) / (xmax - xmin);
end

pixelHeight = spatial_rect(4) * pixelsPerVerticalUnit;
pixelWidth = spatial_rect(3) * pixelsPerHorizUnit;
r1 = (spatial_rect(2) - ymin) * pixelsPerVerticalUnit + 1;
c1 = (spatial_rect(1) - xmin) * pixelsPerHorizUnit + 1;
r2 = round(r1 + pixelHeight);
c2 = round(c1 + pixelWidth);
r1 = round(r1);
c1 = round(c1);

% Check for selected rectangle completely outside the image
if ((r1 > m) || (r2 < 1) || (c1 > n) || (c2 < 1))
    b = [];
else
    r1 = max(r1, 1);
    r2 = min(r2, m);
    c1 = max(c1, 1);
    c2 = min(c2, n);
    b = a(r1:r2, c1:c2, :);
end

switch nargout
    case 0
        if (isempty(b))
            warning(message('images:imcrop:cropRectDoesNotIntersectImage'))
        end

        figure;
        if ~isempty(cm)
            if is_indexed_image
                imshow(b,cm);
            else
                imshow(b,'Colormap',cm);
            end
        else
            imshow(b);
        end

    case 1
        varargout{1} = b;

    case 2
        varargout{1} = b;
        varargout{2} = spatial_rect;

    case 4
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = b;
        varargout{4} = spatial_rect;

    otherwise
        error(message('images:imcrop:tooManyOutputArguments'))
end

end %imcrop


%--------------------------------------------------------------------------
function [x,y,a,cm,spatial_rect,h_image,placement_cancelled] = parseInputs(varargin)

x = [];
y = [];
a = [];
cm = [];
spatial_rect = [];
h_image = [];
placement_cancelled = false;

narginchk(0,5);

switch nargin
    case 0
        % IMCROP()

        % verify we have a target image
        hFig = get(0,'CurrentFigure');
        hAx  = get(hFig,'CurrentAxes');
        hIm = findobj(hAx, 'Type', 'image');
        if isempty(hIm)
            error(message('images:imcrop:noImage'))
        end

        [x,y,a,~,cm] = validateTargetHandle(hIm);
        
        checkForInvertedWorldCoordinateSystem(x,y)
        
        [spatial_rect,h_image,placement_cancelled] = interactiveCrop(hIm);

    case 1
        a = varargin{1};
        if isscalar(a) && ishghandle(a)
            % IMCROP(H)
            h = a;
            [x,y,a,~,cm] = validateTargetHandle(h);
            
            checkForInvertedWorldCoordinateSystem(x,y);
            
            [spatial_rect,h_image,placement_cancelled] = interactiveCrop(h);
        else
            % IMCROP(I) , IMCROP(RGB)
            x = [1 size(a,2)];
            y = [1 size(a,1)];
            
            checkForInvertedWorldCoordinateSystem(x,y);
            
            validateattributes(a,{'logical','int16','single','double','uint16',...
                'uint8'},{'real','nonsparse'},mfilename,'I, RGB, or H',1);
            imshow(a);
            [spatial_rect,h_image,placement_cancelled] = interactiveCrop(gcf);
        end

    case 2
        % IMCROP(X,MAP)
        a = varargin{1};
        x = [1 size(a,2)];
        y = [1 size(a,1)];
        
        checkForInvertedWorldCoordinateSystem(x,y);
        
        if numel(varargin{2}) ~= 4
            % IMCROP(X,MAP)
            cm = varargin{2};
            validateattributes(a,{'logical','single','double','uint16', 'uint8'}, ...
                {'real','nonsparse'},mfilename,'X',1);
            imshow(a,cm);
            [spatial_rect,h_image,placement_cancelled] = interactiveCrop(gcf);
        else
            % IMCROP(I,RECT) , IMCROP(RGB,RECT)
            checkCData(a);
            spatial_rect = varargin{2};
            validateRectangle(spatial_rect,2);
        end

    case 3
        if (size(varargin{3},3) == 3)
            % IMCROP(x,y,RGB)
            x = varargin{1};
            y = varargin{2};
            a = varargin{3};
            
            checkForInvertedWorldCoordinateSystem(x,y);
            
            validateattributes(a,{ 'int16','single','double','uint16', 'uint8'}, ...
                {'real','nonsparse'},mfilename,'RGB',1);
            imshow(a,'XData',x,'YData',y);
            [spatial_rect,h_image,placement_cancelled] = interactiveCrop(gcf);
        elseif isvector(varargin{3})
            % This logic has some holes but it is less hole-ly than the previous
            % version. Furthermore, it is very unlikely that a user
            % would use IMCROP(x,y,I) if I was a vector.

            % IMCROP(X,MAP,RECT)
            a = varargin{1};
            checkCData(a);
            cm = varargin{2};
            spatial_rect = varargin{3};
            validateRectangle(spatial_rect,3);
            x = [1 size(a,2)];
            y = [1 size(a,1)];
        else
            % IMCROP(x,y,I)
            x = varargin{1};
            y = varargin{2};
            a = varargin{3};
            
            checkForInvertedWorldCoordinateSystem(x,y)
            
            validateattributes(a,{'int16','logical','single','double','uint16', 'uint8'}, ...
                {'real','nonsparse'},mfilename,'I',1);
            imshow(a,'XData',x,'YData',y);
            [spatial_rect,h_image,placement_cancelled] = interactiveCrop(gcf);
        end

    case 4
        % IMCROP(x,y,I,RECT) , IMCROP(x,y,RGB,RECT)
        x = varargin{1};
        y = varargin{2};
        a = varargin{3};
        checkCData(a);
        spatial_rect = varargin{4};
        validateRectangle(spatial_rect,4);
    case 5
        % IMCROP(x,y,X,MAP,RECT)
        x = varargin{1};
        y = varargin{2};
        a = varargin{3};
        checkCData(a);
        cm = varargin{4};
        spatial_rect = varargin{5};
        validateRectangle(spatial_rect,5);
end

checkForInvertedWorldCoordinateSystem(x,y);

end %parseInputs


%-------------------------------------------------
function [x,y,a,flag,cm] = validateTargetHandle(h)

[x,y,a,flag] = getimage(h);
if (flag == 0)
    error(message('images:imcrop:noImageFoundInCurrentAxes'));
end
if (flag == 1)
    % input image is indexed; get its colormap
    cm = colormap(ancestor(h,'axes'));
else
    cm = [];
end

end


%-----------------------------------------------------------------------
function [spatial_rect,h_image,placement_cancelled] = interactiveCrop(h)

spatial_rect = [];
h_image = imhandles(h);
if numel(h_image) > 1
    h_image = h_image(1);
end
hAx = ancestor(h_image,'axes');

if isempty(h_image)
    error(message('images:imcrop:noImage'))
end

h_rect = iptui.imcropRect(hAx,[],h_image);
placement_cancelled = isempty(h_rect);
if placement_cancelled
    return;
end

spatial_rect = wait(h_rect);
if ~isempty(spatial_rect)
    % Slightly adjust spatial_rect so that we enclose appropriate pixels.
    % We still require the output of wait to determine whether or not
    % placement was cancelled.
    spatial_rect = h_rect.calculateClipRect(); 
else
    placement_cancelled = true;
end
% We are done with the interactive crop workflow. Delete the rectangle. Use
% isvalid to account for Cancel context menu item, which will have already
% deleted the imrect instance.
if isvalid(h_rect);
    h_rect.delete();
end

end %interactiveCrop


%--------------------------------------------------
function checkForInvertedWorldCoordinateSystem(x,y)

% The specification of XData and YData as a plaid meshgrid is an
% undocumented V1 syntax that is tested in the testsuite. If this syntax is
% specified, detect it and convert it to the [min,max] form that is
% documented for validation.
plaidXYGridsSpecified = ~isvector(x);
if plaidXYGridsSpecified
    x = [x(1,1) x(1,end)];
    y = [y(1,1) y(end,1)];
end

worldAndIntrinsicSystemsInverted = (x(2)-x(1)) < 0 || (y(2)-y(1)) < 0;

if worldAndIntrinsicSystemsInverted
    error(message('images:imcrop:invertedWorldCoordinateSystem'));
end

end %checkForInvertedWorldCoordinateSystem

%-------------------------
function checkCData(cdata)

right_type = (isnumeric(cdata) || islogical(cdata)) && isreal(cdata) && ...
    ~issparse(cdata);

is_2d = ismatrix(cdata);
is_rgb = (ndims(cdata) == 3) && (size(cdata,3) == 3);

if ~right_type || ~(is_2d || is_rgb)
    error(message('images:imcrop:invalidInputImage'));
end

end %checkCData

%-------------------------------
function validateRectangle(rect,inputNumber)

validateattributes(rect,{'numeric'},{'real','vector'}, ...
    mfilename,'RECT',inputNumber);

% rect must contain 4 elements: [x,y,w,h]
if(numel(rect) ~= 4)
    error(message('images:validate:badInputNumel',inputNumber,'RECT',4));
end

end %validateRectangle
