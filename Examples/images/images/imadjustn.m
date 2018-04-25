function out = imadjustn(varargin)
%IMADJUSTN Adjust nD volume intensity values, where n can be 1,2,3 ... n.
%   J = IMADJUSTN(V) maps the values in nD intensity volumetric image V to new values in J
%   such that 1% of data is saturated at low and high intensities of V.
%   This increases the contrast of the output volumetric image J.
% 
%   J = IMADJUSTN(V,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT]) maps the values
%   in intensity volumetric image V to new values in J such that values between LOW_IN
%   and HIGH_IN map to values between LOW_OUT and HIGH_OUT. Values below
%   LOW_IN and above HIGH_IN are clipped; that is, values below LOW_IN map
%   to LOW_OUT, and those above HIGH_IN map to HIGH_OUT. You can use an
%   empty matrix ([]) for [LOW_IN; HIGH_IN] or for [LOW_OUT; HIGH_OUT] to
%   specify the default of [0 1]. If you omit the argument, [LOW_OUT;
%   HIGH_OUT] defaults to [0 1].
%
%   J = IMADJUSTN(V,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA) maps the
%   values of V to new values in J as described in the previous syntax.
%   GAMMA specifies the shape of the curve describing the relationship
%   between the values in V and J. If GAMMA is less than 1, the mapping is
%   weighted toward higher (brighter) output values. If GAMMA is greater
%   than 1, the mapping is weighted toward lower (darker) output values. If
%   you omit the argument, GAMMA defaults to 1 (linear mapping).
%
%   Note that IMADJUSTN(V) is equivalent to IMADJUSTN(V,STRETCHLIM(V(:))).
%
%   Note that if HIGH_OUT < LOW_OUT, the output image volume is reversed, as in a
%   photographic negative.
%
%   Class Support
%   -------------
%   The nD input volumetric image V can be uint8, uint16, int16, double or single.
%   The output image has the same class as the input image. 
%
%   Examples
%   --------
%   Intensity scaling of a 3D volume of MRI data 
%   
%   load mristack;
%   V = mristack;
%   figure
%   slice(double(V),size(V,2)/2,size(V,1)/2,size(V,3)/2)
%   colormap gray; shading interp
%   J = imadjustn(V,[0.2 0.8]);
%   figure
%   slice(double(J),size(J,2)/2,size(J,1)/2,size(J,3)/2)
%   colormap gray; shading interp
%
%   See also DECORRSTRETCH, HISTEQ, IMHISTMATCHN, STRETCHLIM.

%   Copyright 2016-2017 The MathWorks, Inc.


%   Input-output specs
%   ------------------
%   V,J          real, full matrix, 1D,2D,3D ...nD
%                uint8, uint16, double, single, int16
%
%   [LOW_IN; HIGH_IN]    double, real, full matrix
%                        For V, size can only be 2 elements.
%
%   [LOW_OUT; HIGH_OUT]  Same size restrictions as [LOW_IN; HIGH_IN]
%                        LOW_OUT can be less than HIGH_OUT
%
%   LOW_IN, HIGH_IN, LOW_OUT, HIGH_OUT all must be in the range [0,1];
%
%   GAMMA         real, double, nonnegative
%                 scalar for V


%Parse inputs and initialize variables
[img,lowIn,highIn,lowOut,highOut,gamma] = ...
    parseInputs(varargin{:});

%validateLowHigh(lowIn,highIn,lowOut,highOut);

if ~isfloat(img) && numel(img) > 65536
    % integer data type image with more than 65536 elements
    out = adjustWithLUT(img,lowIn,highIn,lowOut,highOut,gamma);

else
    classin = class(img);
    classChanged = false;
    if ~isa(img,'double')
        classChanged = true;
        img = im2double(img);
    end
    
    out = adjustGrayscaleImage(img,lowIn,highIn,lowOut,highOut,gamma);
    
    
    if classChanged
        out = images.internal.changeClass(classin,out);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = adjustWithLUT(img,lowIn,highIn,lowOut,highOut,gamma)

