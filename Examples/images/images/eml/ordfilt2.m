function B = ordfilt2(varargin) %#codegen
%Copyright 2013-2017 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(3,5);
coder.internal.prefer_const(varargin);

% Shared library
coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(images.internal.coder.useSharedLibrary());

% image
image = varargin{1};

% order
order = varargin{2};
validateattributes(order,{'double'},{'real','scalar','integer'}, ...
    mfilename, 'ORDER',2);

% domain
validateattributes(varargin{3},{'numeric','logical'},{'2d','real'}, mfilename, ...
    'DOMAIN',3);
domain = logical(varargin{3});

% check order
coder.internal.errorIf(((order<1) || order>sum(domain(:))), ...
    'images:ordfilt2:orderNotValid');

% padopt of 'ones' is for supporting medfilt2; it is undocumented.
padOptions = {'zeros', 'ones', 'symmetric'};

if (nargin == 4)
    % padopt or additive offsets
    if (ischar(varargin{4}))
        eml_invariant(eml_is_const(varargin{4}),...
            eml_message('MATLAB:images:validate:codegenInputNotConst','PADOPT'), ...
            'IfNotConst','Fail');
        padopt  = validatestring(varargin{4},padOptions,mfilename,'PADOPT',4);
        offsets = [];
    else
        padopt  = 'zeros';
        offsets = varargin{4};
    end
elseif (nargin == 5)
    % additive offsets
    eml_invariant(eml_is_const(varargin{5}),...
        eml_message('MATLAB:images:validate:codegenInputNotConst','PADOPT'), ...
        'IfNotConst','Fail');
    padopt  = validatestring(varargin{5},padOptions,mfilename,'PADOPT',5);
    offsets = varargin{4};
else
    padopt  = 'zeros';
    offsets = [];
end

