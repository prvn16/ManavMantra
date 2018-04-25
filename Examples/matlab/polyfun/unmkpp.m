function [breaks,coefs,l,k,d]=unmkpp(pp)
%UNMKPP Supply details about piecewise polynomial.
%   [BREAKS,COEFS,L,K,D] = UNMKPP(PP) extracts from the piecewise polynomial
%   PP its breaks, coefficients, number of pieces, order and dimension of its
%   target.  PP would have been created by SPLINE or the spline utility MKPP.
%
%   See also MKPP, SPLINE, PPVAL.

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.

if ~isstruct(pp) % for backward compatibility, permit the former way
                 % of encoding the ppform
   if pp(1)==10
      d = pp(2); l=pp(3); breaks=reshape(pp(3+(1:l+1)),1,l+1);
      k=pp(5+l); coefs=reshape(pp(5+l+(1:d*l*k)),d*l,k);
   else
      error(message('MATLAB:unmkpp:InputArrayNotPP'))
   end
else
   if strcmp(pp.form,'pp')
      d = pp.dim; l = pp.pieces; breaks = pp.breaks; coefs = pp.coefs;
      k = pp.order;
   else
      error(message('MATLAB:unmkpp:InputStructNotPP'))
   end
end

