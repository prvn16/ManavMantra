function b = imfilter(varargin) %#codegen
%IMFILTER N-D filtering of multidimensional images.

%   Copyright 2013-2017 The MathWorks, Inc.

%#ok<*EMCA>
coder.internal.prefer_const(varargin);
narginchk(2,5);
coder.extrinsic('gpucoder.internal.isSeparableGPU');

validateattributes(varargin{1},{'int8', 'uint8', 'int16', 'uint16', 'int32', ...
    'uint32', 'single', 'double', 'logical'},{'nonsparse'},mfilename,'A',1);
validateattributes(varargin{2},{'double'},{'nonsparse'},mfilename,'H',2);

a_tmp = varargin{1};
h_tmp = varargin{2};

[boundary, boundary_pos, boundaryEnum, boundaryStr_pos, sameSize, convMode] = parseOptions(3,varargin{:});

[finalSize, pad] = computeSizes(a_tmp, h_tmp, sameSize);

% If this flag is 'true', all integer/logical inputs are typecasted to
% double precision before convolution operation. Else, they are typecasted
% to single precision.
enableDoublePrecision = false;

%Empty Inputs
% 'Same' output then size(b) = size(a)
% 'Full' output then size(b) = size(h)+size(a)-1
if isempty(a_tmp)
    
    b = handleEmptyImage(a_tmp, sameSize, finalSize);
    return
    
elseif isempty(h_tmp)
    
    b = handleEmptyFilter(a_tmp, sameSize, finalSize);
    return
    
end

coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary());
useSharedLibrary = useSharedLibrary && ...
    coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(~images.internal.coder.useSingleThread()) && ...
    ~(coder.isRowMajor && numel(size(a_tmp))>2) && ...
    ~(coder.isRowMajor && numel(size(h_tmp))>2);

if (useSharedLibrary)
    % MATLAB Host Target (PC)
    
    % Separate real and imaginary parts of the filter (h) in MATLAB and
    % filter imaginary and real parts of the image (a) in the mex code.
    if (isSeparable(a_tmp, h_tmp))
        
        % Pad input based on dimensions of filter kernel.
        % Pad based on the last specified boundary string or boundary value
        a = padImage(a_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos);
       
        h = h_tmp;
        
        % extract the components of the separable filter
        [u,s,v] = svd(h);
        % Call diag with explicit 2D input
        s = diag(s(:,:));
        hcol = u(:,1) * sqrt(s(1));
        hrow = v(:,1)' * sqrt(s(1));
        
        % intermediate results should be stored in doubles in order to
        % maintain sufficient precision
        class_of_a = class(a);
        if ~isa(a,'double')
            change_class = true;
            a = double(a);
        else
            change_class = false;
            a = a;
        end
        
        % apply the first component of the separable filter (hrow)
        out_size_row = [size(a,1) finalSize(2:end)];
        start = [0 pad(2:end)];
        b = filterPartOrWhole(a, out_size_row, hrow, start, sameSize, convMode);
        
        % apply the other component of the separable filter (hcol)
        start = [pad(1) 0 pad(3:end)];
        b = filterPartOrWhole(b, finalSize, hcol, start, sameSize, convMode);
        
        if change_class
            % For logical inputs, output is rounded and then casted to
            % logical - expected behavior
            if strcmp(class_of_a,'logical') %#ok<ISLOG>
                b = cast(round(b), class_of_a);
            else
                b = cast(b, class_of_a);
            end
        else
            b = b;
        end
        
    else % non-separable filter case
        
            % Zero-pad input based on dimensions of filter kernel.
            % Pad based on the last specified boundary string or boundary value
            a = padImage(a_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos);
            
            h = h_tmp;
            
            b = filterPartOrWhole(a, finalSize, h, pad, sameSize, convMode);
    end
    
