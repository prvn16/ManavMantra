function b = medfilt2(varargin) %#codegen
%MEDFILT2 2-D median filtering.

%   Copyright 2014-2017 The MathWorks, Inc.

%#ok<*EMCA>

coder.internal.prefer_const(varargin);

narginchk(1,3);

% Note: padopt is an enum and NOT a string. Use padopt wherever possible to
% generate efficient code. Don't use strcmp with padopt.
[ain, mn, padopt] = parseInputs(varargin{:});

if isempty(ain)
    b = ain;
    return
end

coder.extrinsic('images.internal.coder.useSharedLibrary');

useSharedLibrary = coder.const(images.internal.coder.isCodegenForHost()) && ...
        coder.const(images.internal.coder.useSharedLibrary()) && ...
        coder.const(~images.internal.coder.useSingleThread());

if (useSharedLibrary)
    % MATLAB Host Target (PC)
    domain = ones(mn);
    if (rem(prod(mn), 2) == 1)
        if hUseIPPL(ain, mn, padopt)
            b = medianfilter(ain, [mn(1) mn(2)]);
        else
            order = (prod(mn)+1)/2;
            if padopt == ZEROS
                b = ordfilt2(ain, order, domain, 'zeros');
            elseif padopt == ONES
                b = ordfilt2(ain, order, domain, 'ones');
            else % padopt == SYMMETRIC
                b = ordfilt2(ain, order, domain, 'symmetric');
            end
        end
    else
        order1 = prod(mn)/2;
        order2 = order1+1;
        if padopt == ZEROS
            b1 = ordfilt2(ain, order1, domain, 'zeros');
            b2 = ordfilt2(ain, order2, domain, 'zeros');
        elseif padopt == ONES
            b1 = ordfilt2(ain, order1, domain, 'ones');
            b2 = ordfilt2(ain, order2, domain, 'ones');
        else % padopt == SYMMETRIC
            b1 = ordfilt2(ain, order1, domain, 'symmetric');
            b2 = ordfilt2(ain, order2, domain, 'symmetric');
        end
        
        if islogical(b1)
            b = b1 | b2;
    else
            b =	imlincomb(0.5, b1, 0.5, b2);
        end
    end
else
    % Non-PC Target
    b = medianfilter_portable(ain, mn, padopt);
end


%--------------------------------------------------------------------------
function b = medianfilter_portable(a, mn, padopt)

coder.inline('always');
coder.internal.prefer_const(a,mn,padopt);

if padopt == ZEROS
    np = images.internal.coder.NeighborhoodProcessor(size(a), true(mn),...
        coder.const('NeighborhoodCenter'),coder.const(images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT),...
        coder.const('Padding'),coder.const(images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT),...
        coder.const('PadValue'), coder.const(0));
elseif padopt == ONES
    np = images.internal.coder.NeighborhoodProcessor(size(a), true(mn),...
        coder.const('NeighborhoodCenter'), coder.const(images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT),...
        coder.const('Padding'),coder.const(images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT),...
        coder.const('PadValue'),coder.const(1));
else
    np = images.internal.coder.NeighborhoodProcessor(size(a), true(mn),...
        coder.const('NeighborhoodCenter'), coder.const(images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT),...
        coder.const('Padding'),coder.const(images.internal.coder.NeighborhoodProcessor.PADDING.SYMMETRIC));
end

if islogical(a)
    b = coder.nullcopy(false(size(a)));
    b = np.process(a,@nhMedfilt2Algo_logical,b,[]);
else
    b = coder.nullcopy(a);
    b = np.process(a,@nhMedfilt2Algo,b,[]);
end

%--------------------------------------------------------------------------
function out = nhMedfilt2Algo(imnh,~)
coder.inline('always');
% Find median of pixels in the neighborhood.
out =  median(imnh(:),1);

%--------------------------------------------------------------------------
function out = nhMedfilt2Algo_logical(imnh,~)
coder.inline('always');
% Find median of pixels in the neighborhood.
out =  sum(imnh(:),1)>=(numel(imnh(:)))/2;

%%%
%%% Function parse_inputs
%%%
function [a, mn, padopt] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin);

a = varargin{1};
% validate that the input is a 2D, real, numeric or logical matrix.
validateattributes(a, {'double', 'single', 'int8', 'uint8', 'int16', ...
    'uint16', 'int32', 'uint32','logical'}, ...
    {'2d','real','nonsparse'}, mfilename, 'A', 1);

% Input index to process
idx = 2;
if (nargin == 1)
    mn = [3 3];
    padopt = ZEROS;
elseif(nargin == 2)
    if (ischar(varargin{idx}))
        mn = [3 3];
        padopt = parsePADOPT(idx,varargin{:});
    else
        mn = parseMN(idx,varargin{:});
        padopt = ZEROS;
    end
