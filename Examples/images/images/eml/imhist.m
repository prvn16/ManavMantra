function [yout,x] = imhist(varargin) %#codegen
%IMHIST Display histogram of image data.

%   Copyright 2013-2016 The MathWorks, Inc.

%#ok<*EMCA>

coder.extrinsic('images.internal.coder.useSharedLibrary');

%--------------------------------------------------------------------------
% Parse inputs
%--------------------------------------------------------------------------

narginchk(1,2);
validateattributes(varargin{1}, {'double','uint8','int8','logical','uint16','int16','single','uint32', 'int32'}, ...
    {'nonsparse'}, mfilename, ['I or ' 'X'], 1);

if isreal(varargin{1})
    a = varargin{1};
else
    coder.internal.warning('images:imhistc:ignoreImaginaryPart');
    a = real(varargin{1});
end


switch (class(a))
    case {'double', 'single'}
        top = 1;
        
    case {'uint8', 'int8'}
        top = 255;
        
    case 'logical'
        top = 1;
        
    case {'int16', 'uint16'}
        top = 65535;
        
    case {'int32', 'uint32'}
        top = double(intmax('uint32'));
        
    otherwise
        eml_invariant(false,...
                eml_message('images:imhist:unsupportedInputClass'),...
                'IfNotConst','Fail');
end

if nargin == 2
    
    if (size(varargin{2},2) == 3)
        % IMHIST(X,MAP)
        eml_invariant(~isa(a,'int16'),...
            eml_message('images:imhist:invalidIndexedImage'),...
            'IfNotConst','Fail');
        
        iptcheckmap(varargin{2}, mfilename, 'varargin{2}', 2);
        n = size(varargin{2},1);
        isScaled = false;
        top = n;
        
    elseif isscalar(varargin{2})
        % IMHIST(I, N)
        eml_invariant(...
            (isscalar(varargin{2}) == 1) ,...
            eml_message('images:imhist:invalidSecondArgument'),...
            'IfNotConst','Fail');
        if islogical(a)
            eml_invariant(eml_is_const(varargin{2}) && ...
                isequal(varargin{2},2), ...
                eml_message('images:imhist:numBinsNotConstInCodegen'),...
                'IfNotConst','Fail');
        end
        validateattributes(varargin{2}, {'numeric'}, {'real','positive','integer'}, mfilename, ...
            'N', 2);
        n = double(varargin{2});
        isScaled = true;
    else
        eml_invariant(false,...
            eml_message('images:imhist:invalidSecondArgument'),...
            'IfNotConst','Fail');
    end
else % nargin == 1
    if isa(a,'logical')
        n = 2;
    else
        n = 256;
    end
    isScaled = true;
end

eml_invariant(n < intmax('uint32'),...
    eml_message('images:imhistc:tooManyBins',n));

eml_invariant(nargout > 0, ...
    eml_message('images:imhist:noDisplayInCodegen'), ...
    'IfNotConst','Fail');

%--------------------------------------------------------------------------
% Calculate histogram
%--------------------------------------------------------------------------
% The output is not intialized here but it must be initialized to zero 
% because the histogram of the input values will not always occupy all the 
% bins allocated in the output.
% For host-based code, output is initialized in the shared library, for
% portable code output must be initialized prior to use.
yout = coder.nullcopy(zeros(n,1));

if isempty(a)
    yout = zeros(n,1);
elseif islogical(a)
    yout(2) = sum(a(:));
    yout(1) = numel(a) - yout(2);
    yout = yout';
elseif isa(a,'int8')
    yout = calcHistogram(int8touint8(a), yout, n, isScaled, top);
elseif isa(a, 'int16')
    yout = calcHistogram(int16touint16(a), yout, n, isScaled, top);
elseif isa(a, 'int32')
    yout = calcHistogram(int32touint32(a), yout, n, isScaled, top);
else
    yout = calcHistogram(a, yout, n, isScaled, top);
end

range = getrangefromclass(a);

if ~isScaled
    if isfloat(a)
        x = 1:n;
    else
        x = 0:n-1;
    end
elseif islogical(a)
    x = range';
else
    % integer or float
    x = linspace(range(1), range(2), n)';
end

%--------------------------------------------------------------------------

