function n = innerprodintbits(B,V)
%INNERPRODINTBITS Number of integer bits for fixed-point inner product
%
%   INNERPRODINTBITS(B,V) computes the minimum number of integer bits
%   necessary in the inner product of B'*V to guarantee that no overflow
%   will occur and to preserve the best precision such that:
%
%     * both B and V are fi vectors
%     * the values of B are known
%     * only the numeric type of V is relevant (the values are ignored)
%
%   The main use of this function is to determine the number of integer
%   bits necessary in the output Y of an FIR filter that computes the
%   inner product between constant coefficient row vector B and state
%   column vector Z.  For example,
%
%     for k=1:length(X);
%       Z = [X(k);Z(1:end-1)];
%       Y(k) = B * Z;
%     end
%
%   Algorithm:  
%
%   In general, an inner product grows log2(n) bits for vectors of
%   length n.  However, in this case the vector B is known and its
%   values do not change. This knowledge is used to compute the 
%   smallest number of integer bits that are necessary in the output to
%   guarantee that no overflow will occur.
%
%   The largest gain occurs when the vector V has the same sign as the
%   constant vector B.  Therefore, the largest gain due to the vector B
%   is B*sign(B'), which is equal to sum(abs(B)).  In Digital Signal
%   Processing terminology, this is another way of saying that the gain
%   of a filter is bounded by the 1-norm of its impulse response B =
%   norm(B,1).
%  
%   The overall number of integer bits necessary to guarantee that no
%   overflow occurs in the inner product is computed by:
%
%       n = ceil(log2(sum(abs(B)))) + number of integer bits in V + 1 sign bit.
%
%   The extra sign bit is only added if both B and V are signed and B attains
%   its minimum.  This will prevent overflow in the event of (-1)*(-1).
%
%   See FI_C_DEVELOPMENTDEMO for an example.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2011 The MathWorks, Inc.
%     

if ~isfi(B) || ~isfi(V)
  error('Both arguments must be fi objects.')
end

Bd = double(B);
maxgain = norm(Bd(:),1);
n = ceil(log2(maxgain)) + V.WordLength - V.FractionLength;

% Add an extra bit if both B and V are signed and B attains its minimum
% to prevent overflow in the event of (-1)*(-1).
if B.Signed && V.Signed 
  [lowerbnd, upperbnd] = range(B);
  if any(min(B) == lowerbnd)
    n = n+1;
  end
end