imgClass = class(img);


switch imgClass
    case 'uint8'
        lutLength = 256;
        conversionFcn = @im2uint8;
    case 'uint16'
        lutLength = 65536;
        conversionFcn = @im2uint16;
    case 'int16'
        lutLength = 65536;
        conversionFcn = @im2int16;
    otherwise
        error(message('images:imadjust:internalError'))
end

lut = linspace(0,1,lutLength);
scalingFactor = 1;
lut = adjustArray(lut,lowIn,highIn,lowOut,highOut, ...
        gamma,scalingFactor);
lut = conversionFcn(lut);
out = intlut(img,lut);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = adjustGrayscaleImage(img,lIn,hIn,lOut,hOut,g)

expansionFactor = 1;
out = adjustArray(img, lIn, hIn, lOut, hOut, g, expansionFactor);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = adjustArray(img,lIn,hIn,lOut,hOut,g,d)

%make sure img is in the range [lIn;hIn]
img(:) =  max(lIn(d,:), min(hIn(d,:),img));

out = ( (img - lIn(d,:)) ./ (hIn(d,:) - lIn(d,:)) ) .^ (g(d,:));
out(:) = out .* (hOut(d,:) - lOut(d,:)) + lOut(d,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img,low_in,high_in,low_out,high_out,gamma] = ...
    parseInputs(varargin)

narginchk(1,4);

p = inputParser;
p.addRequired('V',@validateVolume);

p.addOptional('lowhigh_in',[0; 1],@validateLowHighIn);
p.addOptional('lowhigh_out',[0; 1],@validateLowHighOut);
p.addOptional('gamma',1,@validateGamma);

p.parse(varargin{:});
res = p.Results;
img = res.V;

% If user passes empty [] argument for LOW_IN, HIGH_IN, LOW_OUT, HIGH_OUT
if isempty(res.lowhigh_in)
    res.lowhigh_in = [0 1];
end

if isempty(res.lowhigh_out)
    res.lowhigh_out = [0 1];
end

if nargin == 1
    % Turn off warning 'images:imhistc:inputHasNans' before calling STRETCHLIM and
    % restore afterwards. STRETCHLIM calls IMHIST/IMHISTC and the warning confuses
    % a user who calls IMADJUST with NaNs.
    s = warning('off','images:imhistc:inputHasNaNs');
    lowhigh_in = stretchlim(img(:));
    warning(s)
else
    lowhigh_in = res.lowhigh_in;
end
    
lowhigh_out = res.lowhigh_out;
gamma = res.gamma;

[low_in, high_in]   = splitRange(lowhigh_in);
[low_out, high_out] = splitRange(lowhigh_out);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rangeMin, rangeMax] = splitRange(range)

rangeMin = range(1);
rangeMax = range(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateVolume(V)
validateattributes(V, {'double' 'uint8' 'uint16' 'int16' 'single'}, ...
    {'real','nonsparse','nonempty'}, mfilename, 'V', 1);
flag = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateLowHighIn(lowhigh_in)

if isempty(lowhigh_in)
    flag = true;
    return;
end

validateattributes(lowhigh_in,{'double'},{'real','numel',2,'increasing','>=',0,'<=',1}, ...
    mfilename,'[LOW_IN; HIGH_IN]', 2);
flag = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateLowHighOut(lowhigh_out)

if isempty(lowhigh_out)
    flag = true;
    return;
end
    
validateattributes(lowhigh_out,{'double'},{'real','numel',2,'>=',0,'<=',1}, ...
    mfilename,'[LOW_OUT; HIGH_OUT]', 3);
flag = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateGamma(gamma)

validateattributes(gamma,{'double'},{'scalar','real','nonnegative','finite'}, ...
    mfilename, 'GAMMA', 4);
flag = true;

