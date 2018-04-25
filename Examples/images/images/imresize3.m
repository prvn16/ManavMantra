function B = imresize3(varargin)
%IMRESIZE3 Resize 3D volumetric intensity image.
%   B = IMRESIZE3(V, SCALE) returns a volume B that is SCALE times the size
%   of V. The input image V must be a 3D volumetric intensity image.
%  
%   B = IMRESIZE3(V, [NUMROWS NUMCOLS NUMPLANES]) resizes the image so that 
%   it has the specified number of rows, columns, and planes.  Either all 
%   three elements can be numeric, or exactly one element can be numeric 
%   while the other two elements are NaN, in which case imresize3 computes 
%   the other two elements automatically to preserve the image aspect 
%   ratio.
%  
%   To control the interpolation method used by IMRESIZE3, add a METHOD
%   argument to any of the syntaxes above, like this:
%
%       IMRESIZE3(V, SCALE, METHOD)
%       IMRESIZE3(V, [NUMROWS NUMCOLS NUMPLANES], METHOD)
%
%   METHOD can be a string or a character vector naming a general
%   interpolation method:
%  
%       'nearest'  - nearest-neighbor interpolation
% 
%       'linear'   - linear interpolation
% 
%       'cubic'    - cubic interpolation; the default method
%
%   METHOD can also be a string or a character vector naming an
%   interpolation kernel:
%
%       'box'        - interpolation with a box-shaped kernel
%
%       'triangle'   - interpolation with a triangular kernel
%                         (equivalent to 'linear')
%
%       'lanczos2'   - interpolation with a Lanczos-2 kernel
%  
%       'lanczos3'   - interpolation with a Lanczos-3 kernel
%  
%   You can achieve additional control over IMRESIZE3 by using
%   parameter/value pairs following any of the syntaxes above.  For
%   example:
%
%       B = IMRESIZE3(V, SCALE, PARAM1, VALUE1, PARAM2, VALUE2, ...)
%
%   Parameters include:
%  
%       'Antialiasing'  - true or false; specifies whether to perform 
%                         antialiasing when shrinking an image. The
%                         default value depends on the interpolation 
%                         method you choose.  For the 'nearest' method,
%                         the default is false; for all other methods,
%                         the default is true.
%  
%       'Method'        - As described above
%  
%       'OutputSize'    - A three-element vector,
%                         [NUMROWS NUMCOLS NUMPLANES],
%                         specifying the output size.  Exactly two elements
%                         may be NaN, in which case these two elements are
%                         computed automatically to preserve the aspect
%                         ratio of the image. 
%  
%       'Scale'         - A scalar or three-element vector specifying the
%                         resize scale factors.  If it is a scalar, the
%                         same scale factor is applied to each
%                         dimension.  If it is a vector, it contains
%                         the scale factors for the row, column, and plane
%                         dimensions, respectively.
%
%   Examples
%   --------
%   This example resizes an MRI volume and halves all the dimensions.
%
%   load('mristack');
%   sizeO = size(mristack);
%   
%   % Display the original volume
%   figure;
%   slice(double(mristack), sizeO(2)/2, sizeO(1)/2, sizeO(3)/2);
%   shading interp, colormap gray;
%   title('Original');
%
%   smallerMriStack = imresize3(mristack, 0.5);
%   sizeR = size(smallerMriStack);
%
%   % Visualize the resized volume
%   figure;
%   slice(double(smallerMriStack), sizeR(2)/2, sizeR(1)/2, sizeR(3)/2);
%   shading interp, colormap gray;
%   title('Resized');
%  
%   Note
%   ----
%   For cubic interpolation, the output image may have some values
%   slightly outside the range of pixel values in the input image.
%
%   Class Support
%   -------------
%   The input image V must be numeric and nonsparse.
%   The output image is of the same class as the input image.
%  
%   See also IMRESIZE, IMROTATE, IMTRANSFORM, TFORMARRAY.

%   Copyright 2016-2017 The MathWorks, Inc.

args   = matlab.images.internal.stringToChar(varargin);
params = parseInputs(args{:});

% Determine which dimension to resize first.
order = matlab.images.internal.resize.dimensionOrder(params.scale);

% Calculate interpolation weights and indices for each dimension.
weights = cell(1,params.num_dims);
indices = cell(1,params.num_dims);
allDimNearestNeighbor = true;
for k = 1:params.num_dims
    [weights{k}, indices{k}] = matlab.images.internal.resize.contributions(...
        size(params.A, k), ...
        params.output_size(k), params.scale(k), params.kernel, ...
        params.kernel_width, params.antialiasing);
    
    if ~matlab.images.internal.resize.isPureNearestNeighborComputation(weights{k})
        allDimNearestNeighbor = false;
    end
