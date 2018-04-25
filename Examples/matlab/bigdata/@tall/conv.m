function C = conv(A, B, shape)
%CONV Convolution and polynomial multiplication for tall arrays
%   C = CONV(A,B)
%   C = CONV(A,B,SHAPE)
%
%   Limitations:
%   1) A and B must both be column vectors.
%   2) B cannot be a tall array.
%
%   See also CONV, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.


if nargin < 3
    shape = 'full';
end

tall.checkIsTall(upper(mfilename), 1, A);
A = tall.validateType(A, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, B, shape);

if ~(isnumeric(B) || islogical(B))
    error(message('MATLAB:conv2:inputType'));
end

A = tall.validateColumn(A, 'MATLAB:bigdata:array:ConvFirstArgNotColumnVector');
B = tall.validateColumn(B, 'MATLAB:bigdata:array:ConvSecondArgNotColumnVector');

try
    shape = validatestring(shape, {'full', 'same', 'valid'});
catch
    error(message('MATLAB:conv:unknownShapeParameter'));
end

% The convolution stencil window is determined by the length of B
if isempty(B)
    % Empty kernel doesn't need a window
    window = [0 0];
elseif mod(length(B), 2) == 0
    % for even numbered length(B), center the window on the current and
    % following slices.
    nb = length(B)/2;
    window = [nb-1 nb];
else
    n = (length(B)-1)/2;
    window = [n n];
end

if strcmpi(shape, 'full')
    aAdaptor = A.Adaptor;
    A = slicefun(@iAssertIfEmpty, A, isempty(A));
    A.Adaptor = aAdaptor;
    C = iConvCol(A, B, window, shape);
else
    C = ternaryfun(...
        iOutputIsRow(A, shape),...
        iConvRow(A, B, window, shape), ...
        iConvCol(A, B, window, shape));
end
end

function isRow = iOutputIsRow(A, shape)
isRow = ~strcmpi(shape, 'full') & size(A,1) == 1;
end

function C = iConvCol(A, B, window, shape)
convStencilFcn = iCreateConvStencilFcn(B, shape);

C = stencilfun(convStencilFcn, window, A);
C = iSetOutputSize(A, B, C, shape);
C = iSetOutputType(A.Adaptor.Class, isa(B, 'single'), C);
end

function C = iConvRow(A, B, window, shape)
% For same and valid convolution, the output C will be a row vector when A
% is a scalar and the adaptor should already be setup for column output.
C = iConvCol(A, B, window, shape);
rowAdaptor = setSizeInDim(C.Adaptor, 2, getSizeInDim(C.Adaptor,1));
rowAdaptor = setSizeInDim(rowAdaptor, 1, 1);
C = clientfun(@(x) x', C);
C.Adaptor = rowAdaptor;
end

function convStencilFcn = iCreateConvStencilFcn(B, shape)
% Use conv2 (2-D) within the stencilFcn instead of conv (1-D)
% This is necessary to generate the correct output shape which will either
% be a column or row vector.  The output will only be a row vector when the
% input shape is either 'same' or 'valid' and the tall input is scalar.
% Otherwise the output will always be a column vector since we restrict the
% allowed inputs to be column vectors.

if strcmpi(shape, 'full')
    convStencilFcn = @(varargin) iConvFullStencil(varargin{:}, B);
elseif strcmpi(shape, 'same')
    convStencilFcn = @(varargin) iConvSameStencil(varargin{:}, B);
else
    % shape must be 'valid', directly use conv
    convStencilFcn = @(~,x) conv2(x, B, shape);
end
end

function y = iConvFullStencil(info, x, B)
import matlab.bigdata.internal.util.indexSlices

if length(x) - sum(info.Padding) == 0
    % No data slices - only padding => empty chunk
    % Emit an empty column of the correct class using 'same'
    % convolution of an empty column.
    y = conv2(cast(zeros(0,1), 'like', x), B, 'same');
    return;
end

% Use full convolution for all chunks
y = conv2(x, B, 'full');

if info.IsHead && info.IsTail && sum(info.Padding) == 0
    % Scalar Case - all slices are valid so no indexing required
    return;
end

% A given data slice will contribute to length(B) output slices.  Given
% that the input is provided as:
%
%      x = [headPad; dataSlices; tailPad]
%
% We expect to process each input data slice up to 3 times (always once and
% up to two more times if provided as padding). The upshot is that a given
% output slice can be generated more than once and we need a unique
% assignment rule for determining which slices are valid outputs for the
% given input data slice.  We remove the redundancy by using a "centered
% kernel rule" which amounts to the following indexing rules:
%
% 1) First valid output slice corresponds to centering B on the first
%    data input slice.
% 2) Last valid output slice corresponds to centering B on the last data
%    input slice.
% 3) Augmentation near absolute boundaries: all leading/trailing slices of
%    the absolute head/tail chunk are always valid as these incorporate the
%    builtin zero-padding of conv.

firstDataSliceId = 1 + info.Padding(1);
lastDataSliceId = size(x,1) - info.Padding(2);
fwdWindow = info.Window(2);

if info.IsHead && info.Padding(1) == 0
    % Absolute head
    validOutputIds = 1:(lastDataSliceId+fwdWindow);
elseif info.IsTail && info.Padding(2) == 0
    % Absolute tail
    validOutputIds = (firstDataSliceId+fwdWindow) : size(y,1);
else
    % Body, partial head, or partial tail chunk
    validOutputIds = (firstDataSliceId:lastDataSliceId) + fwdWindow;
end

y = indexSlices(y, validOutputIds);
end

function y = iConvSameStencil(info, x, B)
if info.IsHead || info.IsTail
    y = conv2(x, B, 'same');
    y = iRemovePaddingSlices(y, info.Padding);
else
    y = conv2(x, B, 'valid');
end
end

function y = iRemovePaddingSlices(y, padding)
import matlab.bigdata.internal.util.indexSlices

y = indexSlices(y, padding(1) + 1 : size(y,1)-padding(2));
end

function C = iSetOutputSize(A, B, C, shape)
if isempty(B) || strcmpi(shape, 'same')
    % Empty kernel preserves the size like 'same'
    C.Adaptor = copySizeInformation(C.Adaptor, A.Adaptor);
elseif strcmpi(shape, 'full')
    % For full convolution: length(C) == length(A) + length(B) - 1
    C.Adaptor = reduceSizeInDimBy(A.Adaptor, 1, -(length(B)-1));
else
    % valid convolution: length(C) == length(A) - (length(B) - 1)
    C.Adaptor = reduceSizeInDimBy(A.Adaptor, 1, length(B)-1);
end
end

function C = iSetOutputType(classA,bIsSingle,C)
% When A or B are of type single, then the output is of type single.
% Otherwise, conv converts inputs to type double and returns type double.

if ~isempty(classA) && strcmpi('single', classA) || bIsSingle
    C = setKnownType(C, 'single');
else
    C = setKnownType(C, 'double');
end
end

function A = iAssertIfEmpty(A, tallInputEmpty)
% Cannot compute full convolution when tall input size is 0x1
assert(~tallInputEmpty, message('MATLAB:bigdata:array:ConvFirstArgCannotBeEmpty'));
end
