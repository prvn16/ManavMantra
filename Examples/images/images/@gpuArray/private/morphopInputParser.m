function [A,se,padfull,unpad,op_type, padSize] = morphopInputParser(A,se,op_type,func_name,varargin)
%MORPHOPINPUTPARSER Parse and validate inputs to morphology family of
%functions and determine padding requirements. Intended for use with
%morphopAlgo in functions IMDILATE, IMERODE, IMOPEN, IMCLOSE, IMTOPHAT and
%IMBOTHAT.

% Copyright 2013-2016 The MathWorks, Inc.

narginchk(4,5);

% Get required inputs and check for validity.
A  = checkInputImage(A);
se = strelcheck(se,func_name,'SE',2);

padSizeNumels = max(cellfun(@(c) ndims(c), {se.Neighborhood}));
padSize = zeros(1, padSizeNumels);
for sInd = 1:numel(se)
    nsize = size(se(sInd).Neighborhood);
    for nInd = 1:numel(nsize)
        padSize(nInd) = max(padSize(nInd), nsize(nInd));
    end
end
padSize = ceil(padSize/2);


% Process optional arguments.
padopt = processOptionalArguments(func_name,varargin{:});

% Get sequence of structuring elements.
se = getsequence(se);

% Find conditionals needed to determing padding requirements.
num_strels      = length(se);
strel_is_single = num_strels == 1;
output_is_full  = strcmp(padopt,'full');

% Check structuring element error conditions. Only 2D, flat structuring
% elements are allowed.
strel_is_all_2d = true;
for k = 1:num_strels
    if (ndims(getnhood(se(k))) > 2) %#ok<ISMAT>
        strel_is_all_2d = false;
        break;
    end
end

if ~strel_is_all_2d
    error(message('images:morphop:gpuStrelNot2D'));
end

strel_is_all_flat = all(isflat(se));
if ~strel_is_all_flat
    error(message('images:morphop:gpuStrelNotFlat'));
end

% Reflect the structuring element if dilating.
if strcmp(op_type,'dilate')
    se = reflect2dFlatStrel(se);
else
    % If a structuring element is empty, pad a zero by reflecting. This is
    % required because the underlying GPU implementation does not accept empty
    % neighbohoods.
    for k = 1:num_strels
        if isempty(getnhood(se(k)))
            se(k)=reflect2dFlatStrel(se(k));
        end
    end
end

% Determine whether padding and unpadding is necessary.

% Pad the input when the pad option is'full' or the structuring element is 
% not single.
padfull = output_is_full || (~strel_is_single);

% Unpad only if the pad option is 'same' and the structuring element is
% not single.
unpad = (~strel_is_single) && (~output_is_full);

%--------------------------------------------------------------------------

%==========================================================================
function A = checkInputImage(A)
%Check input image validity
%  The input image must be a gpuArray holding real,nonsparse data of type
%  UINT8 or LOGICAL.

if ~isreal(A)
    error(message('images:morphop:gpuImageComplexity'));
end

if issparse(A)
    error(message('images:validate:gpuExpectedNonSparse'));
end

if ~(strcmp(classUnderlying(A),'uint8') || strcmp(classUnderlying(A),'logical'))
    error(message('images:morphop:gpuUnderlyingClassTypeImage'));
end
        
%--------------------------------------------------------------------------

%==========================================================================
function padopt = processOptionalArguments(func_name, varargin)
% Process padding option.

% Default value
padopt = 'same';

if ~isempty(varargin)
    allowed_strings = {'same','full'};
    padopt = validatestring(varargin{1},allowed_strings, func_name,...
                            'OPTION',3);
end
%--------------------------------------------------------------------------
