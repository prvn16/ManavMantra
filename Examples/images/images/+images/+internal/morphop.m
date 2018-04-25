function B = morphop(varargin) %#codegen
%MORPHOP Dilate or erode image.
%   B = MORPHOP(OP_TYPE,A,SE,...) computes the erosion or dilation of A,
%   depending on whether OP_TYPE is 'erode' or 'dilate'.  SE is a
%   STREL array or an NHOOD array.  MORPHOP is intended to be called only
%   by IMDILATE or IMERODE.  Any additional arguments passed into
%   IMDILATE or IMERODE should be passed into MORPHOP following SE.  See
%   the help entries for IMDILATE and IMERODE for more details about the
%   allowable syntaxes.

%   Copyright 1993-2017 The MathWorks, Inc.

%#ok<*EMCA>

if ~coder.target('MATLAB')
    % Running in generated code
    B = images.internal.coder.morphop(varargin{:});
    return;
end

[A,se,pre_pad,...
 pre_pack,post_crop,post_unpack,op_type,is_packed,...
 unpacked_M,mex_method] = ParseInputs(varargin{:});

if is_packed
    % In a prepacked binary image, the fill bits at the bottom of the packed
    % array should be handled just like pad values.  The fill bits should be
    % 0 for dilation and 1 for erosion.
    
    fill_value = strcmp(op_type, 'erode');
    A          = images.internal.setPackedFillBits(A, unpacked_M, fill_value);
end

if pre_pad
    % Now compute how padding is needed based on the strel offsets.
    [pad_ul, pad_lr] = getpadsize(se);
    if strcmp(op_type,'erode')
        % Swap
        tmp    = pad_ul;
        pad_ul = pad_lr;
        pad_lr = tmp;
    end

    P = length(pad_ul);
    Q = ndims(A);
    if P < Q
        pad_ul = [pad_ul zeros(1,Q-P)];
        pad_lr = [pad_lr zeros(1,Q-P)];
    end
    
    if is_packed
        % Input is packed binary.  Adjust padding appropriately.
        pad_ul(1) = ceil(pad_ul(1) / 32);
        pad_lr(1) = ceil(pad_lr(1) / 32);
    end
    
    pad_val = getPadValue(A, op_type);

    A = padarray(A,pad_ul,pad_val,'pre');
    A = padarray(A,pad_lr,pad_val,'post');
end

if pre_pack
    unpacked_M = size(A,1);
    A          = bwpack(A);
end

%
% Apply the sequence of dilations/erosions.
%
B = A;
num_strels = length(se);
for sInd = 1:num_strels
    
    height = getheight(se(sInd));
    nhood  = getnhood(se(sInd));

    
    if(strcmp(op_type,'dilate'))
        % Flip 
        if(ismatrix(A))
            % If ndims(nhood)>2, then trailing dimension dont count.
            % Effectively, reflect only the first plane. (the rest get
            % flipped, but they are 'dont-cares').
            height = flip(flip(height,1),2);
            if(any(height(:)))
                % Flip nhood only for non-flat se. Other code paths flip
                % in CPP implementation 
                nhood  = flip(flip(nhood,1),2);
            end
        else
            height(1:end) = height(end:-1:1);
            if(any(height(:)))
                nhood(1:end)  = nhood(end:-1:1);
            end
        end
    end

    if useOCV(B, nhood, height)        
        ocvMethod = sprintf('%s_gray_ocv',op_type);                
        B = images.internal.morphmex(ocvMethod, B, logical(nhood), zeros(size(nhood)), unpacked_M);
    else
        B = images.internal.morphmex(mex_method, B, nhood, height, unpacked_M);
    end
end

%
% Image postprocessing steps.
%
if post_unpack
    B = bwunpack(B,unpacked_M);
end

if post_crop
    % Extract the "middle" of the result; it should be the same size as
    % the input image.
    idx = cell(1,ndims(B));
    for k = 1:ndims(B)
        P      = size(B,k) - pad_ul(k) - pad_lr(k);
        first  = pad_ul(k) + 1;
        last   = first + P - 1;
        idx{k} = first:last;
    end
    B = B(idx{:});
end
%--------------------------------------------------------------------------

%==========================================================================
function pad_value = getPadValue(A, op_type)
% Returns the appropriate pad value, depending on whether we are performing
% erosion or dilation, and whether or not A is logical (binary).

if strcmp(op_type, 'dilate')
   pad_value = -Inf;
else
   pad_value = Inf;
end

if islogical(A)
   % Use 0s and 1s instead of plus/minus Inf.
   pad_value = max(min(pad_value, 1), 0);
end
%--------------------------------------------------------------------------

%==========================================================================
function [A,se,pre_pad,pre_pack, ...
          post_crop,post_unpack,op_type,input_is_packed, ...
          unpacked_M,mex_method] = ParseInputs(A,se,op_type,func_name,varargin)

narginchk(4,7);

% Get the required inputs and check them for validity.
se = images.internal.strelcheck(se,func_name,'SE',2);
validateattributes(A, {'numeric' 'logical'}, ...
                      {'real' 'nonsparse','nonnan'}, ...
                      func_name, 'IM', 1);