else % Non-PC Targets
    % Gpu Enabled condition is added here and it supports when
    % input is real,
    % input dimension is less than or equal to 3 
    % Number of channels in third dimension is less than or equal to 3
    % and Kernel dimension is less than or equal to 2.
    if (coder.gpu.internal.isGpuEnabled && numel(size(h_tmp))<=2 && numel(size(a_tmp))<=3 && size(a_tmp,3)<=3 && isreal(a_tmp))
        
        sepFlag = false;
        hcol = coder.nullcopy(zeros(size(h_tmp,1),1));
        hrow = coder.nullcopy(zeros(1,size(h_tmp,2)));
        
        a_size = size(a_tmp);
        if eml_is_const(h_tmp) && eml_is_const(a_size)
            [sepFlag, hcol, hrow] = coder.const(@gpucoder.internal.isSeparableGPU, a_size, h_tmp);
        elseif ~isa(a_tmp,'single')
            % Note: for single image inputs, we noticed a large performance degredation on Pascal
            % when doing this at runtime.  So we are only doing this runtime check for non-single inputs.
            sepFlag = isSeparableGPUFlag(a_tmp, h_tmp);

            if (sepFlag)
                % extract the components of the separable filter
                [u,s,v] = svd(h_tmp);
                % Call diag with explicit 2D input
                s = diag(s(:,:));
                hcol = u(:,1) * sqrt(s(1));
                hrow = v(:,1)' * sqrt(s(1));
            end
        end
        
        % separable case
        if (sepFlag)
            % Pad input based on dimensions of filter kernel.
            % Pad based on the last specified boundary string or boundary value
            a = padImage_gpu(a_tmp, h_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos, sameSize);
            h = h_tmp;
            
            % intermediate results should be stored in doubles in order to
            % maintain sufficient precision
            class_of_a = class(a);
            if isa(a,'single')
                change_class = false;
                a = a; %#ok<*ASGSL>
            elseif isa(a,'double')
                change_class = false;
                a = a;
            else
                change_class = true;
                if(enableDoublePrecision)
                    a = double(a); %#ok<UNRCH>
                else
                    a = single(a);
                end
            end
            
            % for 2D input image, call conv2 instead of convn as it has GPU implementation.
            if(ismatrix(a))
                b = conv2(hcol,hrow, a, 'valid');
                % for 3D input image, call conv2 for each channel as it has GPU implementation.
            else
                if(~isreal(h) && strcmp('single', class_of_a))
                    b = coder.nullcopy(complex(zeros(finalSize, 'single')));
                elseif(~isreal(h))
                    b = coder.nullcopy(complex(zeros(finalSize)));
                elseif strcmp('single', class_of_a)
                    b = coder.nullcopy(zeros(finalSize, 'single'));
                else
                    b = coder.nullcopy(zeros(finalSize));
                end
                b(:,:,1) = conv2(hcol,hrow,a(:,:,1),'valid');
                b(:,:,2) = conv2(hcol,hrow,a(:,:,2),'valid');
                if(size(a_tmp,3)==3)
                    b(:,:,3) = conv2(hcol,hrow,a(:,:,3),'valid');
                end
            end
            
            % Change output datatype to same class as input datatype
            if change_class
                % For logical inputs, output is rounded and then casted to
                % logical - expected behavior
                if strcmp(class_of_a,'logical') %#ok<ISLOG>
                    if(isreal(h))
                        b = round(b);
                        b = b>0;
                    else
		    	b = b;
                        coder.internal.errorIf(true,'gpucoder:common:ImfilterComplexKernelWithLogicalInputError');
                    end
                else % double to input image data type
                    b = cast(b, class_of_a);
                end
            else
                b = b;
            end
            
        else % not separable case & but still GPU is enabled
            % Zero-pad input based on dimensions of filter kernel.
            % Pad based on the last specified boundary string or boundary value
            a = padImage_gpu(a_tmp, h_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos, sameSize);
            
            % for correlation mode.fliping the kernel.
            if ~convMode
                if ismatrix(h_tmp)
                    h = rot90(h_tmp,2);
                end
            else
                h = h_tmp;
            end
            
            % intermediate results should be stored in doubles in order to
            % maintain sufficient precision
            class_of_a = class(a);
            if isa(a,'single')
                change_class = false;
                a = a;
            elseif isa(a,'double')
                change_class = false;
                a = a;
            else
                change_class = true;
                if(enableDoublePrecision)
                    a = double(a); %#ok<UNRCH>
                else
                    a = single(a);
                end
            end
            % for 2D input image, call conv2 instead of convn as it has GPU implementation.
            if(ismatrix(a))
                b = conv2(a,h,'valid');
            else
                if(~isreal(h) && strcmp('single', class_of_a)) %#ok<*STISA>
                    b = coder.nullcopy(complex(zeros(finalSize, 'single')));
                elseif(~isreal(h))
                    b = coder.nullcopy(complex(zeros(finalSize)));
                elseif strcmp('single', class_of_a)
                    b = coder.nullcopy(zeros(finalSize, 'single'));
                else
                    b = coder.nullcopy(zeros(finalSize));
                end
                b(:,:,1) = conv2(a(:,:,1),h,'valid');
                b(:,:,2) = conv2(a(:,:,2),h,'valid');
                if(size(a_tmp,3)==3)
                    b(:,:,3) = conv2(a(:,:,3),h,'valid');
                end
            end
            
            % Change output datatype to same class as input datatype
            if change_class
                % For logical inputs, output is rounded and then casted to
                % logical - expected behavior
                if strcmp(class_of_a,'logical') %#ok<ISLOG>
                    if(isreal(h))
                        b = round(b);
                        b = b>0;
                    else
		    	b = b;
                       coder.internal.errorIf(true,'gpucoder:common:ImfilterComplexKernelWithLogicalInputError');
                    end
                else % double to input image data type
                    b = cast(b, class_of_a);
                end
            else
                b = b;
            end
            
        end % End of if(isSeparable)
    else
        % 1. If Gpu is not Enabled or,
        % 2. if Gpu is enabled and image dimensions exceeds 3 or,
	% 3. if Gpu is enabled and 3D image has more than 3 channels or,
        % 4. if Gpu is enabled and kernel dimensions exceeds 2, or,
        % 5. if Gpu is enabled and input image is complex
        % in either of the above mentioned cases, call convn as it is fast for CPU code generation.
        
        if (coder.gpu.internal.isGpuEnabled)
            % If input dimensionality exceeds 3, CPU codes will be
            % generated instead of GPU (CUDA) codes.
            if (ndims(a_tmp) > 3)
                coder.internal.compileWarning('gpucoder:common:ImfilterUnsupportedMultiDimImage');
            end

	    % For N-Channel 3D case, when N>3, CPU codes will be
            % generated instead of GPU (CUDA) codes.
            if (size(a_tmp,3) > 3)
                coder.internal.compileWarning('gpucoder:common:ImfilterUnsupportedNChannel3DImage');
            end
            
            % If Kernel dimensionality exceeds 2, CPU codes will be
            % generated instead of GPU (CUDA) codes.
            if (numel(size(h_tmp)) > 2)
                coder.internal.compileWarning('gpucoder:common:ImfilterUnsupportedKernelDim');
            end
            
            % If input image is complex then aborting GPU code generation for embedded target
            % Generate C/C++ code for MEX target.
            if(~isreal(a_tmp))
                coder.internal.compileWarning('gpucoder:common:ImfilterComplexInputImage');
            end
        end
        
        a = padImage(a_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos);
        
        if ~convMode
            if ismatrix(h_tmp)
                h = rot90(h_tmp,2);
            else % numel(size(h))==3
                h = coder.nullcopy(h_tmp);
                for idx = size(h_tmp,3):-1:1
                    h(:,:,size(h_tmp,3)-idx+1) = rot90(h_tmp(:,:,idx),2);
                end
            end
        else
            h = h_tmp;
        end
        
        % Change datatype to double
        class_of_a = class(a);
        if ~isa(a,'double')
            change_class = true;
            a = double(a);
        else
            change_class = false;
            a = a;
        end
        if sameSize
            result = convn(a,h,'same');
        else
            result = convn(a,h,'full');
        end
        
        if ismatrix(a)
            b = result(pad(1)+1:finalSize(1)+pad(1),pad(2)+1:finalSize(2)+pad(2));
        else
            b = result(pad(1)+1:finalSize(1)+pad(1),pad(2)+1:finalSize(2)+pad(2),pad(3)+1:finalSize(3)+pad(3));
        end
        
        if change_class
            if strcmp(class_of_a,'logical') %#ok<ISLOG>
                b = cast(round(b), class_of_a);
            else
                b = cast(b, class_of_a);
            end
        else
            b = b;
        end
    end
