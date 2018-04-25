function [L,N] = superpixels3(varargin)
%SUPERPIXELS3 3-D superpixel over-segmentation of 3-D images
%
%   [L,NumLabels] = superpixels3(A,N) computes 3-D superpixels of 3-D image
%   A using N as the requested number of superpixels.  N must be between 1
%   and the number of pixels in the image A. The first output argument, L, is
%   a label matrix of type double. The second output argument, NumLabels,
%   is the actual number of 3-D superpixels that were computed.
%
%   [L,NumLabels] = superpixels3(___,Name,Value,...) computes superpixels of A
%   with Name-Value pairs used to control aspects of the segmentation.
%
%   Parameters include:
%
%   'Compactness'         - Numeric scalar specifying the compactness
%                           parameter of the SLIC algorithm. Compactness
%                           controls the shape of superpixels. A higher
%                           value for compactness makes superpixels more
%                           regularly shaped/square. A lower value makes
%                           superpixels adhere to boundaries better, making
%                           them irregularly shaped. The allowed range of
%                           Compactness is (0 Inf). Typical values for
%                           Compactness are in the range [0.01, 0.1]. If
%                           this parameter is not specified, the default
%                           value is chosen as 0.001 if METHOD is 'slic0'
%                           and 0.05 if METHOD is 'slic'.
%
%   'Method'              - String specifying the algorithm used to compute
%                           superpixels. Supported options are 'slic' and
%                           'slic0'. When 'Method' is 'slic0', the SLIC0
%                           algorithm is used to adaptively refine
%                           'Compactness' after the first iteration. When
%                           'Method' is 'slic', 'compactness' is constant
%                           during clustering.
%
%                           Default: 'slic0'
%                                                      
%   'NumIterations'       - Numeric scalar specifying the number of
%                           iterations used in the clustering phase of the
%                           algorithm. For most problems it is not
%                           necessary to adjust this parameter.
%
%                           Default: 10
%
%
%   Class Support
%   -------------
%   The input image A must be a real, non-sparse matrix of the following
%   classes: int8, uint8, int16, uint16, int32, uint32, single, or double.
%
%   Notes
%   -----
%   1. When using the 'slic0' method, it is generally not necessary to adjust
%      'Compactness' parameter. The intention of 'slic0' is to adaptively
%      refine 'Compactness' automatically and eliminate the need for users
%      to determine a good value of 'Compactness' for themselves.
%
%   Example
%   -------
%   Compute 3-D superpixels of input volumetric intensity image. Form an
%   output image where each pixel is set to the mean color of its
%   corresponding superpixel region.
%   
%     load mri;
%     D = squeeze(D);
%     A = ind2gray(D,map);
%     [L,N] = superpixels3(A, 34);
% 
%     % Show all xy-planes progressively with superpixel boundaries.
%     imSize = size(A);
%     % Create a stack of RGB images to display the boundaries in color.
%     imPlusBoundaries = zeros(imSize(1),imSize(2),3,imSize(3),'uint8');
%     for plane = 1:imSize(3)
%         BW = boundarymask(L(:, :, plane));
%         % Create an RGB representation of this plane with boundary shown
%         % in cyan.
%         imPlusBoundaries(:, :, :, plane) = imoverlay(A(:, :, plane), BW, 'cyan');
%     end
%     implay(imPlusBoundaries,5)
% 
%     % Set color of each pixel in output image to the mean intensity of
%     % the superpixel region. 
%     % Show the mean image next to the original.
%     pixelIdxList = label2idx(L);
%     meanA = zeros(size(A),'like',D);
%     for superpixel = 1:N
%        memberPixelIdx = pixelIdxList{superpixel};
%        meanA(memberPixelIdx) = mean(A(memberPixelIdx));
%     end
%     implay([A meanA],5);
%   
%   See also superpixels, boundarymask, imoverlay, label2idx, implay.

%   Copyright 2016, The MathWorks, Inc.

%   References: 
%   ----------- 
%   [1] Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi,
%   Pascal Fua, and Sabine Susstrunk, SLIC Superpixels Compared to
%   State-of-the-art Superpixel Methods, IEEE Transactions on Pattern
%   Analysis and Machine Intelligence, vol. 34, num. 11, p. 2274 - 2282,
%   May 2012.
%
%   [2] Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi,
%   Pascal Fua, and Sabine Susstrunk, SLIC Superpixels, EPFL Technical
%   Report no. 149300, June 2010.

narginchk(2,inf);

options = parseInputs(varargin{:});

[L,N] = slicmex3(options.A,...
    options.N,...
    options.Compactness,...
    options.NumIterations,...
    options.RefineCompactness);
end

function options = parseInputs(varargin)
    validateInputImage(varargin{1});

    validateattributes(varargin{2},{'numeric'},...
        {'nonempty','scalar','positive','finite','integer','nonsparse'},...
        mfilename,'N',2);

    parser = inputParser();
    parser.addParameter('Compactness',[],@validateCompactness);
    parser.addParameter('Method','slic0',@validateMethod);
    parser.addParameter('NumIterations',10,@validateNumIters);

    parser.parse(varargin{3:end});
    options = parser.Results;
    options.A = varargin{1};
    options.N = varargin{2};

    if (options.N > numel(options.A))
       error(message('images:superpixels:tooManySuperpixelsRequested')); 
    end

    % If Compactness was not specified by user, set Compactness based on
    % the chosen 'Method' Name/Value.
    if isempty(options.Compactness)
        if strcmp(options.Method,'slic0')
            options.Compactness = 0.001;
        else
            options.Compactness = 0.05;
        end
    end
    options.A = postProcessInputImage(options.A);
    options.RefineCompactness = strcmpi(options.Method,'slic0');
    options.N = double(options.N);
    options.Compactness = double(options.Compactness);
    options.NumIterations = double(options.NumIterations);

end

function A = postProcessInputImage(A)
    if (isa(A, 'int8') || isa(A, 'uint8') || isa(A, 'int16') || isa(A, 'uint16'))
        A = single(A);
    elseif (isa(A, 'int32') || isa(A, 'uint32'))
        A = double(A);
    end
    % Normalize dynamic range to [0, 1]
    minA = min(A(:));
    maxA = max(A(:));
    if minA == maxA
        if maxA ~= 0
           % Uniform image becomes all 1.
           A = A./maxA;             
        end       
    else        
        A = A - minA;
        % Recompute new max after shifting
        maxA = maxA - minA;
        A = A ./ maxA;  
    end
end

function validateInputImage(A)

supportedClasses = {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'single','double'};
attributes = {'nonempty','nonsparse','real','nonnan','finite'};
                
validateattributes(A,supportedClasses,attributes,...
                    mfilename,'A',1);

valid3DIntensityImage = (ndims(A) == 3);
if ~(valid3DIntensityImage)
    error(message('images:validate:expected3D'))
end

if (size(A,1) < 2 || size(A,2) < 2 || size(A,3) < 2)
    error(message('images:validate:expected3D'))
end

end


function TF = validateCompactness(C)

validateattributes(C,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse'},...
    mfilename,'Compactness',3);

TF = true;

end

function TF = validateNumIters(numIters)

validateattributes(numIters,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse','integer'},...
    mfilename,'NumIterations');

TF = true;

end

function TF = validateMethod(method)

validatestring(method,{'slic','slic0'},mfilename,'Method');

TF = true;

end
