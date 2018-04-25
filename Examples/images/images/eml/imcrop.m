function varargout = imcrop(varargin) %#codegen

% Copyright 2015 The MathWorks, Inc.

% Supported Syntax in code generation
% -----------------------------------
%    I2 = imcrop(I,rect)
%    [...] = imcrop(x,y,...)
%    [I2,rect] = imcrop(...)
%    [X,Y,I2,rect] = imcrop(...)
%
% Input/output specs in code generation
% -------------------------------------
% I:     logical or numeric array
%        real
%        nonsparse
%        grayscale (m-by-n) or RGB (m-by-n-by3)
%
% rect:  numeric vector
%        real
%        contains 4 elements: [xmin,ymin,width,height]
%        variable sizing not allowed
%
% x,y:   numeric vector
%        real
%        finite
%        contains 2 elements
%        inverted coordinate systems not allowed
%        default: x = [1,size(I,2)]
%                 y = [1,size(I,1)]
%
% I2:    same class as I
%

%#ok<*EMCA>

nargoutchk(0,4);

[xdata,ydata,I,rect] = parseInputs(varargin{:});

J = doCrop(I,xdata,ydata,rect);

switch nargout
    case 1
        varargout{1} = J;
    case 2
        varargout{1} = J;
        varargout{2} = rect;
    case 3
        varargout{1} = xdata;
        varargout{2} = ydata;
        varargout{3} = J;
    case 4
        varargout{1} = xdata;
        varargout{2} = ydata;
        varargout{3} = J;
        varargout{4} = rect;
end

%--------------------------------------------------------------------------
function [xdata,ydata,I,rect] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin{:});

narginchk(0,5);

switch nargin
    case 2
        % [...] = imcrop(I,rect)
        
        % Validate I
        I = varargin{1};
        validateImage(I,1);
        
        % Validate rect
        rect = varargin{2};
        validateRectangle(rect,2);
        
        % Default values for xdata and ydata
        xdata = [1,size(I,2)];
        ydata = [1,size(I,1)];
    case 4
        % [...] = imcrop(xdata,ydata,I,rect)
        
        % Validate xdata and ydata
        xdata = varargin{1};
        ydata = varargin{2};
        validateXYData(xdata,1,ydata,2);
        
        % Validate I
        I = varargin{3};
        validateImage(I,3);
        
        % Validate rect
        rect = varargin{4};
        validateRectangle(rect,4);
    otherwise
        coder.internal.assert(false,'images:imcrop:unsupportedCodegenSyntax');
end

%--------------------------------------------------------------------------
function validateImage(I,inputNumber)

coder.inline('always');
coder.internal.prefer_const(I,inputNumber);

validateattributes(I,{'logical','numeric'},{'real','nonsparse'}, ...
    mfilename,'I',inputNumber);

isGrayscale = ismatrix(I);
isRGB = (ndims(I) == 3) && (size(I,3) == 3);

coder.internal.errorIf(~isGrayscale && ~isRGB, ...
    'images:imcrop:invalidInputImage');

%--------------------------------------------------------------------------
function validateRectangle(rect,inputNumber)

coder.inline('always');
coder.internal.prefer_const(rect,inputNumber);

validateattributes(rect,{'numeric'},{'real','vector'}, ...
    mfilename,'RECT',inputNumber);

% variable sizing is not allowed for rect
coder.internal.errorIf(~coder.internal.isConst(size(rect)), ...
    'images:validate:inputMustBeFixedSized',inputNumber,'RECT');

% rect must contain 4 elements: [x,y,w,h]
coder.internal.errorIf(numel(rect) ~= 4, ...
    'images:validate:badInputNumel',inputNumber,'RECT',4);

%--------------------------------------------------------------------------
function validateXYData(x,xInputNumber,y,yInputNumber)

coder.inline('always');
coder.internal.prefer_const(x,xInputNumber,y,yInputNumber);