end


%======================================================================

%--------------------------------------------------------------
% Parse inputs
%--------------------------------------------------------------
function b = isBoundaryValue(val)
b = ~ischar(val);

function bStr = isBoundaryStr(str)
% Returns true is str is a valid boundary string
bStr = strncmpi(str,'circular',numel(str)) || strncmpi(str,'replicate',numel(str)) || strncmpi(str, 'symmetric',numel(str));
function p = isOutputSizeStr(str)
% Returns true is str is a valid output size string
p = strncmpi(str,'same',numel(str)) || strncmpi(str,'full',numel(str));

function p = isModeStr(str)
% Returns true is str is a valid mode string
p = strncmpi(str,'corr',numel(str)) || strncmpi(str,'conv',numel(str));

function boundaryEnum = stringToBoundary(bStr)
% Convert boundary string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(bStr,'circular',numel(bStr))
    boundaryEnum = CIRCULAR;
elseif strncmpi(bStr,'replicate',numel(bStr))
    boundaryEnum = REPLICATE;
else %if strncmpi(bStr,'symmetric',numel(bStr))
    boundaryEnum = SYMMETRIC;
end

function sameSize = stringToSameSize(oStr)
% Convert output size string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(oStr,'same',numel(oStr))
    sameSize = true;
else %if strncmpi(oStr,'full',numel(oStr))
    sameSize = false;