end

if allDimNearestNeighbor
    
    B = matlab.images.internal.resize.resizeAllDimUsingNearestNeighbor(params.A, indices);
    
else
    B = params.A;
    for k = 1:numel(order)
        dim = order(k);
        
        B = resizeAlongDim(B, dim, weights{dim}, indices{dim});
    end
end

%=====================================================================
function params = parseInputs(varargin)
% Parse the input arguments, returning the resulting set of parameters
% as a struct.

narginchk(1, Inf);

% Set parameter defaults.
params.kernel = @matlab.images.internal.resize.cubic;
params.kernel_width = 4;
params.antialiasing = [];
params.num_dims = 3; % This parameter is used to distinguish between 
                     % imresize and imresize3. It is 2 for imresize and 3 
                     % for imresize3.  This way, some methods can be 
                     % generalized for both functions.
params.size_dim = []; % If user specifies NaNs for output size, this
                      % parameter indicates the dimension for which the
                      % size was specified.

method_arg_idx = findMethodArg(varargin{:});

first_param_string_idx = matlab.images.internal.resize.findFirstParamString( ...
    varargin, method_arg_idx);

[params.A, params.scale, params.output_size] = ...
    parsePreMethodArgs(varargin, method_arg_idx, first_param_string_idx);

if ~isempty(method_arg_idx)
    [params.kernel, params.kernel_width, params.antialiasing] = ...
        parseMethodArg(varargin{method_arg_idx});
end

params = parseParamValuePairs(params, varargin, first_param_string_idx);

params = fixupSizeAndScale(params);

if isempty(params.antialiasing)
    % If params.antialiasing is empty here, that means the user did not
    % explicitly specify a method or the Antialiasing parameter.  The
    % default interpolation method is bicubic, for which the default
    % antialiasing is true.
    params.antialiasing = true;
end
    
%---------------------------------------------------------------------

%=====================================================================
function idx = findMethodArg(varargin)
% Find the location of the method argument, if it exists, before the
% param-value pairs.  If not found, return [].

idx = [];
for k = 1:nargin
    arg = varargin{k};
    if ischar(arg)
        if isMethodString(arg)
            idx = k;
            break;
        else
            % If this argument is a string but is not a method string, it
            % must be a parameter string.
            break;
        end
    end
end
%---------------------------------------------------------------------

%=====================================================================
function [A, scale, output_size] = parsePreMethodArgs(args, method_arg_idx, ...
                                                  first_param_idx)
% Parse all the input arguments before the method argument.

% Keep only the arguments before the method argument.
if ~isempty(method_arg_idx)
    args = args(1:method_arg_idx-1);
elseif ~isempty(first_param_idx)
    args = args(1:first_param_idx-1);
end

% There must be at least one input argument before the method argument.
if numel(args) < 1
    error(message('MATLAB:images:imresize:badSyntaxMissingImage'));
end

% Set default outputs.
scale = [];
output_size = [];

A = args{1};
validateattributes(A, {'single', ...
                       'double', ...
                       'int8', ...
                       'int16', ...
                       'int32', ...
                       'uint8', ...
                       'uint16', ...
                       'uint32'}, ...
                      {'nonsparse', ...
                       'nonempty'}, ...
                       mfilename, 'V', 1);

% The image input must be 3D
if ndims(A) > 3
    error(message('images:imresize3:incorrectDimensions', ndims(A)));
end

if numel(args) < 2
    return
end

next_arg = 2;
next = args{next_arg};

% The next input argument must either be the scale or the output size.
[scale, output_size] = scaleOrSize(next, next_arg);
next_arg = next_arg + 1;

if next_arg <= numel(args)
    error(message('MATLAB:images:imresize:badSyntaxUnrecognizedInput', next_arg));
end
%---------------------------------------------------------------------

%=====================================================================
function [scale, output_size] = scaleOrSize(arg, position)
% Determine whether ARG is the scale factor or the output size.

scale = [];
output_size = [];

if isnumeric(arg) && isscalar(arg)
    % Argument looks like a scale factor.
    validateattributes(arg, {'numeric'}, {'nonzero', 'real'}, mfilename, ...
        'SCALE', position);
    scale = double(arg);

elseif isnumeric(arg) && isvector(arg) && (numel(arg) == 3)
    % Argument looks like output_size.
    validateattributes(arg, {'numeric'}, {'vector', 'real', 'positive'}, ...
                  mfilename, '[NUMROWS NUMCOLS NUMPLANES]', position);
    output_size = double(arg);
    
