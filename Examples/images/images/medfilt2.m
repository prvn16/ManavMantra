function b = medfilt2(varargin)
%MEDFILT2 2-D median filtering.
%   B = MEDFILT2(A,[M N]) performs median filtering of the matrix
%   A in two dimensions. Each output pixel contains the median
%   value in the M-by-N neighborhood around the corresponding
%   pixel in the input image. MEDFILT2 pads the image with zeros
%   on the edges, so the median values for the points within 
%   [M N]/2 of the edges may appear distorted.
%
%   B = MEDFILT2(A) performs median filtering of the matrix A
%   using the default 3-by-3 neighborhood.
%
%   B = MEDFILT2(...,PADOPT) controls how the matrix boundaries
%   are padded.  PADOPT may be 'zeros' (the default),
%   'symmetric', or 'indexed'. If PADOPT is 'zeros', A is padded
%   with zeros at the boundaries. If PADOPT is 'symmetric', A is
%   symmetrically extended at the boundaries. If PADOPT is
%   'indexed', A is padded with ones if it is double; otherwise
%   it is padded with zeros.
%
%   Class Support
%   -------------
%   The input image A can be logical or numeric.  The output image B is of 
%   the same class as A.
%
%   Remarks
%   -------
%   If the input image A is of integer class, all of the output
%   values are returned as integers. If the number of
%   pixels in the neighborhood (i.e., M*N) is even, some of the
%   median values may not be integers. In these cases, the
%   fractional parts are discarded. Logical input is treated
%   similarly.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       J = imnoise(I,'salt & pepper',0.02);
%       K = medfilt2(J);
%       figure, imshow(J), figure, imshow(K)
%
%   See also FILTER2, ORDFILT2, WIENER2.

%   Copyright 1993-2017 The MathWorks, Inc.

narginchk(1,3);

args = matlab.images.internal.stringToChar(varargin);
[a, mn, padopt] = parse_inputs(args{:});

if isempty(a)
    b = a;
    return
end

% switch to IPP iff
% UseIPPL preference is true .AND.
% kernel is  odd .AND.
%      input data type is single .AND. kernel size is == 3x3
% .OR. input data type is (int16 .OR. uint8 .OR. uint16) .AND. kernel size
%      is between 3x3 and 19x19 

domain = ones(mn);
if (rem(prod(mn), 2) == 1)
    tf = hUseIPPL(a, mn, padopt);
    if tf
        b = medianfiltermex(a, [mn(1) mn(2)]);
    else
        order = (prod(mn)+1)/2;
        b = ordfilt2(a, order, domain, padopt);
    end
else
    order1 = prod(mn)/2;
    order2 = order1+1;
    b = ordfilt2(a, order1, domain, padopt);
    b2 = ordfilt2(a, order2, domain, padopt);
	if islogical(b)
		b = b | b2;
	else
		b =	imlincomb(0.5, b, 0.5, b2);
	end
end


%%%
%%% Function parse_inputs
%%%
function [a, mn, padopt] = parse_inputs(varargin)

% Any syntax in which 'indexed' is followed by other arguments is discouraged.
%
% We have to catch and parse this successfully, so we're going to use a strategy
% that's a little different that usual.
%
% First, scan the input argument list for strings.  The
% string 'indexed', 'zeros', or 'symmetric' can appear basically
% anywhere after the first argument.
%
% Second, delete the strings from the argument list.
%
% The remaining argument list can be one of the following:
% MEDFILT2(A)
% MEDFILT2(A,[M N])

a = varargin{1};
% validate that the input is a 2D, real, numeric or logical matrix.
validateattributes(a, ...
    {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'},...
    {'2d','real','nonsparse'}, mfilename, 'A', 1);

charLocation = [];
for k = 2:nargin
    if (ischar(varargin{k}))
        charLocation = [charLocation k]; %#ok<AGROW>
    end
end

if (length(charLocation) > 1)
    % More than one string in input list
    error(message('images:medfilt2:tooManyStringInputs'));
elseif isempty(charLocation)
    % No string specified
    padopt = 'zeros';
else
    options = {'indexed', 'zeros', 'symmetric'};

    padopt = validatestring(varargin{charLocation}, options, mfilename, ...
                          'PADOPT', charLocation);
    
    varargin(charLocation) = [];
end

if (strcmp(padopt, 'indexed'))
    if (isa(a,'double'))
        padopt = 'ones';
    else
        padopt = 'zeros';
    end
end

if length(varargin) == 1,
  mn = [3 3];% default
elseif length(varargin) >= 2  
    mn = varargin{2}(:)';
    validateattributes(mn,{'numeric'},{'real','positive','integer','nonempty','size',[1 2]},...
        mfilename,'[M N]',2);
    
    if length(varargin) > 2
        % Error if more than one [M N] is specified
        error(message('images:medfilt2:invalidSyntax'));
    end
end

% ------------------------------------------------------------------------
function tf = hUseIPPL(a, mn, padopt)
% switch to IPP iff
% UseIPPL preference is true .AND.
% kernel is  odd .AND.
%      input data type is single .AND. kernel size is == 3x3
% .OR. input data type is uint8 .AND. kernel size is 
%           1xn, n<=5
%   .OR.    nx1, n<=7
%   .OR.    between 3x3 and 19x19
% .OR. input data type is (int16 .OR. uint16) .AND. kernel size
%      is between 3x3 and 19x19 
tf = false;

% Symmetric pading is not supported by IPP
if(isequal(padopt, 'symmetric'))
    return;
end

% Double is not supported for median filtering in IPP
switch class(a)
    case 'single'
        if all(mn==[3 3])
            tf = true;
        end
    case 'uint8'
        if (mn(1)==1 && mn(2)<=5) || (all(mn >= [3 3]) && all(mn <= [19 19])) || (mn(2)==1 && mn(1)<=7)
            tf = true;
        end
    case {'uint16', 'int16'}
        if all(mn >= [3 3]) && all(mn <= [19 19])
            tf = true;
        end
end

tf = tf & iptgetpref('UseIPPL');