end

function convMode = stringToConvMode(modeStr)
% Convert mode string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(modeStr,'conv',numel(modeStr))
    convMode = true;
else %if strncmpi(modeStr,'corr',numel(modeStr))
    convMode = false;
end

function [boundary, boundary_pos, boundaryEnum, boundaryStr_pos, sameSize, convMode] = parseOptions(idx0,varargin)

coder.inline('always');
coder.internal.prefer_const(idx0,varargin);

allStrings = {'replicate', 'symmetric', 'circular', 'conv', 'corr', ...
    'full','same'};

N = numel(varargin);

% Check that all string inputs arguments are constants
for idx = coder.unroll(idx0:N)
    if ischar(varargin{idx})
        eml_invariant(eml_is_const(varargin{idx}),...
            eml_message('images:imfilter:optionalStringNotConst'),...
            'IfNotConst','Fail');
        validatestring(varargin{idx}, allStrings,...
            mfilename, 'OPTION',idx); % potentially idx+2 id idx starts from 1
    end
end

% Parse each input argument to ensure that boundary, boundaryEnum, 
% sameSize and convMode are compile-time constants. Save argument position 
% of boundary value and boundary string and use the one which is specified 
% last.
% Parse Boundary value
idx0p1 = idx0 + 1;
idx0p2 = idx0 + 2;
% Cascade check from each input argument till the end to take care of all 
% combinations of repetition of input arguments 
% e.g. imfilter(a,h,0,'same',1);  imfilter(a,h,0,2,1); imfilter(a,h,'same',2,1);
if idx0 <= N && isBoundaryValue(varargin{idx0})
    if idx0p1 <= N && isBoundaryValue(varargin{idx0p1})
        if idx0p2 <= N && isBoundaryValue(varargin{idx0p2})
            boundary = varargin{idx0p2};
            boundary_pos = idx0p2;
        else
            boundary = varargin{idx0p1};
            boundary_pos = idx0p1;
        end
    elseif idx0p2 <= N && isBoundaryValue(varargin{idx0p2})
        boundary = varargin{idx0p2};
        boundary_pos = idx0p2;
    else
        boundary = varargin{idx0};
        boundary_pos = idx0;
    end
elseif idx0p1 <= N && isBoundaryValue(varargin{idx0p1})
    if idx0p2 <= N && isBoundaryValue(varargin{idx0p2})
        boundary = varargin{idx0p2};
        boundary_pos = idx0p2;
    else
        boundary = varargin{idx0p1};
        boundary_pos = idx0p1;
    end
