function [Q,R] = cordicqr(A,varargin) %#codegen
%CORDICQR   Orthogonal-triangular factorization via CORDIC
%   [Q,R] = CORDICQR(A) produces an upper triangular matrix R of the same
%   dimension as A and an orthogonal matrix Q so that A = Q*R.  The
%   factorization is done via Givens rotations using CORDIC iterations.  The
%   number of CORDIC iterations is automatically chosen as a function of the
%   data type of A.
%
%   [Q,R] = CORDICQR(A,NITER) uses NITER CORDIC iterations.
%
%   [Q,R] = CORDICQR(A,NITER,RQWL) where the wordlength of R and Q is in RQWL.
%
%   Limitations:
%     A must be a signed, real matrix.
%     To generate MEX function or C-Code, NITER and RQWL must be
%     constant if they are used as an input.
%
%     QR has default word length of Q and R to guarantee
%     no overflow in R, whereas this function has default
%     word length for Q and R to be same as that of A.
%
%   Examples:
%     %% Double
%     m = 5;                   % Size of matrix
%     A = randn(m);
%     [Q,R] = cordicqr(A)
%     err = Q*R - A
%     I = Q*Q'
%     figure(1); surf(err); title('QR - A'); figure(gcf)
%     figure(2); surf(I); title('Q''Q'); figure(gcf)
%
%     %% Fixed Point
%     % To prevent overflow, you need to scale so there is room for growth,
%     % or add bits to the word length.
%     m = 5;                   % Size of matrix
%     X = rand(m)-0.5;
%     A = sfi(X);
%     % The growth factor is 1.6468 times the square-root of the number of rows of
%     % A. The bit growth is the next integer above the base-2 logarithm of the
%     % growth. 
%     bit_growth = ceil(log2(cordic_growth_constant * sqrt(m)))
%     %
%     % Initialize R with the same values as A, and a word length increased by the bit
%     % growth. 
%     R = sfi(A, get(A,'WordLength')+bit_growth, get(A,'FractionLength'))
%     %
%     % Use R as input and overwrite it.
%     [Q,R] = cordicqr(R)
%     err = double(Q)*double(R) - double(A)
%     I = double(Q)*double(Q')
%     figure(1); surf(err); title('QR - A'); figure(gcf)
%     figure(2); surf(I); title('Q''Q'); figure(gcf)
%
%   See also QR, CORDICQR_DEMO.

%   Copyright 2004-2017 The MathWorks, Inc.

  % Validate inputs
  validate_first_input(A);
  niter = get_number_of_iterations(A,varargin{:});

  % Initialize Q and R
  [Q,R] = initialize_Q_R(A,varargin{:});
  
  % Kn is the inverse of the CORDIC gain, a constant computed outside the loop
  Kn = inverse_cordic_growth_constant(niter);
  
  % Number of rows and columns of A
  [m,n] = size(A);
  
  % Compute [R Q]
  for j=1:n
    for i=j+1:m
      % Apply Givens rotations, zeroing out the i-jth entry below
      % the diagonal.  Apply the same rotations to the columns of Q
      % that are applied to the rows of R so that Q'*A = R.
      [R(j,j:end),R(i,j:end),Q(:,j),Q(:,i)] = ...
          cordicgivens(R(j,j:end),R(i,j:end),Q(:,j),Q(:,i),niter,Kn);
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
      % x and y form R,         u and v form Q
      x = accumneg(x, bitsra(y, i));
      y = accumpos(y, bitsra(x0,i));
      u = accumneg(u, bitsra(v, i));
      v = accumpos(v, bitsra(u0,i));
    else
      % Clockwise rotation
      % x and y form R,         u and v form Q
      x = accumpos(x, bitsra(y, i));
      y = accumneg(y, bitsra(x0,i));
      u = accumpos(u, bitsra(v, i));
      v = accumneg(v, bitsra(u0,i));
    end
  end
  % Set y(1) to exactly zero so R will be upper triangular without round off
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

function validate_first_input(A)
% Validate first input
  if ~isnumeric(A) || ~isreal(A)
      error(message('fixed:fi:realAndNumeric'));
  elseif ~ismatrix(A)
      error(message('fixed:fi:inputMustBe2D', 'CORDICQR'));
  elseif isinteger(A)
      error(message('MATLAB:matrix:UndefinedFunctionForClass', 'CORDICQR', class(A)));
  elseif isfi(A) && ~issigned(A)
      error(message('fixed:fi:realAndSigned'));
  end
end

function niter = get_number_of_iterations(A,varargin)
% Get or compute number of iterations
  if nargin>=2 && ~isempty(varargin{1})
      niter = varargin{1};
  elseif isa(A,'double') || isfi(A) && isdouble(A)
      niter = 52;
  elseif isa(A,'single') || isfi(A) && issingle(A)
      niter = single(23);
  elseif isfi(A)
      niter = int32(get(A,'WordLength') - 1);
  else
      error(message('fixed:fi:realAndNumeric'));
  end
  validate_number_of_iterations(niter);
end

function validate_number_of_iterations(niter)
  if coder.target('MATLAB')
      fixed.internal.cordic_check_and_parse_niters(niter,'cordicqr');
  else
      eml_cordic_check_niters_arg(niter);
  end
end

function [Q,R] = initialize_Q_R(A,varargin)
% Initialize Q and R

  % Number of rows of A
  m = size(A,1);
  % Q is initially the identity matrix of the same type as A.  If
  % manual scaling is chosen, then the identity matrix is scaled by
  % the equivalent of 1.
  if isfi(A) && isscaledtype(A)
      % If A is a fi object, then we can pick an optimal type for Q.
      % Since Q is orthonormal, then all elements will be bounded by 1 in
      % magnitude, and it needs one additional bit for the CORDIC growth
      % factor of 1.6468 in intermediate computations.
      if nargin>=3
          RQWordLength = varargin{2};
      else
          RQWordLength = get(A,'WordLength');
      end
      Ta = numerictype(A);
      R = fi(ones(size(A)), ...
             'Signedness','Signed',...
             'WordLength',RQWordLength,...
             'FractionLength',Ta.FractionLength,...
             'DataType',Ta.DataType);
      R(:)=A;
      Q = fi(eye(m), ...
             'Signedness','Signed',...
             'WordLength',RQWordLength,...
             'FractionLength',RQWordLength-2,...
             'DataType',Ta.DataType);
      
  else
      % Floating-point (includes double, single, fi double, fi single)
      R = A;
      Q = coder.nullcopy(zeros(m,'like',A));
      Q(:) = eye(m); % m-by-m identity matrix in the same type as A
  end
end