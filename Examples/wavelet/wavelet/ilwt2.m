function x = ilwt2(varargin)
%ILWT2 Inverse 2-D lifting wavelet transform.
%   ILWT2 performs a 2-D lifting wavelet reconstruction
%   with respect to a particular lifted wavelet that you specify.
%
%   X = ILWT2(AD_In_Place,W) computes the reconstructed matrix X
%   using the approximation and detail coefficients matrix AD_In_Place
%   obtained by a lifting wavelet decomposition.
%   W is a lifted wavelet name (see LIFTWAVE).
%
%   X = ILWT2(CA,CH,CV,CD,W) computes the reconstructed matrix X
%   using the approximation coefficients vector CA and detail 
%   coefficients vectors CH, CV, CD obtained by a wavelet 
%   decomposition using lifting.
%
%   X = ILWT2(AD_In_Place,W,LEVEL) or X = ILWT2(CA,CH,CV,CD,W,LEVEL)
%   compute the lifting wavelet reconstruction, at level LEVEL.
%
%   X = ILWT2(AD_In_Place,W,LEVEL,'typeDEC',typeDEC) or
%   X = ILWT2(CA,CH,CV,CD,W,LEVEL'typeDEC',typeDEC) with
%   typeDEC = 'w' or 'wp' compute the wavelet or the
%   wavelet packet decomposition using lifting, at level LEVEL.
%
%   Instead of a lifted wavelet name, you may use the associated
%   lifting scheme LS:
%     X = ILWT2(...,LS,...) instead of X = ILWT2(...,W,...).
%
%   For more information about lifting schemes type: lsinfo.
%
%   NOTE: If AD_In_Place or CA,CH,CV,CD are obtained from an  
%   indexed image analysis (respectively a truecolor image 
%   analysis) then they are m-by-n matrices (respectively 
%   m-by-n-by-3 arrays). In the first case the output array X is
%   an m-by-n matrix,in the second case X is an m-by-n-by-3 array.
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also LWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2000.
%   Last Revision 17-Oct-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

% Check arguments.
nbIn = nargin;
switch nbIn
    case {2,3,5,6,8}
    case 4  % Special case for truecolor image
    case {0,1}
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case {7}
        error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
    otherwise
        error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end

% Default: level and typeDEC.
level = 1; typeDEC = 'w';
firstIdxAPP = 1; firstIdxDET = 1+mod(firstIdxAPP,2);

% Check arguments.
x_in_place = iscell(varargin{2}) | ischar(varargin{2});

if x_in_place
    [x,LS] = deal(varargin{1:2});   
    a = x(firstIdxAPP:2:end,firstIdxAPP:2:end,:);
    h = x(firstIdxDET:2:end,firstIdxAPP:2:end,:);
    v = x(firstIdxAPP:2:end,firstIdxDET:2:end,:);
    d = x(firstIdxDET:2:end,firstIdxDET:2:end,:);
    nextArg = 3;
else
    [a,h,v,d,LS] = deal(varargin{1:5});
    nextArg = 6;
end
if ndims(a)>2 , dim3 = 3; else dim3 = 1; end
sa = size(a); sh = size(h);
sv = size(v); sd = size(d);
if ~x_in_place
    x = zeros(sa(1)+sh(1),sa(2)+sv(2),dim3);
end
if nargin>=nextArg
    level = varargin{nextArg};
    for k = nextArg+1:2:length(varargin)-1
      argName = lower( varargin{k});
      switch argName
        case 'typedec' , typeDEC = varargin{k+1};
      end
    end
end
if ischar(LS) , LS = liftwave(LS); end

% Recursion if level > 1.
if level>1
   level = level-1;
   a = ilwt2(a,LS,level,'typeDEC',typeDEC);
   if isequal(typeDEC,'wp')
       h = ilwt2(h,LS,level,'typeDEC',typeDEC);
       v = ilwt2(v,LS,level,'typeDEC',typeDEC);
       d = ilwt2(d,LS,level,'typeDEC',typeDEC);
   end
end


%===================%
% LIFTING ALGORITHM %
%===================%
NBL = size(LS,1);
LStype = LS{NBL,3};

% Normalization.
if isempty(LStype)
    a = a/(LS{end,1}*LS{end,1});
    h = h/(LS{end,1}*LS{end,2});
    v = v/(LS{end,2}*LS{end,1});
    d = d/(LS{end,2}*LS{end,2});
end

% Reverse Lifting.
for k = NBL-1:-1:1
    liftTYPE = LS{k,1};
    liftFILT = -LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p'
        a = a + lsupdate('c',h,liftFILT,DF,sa,LStype);
        v = v + lsupdate('c',d,liftFILT,DF,sv,LStype);

      case 'd'
        h = h + lsupdate('c',a,liftFILT,DF,sh,LStype);
        d = d + lsupdate('c',v,liftFILT,DF,sd,LStype);
    end
end

% Merging.
sL = [sa(1)+sh(1), sa(2) , dim3];
L = zeros(sL);
L(firstIdxAPP:2:end,:,:) = a;
L(firstIdxDET:2:end,:,:) = h;
clear a h
sH = [sv(1)+sd(1), sv(2) , dim3];
H = zeros(sH);
H(firstIdxAPP:2:end,:,:) = v;
H(firstIdxDET:2:end,:,:) = d;
clear v d

% Reverse Lifting.
for k = NBL-1:-1:1
    liftTYPE = LS{k,1};
    liftFILT = -LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p' , L = L + lsupdate('r',H,liftFILT,DF,sL,LStype);
      case 'd' , H = H + lsupdate('r',L,liftFILT,DF,sH,LStype);
    end   
end

% Merging.
x(:,firstIdxAPP:2:end,:) = L;
x(:,firstIdxDET:2:end,:) = H;
% if dim3>1
%     ST = dbstack;
%     STN = {ST(:).name};
%     idx = strmatch(mfilename,STN);
%     if length(idx)<2 && ~isequal(varargin{end},'noconvert')        
%         x(x<0) = 0;
%         x = uint8(x);
%     end
% end
%=========================================================================%