else
    error(message('images:imresize3:badScaleOrSize'));
end
%---------------------------------------------------------------------

%=====================================================================
function [kernel, kernel_width, antialiasing] = parseMethodArg(method)
% Return the kernel function handle and kernel width corresponding to
% the specified method.

[valid_method_names, method_kernels, kernel_widths] = getMethodInfo();

antialiasing = true;

% Replace validatestring here as an optimization. -SLE, 31-Oct-2006
idx = find(strncmpi(method, valid_method_names, numel(method)));

switch numel(idx)
    case 0
        error(message('MATLAB:images:imresize:unrecognizedMethodString', method));
        
    case 1
        kernel = method_kernels{idx};
        kernel_width = kernel_widths(idx);
        if strcmp(valid_method_names{idx}, 'nearest')
            antialiasing = false;
        end
        
    otherwise
        error(message('MATLAB:images:imresize:ambiguousMethodString', method));
end
%---------------------------------------------------------------------

%=====================================================================
function tf = isMethodString(in)
% Returns true if the input is the name of a method.

if ~ischar(in)
    tf = false;
    
else
    valid_method_strings = getMethodInfo();

    num_matches = sum(strncmpi(in, valid_method_strings, numel(in)));
    tf = num_matches == 1;
end
%---------------------------------------------------------------------

%=====================================================================
function [names,kernels,widths] = getMethodInfo

% Original implementation of getMethodInfo returned this information as
% a single struct array, which was somewhat more readable. Replaced
% with three separate arrays as a performance optimization. -SLE,
% 31-Oct-2006

% For imresize3, linear and cubic should be specified instead of
% trilinear and tricubic.  However, trilinear and tricubic will still
% be accepted, and they will map to linear and cubic, respectively.
names = {'nearest', ...
         'linear', ...
         'trilinear', ...
         'cubic', ...
         'tricubic', ...
         'box', ...
         'triangle', ...
         'lanczos2', ...
         'lanczos3'};

kernels = {@matlab.images.internal.resize.box, ...
           @matlab.images.internal.resize.triangle, ...
           @matlab.images.internal.resize.triangle, ...
           @matlab.images.internal.resize.cubic, ...
           @matlab.images.internal.resize.cubic, ...
           @matlab.images.internal.resize.box, ...
           @matlab.images.internal.resize.triangle, ...
           @matlab.images.internal.resize.lanczos2, ...
           @matlab.images.internal.resize.lanczos3};

widths = [1.0 2.0 2.0 4.0 4.0 1.0 2.0 4.0 6.0];
%---------------------------------------------------------------------

%=====================================================================
function params = parseParamValuePairs(params_in, args, first_param_string)

params = params_in;

if isempty(first_param_string)
    return
end

if rem(numel(args) - first_param_string, 2) == 0
    error(message('images:imresize3:oddNumberArgs'));
end

% Originally implemented valid_params and param_check_fcns as a
% structure which was accessed using dynamic field reference.  Changed
% to separate cell arrays as a performance optimization. -SLE,
% 31-Oct-2006
valid_params = {'Scale', ...
                'OutputSize', ...
                'Method', ...
                'Antialiasing'};

param_check_fcns = {@processScaleParam, ...
                    @processOutputSizeParam, ...
                    @processMethodParam, ...
                    @matlab.images.internal.resize.processAntialiasingParam};

for k = first_param_string:2:numel(args)
    param_string = args{k};
    if ~ischar(param_string)
        error(message('MATLAB:images:imresize:expectedParamString', k));
    end
                  
    idx = find(strncmpi(param_string, valid_params, numel(param_string)));
    num_matches = numel(idx);
    if num_matches == 0
        error(message('MATLAB:images:imresize:unrecognizedParamString', param_string));
    
    elseif num_matches > 1
        error(message('MATLAB:images:imresize:ambiguousParamString', param_string));
        
    else
        check_fcn = param_check_fcns{idx};
        params = check_fcn(args{k+1}, params);

    end
end
%---------------------------------------------------------------------

%=====================================================================
function params = processScaleParam(arg, params_in)

valid = isnumeric(arg) && ...
    ((numel(arg) == 1) || (numel(arg) == params_in.num_dims)) && ...
    all(arg > 0);

if ~valid
    error(message('images:imresize3:invalidScale'));
end

params = params_in;
params.scale = arg;
%---------------------------------------------------------------------

%=====================================================================
function params = processOutputSizeParam(arg, params_in)

valid = isnumeric(arg) && ...
    (numel(arg) == params_in.num_dims) && ...
    all(isnan(arg) | (arg > 0));
if ~valid
    error(message('images:imresize3:badOutputSize'));
