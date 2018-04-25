function t = isequal(varargin)
%ISEQUAL True if quantizer properties are equal
%   ISEQUAL(Q1,Q2) is true if both Q1 and Q2 are quantizer objects, and
%   they have the same values for the following properties:
%     MODE, ROUNDMODE, OVERFLOWMODE, FORMAT.
%
%   ISEQUAL(Q1,Q2,...) is true if all quantizers have the same values
%   for the properties listed above.
%
%   Example:
%     q1 = quantizer('nearest',[8 7]);
%     q2 = quantizer('floor',[8 7]);
%     t = isequal(q1,q2)

%   Thomas A. Bryan, 6 March 2003
%   Copyright 1999-2015 The MathWorks, Inc.

narginchk(2,inf);

t = true;
q = varargin{1};
if ~isa(q,'embedded.quantizer')
  t = false;
  return
end

c = {q.mode,q.roundmode,q.overflowmode,q.format};
k=2;
while k<=nargin && t==true
  if ~isa(varargin{k},'embedded.quantizer')
    t = false;
  else
    q = varargin{k};
    t = t && isequal(c, {q.mode,q.roundmode,q.overflowmode,q.format});
  end
  k = k+1;
end

            
