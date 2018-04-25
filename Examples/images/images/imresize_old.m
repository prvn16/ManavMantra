function varargout = imresize_old(varargin)
%IMRESIZE_OLD Resize image (old version).
%   This function provides the IMRESIZE function as computed by versions
%   5.3 (R2006b) and earlier of the Image Processing Toolbox.
%
%   IMRESIZE_OLD resizes an image of any type using the specified
%   interpolation method. Supported interpolation methods include:
%
%        'nearest'  (default) nearest neighbor interpolation
%
%        'bilinear' bilinear interpolation
%
%        'bicubic'  bicubic interpolation
%
%   B = IMRESIZE_OLD(A,M,METHOD) returns an image that is M times the size
%   of A. If M is between 0 and 1.0, B is smaller than A. If M is greater
%   than 1.0, B is larger than A. If METHOD is omitted, IMRESIZE uses
%   nearest neighbor interpolation.
%
%   B = IMRESIZE_OLD(A,[MROWS MCOLS],METHOD) returns an image of size
%   MROWS-by-MCOLS. If the specified size does not produce the same aspect
%   ratio as the input image has, the output image is distorted.
%
%   When the specified output size is smaller than the size of the input
%   image, and METHOD is 'bilinear' or 'bicubic', IMRESIZE applies a
%   lowpass filter before interpolation to reduce aliasing. The default
%   filter size is 11-by-11.
%
%   You can specify a different length for the default filter using:
%
%        [...] = IMRESIZE_OLD(...,METHOD,N)
%
%   N is an integer scalar specifying the size of the filter, which is
%   N-by-N. If N is 0, IMRESIZE omits the filtering step.
%
%   You can also specify your own filter H using:
%
%        [...] = IMRESIZE_OLD(...,METHOD,H)
%
%   H is any two-dimensional FIR filter (such as those returned by FTRANS2,
%   FWIND1, FWIND2, or FSAMP2).
%
%   Class Support
%   -------------
%   The input image A can be numeric or logical and it must be
%   nonsparse. The output image is of the same class as the
%   input image.
%
%   Example
%   -------
%        I = imread('rice.png');
%        J = imresize(I,.5);
%        figure, imshow(I), figure, imshow(J)
%
%   See also IMRESIZE, IMROTATE, IMTRANSFORM, TFORMARRAY.

%   Copyright 1992-2017 The MathWorks, Inc.


[A,m,method,h] = parse_inputs(varargin{:});

% Preserve classes
inputClass = class(A);
classChanged = 0;
logicalIn = islogical(A);


% Define old and new image sizes, and actual scaling
% sc is a two-element vector: [vert_scale_factor, horiz_scale_factor].
[so(1),so(2),thirdD] = size(A); % old image size
if isscalar(m)
    % m is the scale factor.
    sn = max(floor(m*so(1:2)),1); % new image size=(integer>0)
    sc = [m m];
else
    % m is new image size
    sn = m;
    sc = sn ./ so;
end

if switch_to_nearest_method(sn, so, method)
    warning(message('MATLAB:images:imresize:inputTooSmall'));
    method = 'nearest';
end

% Filtering is under the following conditions
bi_interp = (method(1)=='b'); % non-default interpolation only
defflt_reducedim=(length(h)<2)&any(sn<so);%default filter & reduced image
if length(h)==1,
    nonzero_odr = (h~=0);     % non-zero filter order
else
    nonzero_odr = 1;
end;
custm_flt = (length(h)>1);%custom supplied filter H