validateattributes(x,{'numeric'},{'real','vector','finite'}, ...
    mfilename,'X',xInputNumber);
validateattributes(x,{'numeric'},{'real','vector','finite'}, ...
    mfilename,'Y',yInputNumber);

% variable sizing is not allowed for xdata and ydata
coder.internal.errorIf(~coder.internal.isConst(size(x)), ...
    'images:validate:inputMustBeFixedSized',xInputNumber,'X');
coder.internal.errorIf(~coder.internal.isConst(size(y)), ...
    'images:validate:inputMustBeFixedSized',yInputNumber,'Y');

% xdata and ydata must contain 2 elements
coder.internal.errorIf(numel(x) ~= 2, ...
    'images:validate:badInputNumel',xInputNumber,'X',2);
coder.internal.errorIf(numel(y) ~= 2, ...
    'images:validate:badInputNumel',yInputNumber,'Y',2);

worldAndIntrinsicSystemsInverted = (x(2)-x(1)) < 0 || (y(2)-y(1)) < 0;
coder.internal.errorIf(worldAndIntrinsicSystemsInverted, ...
    'images:imcrop:invertedWorldCoordinateSystem');

%--------------------------------------------------------------------------
function J = doCrop(I,xdata,ydata,rect)

coder.inline('always');
coder.internal.prefer_const(I,xdata,ydata,rect);

% Image dimensions
numRow = coder.internal.indexInt(size(I,1));
numCol = coder.internal.indexInt(size(I,2));

xmin = coder.internal.inf('double');
xmax = 0;
for k = coder.unroll(1:length(xdata))
    x = xdata(k);
    if (x > xmax)
        xmax = x;
    end
    if (x < xmin)
        xmin = x;
    end
end

ymin = coder.internal.inf('double');
ymax = 0;
for k = coder.unroll(1:length(ydata))
    y = ydata(k);
    if (y > ymax)
        ymax = y;
    end
    if (y < ymin)
        ymin = y;
    end
end

% Transform rectangle into row and column indices
if (numRow == 1)
    pixelsPerVerticalUnit = 1;
else
    pixelsPerVerticalUnit = (double(numRow) - 1) / (ymax - ymin);
end
if (numCol == 1)
    pixelsPerHorizontalUnit = 1;
else
    pixelsPerHorizontalUnit = (double(numCol) - 1) / (xmax - xmin);
end

pixelHeight = rect(4) * pixelsPerVerticalUnit;
pixelWidth  = rect(3) * pixelsPerHorizontalUnit;

% New row indices
r1 = (rect(2) - ymin) * pixelsPerVerticalUnit + 1;
rowIdx2 = coder.internal.indexInt(round(r1 + pixelHeight));
rowIdx1 = coder.internal.indexInt(round(r1));

% New column indices
c1 = (rect(1) - xmin) * pixelsPerHorizontalUnit + 1;
colIdx2 = coder.internal.indexInt(round(c1 + pixelWidth));
colIdx1 = coder.internal.indexInt(round(c1));

% Check whether rectangle is completely outside the image
if (rowIdx1 > numRow) || (rowIdx2 < 1) || ...
        (colIdx1 > numCol) || (colIdx2 < 1)
    J = cast([],'like',I);
else
    % Crop the intersection of the rectangle with the image
    % r1 = max(r1,1);
    if (rowIdx1 < 1)
        rowIdx1 = coder.internal.indexInt(1);
    end
    % r2 = min(r2,numRow);
    if (rowIdx2 > numRow)
        rowIdx2 = numRow;
    end
    % c1 = max(c1,1);
    if (colIdx1 < 1)
        colIdx1 = coder.internal.indexInt(1);
    end
    % c2 = min(c2,numCol);
    if (colIdx2 > numCol)
        colIdx2 = numCol;
    end
    % Crop
    J = I(rowIdx1:rowIdx2, colIdx1:colIdx2, :);
end
