function [out,T] = histeq(a,cm,hgram)
%HISTEQ Enhance contrast using histogram equalization.
%   HISTEQ enhances the contrast of images by transforming the values in an
%   intensity image, or the values in the colormap of an indexed image, so
%   that the histogram of the output image approximately matches a specified
%   histogram.
%
%   J = HISTEQ(I,HGRAM) transforms the intensity image I so that the histogram
%   of the output image J with length(HGRAM) bins approximately matches HGRAM.
%   The vector HGRAM should contain integer counts for equally spaced bins
%   with intensity values in the appropriate range: [0,1] for images of class
%   double or single, [0,255] for images of class uint8, [0,65535] for images
%   of class uint16, and [-32768, 32767] for images of class int16. HISTEQ
%   automatically scales HGRAM so that sum(HGRAM) = NUMEL(I). The histogram of
%   J will better match HGRAM when length(HGRAM) is much smaller than the
%   number of discrete levels in I.
%
%   J = HISTEQ(I,N) transforms the intensity image I, returning in J an
%   intensity image with N discrete levels. A roughly equal number of pixels
%   is mapped to each of the N levels in J, so that the histogram of J is
%   approximately flat. (The histogram of J is flatter when N is much smaller
%   than the number of discrete levels in I.) The default value for N is 64.
%
%   [J,T] = HISTEQ(I) returns the gray scale transformation that maps gray
%   levels in the intensity image I to gray levels in J.
%
%   NEWMAP = HISTEQ(X,MAP,HGRAM) transforms the colormap associated with the
%   indexed image X so that the histogram of the gray component of the indexed
%   image (X,NEWMAP) approximately matches HGRAM. HISTEQ returns the
%   transformed colormap in NEWMAP. length(HGRAM) must be the same as
%   size(MAP,1).
%
%   NEWMAP = HISTEQ(X,MAP) transforms the values in the colormap so that the
%   histogram of the gray component of the indexed image X is approximately
%   flat. It returns the transformed colormap in NEWMAP.
%
%   [NEWMAP,T] = HISTEQ(X,...) returns the gray scale transformation T that
%   maps the gray component of MAP to the gray component of NEWMAP.
%
%   Class Support
%   -------------
%   For syntaxes that include an intensity image I as input, I can be uint8,
%   uint16, int16, double or single. The output image J has the same class as
%   I.
%
%   For syntaxes that include an indexed image X as input, X can be uint8,
%   double, or single. The output colormap is always double.  Also, the
%   optional output T (the gray level transform) is always of class double.
%   
%   Note
%   ----
%   I and X can be N-dimensional images.
%
%   Example 1
%   ---------
%   Enhance the contrast of an intensity image using histogram
%   equalization.
%
%       I = imread('tire.tif');
%       J = histeq(I);
%
%       % Display the original and enhanced images
%       figure
%       subplot(1,2,1)
%       imshow(I)
%       subplot(1,2,2)
%       imshow(J)
%
%   Example 2
%   ---------
%   Enhance the contrast of a volumetric image using histogram
%   equalization.
%
%       load mristack
%       enhanced = histeq(mristack);
%
%       % Display the first slice of data
%       figure
%       subplot(1,2,1)
%       imshow(mristack(:,:,1))
%       subplot(1,2,2)
%       imshow(enhanced(:,:,1))
%
%   See also ADAPTHISTEQ, BRIGHTEN, IMADJUST, IMHIST, IMHISTMATCH.

%   Copyright 1993-2016 The MathWorks, Inc.

% NPTS  - Number of Points
% n     - Num buckets in: size(cm,1) or NPTS
% hgram - Histogram to match, flat by default (Argument 'HGRAM')
% m     - Num of output buckets (Argument 'N')
% a     - Input image (intensity or colormap) (Argument 'I' or 'X')
% cm    - Colormap
% out   - Output image (Argument 'J')
% map   - New colormap returned (Argument 'NEWMAP')
% nn    - Bincounts from imhist of input
% cum   - Cumulative bincounts of input
% cumd  - Cumulative bincounts of desired histogram

% Parameter setup
NPTS = 256;
isIntensityImage = false;

if nargin == 1
    %HISTEQ(I)
    validateattributes(a,{'uint8','uint16','double','int16','single'}, ...
        {'nonsparse'}, mfilename,'I',1);
    n = 64; % Default n
    hgram = ones(1,n)*(numel(a)/n);
    n = NPTS;
    isIntensityImage = true;
