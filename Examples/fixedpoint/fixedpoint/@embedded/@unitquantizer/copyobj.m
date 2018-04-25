function varargout = copyobj(varargin)
%COPYOBJ  Copy UNITQUANTIZER object.
%   Q1 = COPYOBJ(Q) makes a copy of UNITQUANTIZER object Q and returns it in UNITQUANTIZER
%   object Q1.
%
%   [Q1,Q2,...] = COPYOBJ(Qa,Qb,...) copies Qa into Q1, Qb into Q2, etc.
%
%   [Q1,Q2,...] = COPYOBJ(Q) makes multiple copies of the same object.
%
%   Example:
%     Q = unitquantizer([8 7]);
%     Q1 = copyobj(Q)
%
%   See also QUANTIZER.

%   Thomas A. Bryan, 20 January 2000
%   Copyright 1999-2011 The MathWorks, Inc.


n=max(1,nargout);
if nargin>1 & n~=nargin
  error(message('fixed:quantizer:copyobj_narginNargoutMismatch'));
end
wrn = warning('off');
for k=1:n
  s = get(varargin{min(k,nargin)});
  q = unitquantizer;
  set(q,s);
  varargout{k} = q;
end
warning(wrn)