else % (nargin == 3)
    if (ischar(varargin{idx})) && (ischar(varargin{idx+1}))
        mn = [];
        padopt = ZEROS;
        coder.internal.errorIf(true,...
            'images:medfilt2:tooManyStringInputs');
    elseif (isnumeric(varargin{idx})) && (isnumeric(varargin{idx+1}))
        mn = [];
        padopt = ZEROS;
        coder.internal.errorIf(true,...
            'images:medfilt2:invalidSyntax');
    elseif ischar(varargin{idx})
        padopt = parsePADOPT(idx,varargin{:});
        mn = parseMN(idx+1,varargin{:});
    else % ischar(varargin{k+1})
        mn = parseMN(idx,varargin{:});
        padopt = parsePADOPT(idx+1,varargin{:});
    end
end

function padopt = parsePADOPT(k,varargin)

coder.inline('always');
coder.internal.prefer_const(k,varargin);

eml_invariant(eml_is_const(varargin{k}),...
    eml_message('MATLAB:images:validate:codegenInputNotConst','PADOPT'),...
    'IfNotConst','Fail');

options = {'indexed', 'zeros', 'symmetric'};
padoptStr = validatestring(varargin{k}, options, mfilename, ...
    'PADOPT', k);

if strcmp(padoptStr,'zeros')
    padopt = ZEROS;
elseif strcmp(padoptStr,'symmetric')
    padopt = SYMMETRIC;
else %strcmp(padoptStr,'indexed')
    if isa(varargin{1},'double')
        padopt = ONES;
    else
        padopt = ZEROS;
    end
end

function mn = parseMN(k,varargin)

coder.inline('always');
coder.internal.prefer_const(varargin,k);

validateattributes(varargin{k}(:)',{'numeric'},{'real','positive','integer','nonempty','size',[1 2]},...
    mfilename,'[M N]',k);

mn = cast(varargin{k}(:)','double');

function padoptFlag = ZEROS()
coder.inline('always');
padoptFlag = int8(1);

function padoptFlag = SYMMETRIC()
coder.inline('always');
padoptFlag = int8(2);

function padoptFlag = ONES()
coder.inline('always');
padoptFlag = int8(3);

% ------------------------------------------------------------------------
function tf = hUseIPPL(a, mn, padopt)
% switch to IPP iff
% UseIPPL preference is true .AND.
% kernel is  odd .AND.
%      input data type is single .AND. kernel size is == 3x3
% .OR. input data type is uint8 .AND. kernel size is
%           1xn, n<=5
%   .OR.    nx1, n<=7
%   .OR.    between 3x3 and 19x19
% .OR. input data type is (int16 .OR. uint16) .AND. kernel size
%      is between 3x3 and 19x19

coder.inline('always');
coder.internal.prefer_const(a,mn);

tf = false;
% Symmetric pading is not supported by IPP
if(padopt == SYMMETRIC)
    return;
end

switch class(a)
    case 'single'
        if all(mn==[3 3])
            tf = true;
        end
    case 'uint8'
        if (mn(1)==1 && mn(2)<=5) || (all(mn >= [3 3]) && all(mn <= [19 19])) || (mn(2)==1 && mn(1)<=7)
            tf = true;
        end
    case {'uint16', 'int16'}
        if all(mn >= [3 3]) && all(mn <= [19 19])
            tf = true;
        end
end

coder.extrinsic('eml_try_catch');
% iptgetpref preference (obtained at compile time)
[errid, errmsg, prefFlag] = eml_const(eml_try_catch('iptgetpref', 'UseIPPL'));
eml_lib_assert(isempty(errmsg), errid, errmsg);

tf = tf & prefFlag;

% -------------------------------------------------------------------------
function Apad = hPadImage(Ain, domainSize, padopt)
% Pad the image suitably

coder.inline('always');
coder.internal.prefer_const(Ain, domainSize, padopt);

center = floor((domainSize + 1) / 2);
padSize = domainSize-center;

coder.internal.assert(((padopt == ZEROS) || ...
    (padopt == SYMMETRIC)),...
    'images:medfilt2:incorrectPaddingOption');

if padopt == ZEROS
    Apad = padarray(Ain, padSize, 0, 'both');
else % padopt is SYMMETRIC
    Apad = padarray(Ain, padSize, 'symmetric', 'both');
end

function outputImage = medianfilter(inputImage, maskSize)
% B = MEDIANFILTER(A,[maskSizeRows maskSizeCols]) where A is an 2-D image, 
% maskSizeRows and maskSizeCols specify the number of rows and columns in 
% the mask.

coder.inline('always');
coder.internal.prefer_const(inputImage, maskSize);

narginchk(2,2);

inputSize = size(inputImage);
% outputSize = inputSize - maskSize + 1;
outputSize = inputSize;

outputImage = coder.nullcopy(zeros(outputSize, 'like', inputImage));

fcnName = ['ippMedianFilter_', images.internal.coder.getCtype(inputImage)];
outputImage = images.internal.coder.buildable.Medianfilter_ippBuildable.medianfilter_ippCore(...
    fcnName, ...
    inputImage,  ...
    inputSize, ...
    maskSize, ...
    outputImage);