elseif nargin == 2
    if numel(cm) == 1
        %HISTEQ(I,N)
        validateattributes(a,{'uint8','uint16','double','int16','single'}, ...
            {'nonsparse'}, mfilename,'I',1);
        validateattributes(cm, {'single','double'},...
            {'nonsparse','integer','real','positive','scalar'},...
            mfilename,'N',2);
        m = cm;
        hgram = ones(1,m)*(numel(a)/m);
        n = NPTS;
        isIntensityImage = true;
    elseif size(cm,2) == 3 && size(cm,1) > 1
        %HISTEQ(X,map)        
        if isa(a, 'uint16')
            error(message('images:histeq:unsupportedUint16IndexedImages'))
        end
        validateattributes(a,{'uint8','double','single'}, ...
            {'nonsparse'},mfilename,'X',1);        
        n = size(cm,1);
        hgram = ones(1,n)*(numel(a)/n);
    else
        %HISTEQ(I,HGRAM)
        validateattributes(a,{'uint8','uint16','double','int16','single'}, ...
            {'nonsparse'}, mfilename,'I',1);
        validateattributes(cm, {'single','double'},...
            {'real','nonsparse','vector','nonempty'},...
            mfilename,'HGRAM',2);
        hgram = cm;
        n = NPTS;
        isIntensityImage = true;
    end
else
    %HISTEQ(X,MAP,HGRAM)
    validateattributes(a,{'uint8','double','uint16','single'}, ...
        {'nonsparse'},mfilename,'X',1);
    if isa(a, 'uint16')
        error(message('images:histeq:unsupportedUint16IndexedImages'))
    end
    validateattributes(hgram, {'single','double'},...
            {'real','nonsparse','vector','nonempty'},...
            mfilename,'HGRAM',3);
    
    n = size(cm,1);
    if length(hgram)~=n
        error(message('images:histeq:HGRAMmustBeSameSizeAsMAP'))
    end
end

if min(size(hgram)) > 1
   error(message('images:histeq:hgramMustBeAVector'))
end

% Normalize hgram
hgram = hgram*(numel(a)/sum(hgram));       % Set sum = numel(a)
m = length(hgram);

% Intensity image or indexed image
if isIntensityImage
    classChanged = false;
    if isa(a,'int16')
        classChanged = true;
        a = im2uint16(a);
    end
    
    [nn,cum] = computeCumulativeHistogram(a,n);
    T = createTransformationToIntensityImage(a,hgram,m,n,nn,cum);
    % Mex call is equivalent to:
    % b = uint8((255.0*T(a+1));
    % or uint16, 65535.0 etc
    b = grayxformmex(a, T);
    
    if nargout == 0
        if ismatrix(b)
            imshow(b);
            return;
        else
            out = a;
            return;
        end
    elseif classChanged
        out = im2int16(b);
    else
        out = b;
    end
        
else
    I = ind2gray(a,cm);
    [nn,cum] = computeCumulativeHistogram(I,n);
    T = createTransformationToIntensityImage(a,hgram,m,n,nn,cum);
    
    % Modify colormap by extending the (r,g,b) vectors.
    % Compute equivalent colormap luminance
    ntsc = rgb2ntsc(cm);
    
    % Map to new luminance using T, store in 2nd column of ntsc.
    ntsc(:,2) = T(floor(ntsc(:,1)*(n-1))+1)';
    
    % Scale (r,g,b) vectors by relative luminance change
    map = cm.*((ntsc(:,2)./max(ntsc(:,1),eps))*ones(1,3));
    
    % Clip the (r,g,b) vectors to the unit color cube
    map = map ./ (max(max(map,[],2),1) *ones(1,3));
    
    if nargout == 0
        if ismatrix(a)
            imshow(a,map);
            return;
        else
            out = a;
            return;
        end
    else
        out = map;
    end
end


function [nn,cum] = computeCumulativeHistogram(img,nbins)

nn = imhist(img,nbins)';
cum = cumsum(nn);


function T = createTransformationToIntensityImage(a,hgram,m,n,nn,cum)
% Create transformation to an intensity image by minimizing the error
% between desired and actual cumulative histogram.

% Generate cumulative hgram
cumd = cumsum(hgram);

% Calc error
% tol = nn w/ 1st and last element set to 0, then divide by 2 and tile to MxN
tol = ones(m,1)*min([nn(1:n-1),0;0,nn(2:n)])/2;
% Calculate errors btw cumulative histograms
err = (cumd(:)*ones(1,n)-ones(m,1)*cum(:)')+tol;

% Find which combo yielded errors above tolerance
d = find(err < -numel(a)*sqrt(eps));
if ~isempty(d)
    % Set to max err
   err(d) = numel(a)*ones(size(d));
end

% Get min error
% T will be the bin mapping of a to hgram
% T(oldbinval) = newbinval
[dum,T] = min(err); %#ok
% Normalize T
T = (T-1)/(m-1);

