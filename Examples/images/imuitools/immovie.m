function mov = immovie(varargin)
%IMMOVIE Make movie from multiframe image.
%   MOV = IMMOVIE(X,MAP) returns an array of movie frame structures MOV
%   containing the images in the multiframe indexed image X with the
%   colormap MAP. X is an M-by-N-by-1-by-K array, where K is the number of
%   images. All the images in X must have the same size and must use the
%   same colormap MAP.  
%
%   To play the movie, call IMPLAY.
%
%   MOV = IMMOVIE(RGB) returns an array of movie frame structures MOV from
%   the images in the multiframe truecolor image RGB. RGB is an
%   M-by-N-by-3-by-K array, where K is the number of images. All the images
%   in RGB must have the same size.
%
%   Class Support
%   -------------
%   An indexed image can be uint8, uint16, single, double, or logical. A
%   truecolor image can be uint8, uint16, single, or double. MOV is a
%   MATLAB movie frame. For details about the movie frame structure,
%   see the reference page for GETFRAME. 
%
%   Example
%   -------
%        load mri
%        mov = immovie(D,map);
%        implay(mov)
%
%   Remark
%   ------
%   You can also make movies from images by using the MATLAB function
%   VIDEOWRITER, which creates AVI files.
%
%   See also VIDEOWRITER, GETFRAME, IMPLAY, MONTAGE, MOVIE.

%   Copyright 1993-2014 The MathWorks, Inc.

[X,map] = parse_inputs(varargin{:});

numframes = size(X,4);
mov = repmat(struct('cdata',[],'colormap',[]),[1 numframes]);

isIndexed = size(X,3) == 1;

for k = 1 : numframes
  if isIndexed
      mov(k).cdata = matlab.images.internal.ind2rgb8(X(:,:,:,k),map);
  else
      mov(k).cdata = X(:,:,:,k);      
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,map] = parse_inputs(varargin)

narginchk(1, 2);

switch nargin
    case 1                      % immovie(RGB)
        X = varargin{1};
        map = [];
    case 2                      % immovie(X,map)
        X = varargin{1};
        map = varargin{2};
end

% Check parameter validity

if isempty(map) %RGB image
    validateattributes(X, {'uint8','uint16','single','double'},{},...
        'RGB', mfilename, 1);
    if size(X,3)~=3
        error(message('images:immovie:invalidTruecolorImage'));
    end
    if ~isa(X,'uint8')
        X = im2uint8(X);
    end

else % indexed image
    validateattributes(X, {'uint8','uint16','double','single','logical'}, ...
        {},'X', mfilename, 1);
    if size(X,3) ~= 1
        error(message('images:immovie:invalidIndexedImage'));
    end
    iptcheckmap(map, mfilename, 'MAP', 2);

    if ~isa(X,'uint8')
        X = im2uint8(X,'indexed');
    end
end