elseif idx0p2 <= N && isBoundaryValue(varargin{idx0p2})
    boundary = varargin{idx0p2};
    boundary_pos = idx0p2;
else
    boundary = 0; % default
    boundary_pos = 0;
end

% Parse Boundary string
idx0p1 = idx0 + 1;
idx0p2 = idx0 + 2;
% Cascade check from each input argument till the end to take care of all 
% combinations of repetition of input arguments 
if idx0 <= N && isBoundaryStr(varargin{idx0})
    if idx0p1 <= N && isBoundaryStr(varargin{idx0p1})
        if idx0p2 <= N && isBoundaryStr(varargin{idx0p2})
            boundaryEnum = stringToBoundary(varargin{idx0p2});
            boundaryStr_pos = idx0p2;
        else
            boundaryEnum = stringToBoundary(varargin{idx0p1});
            boundaryStr_pos = idx0p1;
        end
    elseif idx0p2 <= N && isBoundaryStr(varargin{idx0p2})
        boundaryEnum = stringToBoundary(varargin{idx0p2});
        boundaryStr_pos = idx0p2;
    else
        boundaryEnum = stringToBoundary(varargin{idx0});
        boundaryStr_pos = idx0;
    end
elseif idx0p1 <= N && isBoundaryStr(varargin{idx0p1})
    if idx0p2 <= N && isBoundaryStr(varargin{idx0p2})
        boundaryEnum = stringToBoundary(varargin{idx0p2});
        boundaryStr_pos = idx0p2;
    else
        boundaryEnum = stringToBoundary(varargin{idx0p1});
        boundaryStr_pos = idx0p1;
    end
elseif idx0p2 <= N && isBoundaryStr(varargin{idx0p2})
    boundaryEnum = stringToBoundary(varargin{idx0p2});
    boundaryStr_pos = idx0p2;
else
    boundaryEnum = int8(0); % default
    boundaryStr_pos = 0;
end


% Output size string
idx0p1 = idx0 + 1;
idx0p2 = idx0 + 2;
% Cascade check from each input argument till the end to take care of all 
% combinations of repetition of input arguments 
if idx0 <= N && isOutputSizeStr(varargin{idx0})
    if idx0p1 <= N && isOutputSizeStr(varargin{idx0p1})
        if idx0p2 <= N && isOutputSizeStr(varargin{idx0p2})
            sameSize = stringToSameSize(varargin{idx0p2});
        else
            sameSize = stringToSameSize(varargin{idx0p1});
        end
    elseif idx0p2 <= N && isOutputSizeStr(varargin{idx0p2})
        sameSize = stringToSameSize(varargin{idx0p2});
    else
        sameSize = stringToSameSize(varargin{idx0});
    end
elseif idx0p1 <= N && isOutputSizeStr(varargin{idx0p1})
    if idx0p2 <= N && isOutputSizeStr(varargin{idx0p2})
        sameSize = stringToSameSize(varargin{idx0p2});
    else
        sameSize = stringToSameSize(varargin{idx0p1});
    end
elseif idx0p2 <= N && isOutputSizeStr(varargin{idx0p2})
    sameSize = stringToSameSize(varargin{idx0p2});
else
    sameSize = true; % Output size == 'same' default
end

% Mode string
idx0p1 = idx0 + 1;
idx0p2 = idx0 + 2;
% Cascade check from each input argument till the end to take care of all 
% combinations of repetition of input arguments 
if idx0 <= N && isModeStr(varargin{idx0})
    if idx0p1 <= N && isModeStr(varargin{idx0p1})
        if idx0p2 <= N && isModeStr(varargin{idx0p2})
            convMode = stringToConvMode(varargin{idx0p2});
        else
            convMode = stringToConvMode(varargin{idx0p1});
        end
    elseif idx0p2 <= N && isModeStr(varargin{idx0p2})
        convMode = stringToConvMode(varargin{idx0p2});
    else
        convMode = stringToConvMode(varargin{idx0});
    end
