function Bout = morphop(A,se,op_type,func_name,varargin) %#codegen
%MORPHOP Dilate or erode image.
%   B = MORPHOP(OP_TYPE,A,SE,...) computes the erosion or dilation of A,
%   depending on whether OP_TYPE is 'erode' or 'dilate'.  SE is a
%   STREL array or an NHOOD array.  MORPHOP is intended to be called only
%   by IMDILATE or IMERODE.  Any additional arguments passed into
%   IMDILATE or IMERODE should be passed into MORPHOP following SE.  See
%   the help entries for IMDILATE and IMERODE for more details about the
%   allowable syntaxes.

%   Copyright 2013-2017 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(4,7);
% Extrinsic call to 'removePaddedZeros'. Used to compute padded Zeros in
% the structuring element.
coder.extrinsic('gpucoder.internal.removePaddedZeros');

%% Validate inputs
% Get the required inputs and check them for validity.
se = images.internal.strelcheck(se,func_name,'SE',2);
validateattributes(A, {'numeric' 'logical'}, ...
    {'real' 'nonsparse','nonnan'}, ...
    func_name, 'IM', 1);

% N-D not supported
coder.internal.errorIf(numel(size(A))>3,'images:morphop:noNDInMode');
coder.internal.errorIf(numel(size(getnhood(se)))>3,'images:morphop:noNDInMode');


%% Process optional arguments.
% varargin of length 0-3 will contain one or more of the following in any
% order: padoption (same/full), packoption (notpacked/ispacked} and a
% scalar number (unpacked_M, only from erode client)
%

allowed_strings = {'same','full','ispacked','notpacked'};

% Defaults:
% input_is_packed = false;
% output_is_full  = false;
% inNumRows       = -1; % i.e unused.

