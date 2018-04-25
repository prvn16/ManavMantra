function rgb = lab2rgb(lab,varargin) %#codegen
%lab2rgb Convert CIE 1976 L*a*b* to RGB

%   Copyright 2015-2016 The MathWorks, Inc.

%   Syntax
%   ------
%
%       rgb = lab2rgb(lab)
%       rgb = lab2rgb(lab,Name,Value)
%
%   Input Specs
%   -----------
%
%     Lab:
%       Px3 matrix of L*a*b* triplets or MxNx3 L*a*b* image or MxNx3xF image stack
%       must be real
%       can be single or double
%
%     ColorSpace:
%       string
%       'srgb' (default), 'adobe-rgb-1998', or 'linear-rgb'
%       must be a compile-time constant
%
%     WhitePoint:
%       can be string, single or double
%       'd65' (default), 'a', 'c', 'e', 'd50', 'd55', 'icc', or 1x3 vector
%       if string, must be a compile-time constant
%
%     OutputType:
%       string with values: 'double', 'single', 'uint8', 'uint16'
%       default: the same type as the input (single or double)
%       must be a compile-time constant
%
%   OutputSpecs
%   -----------
%
%     RGB:
%       array the same shape as Lab
%       type specified by OutputType
%
%   Summary
%   -------
%
%   This public interface function does the following:
%     - Parse and validate the inputs
%     - Allocate space for the output
%     - Dispatch to the right conversion pipeline
%     - Each conversion pipeline implements the following steps:
%         1. Conversion to unencoded XYZ
%         2. Chromatic adaptation to D65 illuminant (if necessary)
%         3. Conversion to linear RGB
%         4. Conversion to sRGB or Adobe RGB 1998
%         5. Encoding

[isSRGB,isLinear,outputType,whitePoint,chromAdaptTform,isWhitePointD65] = ...
    parseInputs(lab,varargin{:});

% Compute the 3x3 transform from XYZ to linear RGB
M = images.color.internal.linearRGBToXYZTransform(isSRGB);
M = M \ eye(3);

coder.internal.prefer_const(isSRGB,outputType,whitePoint, ...
    chromAdaptTform,isWhitePointD65,M);

% Allocate space for output
% rgb has the same size as lab
rgb = coder.nullcopy( cast(zeros(size(lab)),outputType) );

if isStack(lab)
    % lab is MxNx3xF
    numFrames = size(lab,4);
    numRows   = size(lab,1);
    numCols   = size(lab,2);
    
    % For each triplet, apply the pipeline
    for frame = 1:numFrames
        for col = 1:numCols
            for row = 1:numRows
                % Read L*, a*, and b* from the input buffer
                L = lab(row,col,1,frame);
                a = lab(row,col,2,frame);
                b = lab(row,col,3,frame);
                
                % Do the conversion
                [R,G,B] = convertLabToRGB( ...
                    L,a,b,isSRGB,isLinear,outputType,whitePoint, ...
                    chromAdaptTform,isWhitePointD65,M);
                
                % Write R, G, B to output buffer
                rgb(row,col,1,frame) = R;
                rgb(row,col,2,frame) = G;
                rgb(row,col,3,frame) = B;
            end
        end
    end
else
    % lab is Px3
    numTriplets = size(lab,1);
    
    % For each triplet, apply the pipeline
    for k = 1:numTriplets
        % Read L*, a*, and b* from the input buffer
        L = lab(k,1);
        a = lab(k,2);
        b = lab(k,3);
        
        % Do the conversion
        [R,G,B] = convertLabToRGB( ...
            L,a,b,isSRGB,isLinear,outputType,whitePoint, ...
            chromAdaptTform,isWhitePointD65,M);
        
        % Write R, G, and B to output buffer
        rgb(k,1) = R;
        rgb(k,2) = G;
        rgb(k,3) = B;
    end
end

%--------------------------------------------------------------------------
% Parse and validate the inputs.
%
%   isSRGB:
%     boolean - true if ColorSpace is sRGB, false if it is Adobe RGB 1998
%
%   isLinear:
%     boolean - true if ColorSpace is Linear RGB (linearized sRGB)
%
%   outputType:
%     string - encoding type for the RGB values returned by lab2rgb
%
%   whitePoint:
%     1x3 vector of the same class as lab
%
%   chromAdaptTform:
%     3x3 matrix to do chromatic adaptation of the same type as lab
%
function [isSRGB,isLinear,outputType,whitePoint,chromAdaptTform,isWhitePointD65] = parseInputs(lab,varargin)

coder.internal.prefer_const(lab,varargin{:});

narginchk(1,7);

% Validate LAB
validateattributes(lab,{'single','double'},{'real'},mfilename,'LAB',1)