elseif idx0p1 <= N && isModeStr(varargin{idx0p1})
    if idx0p2 <= N && isModeStr(varargin{idx0p2})
        convMode = stringToConvMode(varargin{idx0p2});
    else
        convMode = stringToConvMode(varargin{idx0p1});
    end
elseif idx0p2 <= N && isModeStr(varargin{idx0p2})
    convMode = stringToConvMode(varargin{idx0p2});
else
    convMode = false; % Mode == 'corr' default
end

%--------------------------------------------------------------
function boundaryFlag = SYMMETRIC()
coder.inline('always');
boundaryFlag = int8(2);
%--------------------------------------------------------------
function boundaryFlag = REPLICATE()
coder.inline('always');
boundaryFlag = int8(3);
%--------------------------------------------------------------
function boundaryFlag = CIRCULAR()
coder.inline('always');
boundaryFlag = int8(4);

%--------------------------------------------------------------
function separable = isSeparable(a, h)
% check for filter separability only if the kernel has at least
% 17x17 (non-double input) or 7x7 (double input),
% both the image and the filter kernel are two-dimensional and the
% kernel is not a row or column vector, nor does it contain any NaNs of Infs

coder.inline('always');

if isa(a,'double')
    sep_threshold = 49;
else
    sep_threshold = 289;
end

if ((numel(h) >= sep_threshold) && ...
        (ismatrix(h)) && ...
        all(size(h) ~= 1) && ...
        all(isfinite(h(:))))
    
    % extract the components if separable filter
    [~,s,~] = svd(h);
	
    % Call diag with explicit 2D input
    s = diag(s(:,:));
    tol = length(h) * max(s) * eps;
    rank = sum(s > tol);
    
    if (rank == 1)
        separable = true;
    else
        separable = false;
    end
    
else
    
    separable = false;
    
end
% Function to check whether input filter is separable and define GPU specific thresholds
function separable = isSeparableGPUFlag(a, h)
% check for filter separability only if one of the below conditions are met:
% 1. Filter Size should be greater than or equal to 9x9 when input image resolution is greater than HD resolution.
% 2. Filter Size should be greater than or equal to 17x17 when input image resolution is less than or equal to HD resolution.
% both the image and the filter kernel are two-dimensional and the
% kernel is not a row or column vector, nor does it contain any NaNs of Infs

coder.inline('always');

resHD = 720*1280;
if (size(a,1)*size(a,2) > resHD)
	sep_threshold = 81;
else
	sep_threshold = 289;
end

if ((numel(h) >= sep_threshold) && ...
        (ismatrix(h)) && ...
        all(size(h) ~= 1) && ...
        all(isfinite(h(:))))
    
    % extract the components if separable filter
    [~,s,~] = svd(h);
    
    % Call diag with explicit 2D input
    s = diag(s(:,:));
    tol = length(h) * max(s) * eps;
    rank = sum(s > tol);
    
    if (rank == 1)
        separable = true;
    else
        separable = false;
    end
    
else
    
    separable = false;
    
end
%--------------------------------------------------------------
function b = handleEmptyImage(a, sameSize, im_size)

coder.inline('always');
coder.internal.prefer_const(sameSize);
if (sameSize)
    
    b = a;
    
else
    
    if all(im_size >= 0)
        
        if islogical(a)
            b = false(im_size);
        else
            b = zeros(im_size,'like',a);
        end
        
    else
        
        eml_invariant(all(im_size < 0),...
            eml_message('images:imfilter:negativeDimensionBadSizeB'));
        if islogical(a)
            b = false(im_size);
        else
            b = zeros(im_size,'like',a);
        end
        
    end
    
end

%--------------------------------------------------------------
function b = handleEmptyFilter(a, sameSize, im_size)

coder.inline('always');
coder.internal.prefer_const(sameSize);
if (sameSize)
    
    if islogical(a)
        b = false(size(a));
    else
        b = zeros(size(a),'like',a);
    end
    
else
    
    if all(im_size>=0)
        
        if islogical(a)
            b = false(im_size);
        else
            b = zeros(im_size,'like',a);
        end
    else
        
        eml_invariant(all(im_size < 0),...
            eml_message('images:imfilter:negativeDimensionBadSizeB'));
        if islogical(a)
            b = false(im_size);
        else
            b = zeros(im_size,'like',a);
        end
        
    end
    