switch numel(varargin)
    case 1
        % Has to be a string
        string = validatestring(varargin{1}, allowed_strings, ...
            func_name, 'OPTION', 3); % 3rd position in calling function
        switch string
            case {'full','same'}
                input_is_packed = false;
                output_is_full  = strcmp(string,'full');
            case {'ispacked','notpacked'}
                input_is_packed = strcmp(string,'ispacked');
                output_is_full  = false;
        end
        inNumRows = -1;
        
    case 2
        % Either
        % shapeopt, packout
        % packopt, shapeopt
        % packopt, M
        string = validatestring(varargin{1}, allowed_strings, ...
            func_name, 'OPTION', 3); % 3rd position in calling function
        switch string
            case {'full','same'}
                % shapeopt, packout
                output_is_full  = strcmp(string,'full');
                packString      = validatestring(varargin{2}, {'ispacked','notpacked'}, ...
                    func_name, 'OPTION', 4);
                input_is_packed = strcmp(packString,'ispacked');
                inNumRows       = -1;
            case {'ispacked','notpacked'}
                % packopt, shapeopt
                % packopt, M
                input_is_packed = strcmp(string,'ispacked');
                if(ischar(varargin{2}))
                    % packopt, shapeopt
                    shapeString    = validatestring(varargin{2}, {'same','full'}, ...
                        func_name, 'OPTION', 4);
                    output_is_full = strcmp(shapeString,'full');
                    inNumRows      = -1;
                else
                    % packopt, M
                    inNumRows      = varargin{2};
                    validateattributes(inNumRows, {'double'},...
                        {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
                        func_name, 'M', 4);
                    output_is_full = false;
                end
        end
        
    case 3
        % Either
        % shapeopt, packout, M
        % packopt, M, shapeopt
        
        % Has to be string first
        string = validatestring(varargin{1}, allowed_strings, ...
            func_name, 'OPTION', 3); % 3rd position in calling function
        switch string
            case {'full','same'}
                % shapeopt, packout, M
                output_is_full  = strcmp(string,'full');
                packString      = validatestring(varargin{2}, {'ispacked','notpacked'}, ...
                    func_name, 'OPTION', 4);
                input_is_packed = strcmp(packString,'ispacked');
                inNumRows       = varargin{3};
                validateattributes(inNumRows, {'double'},...
                    {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
                    func_name, 'M', 5);
                
            case {'ispacked','notpacked'}
                % packopt, M, shapeopt
                input_is_packed = strcmp(string,'ispacked');
                inNumRows       = varargin{2};
                validateattributes(inNumRows, {'double'},...
                    {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
                    func_name, 'M', 4);
                shapeString     = validatestring(varargin{3}, {'same','full'}, ...
                    func_name, 'OPTION', 5);
                output_is_full  = strcmp(shapeString,'full');
                
        end
        
    otherwise
        % Defaults
        output_is_full  = false;
        input_is_packed = false;
        inNumRows       = -1;
        
end

% The optional input options have to be compile time constants
eml_invariant(eml_is_const(output_is_full),...
    eml_message('images:morphop:shapeOptNotConst'),...
    'IfNotConst','Fail');
eml_invariant(eml_is_const(input_is_packed),...
    eml_message('images:morphop:packOptNotConst'),...
    'IfNotConst','Fail');

% Check inNumRows for consistency with image size.
if input_is_packed
    if inNumRows >= 0
        d = 32*size(A,1) - inNumRows;
        % run-time check
        eml_invariant(~(d < 0) || (d > 31),...
            eml_message('images:imerode:inconsistentUnpackedM'));
    end
end

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary());
useSharedLibrary = useSharedLibrary && ...
    coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(~images.internal.coder.useSingleThread()) && ...
    ~(coder.isRowMajor && numel(size(A))>2) && ...
    ~(coder.isRowMajor && numel(size(getnhood(se)))>2);

%
%% Compute processing flags
% Figure out the appropriate image preprocessing steps, image
% postprocessing steps, and method to invoke.
%
% First, find out the values of all the necessary predicates.
%
num_strels        = coder.const(getsequencelength(se));
input_numdims     = coder.const(numel(size(A)));
strel_is_single   = coder.const(num_strels == 1);
input_is_uint32   = coder.const(isa(A,'uint32'));
input_is_logical  = coder.const(islogical(A));
input_is_2d       = coder.const(numel(size(A))==2);

strel_is_all_flat = coder.const(is_strel_all_flat(se, num_strels));
strel_is_all_2d   = coder.const(is_strel_all_2d(se, num_strels));

%
% Check for error conditions related to packing
%

% if input is packed data. no gpu code is generated and gpu code generation is aborted.
if (coder.gpu.internal.isGpuEnabled && input_is_packed )
    coder.internal.errorIf(true,'gpucoder:common:MorphOpUnsupportedInputDataError');
end


coder.internal.errorIf(...
    input_is_packed && strcmp(op_type, 'erode') && (inNumRows < 1),...
    'images:morphop:missingPackedM');
coder.internal.errorIf(...
    input_is_packed && ~strel_is_all_2d,...
    'images:morphop:packedStrelNot2D');
coder.internal.errorIf(...
    input_is_packed && ~input_is_uint32,...
    'images:morphop:invalidPackedInputType');
coder.internal.errorIf(...
    input_is_packed && ~strel_is_all_flat,...
    'images:morphop:nonflatStrelPacked');
coder.internal.errorIf(...
    input_is_packed && (input_numdims > 2),...
    'images:morphop:packedImageNot2D');
coder.internal.errorIf(...
    input_is_packed && output_is_full,...
    'images:morphop:packedFull');
coder.internal.errorIf(...
    input_is_packed && ~useSharedLibrary,...
    'images:morphop:packedInputsNotSupported');

%
% Next, use predicate values to determine the necessary preprocessing and
% postprocessing steps.
%

% If the user has asked for full-size output, or if there are multiple
% and/or decomposed strels that are not rectangular, then pre-pad the input image.
% Note - currently strel_is_single is always true.
pre_pad = output_is_full || (~strel_is_single && ~isdecompositionorthogonal(se));
pre_pad = coder.const(pre_pad);

% If we had to pre-pad the input but the user didn't specify the 'full'
% option, then crop the image before returning it.
% Note - This is always false (since strel_is_single is always true.)
post_crop = pre_pad & ~output_is_full;
post_crop = coder.const(post_crop);

% If the input image is logical, then the strel must be flat.
coder.internal.errorIf(...
    input_is_logical && ~strel_is_all_flat,...
    'images:morphop:binaryWithNonflatStrel',func_name);

% If the input image is logical and not packed, and if there are multiple
% all-flat strels, the prepack the input image.
pre_pack = ~strel_is_single & input_is_logical & input_is_2d & ...
    strel_is_all_flat & strel_is_all_2d;
% packed processing is only supported with shared libraries
pre_pack = pre_pack & useSharedLibrary;
pre_pack = coder.const(pre_pack);

% If this function pre-packed the image, unpack it before returning it.
post_unpack = pre_pack;
post_unpack = coder.const(post_unpack);

%% Other compile time constants

if(images.internal.coder.useSingleThread())
    tsuffix         = '';
else
    tsuffix         = '_tbb';
end


%
%% Determine function and corresponding library to call.
%
ctype = images.internal.coder.getCtype(A);
if pre_pack || input_is_packed
    fcnName = 'packed_uint32';
    libName = 'packed';
elseif input_is_logical
    if input_is_2d && strel_is_single && strel_is_all_2d
        if isequal(getnhood(se), ones(3))
            fcnName = 'binary_ones33';
        else
            fcnName = 'binary_twod';
        end
    else
        fcnName = 'binary';
    end
    fcnName = [fcnName, tsuffix];
    libName = ['binary', tsuffix];
elseif strel_is_all_flat
    fcnName = ['flat_', ctype, tsuffix];
    libName = ['flat', tsuffix];
else
    fcnName = ['nonflat_', ctype, tsuffix];
    libName = ['nonflat', tsuffix];
end
% prefix op_type (erode or dilate)
fcnName = [op_type,'_', fcnName];

%% PreProcessing

%  Gpu Enabled condition is added here and it is supported when
%  SE dimension is less than or equal to 2.
%  and Number of channels in third dimension for input image is less than or equal to 3
%  and SE must be flat structuring element.
%  and input sizes must be constant.
if (coder.gpu.internal.isGpuEnabled && numel(size(getnhood(se)))<=2 && size(A,3)<=3 && coder.internal.isConst(size(A))&& strel_is_all_flat)
    % Pre-processing of the input contains
    % 1. Input Padding: Padding of the input according to the padvalue
    % specified by the morph operation and pad size according to strel size
    % is done. This is to ensure that the output image includes the
    % processing of the image borders.
    % 2. Structuring Element Checks: Structuring elememts can contain zero
    % rows/columns. These are to be checked and handled accordingly. Also,
    % handling of empty strels are done.
    
    % Obtain the strel matrix from the strel structure using getnhood.
    seNhood = coder.const(getnhood(se));
    
    % Function to fetch the number of zero-padded row/columns.
    % This is done at compile time. Code generation doesn't happen for this
    % function.
    % 'removePaddedZeros' computes padded zero row/columns in the
    % structuring element. The output of this fucntion is the number of
    % zeros rows/columns in all the four directions of a 2D strel.
    [top,bottom,left,right] = coder.const(@gpucoder.internal.removePaddedZeros,seNhood);
    
    % pragma to launch kernels with threads
    coder.gpu.kernelfun();
    % Pre padding option to check output shape is 'full'.
    pre_pad = output_is_full ;
    
    % Handling of an empty structuring element.
    % If an empty structuring element is passed the strel is considered to
    % be 0 (zero) of size 1x1.
    if  ~isempty(seNhood)
        maskSize = size(getnhood(se));
    else
        seNhood = cast(0,class(seNhood));
        maskSize = size(seNhood);
    end
    if(strcmp(op_type,'dilate'))
        % getting padvalue depending on input datatype.
        padval = getPadValue(class(A),'dilate');
    else
        padval = getPadValue(class(A),'erode');
        
        % In case of erosion the zero padded rows/columns are swapped. This is to
        % ensure that the final output is rightly cropped.
        
        % Swapping bottom & top
        tmpVal = top;
        top = bottom;
        bottom = tmpVal;
        
        % Swapping left & right
        tmpVal = left;
        left = right;
        right = tmpVal;
    end
    
    % Padding sizes are determined by the size of the structuring element.
    % Padding values are determined by the morphological operation. For
    % dilation operation a minimum value is padded, for erosion a maximum
    % value is padded. The max and min is determined by the data-type of the
    % input.
    if pre_pad
        imPad = padarray(A, (maskSize - 1),padval);
    else
        % Adjust padding appropriately in 'same' mode. Because of 'even'
        % filters.
        if(strcmp(op_type,'dilate'))
            % if the neighbourhood is odd filter
            if (mod(maskSize(1,1),2)==1 && mod(maskSize(1,2),2)== 1)
                imPad = padarray(A, ((maskSize - 1)/2),padval);
            else % if the neighbourhood is even filter
                imPre = padarray(A, ceil((maskSize - 1)/2),padval,'pre');
                imPad = padarray(imPre, floor((maskSize - 1)/2),padval,'post');
            end
        else
            % if the neighbourhood is odd filter
            if (mod(maskSize(1,1),2)==1 && mod(maskSize(1,2),2)== 1)
                imPad = padarray(A, ((maskSize - 1)/2),padval);
            else % if the neighbourhood is even filter
                imPre = padarray(A, ceil((maskSize - 1)/2),padval,'post');
                imPad = padarray(imPre, floor((maskSize - 1)/2),padval,'pre');
            end
        end
    end
    
    finalOut = cell(1,num_strels+1);
else
    % Pre-process
    if input_is_packed
        % In a prepacked binary image, the fill bits at the bottom of the packed
        % array should be handled just like pad values.  The fill bits should be
        % 0 for dilation and 1 for erosion.
        
        fill_value = strcmp(op_type, 'erode');
        fill_value = coder.const(fill_value);
        A          = images.internal.setPackedFillBits(A, inNumRows, fill_value);
    end
    
    if pre_pad
        % Now compute how padding is needed based on the strel offsets.
        
        switch(op_type)
            case 'erode'
                % Swap
                [pad_ul1, pad_lr1] = getpadsize(se);
                tmp     = pad_ul1;
                pad_ul1 = pad_lr1;
                pad_lr1 = tmp;
            case 'dilate'
                [pad_ul1, pad_lr1] = getpadsize(se);
            otherwise
                assert('Unknown option');
        end
        
        P = length(pad_ul1);
        Q = ndims(A);
        if P < Q
            pad_ul = [pad_ul1 zeros(1,Q-P)];
            pad_lr = [pad_lr1 zeros(1,Q-P)];
        else
            pad_ul = pad_ul1;
            pad_lr = pad_lr1;
        end
        
        if input_is_packed
            % Input is packed binary.  Adjust padding appropriately.
            pad_ul(1) = ceil(pad_ul(1) / 32);
            pad_lr(1) = ceil(pad_lr(1) / 32);
        end
        
        pad_val = getPadValue(class(A), op_type);
        
        Apadpre = padarray(A,pad_ul,pad_val,'pre');
        Apad    = padarray(Apadpre,pad_lr,pad_val,'post');
    else
        Apad    = A;
    end
    
    
    if pre_pack
        numRows  = size(Apad,1);
        Apadpack = bwpack(Apad);
    else
        numRows  = inNumRows;
        Apadpack = Apad;
    end
    
end
%
%% Apply the sequence of dilations/erosions.

%  Gpu Enabled condition is added here and it is supported when
%  SE dimension is less than or equal to 2.
%  and Number of channels in third dimension for input image is less than or equal to 3
%  and SE must be flat structuring element.
%  and input sizes must be constant.
if (coder.gpu.internal.isGpuEnabled && numel(size(getnhood(se)))<=2 && size(A,3)<=3 && coder.internal.isConst(size(A))&& strel_is_all_flat)
    num_strels = getsequencelength(se);
    for sInd = coder.unroll(1:num_strels)
        % If SE is decomposable ,getting decomposed elements
        nhoodMat = getnhood(se,sInd);
        if isempty(nhoodMat)
            nhoodIn = cast(0,class(nhoodMat));
        else
            nhoodIn = nhoodMat;
        end
        
        
        % Flipping of the structuring element should be done incase of
        % morphological dilation.
        if(strcmp(op_type,'dilate'))
            nhoodIn(1:end)     = nhoodIn(end:-1:1);
        end
        strelSize = size(nhoodIn);
        nhoodIn = cast(nhoodIn,class(A));
        finalOut{1} = imPad;
        finalSizePad = size(finalOut{sInd});
        
        % Preallocating output buffer.
        finalOut{sInd+1} = coder.nullcopy((zeros([ finalSizePad(1)-strelSize(1)+1 finalSizePad(2)-strelSize(2)+1 size(A,3)], class(A))));
        
        % Using stencilKernel pragma here to perform min(erode)/max(dilate) operation for
        % a given structuring element.
        % for 2channel 3D or 3channel 3D input image, call stencilKernel for each channel as it has GPU implementation.
        if (size(A,3)>1)
            if(strcmp(op_type,'dilate'))% dilation operation using stencil kernel
                finalOut{sInd+1}(:,:,1) = gpucoder.stencilKernel(@doMaskDilate, finalOut{sInd}(:,:,1), size(nhoodIn), 'valid', nhoodIn, padval);
                finalOut{sInd+1}(:,:,2) = gpucoder.stencilKernel(@doMaskDilate, finalOut{sInd}(:,:,2), size(nhoodIn), 'valid', nhoodIn, padval);
                if(size(A,3)==3)
                    finalOut{sInd+1}(:,:,3) = gpucoder.stencilKernel(@doMaskDilate, finalOut{sInd}(:,:,3), size(nhoodIn), 'valid', nhoodIn, padval);
                end
                
            else % erosion operation using stencil kernel
                finalOut{sInd+1}(:,:,1) = gpucoder.stencilKernel(@doMaskErode, finalOut{sInd}(:,:,1), size(nhoodIn), 'valid', nhoodIn, padval);
                finalOut{sInd+1}(:,:,2) = gpucoder.stencilKernel(@doMaskErode, finalOut{sInd}(:,:,2), size(nhoodIn), 'valid', nhoodIn, padval);
                if(size(A,3)==3)
                    finalOut{sInd+1}(:,:,3) = gpucoder.stencilKernel(@doMaskErode, finalOut{sInd}(:,:,3), size(nhoodIn), 'valid', nhoodIn, padval);
                end
            end
        else % this is for single channel
            if(strcmp(op_type,'dilate'))% dilation operation using stencil kernel
                finalOut{sInd+1} = gpucoder.stencilKernel(@doMaskDilate, finalOut{sInd}, size(nhoodIn), 'valid', nhoodIn, padval);
            else % erosion operation using stencil kernel
                finalOut{sInd+1} = gpucoder.stencilKernel(@doMaskErode, finalOut{sInd}, size(nhoodIn), 'valid', nhoodIn, padval);
            end
        end
    end
else
    % 1. If Gpu is not Enabled or,
    % 2. if Gpu is enabled and structuring element dimensions exceeds 2, or,
    % 3. if Gpu is enabled and 3D image has more than 3 channels or,
    % 4. if Gpu is enabled and input image sizes are not constant.
    % in either of the above mentioned cases, unoptimized GPU code will be generated.
    if (coder.gpu.internal.isGpuEnabled)
        % If SE dimensionality exceeds 2, unoptimized
        %  GPU (CUDA) codes will be generated.
        if (numel(size(getnhood(se))) > 2)
            coder.internal.compileWarning('gpucoder:common:MorphOpUnsupportedStructuringElementDim');
        end
        
        % For N-Channel 3D case, when N>3, unoptimized
        %  GPU (CUDA) codes will be generated.
        if (size(A,3) > 3)
            coder.internal.compileWarning('gpucoder:common:MorphOpUnsupportedNChannel3DImage');
        end
        
        
        % For varibale input sizes, unoptimized
        %  GPU (CUDA) codes will be generated.
        if ( ~coder.internal.isConst(size(A)))
            coder.internal.compileWarning('gpucoder:common:MorphOpUnsupportedUnboundedInputs');
        end
        
        
        % Only flat structuring elements are allowed.Otherwise unoptimized
        %  GPU (CUDA) codes will be generated.
        if (~strel_is_all_flat)
            coder.internal.compileWarning('gpucoder:common:MorphOpUnsupportedStreltype');
        end
    end
    
    num_strels = getsequencelength(se);
    for sInd = coder.unroll(1:num_strels)
        
        B = coder.nullcopy(Apadpack);
        
        nhoodIn     = getnhood(se,sInd);
        allheightIn = getheight(se,sInd);
        
        if(useSharedLibrary)
            if useOCV(A, nhoodIn) && strel_is_all_flat
                ocvFcnName = [op_type,'_', ctype,'_ocv'];
                ocvLibName = 'ocv';
                B = callSharedLibrary(ocvLibName, ocvFcnName, op_type, ...
                    Apadpack, logical(nhoodIn), allheightIn, numRows, B);
            else
                nhood = nhoodIn;
                allheight = allheightIn;
                % Flip height if we are dilating.
                if(strcmp(op_type,'dilate'))
                    if(ismatrix(A))
                        % If ndims(nhood)>2, then trailing dimension dont count.
                        % Effectively, reflect only the first plane. (the rest get
                        % flipped, but they are 'dont-cares').
                        allheight = flip(flip(allheight,1),2);
                        if(any(allheight(:)))
                            % Flip nhood only for non-flat se
                            nhood = flip(flip(nhood,1),2);
                        end
                    else
                        allheight(1:end) = allheight(end:-1:1);
                        if(any(allheight(:)))
                            nhood(1:end) = nhood(end:-1:1);
                        end
                    end
                end
                
                if(coder.isRowMajor)
                    % Tranpose height and nhood so that they are traversed in
                    % row-major format
                    allheightT = allheight';
                    nhoodT = nhood';
                else
                    allheightT = allheight;
                    nhoodT = nhood;
                end
                
                % pick only non-zero heights. (For the toolbox, this is done in the
                % mex layer)
                height = allheightT(nhoodT);
                
                B = callSharedLibrary(libName, fcnName, op_type, ...
                    Apadpack, nhood, height, numRows, B);
                
            end
        else
            % portable C code
            B = images.internal.coder.morphopAlgo(Apadpack,...
                nhoodIn , allheightIn,...
                op_type, B);
            
        end
        
        % prepare for next iteration
        Apadpack = B;
    end
end
%
%% Postprocessing


%  Gpu Enabled condition is added here and it is supported when
%  SE dimension is less than or equal to 2.
%  and Number of channels in third dimension for input image is less than or equal to 3
%  and SE must be flat structuring element.
%  and input sizes must be constant.
if (coder.gpu.internal.isGpuEnabled && numel(size(getnhood(se)))<=2 && size(A,3)<=3 && coder.internal.isConst(size(A))&& strel_is_all_flat)
    
    % If structuring element contain zeros rows/columns, the output's
    % correspoding rows/columns are skipped depending on the morph
    % operation.
    Bout_post = finalOut{num_strels+1};
    if pre_pad
        Bout = Bout_post(top + 1 : size(Bout_post,1) - bottom, left + 1 : size(Bout_post,2) - right, :);
    else
        Bout = Bout_post;
    end
else
    if post_unpack
        Bunpack = bwunpack(B,numRows);
    else
        Bunpack = B;
    end
    
    if post_crop
        % Crop out the padded portion
        diml = pad_ul+1;
        dimh = diml + size(Bunpack) - pad_ul - pad_lr -1;
        switch ndims(Bunpack)
            case 2
                Bout = Bunpack(diml(1):dimh(1), diml(2):dimh(2));
            case 3
                Bout = Bunpack(diml(1):dimh(1), diml(2):dimh(2), diml(3):dimh(3));
                % otherwise - covered in input validation.
        end
    else
        Bout = Bunpack;
    end
end

%--------------------------------------------------------------------------

%==========================================================================
function pad_value = getPadValue(className, op_type)
% Returns the appropriate pad value, depending on whether we are performing
% erosion or dilation, and whether or not A is logical (binary).

if strcmp(op_type, 'dilate')
    switch className
        case 'logical'
            pad_value = false;
        case {'single', 'double'}
            pad_value = -inf(1,className);
        otherwise
            pad_value = intmin(className);
    end
else
    switch className
        case 'logical'
            pad_value = true;
        case {'single', 'double'}
            pad_value = inf(1,className);
        otherwise
            pad_value = intmax(className);
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function TF = useOCV(A, nhood)
TF = false;
if isempty(nhood)
    return;
end

is2DInput = ismatrix(A);
strelIsAll2D = ismatrix(nhood);

strelSize = size(nhood);
if any(strelSize > 200)
    isSizeBadForOCV = true;
else
    isSizeBadForOCV = false;
end
density = nnz(nhood)/numel(nhood);
if density < 0.05
    isDensityBadForOCV = true;
else
    isDensityBadForOCV = false;
end

supportedType   = isa(A,'uint8')...
    || isa(A,'uint16')...
    || isa(A,'single');

TF  = is2DInput && supportedType && strelIsAll2D &&  ...
    ~isSizeBadForOCV && ~isDensityBadForOCV ;
%--------------------------------------------------------------------------

%==========================================================================
function TF = is_strel_all_flat(se, num_strels)
% Check if all the decomposed strel elements are flat
TF = true;
for sInd = coder.unroll(1:num_strels)
    if (~isflat(se,sInd))
        TF = false;
        break;
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function TF = is_strel_all_2d(se, num_strels)
TF = true;
for sInd = coder.unroll(1:num_strels)
    if (~ismatrix(getnhood(se,sInd)))
        TF = false;
        break;
    end
end
%--------------------------------------------------------------------------

%==========================================================================
% Function Call for gpu coder support Dilate
function out = doMaskDilate(a,b,padval)
coder.inline('always');
coder.gpu.constantMemory(b);
[h,w] = size(b);
maxVal = padval ;
for n = 1:w
    for m = 1:h
        if (b(m,n) > 0)
            out = a(m,n)*b(m,n);
            % dilate
            out = cast(out,class(a));
            if(out>maxVal)
                maxVal = out;
            end
        end
    end
end
out = maxVal;
%--------------------------------------------------------------------------

%==========================================================================
% Function Call for gpu coder support Erode
function out = doMaskErode(a,b,padval)
coder.inline('always');
coder.gpu.constantMemory(b);
[h,w] = size(b);
minVal = padval ;
for n = 1:w
    for m = 1:h
        if (b(m,n) > 0)
            out = a(m,n)*b(m,n);
            % erode
            out = cast(out,class(a));
            if(out<minVal)
                minVal = out;
            end
        end
    end
end
out = minVal;
%--------------------------------------------------------------------------

%==========================================================================
function B = callSharedLibrary(libName, fcnName, op_type, Apadpack, nhood, height, numRows, B)
coder.inline('always');
switch libName
    case 'nonflat_tbb'
        B = images.internal.coder.buildable.Morphop_nonflat_tbb_Buildable.morphop_nonflat_tbb(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            height,...
            B);
    case 'nonflat'
        B = images.internal.coder.buildable.Morphop_nonflat_Buildable.morphop_nonflat(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            height,...
            B);
    case 'flat_tbb'
        B = images.internal.coder.buildable.Morphop_flat_tbb_Buildable.morphop_flat_tbb(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            B);
    case 'flat'
        B = images.internal.coder.buildable.Morphop_flat_Buildable.morphop_flat(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            B);
    case 'ocv'
        B = images.internal.coder.buildable.Morphop_ocv_Buildable.morphop_ocv(...
            fcnName, ...
            Apadpack,     size(Apadpack),...
            nhood, size(nhood), ...
            B);
    case 'binary_tbb'
        B = images.internal.coder.buildable.Morphop_binary_tbb_Buildable.morphop_binary_tbb(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            B);
    case 'binary'
        B = images.internal.coder.buildable.Morphop_binary_Buildable.morphop_binary(...
            fcnName, ...
            Apadpack,     size(Apadpack),     ndims(Apadpack),...
            nhood, size(nhood), ndims(nhood),...
            B);
    case 'packed'
        if(strcmp(op_type,'dilate'))
            B = images.internal.coder.buildable.Morphop_packed_Buildable.dilate_packed(...
                fcnName, ...
                Apadpack,     size(Apadpack),     ndims(Apadpack),...
                nhood, size(nhood), ndims(nhood),...
                B);
        else
            B = images.internal.coder.buildable.Morphop_packed_Buildable.erode_packed(...
                fcnName, ...
                Apadpack,     size(Apadpack),     ndims(Apadpack),...
                nhood, size(nhood), ndims(nhood),...
                numRows,...
                B);
        end
end