% Process optional arguments.
[padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin{:});

% Check 
if strcmp(packopt,'ispacked')
    if unpacked_M >= 0
        d = 32*size(A,1) - unpacked_M;
        if (d < 0) || (d > 31)
            error(message('images:imerode:inconsistentUnpackedM'))
        end
    end
end

%
% Figure out the appropriate image preprocessing steps, image 
% postprocessing steps, and MEX-file method to invoke.
%
% First, find out the values of all the necessary predicates.
% 
se                = se.decompose();
num_strels        = length(se);
input_numdims     = ndims(A);
strel_is_single   = num_strels == 1;
input_is_uint32   = isa(A,'uint32');
input_is_packed   = strcmp(packopt,'ispacked');
input_is_logical  = islogical(A);
input_is_2d       = ismatrix(A);
output_is_full    = strcmp(padopt,'full');

strel_is_all_flat = true;
for sInd = 1:length(se)
    if (~isflat(se(sInd)))
        strel_is_all_flat = false;
        break;
    end
end

strel_is_all_2d = true;
for sInd = 1:length(se)
    if (~ismatrix(getnhood(se(sInd))))
        strel_is_all_2d = false;
        break;
    end
end

%
% Check for error conditions related to packing
%
if input_is_packed && strcmp(op_type, 'erode') && (unpacked_M < 1)
    error(message('images:morphop:missingPackedM'))
end
if input_is_packed && ~strel_is_all_2d
    error(message('images:morphop:packedStrelNot2D'))
end
if input_is_packed && ~input_is_uint32
    error(message('images:morphop:invalidPackedInputType'))
end
if input_is_packed && ~strel_is_all_flat
    error(message('images:morphop:nonflatStrelPacked'))
end
if input_is_packed && (input_numdims > 2)
    error(message('images:morphop:packedImageNot2D'))
end
if input_is_packed && output_is_full
    error(message('images:morphop:packedFull'))
end

%
% Next, use predicate values to determine the necessary
% preprocessing and postprocessing steps.
%

% If the user has asked for full-size output, or if there are multiple
% and/or decomposed strels that are not rectangular, then pre-pad the input image.
pre_pad = output_is_full || (~strel_is_single && ~isdecompositionorthogonal(se));

% If the input image is logical, then the strel must be flat.
if input_is_logical && ~strel_is_all_flat
    error(message('images:morphop:binaryWithNonflatStrel', func_name))
end

% If the input image is logical and not packed, and if there are multiple
% all-flat strels, the prepack the input image.
pre_pack = ~strel_is_single & input_is_logical & input_is_2d & ...
    strel_is_all_flat & strel_is_all_2d;

% If we had to pre-pad the input but the user didn't specify the 'full'
% option, then crop the image before returning it.
post_crop = pre_pad & ~output_is_full;

% If this function pre-packed the image, unpack it before returning it.
post_unpack = pre_pack;

%
% Finally, determine the appropriate MEX-file method to invoke.
%
if pre_pack || strcmp(packopt,'ispacked')
    mex_method = sprintf('%s_binary_packed',op_type);
    
elseif input_is_logical 
    if input_is_2d && strel_is_single && strel_is_all_2d
        if isequal(getnhood(se), ones(3))
            mex_method = sprintf('%s_binary_ones33',op_type);
        else
            mex_method = sprintf('%s_binary_twod',op_type);
        end
    else
        mex_method = sprintf('%s_binary',op_type);
    end
elseif strel_is_all_flat
    mex_method = sprintf('%s_gray_flat',op_type);
else
    mex_method = sprintf('%s_gray_nonflat',op_type);
end
%--------------------------------------------------------------------------

%==========================================================================
function TF = useOCV(A, nhood, height)

TF = false;
if isempty(nhood)
    return;
end

is2DInput = ismatrix(A);
strelIsAll2D = ismatrix(nhood);

isBadForOCV = false;
strelSize = size(nhood);
if any(strelSize > 200)
    isBadForOCV = true;
end
density = nnz(nhood)/numel(nhood);
if density < 0.05
    isBadForOCV = true;
end
supportedType   = isa(A,'uint8')...
    || islogical(A)...
    || isa(A,'uint16')...
    || isa(A,'int16')...
    || isa(A,'single')...
    || isa(A,'double');

TF  = is2DInput && supportedType && strelIsAll2D && ~any(height(:)) && ~isBadForOCV ; 
%--------------------------------------------------------------------------

%==========================================================================
function [padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin)

% Default values
padopt     = 'same';
packopt    = 'notpacked';
unpacked_M = -1;

args = matlab.images.internal.stringToChar(varargin);
allowed_strings = {'same','full','ispacked','notpacked'};

for k = 1:length(args)
    if ischar(args{k})
        str = validatestring(args{k}, allowed_strings, ...
            func_name, 'OPTION', k+2);
        switch str
            case {'full','same'}
                padopt = str;
            case {'ispacked','notpacked'}
                packopt = str;
        end
    else
        unpacked_M = args{k};
        validateattributes(unpacked_M, {'double'},...
            {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
            func_name, 'M', k+2);
    end
end