end

%--------------------------------------------------------------
function [finalSize, pad] = computeSizes(a, h, sameSize)

coder.inline('always');
coder.internal.prefer_const(sameSize);

nda = numel(size(a));
ndh = numel(size(h));
ndfinalSize = max(nda,ndh);
finalSize = coder.nullcopy(zeros(1,ndfinalSize));
filter_center = coder.nullcopy(zeros(1,ndfinalSize));
pad = coder.nullcopy(zeros(1,ndfinalSize));

if (sameSize)
    %Same output
    for k = coder.unroll(1:ndfinalSize)
        finalSize(k) = size(a,k);
        
        %Calculate the number of pad pixels
        filter_center(k) = floor((size(h,k) + 1)/2);
        pad(k) = size(h,k) - filter_center(k);
    end
else
    %Full output
    for k = coder.unroll(1:ndfinalSize)
        finalSize(k) = size(a,k) + size(h,k) - 1;
        pad(k) = size(h,k) - 1;
    end
end


function a = padImage(a_tmp, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos)

% Zero-pad input based on dimensions of filter kernel.
% Pad based on the last specified boundary string or boundary value
if boundaryEnum == CIRCULAR && boundary_pos < boundaryStr_pos
    a = padarray(a_tmp,pad,'circular','both');
elseif boundaryEnum == REPLICATE && boundary_pos < boundaryStr_pos
    a = padarray(a_tmp,pad,'replicate','both');
elseif boundaryEnum == SYMMETRIC && boundary_pos < boundaryStr_pos
    a = padarray(a_tmp,pad,'symmetric','both');
else
    a = padarray(a_tmp,pad,boundary,'both');
end


function a = padImage_gpu(a_tmp, h, pad, boundary, boundary_pos, boundaryEnum, boundaryStr_pos, sameSize)

nonSymmetricPadShift = 1-mod(size(h),2);

if sameSize && any(nonSymmetricPadShift == 1)
	if boundaryEnum == CIRCULAR && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'circular','both');
	elseif boundaryEnum == REPLICATE && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'replicate','both');
	elseif boundaryEnum == SYMMETRIC && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'symmetric','both');
	else
		a = padarray(a_tmp,pad,boundary,'both');
	end
	 a = a(1+nonSymmetricPadShift(1):end,1+nonSymmetricPadShift(2):end,:); 
else
	% Pad input based on dimensions of filter kernel.
	% Pad based on the last specified boundary string or boundary value

	% Zero-pad input based on dimensions of filter kernel.
	% Pad based on the last specified boundary string or boundary value
	if boundaryEnum == CIRCULAR && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'circular','both');
	elseif boundaryEnum == REPLICATE && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'replicate','both');
	elseif boundaryEnum == SYMMETRIC && boundary_pos < boundaryStr_pos
		a = padarray(a_tmp,pad,'symmetric','both');
	else
		a = padarray(a_tmp,pad,boundary,'both');
	end
end

function result = filterPartOrWhole(a, outSize, h, start, sameSize, convMode)

coder.inline('always');
coder.internal.prefer_const(sameSize, convMode);
% Create connectivity matrix.  Only use nonzero values of the filter.
conn = h~=0;

if coder.isColumnMajor
    % if filter is 1 x N or N x 1
    if isvector(h) && isvector(conn)
        h_tmp = h(:);
        nonzero_h = h_tmp(conn(:));
    else
        % For other shapes
        nonzero_h = h(conn);
    end
else
    % if filter is 1 x N or N x 1
    if isvector(h) && isvector(conn)
        h_tmp = h(:);
        nonzero_h = h_tmp(conn(:));
    else
        % For other shapes
        h_tmp = h.';
        nonzero_h = h_tmp(conn);
    end
end

% If the filter, h is complex, call imfiltercore once each for
% the real and imaginary parts of the filter.
% If the image, A is complex, imfiltercore applies the filter separately on
% the real and imaginary parts of the image.
if (isreal(h))

    result = imfiltercore(a, outSize, h, nonzero_h,...
        conn, start, sameSize, convMode);
    
