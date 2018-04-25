function y = mswthresh(x,s_OR_h,t,varargin)
%MSWTHRESH Perform multisignal 1-D thresholding.
%   Y = MSWTHRESH(X,SORH,T) returns soft (if SORH = 's')
%   or hard (if SORH = 'h') T-thresholding  of the input 
%   matrix X. 
%
%   T can be a single value, a matrix of the same size as X
%   or a vector. In this last case, thresholding is 
%   performed rowwise, LT = length(T) must be such that
%   LT => size(X,1).
%
%   Y = MSWTHRESH(X,SORH,T,'c') performs a columnwise
%   thresholding, LT => size(X,2).
%
%   Y = MSWTHRESH(X,'s',T) returns Y = SIGN(X).(|X|-T)+, soft 
%   thresholding is shrinkage.
%
%   Y = MSWTHRESH(X,'h',T) returns Y = X.1_(|X|>T), hard
%   thresholding is cruder.
%
%   See also mswden, mswcmp, wthresh, wdencmp, wpdencmp

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Check inputs arguments.
[rt,ct] = size(t);
[rx,cx] = size(x);
if rt>1 && ct>1
    err = (rt~=rx) || (ct~=cx);
elseif rt==1 && ct==1
    err = 0;
else
    lt = max([rt ct]);
    if length(varargin)<1 ,
        err = lt<rx ;
        if ~err , t = t(1:rx); t = t(:);  t = t(:,ones(1,cx)); end
    else
        err = lt<cx ;
        if ~err , t = t(1:cx); t = t(:)'; t = t(ones(1,rx),:); end
    end
end    
if err
    error(message('Wavelet:FunctionArgVal:Invalid_ThrVal'));
end 

switch s_OR_h
  case 's'
    tmp = abs(x)-t;
    tmp = (tmp + abs(tmp))/2;
    y   = sign(x).*tmp;
 
  case 'h'
    y   = x.*(abs(x)>t);
 
  otherwise
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
