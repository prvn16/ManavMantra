function OUT = lwtcoef2(type,xDEC,LS,level,levEXT)
%LWTCOEF2 Extract or reconstruct 2-D LWT wavelet coefficients.
%   Y = LWTCOEF2(TYPE,XDEC,LS,LEVEL,LEVEXT) returns the coefficients
%   or the reconstructed coefficients of level LEVEXT, extracted from
%   XDEC, the LWT decomposition at level LEVEL obtained with the 
%   lifting scheme LS.
%   The valid values for TYPE are:
%      - 'a' for approximations
%      - 'h', 'v', 'd'  for horizontal, vertical and diagonal details
%         respectively.
%      - 'ca' for  coefficients of approximations
%      - 'ch', 'cv', 'cd'  for  coefficients of horizontal, vertical
%        and diagonal details respectively.
%
%   Y = LWTCOEF2(TYPE,XDEC,W,LEVEL,LEVEXT) returns the same output 
%   using W which is the name of a "lifted wavelet".
%
%   NOTE: If XDEC is obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then 
%   it is an m-by-n matrix (respectively m-by-n-by-3 array).
%   In the first case the output array Y is an m-by-n matrix,
%   in the second case Y is an m-by-n-by-3 array.
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also ILWT2, LWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-2000.
%   Last Revision: 17-Oct-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

firstIdxAPP = 1;
% firstIdxDET = 1+mod(firstIdxAPP,2);
DELTA = firstIdxAPP-1;

[R,C,dim3]  = size(xDEC);
indCFS_ROW = 1:R;
indCFS_COL = 1:C;
indROW = (1-DELTA)*ones(1,levEXT);
indCOL = (1-DELTA)*ones(1,levEXT);
switch type
  case {'a','ca'}
  case {'h','ch'} , indROW(levEXT) = DELTA;
  case {'v','cv'} , indCOL(levEXT) = DELTA;
  case {'d','cd'} , indCOL(levEXT) = DELTA; indROW(levEXT) = DELTA;
end

% Extract coefficients.
for k=1:levEXT
    firstROW = 2-indROW(k);
    firstCOL = 2-indCOL(k);
    indCFS_ROW = indCFS_ROW(firstROW:2:end);
    indCFS_COL = indCFS_COL(firstCOL:2:end);
end
OUT = xDEC(indCFS_ROW,indCFS_COL,:);
if isequal(type,'ca') && (level>levEXT)
    OUT = ilwt2(OUT,LS,level-levEXT,'noconvert');
end

switch type
  case {'a','h','v','d'}
    xTMP = zeros(R,C,dim3);
    xTMP(indCFS_ROW,indCFS_COL,:) = OUT;
    OUT = ilwt2(xTMP,LS,level);
end
if dim3>1 && isequal(type,'a');
    OUT(OUT<0) = 0;
    OUT = uint8(OUT);
end