else
    
    b1 = imfiltercore(a, outSize, real(h), real(nonzero_h),...
        conn, start, sameSize, convMode) ;
    
    b2 = imfiltercore(a, outSize, imag(h), imag(nonzero_h),...
        conn, start, sameSize, convMode) ;
    
    if isreal(a)
        
        % b1 and b2 will always be real; result will always be complex
        result = complex(b1, b2);
        
    else

        % b1 and/or b2 may be complex;
        % result will always be complex
        result = complex(real(b1) - imag(b2),...
            imag(b1) + real(b2));
        
    end
    
end

%--------------------------------------------------------------
function out = imfiltercore(a, outSize, h, nonzero_h,...
    connb, start, sameSize, convMode)

coder.inline('always');

coder.extrinsic('eml_try_catch');
% iptgetpref preference (obtained at compile time)
myfun      = 'iptgetpref';
[errid, errmsg, prefFlag] = eml_const(eml_try_catch(myfun, 'UseIPPL'));
eml_lib_assert(isempty(errmsg), errid, errmsg);

densityFlag = false;
if numel(nonzero_h)/numel(h) > 0.05
    densityFlag = true;
end

hDims = ndims(h);
hDimsFlag = (hDims == 2);

tooBig = true;
for i = 1:ndims(a)
    tooBig = tooBig && outSize(i)>65500;
end


myArchfun = 'computer';
[archErrid, archErrmsg, archStr] = eml_const(eml_try_catch(myArchfun,'arch'));
eml_lib_assert(isempty(archErrmsg),archErrid,archErrmsg);

% IPP filtering has an issue with sizes which are multiple of 256 on MAC.
% The executable obtained by building generated code has an offset of 1
% location. Disabling IPP for images which are multiples of 256 on MAC.
size256 = false;
if(strcmpi(archStr,'MACI64'))
    imsize = size(a);
    size256 = any(mod(imsize,256)==0);
end


modeFlag = prefFlag && densityFlag && hDimsFlag && (~tooBig) && ~size256;
modeFlag = modeFlag && ( (isa(a,'double') && ~strcmpi(archStr,'win32')) ...
    || isa(a,'single') || isa(a,'uint8') || isa(a,'int16') || isa(a,'uint16'));

% The filter, h will always be real but the image, a may be complex
if isreal(a)
    
    out = imfiltercoreAlgo(a, outSize, h, nonzero_h,...
        connb, start, sameSize, convMode, modeFlag);
else
    
    outR = imfiltercoreAlgo(real(a), outSize, h, nonzero_h,...
        connb, start, sameSize, convMode, modeFlag);
    
    outI = imfiltercoreAlgo(imag(a), outSize, h, nonzero_h,...
        connb, start, sameSize, convMode, modeFlag);
    
    out = outR + 1i*outI;
    
end

%--------------------------------------------------------------
function out = imfiltercoreAlgo(a, outSize, h, nonzero_h,...
    connb, start, sameSize, convMode, modeFlag)

coder.inline('always');
if islogical(a)
    out = coder.nullcopy(false(outSize));
else
    out = coder.nullcopy(zeros(outSize,'like', a));
end

if modeFlag
    % Use IPP codepath
    fcnName = ['ippfilter_', images.internal.coder.getCtype(a)];
    out = images.internal.coder.buildable.IppfilterBuildable.ippfiltercore(...
        fcnName,...
        a,...
        out,...
        outSize,...
        ndims(a),...
        size(a),...
        h,...
        size(h),...
        convMode);
else
    fcnName = ['imfilter_', images.internal.coder.getCtype(a)];
    out = images.internal.coder.buildable.ImfilterBuildable.imfiltercore(...
        fcnName,...
        a,...
        out,...
        numel(outSize),...
        outSize,...
        ndims(a),...
        size(a),...
        nonzero_h,...
        numel(nonzero_h),...
        connb,...
        ndims(connb),...
        size(connb),...
        start,...
        numel(start),...
        sameSize,...
        convMode);
end
    


