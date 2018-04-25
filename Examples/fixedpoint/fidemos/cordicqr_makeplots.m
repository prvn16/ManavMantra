function [Q,R] = cordicqr_makeplots(A,varargin) %#codegen 
%CORDICQR   Make Plots for Orthogonal-triangular decomposition via CORDIC
%   See also CORDICQR
%   Copyright 2004-2010 The MathWorks, Inc.
  if nargin>=2 && ~isempty(varargin{1})
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
  if nargin>=3 && ~isempty(varargin{2})
    one = varargin{2};
  else
    one = 1;
  end
  PLOT_CORDIC_ROTATION = true;
  % Kn is the inverse of the CORDIC gain, a constant computed outside the loop
  Kn = cordic_constants(niter);
  % Number of rows and columns in A
  [m,n] = size(A);
  % Compute R in-place over A.
  R = A;
  % Q is initially the identity matrix of the same type as A.  If
  % manual scaling is chosen, then the identity matrix is scaled by
  % the equivalent of 1.
  if isfi(A) && (isfixed(A) || isscaleddouble(A)) && isequal(one,1)
    % If A is a fi object, then we can pick an optimal type for Q.  Since Q
    % is orthogonal, then all elements will be bounded by 1 in magnitude, and
    % it needs one additional bit for the CORDIC growth factor of 1.6468 in
    % intermediate computations.
    Q = fi(one*eye(m), get(A,'NumericType'), 'FractionLength',get(A,'WordLength')-2);
  else
    Q = coder.nullcopy(repmat(A(:,1),1,m));
    Q(:) = one*eye(m,class(one));
  end
  % Determine axis size based on maximum growth.  
  % Make the axis limits to nearest 1/2
  q = quantizer([52 1],'round');
  max_axis = quantize(q,(1/Kn) * sqrt(m) * max(abs(double(A(:)))))
  ax = [-max_axis max_axis -max_axis max_axis];
  % Compute [R Q]
  for j=1:n
    for i=(j+1):m
      % Apply Givens rotations, zeroing out the i-jth entry below
      % the diagonal.  Apply the same rotations to the columns of Q
      % that are applied to the rows of R so that Q'*A = R.
      row_col = sprintf('CORDIC rotations about R(%d,%d), R(%d, %d)',j,j,i,j);
      fprintf('\n\n\n%s\n',row_col);
      figure; axis(ax);axis square;set(gca,'Box','on');grid on;xlabel('X(1)');ylabel('Y(1)')
      title(row_col)
      figure(gcf); drawnow
      [R(j,j:end),R(i,j:end),Q(:,j),Q(:,i)] = cordicgivens(R(j,j:end),R(i,j:end),...
                                                        Q(:,j),Q(:,i),niter,Kn,...
                                                        i,j,PLOT_CORDIC_ROTATION);
      R %#ok
      Q %#ok
    end
  end
end

function [x,y,u,v] = cordicgivens(x,y,u,v,niter,Kn,row,col,PLOT_CORDIC_ROTATION)
  if PLOT_CORDIC_ROTATION
    theta = linspace(0,2*pi,512);
    magnitude = hypot(x(1),y(1));
    c = magnitude*cos(theta); s = magnitude*sin(theta);
    line(c,s,'Color','c')
    line(x(1),y(1),'Color','g','Marker','.','MarkerSize',15,'LineStyle','none');
    text(x(1),y(1),'Initial value = (x,y)','HorizontalAlignment','right');
    drawnow
  end
  if x(1)<0
    % Compensation for 3rd and 4th quadrants
    x0 = x; y0=y;
    x = -x;  u = -u;
    y = -y;  v = -v;
    if PLOT_CORDIC_ROTATION
      line([x0(1) x(1)],[y0(1) y(1)],'Color','b')
      line(x(1),y(1),'Color','b','Marker','.','MarkerSize',15,'LineStyle','none');
      text(x(1),y(1),'First quadrant correction',...
           'HorizontalAlignment','right');
      drawnow
    end
  end
  for i=0:niter-1
    x0 = x; y0 = y;
    u0 = u; v0 = v;
    if y(1)<0
      % Counter-clockwise rotation
      % x and y form R,         u and v form Q
      x(:) = x - bitsra(y, i);  u(:) = u - bitsra(v, i);
      y(:) = y + bitsra(x0,i);  v(:) = v + bitsra(u0,i);
      if PLOT_CORDIC_ROTATION
        plot_next_line(i,x0,x,y0,y,u0,u,v0,v,row,col);
      end
    else
      % Clockwise rotation
      % x and y form R,         u and v form Q
      x(:) = x + bitsra(y, i);  u(:) = u + bitsra(v, i);
      y(:) = y - bitsra(x0,i);  v(:) = v - bitsra(u0,i);
      if PLOT_CORDIC_ROTATION
        plot_next_line(i,x0,x,y0,y,u0,u,v0,v,row,col);
      end
    end
  end
  % Set y(1) to exactly zero so R will be upper triangular without roundoff
  % showing up in the lower triangle.
  x0 = x; y0 = y;
  u0 = u; v0 = v; %#ok
  y(1) = 0;
  % Normalize the CORDIC gain
  % Annotation units are relative to the figure, not the axis, so everything must be scaled.
  ylim = get(gca,'YLim')
  line([magnitude magnitude],[ylim(2)/2 0],'Color','c');
  line([x(1) x(1)],[ylim(2)/2 0],'Color','c');
  text(magnitude + (x(1)-magnitude)/2, ylim(2)/2 + 0.1, '  CORDIC Growth  ','HorizontalAlignment','center');

  x(:) = Kn * x;  u(:) = Kn * u;
  y(:) = Kn * y;  v(:) = Kn * v;

  line([x0(1) x(1)],[y0(1) y(1)],'Color','b');
  line(x(1),y(1),'Color','r','Marker','.','MarkerSize',15,'LineStyle','none');
  text(x(1),y(1),'Final value = Kn * (x,y)','HorizontalAlignment','right');
  drawnow
end

function [Kn,phi] = cordic_constants(niter)
%CORDIC_CONSTANTS  CORDIC constants.
%   [Kn,PHI] = CORDIC_CONSTANTS(NITER) returns the inverse of the CORDIC growth factor Kn
%   after NITER iterations, and the vector PHI of CORDIC angles in radians.
%
%   Kn quickly converges to around 0.60725.
  Kn = 1/prod(sqrt(1+2.^(-2*(0:double(niter)-1))));
  phi = atan(pow2(-(0:double(niter)-1)));
end

function plot_next_line(i,x0,x,y0,y,u0,u,v0,v,row,col) %#ok
  line([x0(1) x(1)],[y0(1) y(1)],'Color','b')
  line(x(1),y(1),'Color','b','Marker','.','MarkerSize',15,'LineStyle','none');
  drawnow
end
