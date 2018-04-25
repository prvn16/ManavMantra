function out = imboxfilt(A, varargin)%#codegen
% IMBOXFILTER 2-D box filtering of images
%

% Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

    narginchk(1, 6);
    
    validateImage(A);
    
    [normFactor, filterSize, padding] = parseInputs(varargin{:});
    
    if isempty(A)
        out = zeros(size(A),'like',A);
        return;
    end
    
    coder.extrinsic('images.internal.coder.useSharedLibrary');
    useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary());
    useSharedLibrary = useSharedLibrary && ...
        coder.const(images.internal.coder.isCodegenForHost()) && ...
            coder.const(~images.internal.coder.useSingleThread()) && ...
            ~(coder.isRowMajor && numel(size(A))>2);
   
    imfilterFaster = isImfilterFaster(filterSize, useSharedLibrary);

    if (imfilterFaster)
        out = boxFilterFromImfilter(A, filterSize, padding, normFactor);
    else
        if(useSharedLibrary)
            out = boxFilterFromIntegralImageSharedLib(A, filterSize, padding, normFactor);
        else
            out = boxFilterFromIntegralImagePortable(A, filterSize, padding, normFactor);
        end
    end

end

function [NormalizationFactor, FilterSize, Padding] = parseInputs(varargin)
    
    coder.inline('always');
    coder.internal.prefer_const(varargin);
    
    % Default values
    FilterSizeDefault = [3,3];
    NormalizationFactorDefault = 1/9;
    PaddingDefault = 'replicate';

    if nargin > 0
        % If first input is FilterSize
        if ~ischar(varargin{1})
            % Validate FilterSize
            FilterSize = validateFilterSize(varargin{1});
            % compute Norm factor
            NormalizationFactorDefault = 1/prod(FilterSize);
            beginNVIdx = 2;
        else
            % The first input is NV pair
            FilterSize = FilterSizeDefault;
            beginNVIdx = 1;
        end
        
        % Parse the VN pair for NormalizationFactor
        [normFactor, pad] = parseNameValuePairs(NormalizationFactorDefault, PaddingDefault,...
                                                varargin{beginNVIdx:end});
        NormalizationFactor = validateNormalizationFactor(normFactor);
        Padding = validatePadding(pad);
        
    else
        % No input params given use the default filter values
        FilterSize = FilterSizeDefault;
        NormalizationFactor = NormalizationFactorDefault;
        Padding = PaddingDefault;
    end

end

function [normalizationFactor, pad] = parseNameValuePairs(normFactorDefault, PaddingDefault, ...
                                                   varargin)
                                               
    coder.inline('always');
    coder.internal.prefer_const(normFactorDefault,varargin);

    params = struct( 'NormalizationFactor', uint32(0),...
                     'Padding', uint32(0));

    options = struct( ...
        'CaseSensitivity',false, ...
        'StructExpand',   true, ...
        'PartialMatching',true);

    optarg = eml_parse_parameter_inputs(params,options,varargin{:});

    normalizationFactor = eml_get_parameter_value( ...
        optarg.NormalizationFactor, ...
        normFactorDefault, ...
        varargin{:});
    
    pad = eml_get_parameter_value( ...
        optarg.Padding, ...
        PaddingDefault, ...
        varargin{:});
end

function validateImage(A)

supportedTypes = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
supportedAttributes = {'real','nonsparse'};
validateattributes(A, supportedTypes, supportedAttributes, mfilename, 'A');

end

function filterSize = validateFilterSize(filterSizeIn)

    coder.inline('always');
    coder.internal.prefer_const(filterSizeIn);

    validateattributes(filterSizeIn,{'numeric'}, ...
    {'real','nonsparse','nonempty','positive','integer','odd'}, ...
    mfilename,'filterSize');
    
    filterSize = coder.nullcopy(zeros(1,2));
    
    if isscalar(filterSizeIn)
        filterSize(:) = [double(filterSizeIn),double(filterSizeIn)];
    else
        coder.internal.errorIf(numel(filterSizeIn) ~= 2, ...
            'images:validate:badVectorLength','filterSize',2);

        filterSize(:) = [double(filterSizeIn(1)),double(filterSizeIn(2))];
    end
    
end

function pad = validatePadding(padIn)

    coder.inline('always');
    coder.internal.prefer_const(padIn);

    if ~ischar(padIn)
        validateattributes(padIn, {'numeric'}, {'real','scalar','nonsparse'}, mfilename, 'Padding');
        pad = padIn;
    else
        pad = validatestring(padIn, {'replicate','circular','symmetric'}, mfilename, 'Padding');
    end

end

function normalize = validateNormalizationFactor(normalize)
    
    coder.inline('always');
    coder.internal.prefer_const(normalize);
    
    validateattributes(normalize, {'numeric'}, {'real','nonzero','scalar','nonsparse'}, mfilename, 'NormalizationFactor');
    normalize = double(normalize); 

end

function TF = isImfilterFaster( hsize, useSharedLibrary)   
    coder.inline('always');
    coder.internal.prefer_const(hsize);
    
    % We use integral image implementation if the kernel is large.
    TF =  prod(prod(hsize)) < getBoxFilterThreshold(useSharedLibrary);        
end


function minKernelElems = getBoxFilterThreshold(useSharedLibrary)
    
    if(useSharedLibrary)
        minKernelElems = 250;   %break-even is close to 15x15 for sharedlib codegen
    else
        minKernelElems = 25;   %break-even is close to 5x5 for portable codegen
        
    end

end

function A = boxFilterFromImfilter(A, hsize, padding, normFactor)

    box = ones(hsize) .* normFactor;
    A = imfilter(A, box, padding);

end

function out = boxFilterFromIntegralImagePortable(A, filterSize, padding, normFactor)

    % Assume filtSize is odd.
    padSize = (filterSize - 1)/2;

    paddedImage = padarray(A,padSize,padding,'both');

    intA = integralImage(paddedImage);
    
    outDouble = integralBoxFilter(intA, filterSize, 'NormalizationFactor', normFactor); % Check data copies

    out = cast(outDouble, class(A));
end


function out = boxFilterFromIntegralImageSharedLib(A, filterSize, padding, normFactor)

    % Assume filtSize is odd.
    padSize = (filterSize - 1)/2;

    paddedImage = padarray(A,padSize,padding,'both');

    intA = integralImage(paddedImage);
    
    outSize = size(intA) - [filterSize(1:2),zeros(1,numel(size(intA))-2)];
    
    out = coder.nullcopy(zeros(outSize,'like',A));
    
    nPlanes = coder.internal.prodsize(out,'above',2);
    
    
    
    fcnName = ['boxfilter_', images.internal.coder.getCtype(A)];
    
    out = images.internal.coder.buildable.BoxfilterBuildable.boxfiltercore(fcnName,...
        intA,...
        size(intA),...
        filterSize,...
        normFactor,...
        [1 1],... %preRow and preCol hard coded as [1 1]. This is reserved for a future functionality
        out,...
        outSize,...
        nPlanes);
    
end

