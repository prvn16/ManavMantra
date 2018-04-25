function [Q,R] = givensqr(A) 
% Givens QR, Algorithm 5.2.2, p. 214, Golub & Van Loan, Matrix Computations, 2nd edition

%   Copyright 2010 The MathWorks, Inc.

  [m,n] = size(A);   % Number of rows and columns in A
  % Compute R in-place over A.
  R = A;
  % Q is initially the identity matrix.
  Q = eye(m);
  % Compute [R Q]
  for j=1:n
    for i=j+1:m
      % Apply Givens rotations, zeroing out the i-jth entry below
      % the diagonal.  Apply the same rotations to the columns of Q
      % that are applied to the rows of R so that Q'*A = R.
      [R(j,j:end),R(i,j:end),Q(:,j),Q(:,i)] = givensrotation(R(j,j:end),R(i,j:end),Q(:,j),Q(:,i));
    end
  end
end

function [x,y,u,v] = givensrotation(x,y,u,v)
% Givens rotation, Algorithm 5.1.5, p. 202 & Algorithm 5.1.6, p. 203, 
% Golub & Van Loan, Matrix Computations, 2nd edition  
  a = x(1); b = y(1);
  if b==0
    % No rotation necessary.  c = 1; s = 0;
    return;
  else
    if abs(b) > abs(a)
      t = -a/b; s = 1/sqrt(1+t^2); c = s*t;
    else
      t = -b/a; c = 1/sqrt(1+t^2); s = c*t;
    end
  end
  x0 = x;             u0 = u;        
  % x and y form R,   u and v form Q
  x(:) = c*x0 - s*y;  u(:) = c*u0 - s*v;
  y(:) = s*x0 + c*y;  v(:) = s*u0 + c*v;
end