function y = calcHistogram(a, y, n, isScaled, top)

coder.inline('always');
coder.internal.prefer_const(a,n,isScaled,top);

coder.extrinsic('images.internal.coder.useSharedLibrary');
if (coder.const(images.internal.coder.isCodegenForHost()) && ...
        coder.const(images.internal.coder.useSharedLibrary()))
    % MATLAB Host Target (PC)
    rngFlag = false;
    nanFlag = false;
    
    numCores = 1;
    numCores = images.internal.coder.buildable.GetnumcoresBuildable.getnumcores(numCores);
    
    % number of threads (obtained at compile time)
    singleThread = images.internal.coder.useSingleThread();
    
    GRAIN_SIZE = 500000;
    
    useParallel = ...
        (numel(a) > GRAIN_SIZE) && ...
        (numCores > 1) && ...
        (~singleThread);
    
    if coder.isColumnMajor
        rowsA = size(a,1); %MxGetM(a)
        colsAEtc = numel(a)/size(a,1);
    else
        sizeA = size(a);
        rowsA = sizeA(end);
        colsAEtc = numel(a)/sizeA(end);
    end
    
    switch(class(a))
        case 'uint8'
            if isScaled
                if ((n == 256) && (top == 255))
                    if useParallel
                        [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint8(...
                            a,...
                            numel(a),...
                            rowsA,...
                            colsAEtc,...
                            y,...
                            numel(y),...
                            n,...
                            rngFlag,...
                            nanFlag);
                    else
                        [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,256,y);
                    end
                else
                    if useParallel
                        [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint8_scaled(...
                            a,...
                            numel(a),...
                            rowsA,...
                            colsAEtc,...
                            y,...
                            numel(y),...
                            top,...
                            n,...
                            rngFlag,...
                            nanFlag);
                    else
                        [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
                    end
                end
            else
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint8(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,256,y);
                end
            end
        case 'uint16'
            if isScaled
                if ((n == 65536) && (top == 65535))
                    if useParallel
                        [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint16(...
                            a,...
                            numel(a),...
                            rowsA,...
                            colsAEtc,...
                            y,...
                            numel(y),...
                            n,...
                            rngFlag,...
                            nanFlag);
                    else
                        [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,65536,y);
                    end
                else
                    if useParallel
                        [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint16_scaled(...
                            a,...
                            numel(a),...
                            rowsA,...
                            colsAEtc,...
                            y,...
                            numel(y),...
                            top,...
                            n,...
                            rngFlag,...
                            nanFlag);
                    else
                        [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
                    end
                end
            else
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint16(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,65536,y);
                end
            end
        case 'uint32'
            if useParallel
                [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_uint32_scaled(...
                    a,...
                    numel(a),...
                    rowsA,...
                    colsAEtc,...
                    y,...
                    numel(y),...
                    top,...
                    n,...
                    rngFlag,...
                    nanFlag);
            else
                [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
            end
        case 'single'
            if isScaled
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_single_scaled(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        top,...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_floating_scaled(a,n,top,y);
                end
                
            else
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_single(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_floating(a,n,y);
                end
            end
        case 'double'
            if isScaled
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_double_scaled(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        top,...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_floating_scaled(a,n,top,y);
                end
                
            else
                if useParallel
                    [y, rngFlag, nanFlag] = images.internal.coder.buildable.TbbhistBuildable.tbbhistcore_double(...
                        a,...
                        numel(a),...
                        rowsA,...
                        colsAEtc,...
                        y,...
                        numel(y),...
                        n,...
                        rngFlag,...
                        nanFlag);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_floating(a,n,y);
                end
            end
        otherwise
            eml_invariant(false,...
                eml_message('images:imhist:unsupportedInputClass'),...
                'IfNotConst','Fail');
    end
    
else % Non-PC Targets
    switch(class(a))
        case 'uint8'
            if isScaled
                if ((n == 256) && (top == 255))
                    [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,256,y);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
                end
            else
                [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,256,y);
            end
            
        case 'uint16'
            if isScaled
                if ((n == 65536) && (top == 65535))
                    [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,65536,y);
                else
                    [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
                end
            else
                [y, rngFlag, nanFlag] = imhistAlgo_integer(a,n,65536,y);
            end
            
        case 'uint32'
            [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(a,n,top,y);
        
        case 'single'
            if isScaled
                [y, rngFlag, nanFlag] = imhistAlgo_floating_scaled(a,n,top,y);
            else
                [y, rngFlag, nanFlag] = imhistAlgo_floating(a,n,y);
            end
            
        case 'double'
            if isScaled
                [y, rngFlag, nanFlag] = imhistAlgo_floating_scaled(a,n,top,y);
            else
                [y, rngFlag, nanFlag] = imhistAlgo_floating(a,n,y);
            end
            
        otherwise
            eml_invariant(false,...
                eml_message('images:imhist:unsupportedInputClass'),...
                'IfNotConst','Fail');
    end
end

% Range and NaN warnings
if rngFlag
    coder.internal.warning('images:imhistc:outOfRange');
end

if nanFlag
    coder.internal.warning('images:imhistc:inputHasNaNs');
end

%--------------------------------------------------------------------------
function [y, rngFlag, nanFlag] = imhistAlgo_floating_scaled(img,n,top,y)
% Algorithm for floating-point, scaled histogram binning.

coder.inline('always');
coder.internal.prefer_const(img,n,top);

y(:) = zeros(n,1);
scale = cast(n-1,'like',img)/cast(top,'like',img);

nanFlag = false;
rngFlag = false;
idx = coder.nullcopy(zeros(1,'like',img));

if coder.isColumnMajor() || (coder.isRowMajor() && numel(size(img))>2)
    for i = 1:numel(img)
        if isnan(img(i))
            nanFlag = true;
            idx(1) = 0;
        else
            % idx = floor(img(i) * scale + 0.5);
            % floor() is not required as the subsequent call to
            % coder.internal.indexPlus(idx(1),1) introduces a c-style cast of
            % idx(1) before adding which truncates the index value as desired.
            % idx is expected to be non-negative and less than the size of the
            % output array before the cast is applied.
            idx(1) = img(i) * scale + 0.5;
        end
        
        if idx < 0
            % Use the first bin for -Inf and other index values below the
            % lower range (0).
            y(1) = y(1) + 1;
        elseif (idx > n-1)
            y(end) = y(end) + 1;
        elseif isinf(img(i))
            % Use the last bin for Inf inputs as the calculated index is not
            % in the valid range.
            y(end) = y(end) + 1;
        else
            % Add 1 to the index to account for 1-indexing in MATLAB vs
            % 0-indexing in C.
            y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
        end
    end
else
    % Row-major 2-D only
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            if isnan(img(i,j))
                nanFlag = true;
                idx(1) = 0;
            else
                % idx = floor(img(i,j) * scale + 0.5);
                % floor() is not required as the subsequent call to
                % coder.internal.indexPlus(idx(1),1) introduces a c-style cast of
                % idx(1) before adding which truncates the index value as desired.
                % idx is expected to be non-negative and less than the size of the
                % output array before the cast is applied.
                idx(1) = img(i,j) * scale + 0.5;
            end
            
            if idx < 0
                % Use the first bin for -Inf and other index values below the
                % lower range (0).
                y(1) = y(1) + 1;
            elseif (idx > n-1)
                y(end) = y(end) + 1;
            elseif isinf(img(i,j))
                % Use the last bin for Inf inputs as the calculated index is not
                % in the valid range.
                y(end) = y(end) + 1;
            else
                % Add 1 to the index to account for 1-indexing in MATLAB vs
                % 0-indexing in C.
                y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
            end
        end
    end
end

%--------------------------------------------------------------------------
function [y, rngFlag, nanFlag] = imhistAlgo_floating(img,n,y)
% Algorithm for floating-point, unscaled histogram binning.

coder.inline('always');
coder.internal.prefer_const(img,n);

y(:) = zeros(n,1);
nanFlag = false;
rngFlag = false;

if coder.isColumnMajor() || (coder.isRowMajor() && numel(size(img))>2)
    for i = 1:numel(img)
        if isnan(img(i))
            nanFlag = true;
            idx = coder.internal.indexInt(0);
        else
            value_minus_1 = cast(img(i) - 1.0,'double');
            
            if value_minus_1 < 0
                rngFlag = true;
                idx = coder.internal.indexInt(0);
            elseif (value_minus_1 > n)
                rngFlag = true;
                idx = coder.internal.indexInt(n-1);
            else
                idx = coder.internal.indexInt(value_minus_1);
            end
        end
        % Add 1 to the index to account for 1-indexing in MATLAB vs
        % 0-indexing in C.
        y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
    end
else
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            if isnan(img(i,j))
                nanFlag = true;
                idx = coder.internal.indexInt(0);
            else
                value_minus_1 = cast(img(i,j) - 1.0,'double');
                
                if value_minus_1 < 0
                    rngFlag = true;
                    idx = coder.internal.indexInt(0);
                elseif (value_minus_1 > n)
                    rngFlag = true;
                    idx = coder.internal.indexInt(n-1);
                else
                    idx = coder.internal.indexInt(value_minus_1);
                end
            end
            % Add 1 to the index to account for 1-indexing in MATLAB vs
            % 0-indexing in C.
            y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
        end
    end
end

%--------------------------------------------------------------------------
function [y, rngFlag, nanFlag] = imhistAlgo_integer_scaled(img,n,top,y)
% Algorithm for histogram binning of scaled integers.

coder.inline('always');
coder.internal.prefer_const(img,n,top);

nanFlag = false;
rngFlag = false;

scale = (n-1)/top;

% The following commented code section represents the simplified version of 
% the algorithm expressed below using loop unrolling
%
% Simplified code:
%
% for i = 1:numel(img)
%     idx = coder.internal.indexInt(double(img(i))*scale+0.5);
% 
%     if idx > n-1
%         y(end) = y(end) + 1;
%     else
%         y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
%     end
% end

y(:) = zeros(n,1); % used as both the output and the 4th bin group.

if coder.isColumnMajor() || (coder.isRowMajor() && numel(size(img))>2)
    localBins1 = zeros(n,1);
    localBins2 = zeros(n,1);
    localBins3 = zeros(n,1);
    
    i = coder.internal.indexInt(1);
    % Use loop unrolling to process input values in groups of 4 per loop. This
    % aids in instruction level parallelism which improves performance.
    while (i+3 <= numel(img))
        idx1 = coder.internal.indexInt(double(img(i))*scale+0.5);
        idx2 = coder.internal.indexInt(double(img(i+1))*scale+0.5);
        idx3 = coder.internal.indexInt(double(img(i+2))*scale+0.5);
        idx4 = coder.internal.indexInt(double(img(i+3))*scale+0.5);
        
        if idx1 > n-1
            localBins1(end) = localBins1(end) + 1;
        else
            localBins1(coder.internal.indexPlus(idx1,1)) = localBins1(coder.internal.indexPlus(idx1,1)) + 1;
        end
        
        if idx2 > n-1
            localBins2(end) = localBins2(end) + 1;
        else
            localBins2(coder.internal.indexPlus(idx2,1)) = localBins2(coder.internal.indexPlus(idx2,1)) + 1;
        end
        
        if idx3 > n-1
            localBins3(end) = localBins3(end) + 1;
        else
            localBins3(coder.internal.indexPlus(idx3,1)) = localBins3(coder.internal.indexPlus(idx3,1)) + 1;
        end
        
        if idx4 > n-1
            y(end) = y(end) + 1;
        else
            y(coder.internal.indexPlus(idx4,1)) = y(coder.internal.indexPlus(idx4,1)) + 1;
        end
        
        i = i + 4;
    end
    
    % Process remaining input values
    while (i <= numel(img))
        idx = coder.internal.indexInt(double(img(i))*scale+0.5);
        
        if idx > n-1
            y(end) = y(end) + 1;
        else
            y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
        end
        
        i = i + 1;
    end
    
    % Combine unrolled bins.
    for i = 1:n
        y(i) = y(i) + localBins1(i) + localBins2(i) + localBins3(i);
    end
else
    % Row-major 2-D only
    for p = 1:size(img,1)
        for q = 1:size(img,2)
            idx = coder.internal.indexInt(double(img(p,q))*scale+0.5);
            
            if idx > n-1
                y(end) = y(end) + 1;
            else
                y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
            end
        end
    end
end

%--------------------------------------------------------------------------
function [y, rngFlag, nanFlag] = imhistAlgo_integer(img,n,BINS,y)
% Algorithm for histogram binning of unscaled integers.

coder.inline('always');
coder.internal.prefer_const(img,n);

nanFlag = false;
rngFlag = false;

% The following commented code section represents the simplified version of 
% the algorithm expressed below using loop unrolling
%
% Simplified code:
%
% for i = 1:numel(img)
%     idx = coder.internal.indexInt(img(i)); % size_t no static cast
%     
%     if idx > n-1
%         rngFlag = true;
%         y(end) = y(end) + 1;
%     else
%         y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
%     end
% end

y(:) = zeros(n,1); % used as both the output and the 4th bin group.

if coder.isColumnMajor() || (coder.isRowMajor() && numel(size(img))>2)
    localBins1 = zeros(n,1);
    localBins2 = zeros(n,1);
    localBins3 = zeros(n,1);
    
    i = coder.internal.indexInt(1);
    if (n == BINS)
        % Use loop unrolling to process input values in groups of 4 per loop
        while (i+3 <= numel(img))
            idx1 = coder.internal.indexInt(img(i));
            idx2 = coder.internal.indexInt(img(i+1));
            idx3 = coder.internal.indexInt(img(i+2));
            idx4 = coder.internal.indexInt(img(i+3));
            
            localBins1(coder.internal.indexPlus(idx1,1)) = localBins1(coder.internal.indexPlus(idx1,1)) + 1;
            localBins2(coder.internal.indexPlus(idx2,1)) = localBins2(coder.internal.indexPlus(idx2,1)) + 1;
            localBins3(coder.internal.indexPlus(idx3,1)) = localBins3(coder.internal.indexPlus(idx3,1)) + 1;
            y(coder.internal.indexPlus(idx4,1)) = y(coder.internal.indexPlus(idx4,1)) + 1;
            
            i = i + 4;
        end
        
        % Process remaining input values
        while (i <= numel(img))
            idx = coder.internal.indexInt(img(i));
            
            y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
            
            i = i + 1;
        end
    else
        % Use loop unrolling to process input values in groups of 4 per loop
        while (i+3 <= numel(img))
            idx1 = coder.internal.indexInt(img(i));
            idx2 = coder.internal.indexInt(img(i+1));
            idx3 = coder.internal.indexInt(img(i+2));
            idx4 = coder.internal.indexInt(img(i+3));
            
            if idx1 > n-1
                rngFlag = true;
                localBins1(end) = localBins1(end) + 1;
            else
                localBins1(coder.internal.indexPlus(idx1,1)) = localBins1(coder.internal.indexPlus(idx1,1)) + 1;
            end
            
            if idx2 > n-1
                rngFlag = true;
                localBins2(end) = localBins2(end) + 1;
            else
                localBins2(coder.internal.indexPlus(idx2,1)) = localBins2(coder.internal.indexPlus(idx2,1)) + 1;
            end
            
            if idx3 > n-1
                rngFlag = true;
                localBins3(end) = localBins3(end) + 1;
            else
                localBins3(coder.internal.indexPlus(idx3,1)) = localBins3(coder.internal.indexPlus(idx3,1)) + 1;
            end
            
            if idx4 > n-1
                rngFlag = true;
                y(end) = y(end) + 1;
            else
                y(coder.internal.indexPlus(idx4,1)) = y(coder.internal.indexPlus(idx4,1)) + 1;
            end
            
            i = i + 4;
            
        end
        
        % Process remaining input values
        while (i <= numel(img))
            idx = coder.internal.indexInt(img(i));
            
            if idx > n-1
                rngFlag = true;
                y(end) = y(end) + 1;
            else
                y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
            end
            
            i = i + 1;
        end
        
    end
    
    % Combine all bins.
    for i = 1:n
        y(i) = y(i) + localBins1(i) + localBins2(i) + localBins3(i);
    end
else
    % Row-major 2-D only
    for p = 1:size(img,1)
        for q = 1:size(img,2)
            idx = coder.internal.indexInt(img(p,q));
            
            if idx > n-1
                rngFlag = true;
                y(end) = y(end) + 1;
            else
                y(coder.internal.indexPlus(idx,1)) = y(coder.internal.indexPlus(idx,1)) + 1;
            end
        end
    end
end