end

params = params_in;
params.output_size = arg;
%---------------------------------------------------------------------

%=====================================================================
function params = processMethodParam(arg, params_in)

if ~isMethodString(arg)
    if ischar(arg) || isnumeric(arg) || isstring(arg)
        error(message('images:imresize3:badMethod', arg));
    else
        error(message('images:imresize3:badMethod', class(arg)));
    end
end

params = params_in;
[params.kernel, params.kernel_width, antialiasing] = parseMethodArg(arg);
if isempty(params.antialiasing)
    % Antialiasing hasn't been set explicity in the input arguments
    % parsed so far, so set it according to what parseMethodArg
    % returns.
    params.antialiasing = antialiasing;
end
%---------------------------------------------------------------------

%=====================================================================
function params = fixupSizeAndScale(params_in)
% If the scale factor was specified as a scalar, turn it into a
% params.num_dims element vector.  If the scale factor wasn't specified,
% derive it from the specified output size.
%
% If the output size has NaN(s) in it, fill in the value(s)
% automatically. If the output size wasn't specified, derive it from
% the specified scale factor.

params = params_in;

if isempty(params.scale) && isempty(params.output_size)
    error(message('MATLAB:images:imresize:missingScaleAndSize'));
end

% If the input is a scalar, turn it into a params.num_dims element vector.
if ~isempty(params.scale) && isscalar(params.scale)
    params.scale = repmat(params.scale, 1, params.num_dims);
end

[params.output_size, params.size_dim] = fixupSize(params);

if isempty(params.scale)
    params.scale = matlab.images.internal.resize.deriveScaleFromSize(params);
end

if isempty(params.output_size)
    params.output_size = matlab.images.internal.resize.deriveSizeFromScale(params);
end
%---------------------------------------------------------------------

%=====================================================================
function [output_size, size_dim] = fixupSize(params)
% If params.output_size has two NaNs in it, calculate the appropriate
% value to substitute for the NaNs.

output_size = params.output_size;
size_dim = [];

if ~isempty(output_size)
    if ~all(output_size)
        error(message('images:imresize3:zeroOutputSize'));
    end
    
    if all(isnan(output_size))
        error(message('images:imresize3:allNaN'));
    end
    
    if isnan(output_size(1)) && isnan(output_size(2))
        size_dim = 3;
        output_size(1) = calcOutputSizeForDim(params, 1, size_dim);
        output_size(2) = calcOutputSizeForDim(params, 2, size_dim);
        
    elseif isnan(output_size(1)) && isnan(output_size(3))
        size_dim = 2;
        output_size(1) = calcOutputSizeForDim(params, 1, size_dim);
        output_size(3) = calcOutputSizeForDim(params, 3, size_dim);
        
    elseif isnan(output_size(2)) && isnan(output_size(3))
        size_dim = 1;
        output_size(2) = calcOutputSizeForDim(params, 2, size_dim);
        output_size(3) = calcOutputSizeForDim(params, 3, size_dim);
        
    elseif any(isnan(output_size))
        error(message('images:imresize3:invalidOutputSize'));
    end
    
    output_size = ceil(output_size);
end
%---------------------------------------------------------------------

%=====================================================================
function output_size = calcOutputSizeForDim(params, dim_unknown, dim_known)
% Determine the output size for a single dimension from a dimension
% whose output size is known.

output_size = params.output_size(dim_known) * ...
    size(params.A, dim_unknown) / size(params.A, dim_known);
%---------------------------------------------------------------------

%=====================================================================
function out = resizeAlongDim(in, dim, weights, indices)
% Resize along a specified dimension
%
% in           - input array to be resized
% dim          - dimension along which to resize
% weights      - weight matrix; row k is weights for k-th output pixel
% indices      - indices matrix; row k is indices for k-th output pixel

if matlab.images.internal.resize.isPureNearestNeighborComputation(weights)
    out = matlab.images.internal.resize.resizeAlongDimUsingNearestNeighbor(in, ...
        dim, indices);
    return
end

% If dim is 3, permute the input matrix so that the third dimension
% becomes the first dimension.  This way, we can resize along the
% third dimensions as though we were resizing along the first dimension.
isThirdDimResize = 3 == dim;
if isThirdDimResize
    in = permute(in,[3 2 1]);
    dim = 1;
end

% The 'out' datatype will be same as 'in' datatype
out = matlab.images.internal.resize.imresizemex(in, weights', indices', dim);

% Permute back so that the original dimensions are restored if we were
% resizing along the third dimension.
if isThirdDimResize
    out = permute(out,[3 2 1]);
end
%---------------------------------------------------------------------
