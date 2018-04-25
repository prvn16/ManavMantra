function B = imgaussfilt(A, varargin)%#codegen
%IMGAUSSFILT 2-D Gaussian filtering of images

% Copyright 2015, The MathWorks, Inc.

    narginchk(1, 6);

    supportedClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
    supportedImageAttributes = {'real','nonsparse'};
    validateattributes(A, supportedClasses, supportedImageAttributes, mfilename, 'A');

    [sigma, hsize, padding] = parseInputs(varargin{:});

    B = spatialGaussianFilter(A, sigma, hsize, padding);

end

%--------------------------------------------------------------------------
% Spatial Domain Filtering
%--------------------------------------------------------------------------
function out = spatialGaussianFilter(A, sigma, hsize, padding)
    
    h = images.internal.createGaussianKernel(sigma, hsize);
    out = imfilter(A, h, padding);
    
end


function filterSize = computeFilterSizeFromSigma(sigma)

filterSize = 2*ceil(2*sigma) + 1;

end


%--------------------------------------------------------------------------
% Input Parsing
%--------------------------------------------------------------------------
function [sigma, hsize, padding] = parseInputs(varargin)

    sigmaDefault = [0.5 0.5];
    filterSizeDefault = [3 3];
    paddingDefault = 'replicate';
        
    if nargin > 0 
        if ~ischar(varargin{1})
         
            sigma = validateSigma(varargin{1});
            filterSizeDefault = computeFilterSizeFromSigma(sigma);
            beginNVIdx = 2;
        else
            sigma = sigmaDefault;
            beginNVIdx = 1;
        end

        % Parse the VN pair for NormalizationFactor
        [filtSize, pad] = parseNameValuePairs(filterSizeDefault, paddingDefault, ...
                                                    varargin{beginNVIdx:end});
        hsize = validateFilterSize (filtSize);
        padding = validatePadding (pad);
        
    else

        sigma = sigmaDefault;
        hsize = filterSizeDefault;
        padding = paddingDefault;
        
    end

end


function [hsize, padding] = parseNameValuePairs(filterSizeDefault, paddingDefault, ...
                                                   varargin)
                                               
    coder.inline('always');
    coder.internal.prefer_const(filterSizeDefault,varargin);

    params = struct( 'FilterSize', uint32(0),...
                     'Padding', uint32(0));

    options = struct( ...
        'CaseSensitivity',false, ...
        'StructExpand',   true, ...
        'PartialMatching',true);

    optarg = eml_parse_parameter_inputs(params,options,varargin{:});

    hsize = eml_get_parameter_value( ...
        optarg.FilterSize, ...
        filterSizeDefault, ...
        varargin{:});
    
    padding = eml_get_parameter_value( ...
        optarg.Padding, ...
        paddingDefault, ...
        varargin{:});
end

function sigma = validateSigma(sigmaIn)

validateattributes(sigmaIn, {'numeric'}, {'real','nonsparse','positive','finite','nonempty'}, mfilename, 'Sigma');

if numel(sigmaIn)>2
    coder.internal.errorIf(numel(sigmaIn)>2, 'images:imgaussfilt:invalidLength', 'Sigma');
end

if isscalar(sigmaIn)
    sigma = [double(sigmaIn) double(sigmaIn)];
else
    sigma = [double(sigmaIn(1)) double(sigmaIn(2))];
end



end

function filterSize = validateFilterSize(filterSizeIn)

    coder.inline('always');
    coder.internal.prefer_const(filterSizeIn);

    validateattributes(filterSizeIn, {'numeric'},...
        {'real','nonsparse','positive','integer','odd'}, mfilename, 'filterSize');

    if isscalar(filterSizeIn)
        
        filterSize = [double(filterSizeIn) double(filterSizeIn)];
    
    else
        
        coder.internal.errorIf(numel(filterSizeIn)~= 2,'images:validate:badVectorLength');

        % Convert filterSizeIn vector to row if needed
        filterSize = [double(filterSizeIn(1)) double(filterSizeIn(2))];
    end
end

function paddingout = validatePadding(padding)

coder.internal.prefer_const(padding);

if ~ischar(padding)
    validateattributes(padding, {'numeric','logical'}, {'real','scalar','nonsparse'}, mfilename, 'Padding');
    paddingout = padding;
else
    paddingout = validatestring(padding, {'replicate','circular','symmetric'}, mfilename, 'Padding');
end

end