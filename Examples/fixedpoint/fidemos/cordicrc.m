function [R,C] = cordicrc(A,B,varargin) %#codegen 
%CORDICRC   Orthogonal-triangular decomposition via CORDIC
%   [R,C] = CORDICRC(A,B,NITER) produces an upper triangular matrix R of the same
%   dimension as A and an orthogonal matrix Q so that C = Q'*B.  The
%   decomposition is done via Givens rotations that use NITER CORDIC iterations.
%
%   [R,C] = CORDICRC(A,B,NITER,ONE) specifies which value is equivalent to one.
%   For example, if you manually scale integers (e.g. without using the fi
%   object), and your binary point is 14, then you can specify ONE=2^14.
%
%   Example:
%     A = randn(8,6);
%     B = randn(8,2);
%     [R,C] = cordicrc(A,B)
%     [Q,~] = cordicqr(A)
%     err = Q'*B - C
%
%   See also FI_CORDICQR, FI_CORDICQR_DEMO.

%   Copyright 2004-2010 The MathWorks, Inc.
  if nargin>=3 && ~isempty(varargin{1})
     niter = varargin{1};
  elseif isa(A,'double') || isfi(A) && isdouble(A)
    niter = 52;
  elseif isa(A,'single') || isfi(A) && issingle(A)
    niter = single(23);
  elseif isfi(A)
    niter = int32(get(A,'WordLength') - 1);
  elseif isa(A,'int8')
    niter = int8(7);
  elseif isa(A,'int16')
    niter = int16(15);
  elseif isa(A,'int32')
    niter = int32(31);
  elseif isa(A,'int64')
    niter = int32(63);
  else
    assert(0,'First input must be double, single, fi, or signed integer.');
  end
  % Kn is the inverse of the CORDIC gain, a constant computed outside the loop
  Kn = inverse_cordic_growth_constant(niter);
  % Number of rows and columns in A
  [m,n] = size(A);
  % Compute R in-place over A.
  R = A;
  C = B;
  for j=1:n
    for i=j+1:m
      % Apply Givens rotations, zeroing out the i-jth entry below
      % the diagonal.  Apply the same rotations to the columns of Q
      % that are applied to the rows of R so that Q'*A = R.
      [R(j,j:end),R(i,j:end),C(j,:),C(i,:)] = ...
          cordicgivens(R(j,j:end),R(i,j:end),C(j,:),C(i,:),niter,Kn);
    end
  end
end

function [x,y,u,v] = cordicgivens(x,y,u,v,niter,Kn)
%CORDICGIVENS  Givens rotation via CORDIC about the first element.
%   [Xn,Yn,Un,Vn] = CORDICGIVENS(X,Y,U,V,NITER) rotates vector (X,Y) about X(1), Y(1) to
%   (Xn,Yn) where Yn(1) is approximately 0.  Vectors U and V are rotated
%   through the same angles.
%
%   The CORDICGIVENS function is numerically equivalent to the following
%   Givens rotation, Algorithm 5.1.5, p. 202 & Algorithm 5.1.6, p. 203,
%   Golub & Van Loan, Matrix Computations, 2nd edition.
%       function [x,y,u,v] = givensrotation(x,y,u,v)
%         a = x(1); b = y(1);
%         if b==0
%           c = 1; s = 0;
%         else
%           if abs(b) > abs(a)
%             t = -a/b; s = 1/sqrt(1+t^2); c = s*t;
%           else
%             t = -b/a; c = 1/sqrt(1+t^2); s = c*t;
%           end
%         end
%         x0 = x;          u0 = u;
%         x = c*x0 - s*y;  u = c*u0 - s*v;
%         y = s*x0 + c*y;  v = s*u0 + c*v;
%       end
%
%   The advantage of the CORDICGIVENS function is that it does not compute
%   the square root or divide operation, which are expensive in fixed-point.
%   Only bit-shifts, addition, and subtraction are needed in the main
%   loop.  And then one scalar-times-vector multiply at the end to normalize
%   the CORDIC gain.
  if x(1)<0
    % Compensation for 3rd and 4th quadrants
    x(:) = -x;  u(:) = -u;
    y(:) = -y;  v(:) = -v;
  end
  for i=0:niter-1
    x0 = x;
    u0 = u;
    if y(1)<0
      % Counter-clockwise rotation
      % x and y form R,         u and v form C=Q'*B
      x(:) = x - bitsra(y, i);  u(:) = u - bitsra(v, i);
      y(:) = y + bitsra(x0,i);  v(:) = v + bitsra(u0,i);
    else
      % Clockwise rotation
      % x and y form R,         u and v form C=Q'*B
      x(:) = x + bitsra(y, i);  u(:) = u + bitsra(v, i);
      y(:) = y - bitsra(x0,i);  v(:) = v - bitsra(u0,i);
    end
  end
  % Set y(1) to exactly zero so R will be upper triangular without roundoff
  % showing up in the lower triangle.
  y(1) = 0;
  % Normalize the CORDIC gain
  x(:) = Kn * x;  u(:) = Kn * u;
  y(:) = Kn * y;  v(:) = Kn * v;
end

function Kn = inverse_cordic_growth_constant(niter)
% Kn = INVERSE_CORDIC_GROWTH_CONSTANT(NITER) returns the inverse of the 
% CORDIC growth factor after NITER iterations. Kn quickly converges to around
% 0.60725.  
  Kn = 1/prod(sqrt(1+2.^(-2*(0:double(niter)-1))));
end

