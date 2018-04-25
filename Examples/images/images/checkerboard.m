function I = checkerboard(varargin)
%CHECKERBOARD Create checkerboard image.
%   I = CHECKERBOARD creates a checkerboard image composed of squares that
%   have 10 pixels per side. The light squares on the left half of the
%   checkerboard are white. The light squares on the right half of the
%   checkerboard are gray.
%
%   I = CHECKERBOARD(N) creates a checkerboard where each square has N
%   pixels per side.
%
%   I = CHECKERBOARD(N,P,Q) creates a rectangular checkerboard. There are P
%   rows of TILE and Q columns of TILE. TILE = [DARK LIGHT; LIGHT DARK]
%   where DARK and LIGHT are squares with N pixels per side. If you omit Q,
%   it defaults to P and the checkerboard is square.
%
%   The CHECKERBOARD function is useful for creating test images for
%   geometric operations.
%   
%   Examples
%   --------
%       I = checkerboard(20);
%       figure, imshow(I)
%
%       J = checkerboard(10,2,3);
%       figure, imshow(J)
%
%       K = (checkerboard > 0.5); % creates a black and white checkerboard
%       figure, imshow(K)
%
%  See also CP2TFORM, IMTRANSFORM, MAKETFORM.


%   Copyright 1993-2017 The MathWorks, Inc.

%   Input-output specs
%   ------------------ 
%   N,P,Q:    scalar positive integers 
%
%   I:        real double 2D matrix

[n, p, q] = ParseInputs(varargin{:});

tile = repelem([0 1; 1 0], n, n);

if ~mod(q, 2)
    % Make left and right sections separately
    numColReps = ceil(q/2);
    Ileft = repmat(tile, p, numColReps);
    
    tileRight = repelem([0 0.7; 0.7 0], n, n);
    Iright = repmat(tileRight, p, numColReps);
    % tile the left and right halves together
    I = [Ileft Iright];
else
    % Make the entire image in one shot
    I = repmat(tile,p,q);

    % make right half plane have light gray tiles
    ncols = size(I,2);
    midcol = ncols/2 + 1; 
    I(:,midcol:ncols) = I(:,midcol:ncols) - .3;
    I(I<0) = 0;
end

%-------------------------------
% Function  ParseInputs
%
function [n, p, q] = ParseInputs(varargin)

% defaults
n = 10;
p = 4;
q = p;

narginchk(0,3);

varNames={'N', 'P', 'Q'};
for x = 1:1:length(varargin)
    validateattributes(varargin{x}, {'numeric'},...
                  {'integer' 'real' 'positive' 'scalar'}, ...
                  mfilename,varNames{x},x);
end

switch nargin
  case 0
    % I = CHECKERBOARD
    return;
    
  case 1
    % I = CHECKERBOARD(N)
    n = varargin{1};

  case 2
    % I = CHECKERBOARD(N,P)
    n = varargin{1};
    p = varargin{2};
    q = p;

  case 3
    % I = CHECKERBOARD(N,P,Q)
    n = varargin{1};
    p = varargin{2};    
    q = varargin{3};    
end

n = double(n);
p = double(p);
q = double(q);