if bi_interp && nonzero_odr && any([defflt_reducedim,custm_flt]),
    if (~isa(A,'double')),%change format to double to perform imfilter
        A = im2double(A);
        classChanged = 1;
    end

    if defflt_reducedim,%Design anti-aliasing filter for reduced image
        drec = find(sn<so);% find direction of filtering
        for k = drec,% create filter for drec-direction
            if isempty(h),% make filter order corresponding to scale
                h = 11;
            end;
            hh(k,:) = DesignFilter(h,sn(k)/so(k)); %#ok<AGROW>
        end;
        if length(drec)==1,%filters in one direction only
            % first direction is column, second is row
            h = reshape(hh(k,:),(h-1)*(k==1)+1,(h-1)*(k==2)+1);
        else % filters in both directions
            for k=1:thirdD,%loop if A matrix is 3D
                A(:,:,k) = imfilter(imfilter(A(:,:,k), hh(2,:),'replicate'),...
                    hh(1,:).','replicate');
            end
        end;
    end;
    if custm_flt || (defflt_reducedim && (length(drec)==1)), % filters in one direction
        for k=1:thirdD,%loop if A matrix is 3D
            A(:,:,k) = imfilter(A(:,:,k),h,'replicate');
        end
    end;
end;

% Construct an affine tform that:
%   *  maps (u,v) = (0.5,0.5) in input space to (x,y) = (0.5,0.5) in
%      output space.
%
%   *  maps (u,v) = (1.5,1.5) in input space to (x,y) =
%      (0.5+sc(2),0.5+sc(1)) in output space.

a = [sc(2),         0,                0
     0,             sc(1),            0
     0.5*(1-sc(2)), 0.5*(1-sc(1)),    1];
T = maketform('affine', a);

% Interpolation
if method(1)=='n', 
    % nearest neighbor (default)
    subscripts = repmat({':'}, [1 ndims(A)]);
    X = [(1:sn(2)).', ones(sn(2), 1)];
    U = tforminv(T, X);
    c = min(round(U(:,1)), so(2));
    
    X = [ones(sn(1), 1), (1:sn(1)).'];
    U = tforminv(T, X);
    r = min(round(U(:,2)), so(1));
    
    subscripts{1} = r;
    subscripts{2} = c;
    A = A(subscripts{:});
    
else
    % bilinear or bicubic
    if strcmp(method,'bicubic')
        R = makeresampler('cubic','replicate');
    else
        R = makeresampler('linear','replicate');
    end

    % In the construction of the affine transform matrix above, the first coordinate
    % lies along the horizontal dimensions, and the second coordinate lies along
    % the vertical dimension.  However, the default coordinate convention for
    % tformarray follows MATLAB's array indexing ordering. That is, the first
    % spatial transform dimension corresponds to the rows, the second spatial
    % transform dimension corresponds to the columns, etc. That's the reason for
    % specifying [2 1], [2 1], and [sn(2) sn(1)] in the call to tformarray
    % below.
    A = tformarray(A, T, R, [2 1], [2 1], [sn(2) sn(1)], [], []);
end

% Change format from double back to the original
if logicalIn,  % output should be logical (i.e. binary image)
    if ~islogical(A) % A became double because of imfilter, turn it back to logical
        A = A>.5;
    end
elseif classChanged,
    A = images.internal.changeClass(inputClass, A);
end

% Output
if (nargout == 0)
    imshow(A);
else
    varargout{1} = A;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [A,m,method,h] = parse_inputs(varargin)
% Outputs:  A       the input image
%           m       the resize scaling factor or the new size
%           method  interpolation method (nearest,bilinear,bicubic)
%           h       if 0, skip filtering; if non-zero scalar, use filter
%                   of size h; if empty, use filter of size 11;
%                   otherwise h is the anti-aliasing filter provided by user
% Defaults:
method = 'nearest';
h = [];

narginchk(2,6)
switch nargin
    case 2,                   % imresize(A,m)
        A = varargin{1};
        m = varargin{2};
    case 3,                   % imresize(A,m,method)
        A = varargin{1};
        m = varargin{2};
        method = varargin{3};
    case 4,                   % imresize(A,m,method,h)
        A = varargin{1};
        m = varargin{2};
        method = varargin{3};
        h = varargin{4};
    otherwise,
        error(message('MATLAB:images:imresize:invalidInputs'));
end

validateattributes(A,{'numeric', 'logical'},{'nonsparse'},mfilename,'A',1);

% Check validity of the input parameters
if isempty(m) || (ndims(m)>2) || any(m<=0) || length(m(:))>2,
    error(message('MATLAB:images:imresize:invalidScaleFactor'));
elseif length(m)==2,% make sure that m is a row of non-negative integers
    m = ceil(m(:).');
end;

if ischar(method),
    strings = {'nearest','bilinear','bicubic'};
    idx = find(strncmpi(method, strings, numel(method)));
    if isempty(idx),
        error(message('MATLAB:images:imresize:unrecognizedInterpolationMethod', method));
    elseif length(idx)>1,
        error(message('MATLAB:images:imresize:ambiguousInterpolationMethod', method));
    else
        method = strings{idx};
    end
else
    error(message('MATLAB:images:imresize:expectedString'));
end;

if length(h)==1,% represents filter order
    if (h<0) || (h~=round(h)),
        error(message('MATLAB:images:imresize:invalidFilterOrder', sprintf( '%g', h )));
    end;
elseif (length(h)>1) && (ndims(h)>2),% custom supplied filter
    error(message('MATLAB:images:imresize:expected2DFilter'));
end

function b = DesignFilter(N,Wn)
% Modified from SPT v3 fir1.m and hanning.m
% first creates only first half of the filter
% and later mirrows it to the other half

odd = rem(N,2);
vec = 1:floor(N/2);
vec2 = pi*(vec-(1-odd)/2);

wind = .54-.46*cos(2*pi*(vec-1)/(N-1));
b = [fliplr(sin(Wn*vec2)./vec2).*wind Wn];% first half is ready
b = b([vec floor(N/2)+(1:odd) fliplr(vec)]);% entire filter
b = b/abs(polyval(b,1));% norm

function tf = switch_to_nearest_method(new_size, old_size, method)
%
% Returns true if method is not 'nearest' but 'nearest' must be used
% because of the input and output image sizes.

tf = any(new_size < 4) && any(new_size < old_size) && ...
     (method(1) ~= 'n');
