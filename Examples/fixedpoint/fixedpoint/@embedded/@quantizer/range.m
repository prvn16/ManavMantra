function varargout = range(q)
%RANGE  Numerical range of a QUANTIZER object
%   R = RANGE(Q), for QUANTIZER object Q, returns the two-element 
%   row vector R = [A B] such that for all real X,  
%   Y = QUANTIZE(Q,X) returns Y in the range A <= Y <= B.
%
%   [A,B] = RANGE(Q) returns the minimum and maximum values of the range in
%   separate output variables.
%
%   Examples:
%     q = quantizer('float',[6 3]);
%     r = range(q)
%   returns r = [-14 14].
%
%     q = quantizer('fixed',[4 2],'floor');
%     [a,b] = range(q)
%   returns a = -2,  b = 1.75 = 2 - eps(q).
%     
%   See also QUANTIZER, EMBEDDED.QUANTIZER/EPS, 
%            EMBEDDED.QUANTIZER/QUANTIZE

%   Thomas A. Bryan, 7 May 1999.
%   Copyright 1999-2006 The MathWorks, Inc.

error(nargoutchk(0,2,nargout,'struct'));

a = q.lowerbound;
b = q.upperbound;
switch nargout
  case {0,1}
    varargout = {[a b]};
  otherwise
    varargout = {a, b};
end
 
