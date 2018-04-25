function RGB = label2rgb(label,map,varargin) %#codegen
%MATLAB Code Generation Library Function

% Limitations for RGB = LABEL2RGB(LABEL, MAP, ZEROCOLOR, ORDER)
%
%   At least two input arguments are required: LABEL2RGB(LABEL,MAP)
%
%   MAP must be an n-by-3 double colormap matrix.  Not supported: string
%   containing the name of a MATLAB colormap function. Not supported:
%   function handle of a colormap function.
%
%   No warning is thrown if ZEROCOLOR matches the color of one of the
%   regions in LABEL.
%
%   ORDER 'shuffle' is not supported.

% ZEROCOLOR and ORDER do not need to be coder.Constant(). Error checking is
% done at runtime.

%   Copyright 1996-2015 The MathWorks, Inc.

% Number of input args supported by the toolbox version
narginchk(1,4);

% Both LABEL and MAP must be input in MATLAB Coder
coder.internal.errorIf(nargin < 2,'images:label2rgb:tooFewInputsCodegen');
coder.internal.prefer_const(label,map);

% Validate LABEL
if islogical(label)
    validateattributes(label,{'numeric','logical'}, ...
        {'real','2d','nonsparse'}, ...
        mfilename,'L',1);
else
    % We have to differentiate between numeric and logical because of g1238468
    validateattributes(label,{'numeric','logical'}, ...
        {'real','2d','nonsparse','finite','nonnegative','integer'}, ...
        mfilename,'L',1);
end

% Validate MAP
validateMap(map);

% Parse and validate ZEROCOLOR
if (nargin < 3)
    zerocolor = [1 1 1];   % white
else
    zerocolor_in = varargin{1};
    zerocolor = parseZerocolor(zerocolor_in);
    validateZerocolor(zerocolor);
end

% Validate 'noshuffle'
if (nargin >= 4)
    order = varargin{2};
    coder.internal.prefer_const(order);
    % Only support 'noshuffle' for code generation using MATLAB.
    coder.internal.errorIf(~eml_partial_strcmp('noshuffle',eml_tolower(order)),...
           'images:label2rgb:shuffleNotSupported');
end

% Concatenate with zero color and 
% convert double 0 <= map <= 1 to uint8 0 <= CMAP <= 255 
CMAP = uint8([zerocolor; map] * 255);

% The actual algorithm (equivalent to ind2rgb8)
[m,n] = size(label);
RGB = coder.nullcopy(zeros(m,n,3,'uint8'));
if coder.isColumnMajor()
    for j = 1:n
        for i = 1:m
            index = coder.internal.indexPlus(coder.internal.indexInt(label(i,j)),1);
            RGB(i,j,:) = CMAP(index,:);
        end
    end
else
    for i = 1:m
        for j = 1:n
            index = coder.internal.indexPlus(coder.internal.indexInt(label(i,j)),1);
            RGB(i,j,:) = CMAP(index,:);
        end
    end
end

%--------------------------------------------------------------------------
function validateMap(map)

coder.internal.errorIf(isa(map,'char'), ...
    'images:label2rgb:invalidColormapCodegen');

coder.internal.errorIf(~isa(map,'double') || isempty(map) || ...
    ~ismatrix(map) || size(map,2)~=3 || ~isreal(map), ...
    'images:label2rgb:invalidColormap');

coder.internal.errorIf(~ALL_BETWEEN_ZERO_AND_ONE(map), ...
    'images:label2rgb:invalidColormap');

%--------------------------------------------------------------------------
function zerocolor = parseZerocolor(zerocolor_in)

coder.internal.prefer_const(zerocolor_in);

if ischar(zerocolor_in)
    color_spec = eml_tolower(zerocolor_in);
    assert(~isempty(color_spec) && ~isequal('bl',color_spec),...
        eml_message('images:label2rgb:notInColorspecCodegenbl'));
    if     eml_partial_strcmp('yellow',color_spec)
        zerocolor = [1 1 0];   % yellow
    elseif eml_partial_strcmp('magenta',color_spec)
        zerocolor = [1 0 1];   % magenta
    elseif eml_partial_strcmp('cyan',color_spec)
        zerocolor = [0 1 1];   % cyan
    elseif eml_partial_strcmp('red',color_spec)
        zerocolor = [1 0 0];   % red
    elseif eml_partial_strcmp('green',color_spec)
        zerocolor = [0 1 0];   % green
    elseif isequal('b', color_spec) || eml_partial_strcmp('blue',color_spec)
        zerocolor = [0 0 1];   % blue
    elseif eml_partial_strcmp('white',color_spec)
        zerocolor = [1 1 1];   % white
    elseif isequal('k',color_spec) || eml_partial_strcmp('black',color_spec)
        zerocolor = [0 0 0];   % black
    else
        assert(false,eml_message('images:label2rgb:notInColorspecCodegen'));
        zerocolor = [1 1 1]; % To set types and sizes for compilation step
    end
else
    zerocolor = zerocolor_in;
end

%--------------------------------------------------------------------------
function validateZerocolor(zerocolor)

coder.internal.errorIf(~isa(zerocolor,'double') || ...
       ~isequal(size(zerocolor),[1,3]) || ~isreal(zerocolor), ...
       'images:label2rgb:invalidZerocolor');
   
coder.internal.errorIf(~ALL_BETWEEN_ZERO_AND_ONE(zerocolor), ...
       'images:label2rgb:invalidZerocolor');

%--------------------------------------------------------------------------
function p = ALL_BETWEEN_ZERO_AND_ONE(v)

[M,N] = size(v);
for r = 1:M
    for c = 1:N
        if ~(v(r,c) >= 0 && v(r,c) <= 1)
            p = false;
            return
        end
    end    
end

p = true;
