function BW = boundarymask(L,varargin) %#codegen
%BOUNDARYMASK Find region boundaries of segmentation
%   MASK = BOUNDARYMASK(L) computes a mask which represents the region
%   boundaries for the input label matrix L. The output, MASK, is a logical
%   image which is true at boundary locations and false at non-boundary
%   locations.
%
%   MASK = BOUNDARYMASK(BW) computes the region boundaries for the input
%   binary image BW.
%
%   MASK = BOUNDARYMASK(___,CONN) computes the region boundaries using a
%   connectivity specified by the scalar CONN. CONN may be 4 or 8. For a
%   given pixel P in the input image, the corresponding output MASK(P) is
%   true if any of the pixels in the 4 or 8 connected neighborhood of P
%   have a value different than P. If CONN is not specified, a default
%   connectivity of 8 is used.
%
%   Examples
%   --------
%   A = imread('kobi.png');
%   L = superpixels(A,100);
%   BW = boundarymask(L);
%   figure
%   imshow(BW)
%
%   See also imoverlay, superpixels

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1,2);

numericTypes = images.internal.iptnumerictypes();

validateattributes(L,{numericTypes{:},'logical'},...
    {'finite','2d','nonnegative','nonsparse'},mfilename); %#ok<CCAT>

if nargin < 2
    conn = 8; % Default connectivity is 8.
else
    connIn = varargin{1};
    validateattributes(connIn,numericTypes,{'scalar','finite','positive'},...
        mfilename,'CONN');
    coder.internal.errorIf(~coder.internal.isConst(connIn), ...
        'MATLAB:images:validate:codegenInputNotConst','CONN');
    conn = double(connIn);
end

coder.internal.errorIf(~isequal(conn,4) && ~isequal(conn,8), ...
    'images:boundarymask:invalidConnectivity');

if conn == 4
    se = [ ...
        0,1,0; ...
        1,1,1; ...
        0,1,0; ...
        ];
else
    se = ones(3);
end

BW = (imdilate(L,se) > L) | (imerode(L,se) < L);