if ~isempty(offsets)
    validateattributes(image,...
        {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'},...
        {'2d','real','nonsparse'},mfilename,'A',1);
    A = double(image);
    % check offsets
    coder.internal.errorIf(~isequal(size(offsets), size(domain)), ...
        'images:ordfilt2:sizeMismatch');
    sDomain = offsets(domain ~= 0);
    validateattributes(offsets, {'double'}, {'real'}, mfilename, 'S', 4);
else
    sDomain = [];
    A = image;
    validateattributes(A, ...
        {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'},...
        {'2d','real','nonsparse'}, mfilename, 'A', 1);
end

% center of domain
domainSize = size(domain);
domainSize = coder.internal.flipIf(coder.isRowMajor,domainSize);
center     = floor((domainSize + 1) / 2);

if coder.isColumnMajor()
    % find implementation - MATLAB's find at run-time cannot accept row-vectors
    if(eml_is_const(domain))
        [rows, cols] = find(domain);
    else
        numElems = sum(domain(:));
        cols = zeros([numElems, 1]);
        rows = zeros([numElems, 1]);
        index = 1;
        for i = 1:numel(domain)
            if(domain(i))
                [rows(index), cols(index)] = ind2sub(size(domain), i);
                index = index + 1;
            end
        end
    end
else
    if(eml_is_const(domain))
        [rows, cols] = find(domain);
    else
        numElems = sum(domain(:));
        cols = zeros([numElems, 1]);
        rows = zeros([numElems, 1]);
        index = 1;
        for r = 1:size(domain,1)
            for c = 1:size(domain,2)
                if(domain(r,c))
                    rows(index) = c;
                    cols(index) = r;
                    index = index + 1;
                end
            end
        end
    end
end

rows = rows - center(1);
cols = cols - center(2);
padSize = max(max(abs(rows)), max(abs(cols)));

if (strcmp(padopt, 'zeros'))
    Apad = padarray(A, padSize * [1 1], 0, 'both');
elseif (strcmp(padopt, 'ones'))
    Apad = padarray(A, padSize * [1 1], 1, 'both');
else
    Apad = padarray(A, padSize * [1 1], 'symmetric', 'both');
end

if(isempty(image))
    B = A;
else
    if(useSharedLibrary)
        if coder.isColumnMajor()
            Ma = size(Apad,1);
        else
            Ma = size(Apad,2);
        end
        indices = int32(cols*Ma + rows);
        startIdx = [padSize padSize];
        B = ordfilt2SharedLibrary(A, Apad, order, offsets, indices, startIdx, domainSize, sDomain);
    else
        B = ordfilt2PortableAlgo(A, Apad, order, offsets, domain, padSize, sDomain);
    end
end
end

function B = ordfilt2SharedLibrary(A, Apad, order, offsets, indices, startIdx, domainSize, sDomain)
%% Shared Library
coder.inline('always');
coder.internal.prefer_const(A, Apad, order, offsets, indices, startIdx, domainSize, sDomain);

% using C-style order; indices start from 0 in the shared library
ctype = images.internal.coder.getCtype(A);

if isempty(offsets)
    %ORDFILT2(A,ORDER,DOMAIN)
    fcnName = ['ordfilt2_', ctype];
    if(islogical(A))
        B = coder.nullcopy(true(size(A)));
    else
        B = coder.nullcopy(zeros(size(A), 'like', A));
    end
    
    B = images.internal.coder.buildable.Ordfilt2Buildable.ordfilt2core(fcnName, Apad, order-1, indices, startIdx, ...
        domainSize, B);
else
    %ORDFILT2(A,ORDER,DOMAIN,S,PADOPT)
    fcnName = 'ordfilt2_offsets';
    B = coder.nullcopy(zeros(size(A), 'double'));
    
    B = images.internal.coder.buildable.Ordfilt2Buildable.ordfilt2offsetscore(fcnName, Apad, order-1, indices, startIdx, ...
        domainSize, sDomain, B);
end
end

function B = ordfilt2PortableAlgo(A, Apad, order, offsets, domain, padSize, sDomain)
%% Portable Code
coder.inline('always');
coder.internal.prefer_const(A, Apad, order, offsets, domain, padSize, sDomain);

borderUp = padSize-floor((size(domain,1)-1)/2);
borderDown = padSize+floor(size(domain,1)/2);
borderLeft = padSize-floor((size(domain,2)-1)/2);
borderRight = padSize+floor(size(domain,2)/2);

if isempty(offsets)
    if(islogical(A))
        B = coder.nullcopy(false(size(A)));
        for j = 1:size(A,2)
            for i = 1:size(A,1)
                sortPixels = 0;
                for l = j+borderLeft:j+borderRight
                    for k = i+borderUp:i+borderDown
                        sortPixels = sortPixels + Apad(k,l);
                    end
                end
                B(i,j) = ge(sortPixels,numel(domain)-order+1);
            end
        end
    else
        buffer = zeros([nnz(domain) 1],'like',A);
        bufferIndices = zeros([nnz(domain) 1],'like',A);
        B = zeros(size(A), 'like', A);
        k = 0;
        for ii = 1:numel(domain)
            if(domain(ii))
                k = k+1;
                bufferIndices(k) = ii;
            end
        end
        for j = 1:size(A,2)
            for i = 1:size(A,1)
                sortSum = zeros(1,'like',Apad);
                toSort = Apad(i+borderUp:i+borderDown, j+borderLeft:j+borderRight);
                for ii=1:numel(bufferIndices)
                    buffer(ii) = toSort(bufferIndices(ii));
                    sortSum = sortSum + buffer(ii);
                end
                sortPixels = sort(buffer);
                if(isfloat(A))
                    if(isnan(sortSum))
                        B(i,j) = sortPixels(end);
                    else
                        B(i,j) = sortPixels(order);
                    end
                else
                    B(i,j) = sortPixels(order);
                end
            end
        end
    end
else
    buffer = zeros([nnz(domain) 1],'like',A);
    bufferIndices = zeros([nnz(domain) 1],'like',A);
    B = zeros(size(A), 'like', A);
    k = 0;
    for ii = 1:numel(domain)
        if(domain(ii))
            k = k+1;
            bufferIndices(k) = ii;
        end
    end
    for j = 1:size(A,2)
        for i = 1:size(A,1)
            sortSum = zeros(1,'like',Apad);
            toSort = Apad(i+borderUp:i+borderDown, j+borderLeft:j+borderRight);
            for ii=1:numel(bufferIndices)
                buffer(ii) = toSort(bufferIndices(ii));
                sortSum = sortSum + buffer(ii) + sDomain(ii);
            end
            sortPixels = sort(buffer(:)+sDomain(:));
            if(isnan(sortSum))
                B(i,j) = sortPixels(end);
            else
                B(i,j) = sortPixels(order);
            end
        end
    end
end
end