% Validate the shape of LAB:
% throw error if it is not Px3 or MxNx3xF
coder.internal.errorIf( ...
    ~(ismatrix(lab) && (size(lab,2) == 3)) && ...
    ~((numel(size(lab)) < 5) && (size(lab,3) == 3)), ...
    'images:color:invalidShape','LAB');

% Parse optional parameters, if any
[colorSpaceStr,whitePointStr,outputTypeStr] = parsePVPairs(lab,varargin{:});

% Validate ColorSpace string
validateattributes(colorSpaceStr,{'char'},{},mfilename,'ColorSpace'); % g1278866
colorSpace = validatestring(colorSpaceStr, ...
    {'srgb','adobe-rgb-1998','linear-rgb'}, ...
    mfilename);
isSRGB = coder.const(~strcmp(colorSpace(1),'a'));
isLinear = coder.const(strcmp(colorSpace(1),'l'));

% Validate WhitePoint string and return a 1x3 vector
whitePoint = cast( ...
    images.color.internal.checkWhitePoint(whitePointStr), ...
    'like',lab);

% Validate OutputType string
outputType = validatestring(outputTypeStr, ...
    {'single','double','uint8','uint16'},mfilename);

% chromAdaptMat: used to adapt chromaticity to the desired reference white
if strcmp(whitePointStr,'d65')
    % Nothing to adapt if the reference is D65
    chromAdaptTform = cast(eye(3),'like',lab);
    isWhitePointD65 = coder.const(true);
else
    chromAdaptTform = ...
        images.color.internal.coder.XYZChromaticAdaptationTransform( ...
        whitePoint,cast(whitepoint('d65'),'like',lab));
    isWhitePointD65 = coder.const(false);
end

%--------------------------------------------------------------------------
% Parse optional PV pairs - 'ColorSpace', 'WhitePoint' and 'OutputType'
function [colorSpace,whitePoint,outputType] = parsePVPairs(lab,varargin)

coder.internal.prefer_const(lab,varargin{:});

% Default values
defaultColorSpace = 'srgb';
defaultWhitePoint = 'd65';
defaultOutputType = class(lab);

params = struct( ...
    'ColorSpace',uint32(0), ...
    'WhitePoint',uint32(0), ...
    'OutputType',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

colorSpace = eml_get_parameter_value( ...
    optarg.ColorSpace, ...
    defaultColorSpace, ...
    varargin{:});

whitePoint = eml_get_parameter_value( ...
    optarg.WhitePoint, ...
    defaultWhitePoint, ...
    varargin{:});

outputType = eml_get_parameter_value( ...
    optarg.OutputType, ...
    defaultOutputType, ...
    varargin{:});

%--------------------------------------------------------------------------
function TF = isStack(lab)

if ismatrix(lab) && (size(lab,2) == 3)
    % Px3 vector of L*a*b* triplets
    TF = false;
else
    % MxNx3xF stack of L*a*b* images
    TF = true;
end

%--------------------------------------------------------------------------
% Conversion pipeline from unencoded L*a*b* arrays to encoded RGB
function [encodedR,encodedG,encodedB] = convertLabToRGB(L,a,b,isSRGB, ...
    isLinear,outputType,whitePoint,chromAdaptTform,isWhitePointD65,M)

coder.internal.prefer_const(isSRGB,isLinear,outputType,whitePoint, ...
    chromAdaptTform,isWhitePointD65,M);

% 1. Convert to XYZ
[X,Y,Z] = images.color.internal.coder.LABToXYZ(L,a,b,whitePoint);

% 2. Adapt the chromaticity of XYZ if necessary
% This if/else branch should be constant-folded at compile time
if ~isWhitePointD65
    [X,Y,Z] = images.color.internal.coder.adaptXYZ(X,Y,Z,chromAdaptTform);
end

% 3a. or 3b. Convert to linear RGB
[linearR,linearG,linearB] = matrixMultiply(M,X,Y,Z);

% This if/else branch should be constant-folded at compile time
if isSRGB && ~isLinear
    % 4a. Delinearize to sRGB
    [R,G,B] = images.color.internal.coder.delinearizeSRGB( ...
        linearR,linearG,linearB);
elseif isLinear
    % 4c. Return linear RGB values
    R = linearR;
    G = linearG;
    B = linearB;
else
    % 4b. Delinearize to Adobe RGB 1998
    [R,G,B] = images.color.internal.coder.delinearizeAdobeRGB( ...
        linearR,linearG,linearB);
end

% 5. Encode to outputType
[encodedR,encodedG,encodedB] = images.color.internal.coder.encodeRGB( ...
    R,G,B,outputType);

%--------------------------------------------------------------------------
function [R,G,B] = matrixMultiply(M,X,Y,Z)

R = M(1,1)*X + M(1,2)*Y + M(1,3)*Z;
G = M(2,1)*X + M(2,2)*Y + M(2,3)*Z;
B = M(3,1)*X + M(3,2)*Y + M(3,3)*Z;
