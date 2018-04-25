function solinit = bvpinit(x,v,parameters,varargin)
%BVPINIT  Form the initial guess for BVP solvers.
%   SOLINIT = BVPINIT(X,YINIT) forms the initial guess for BVP4C or BVP5C in 
%   common circumstances. The boundary value problem (BVP) is to be solved 
%   on [a,b]. The vector X specifies a and b as X(1) = a and X(end) = b. 
%   It is also a guess for an appropriate mesh. BVP solvers will adapt this 
%   mesh to the solution, so often a guess like X = linspace(a,b,10) will 
%   suffice, but in difficult cases, mesh points should be placed where the 
%   solution changes rapidly. 
%
%   The entries of X must be ordered. For two-point BVPs, the entries of X 
%   must be distinct, so if a < b, then X(1) < X(2) < ... < X(end), and 
%   similarly for a > b. For multipoint BVPs there are boundary conditions
%   at points in [a,b]. Generally, these points represent interfaces and 
%   provide a natural division of [a,b] into regions. BVPINIT enumerates 
%   the regions from left to right (from a to b), with indices starting 
%   from 1. You can specify interfaces by double entries in the initial 
%   mesh X. BVPINIT interprets one entry as the right end point of region k 
%   and the other as the left end point of region k+1. THREEBVP exemplifies 
%   this for a three-point BVP.
%
%   YINIT provides a guess for the solution. It must be possible to evaluate 
%   the differential equations and boundary conditions for this guess. 
%   YINIT can be either a vector or a function handle:
%
%   vector:  YINIT(i) is a constant guess for the i-th component Y(i,:) of 
%            the solution at all the mesh points in X.
%
%   function:  YINIT is a function of a scalar x. For example, use 
%              solinit = bvpinit(x,@yfun) if for any x in [a,b], yfun(x) 
%              returns a guess for the solution y(x). For multipoint BVPs, 
%              BVPINIT calls Y = YINIT(X,K) to get an initial guess for the 
%              solution at x in region k. 
%                       
%   SOLINIT = BVPINIT(X,YINIT,PARAMETERS) indicates that the BVP involves 
%   unknown parameters. A guess must be provided for all parameters in the 
%   vector PARAMETERS. 
%
%   See also BVPGET, BVPSET, BVP4C, BVP5C, BVPXTEND, DEVAL, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2007 The MathWorks, Inc.

% Extend existing solution?  (backwards compatibility)
if isstruct(x)
  solinit = x;  
  if ~isfield(solinit,'solver')
    solinit.solver = 'bvp4c';  % backwards compatibility
  end
  if nargin < 2 || length(v) < 2
    error(message('MATLAB:bvpinit:NoSolInterval'))
  elseif nargin < 3
    solinit = bvpxtend(solinit,v(1),'solution');
    solinit = bvpxtend(solinit,v(2),'solution');      
  else % pass unknown parameters    
    solinit = bvpxtend(solinit,v(1),'solution',parameters);
    solinit = bvpxtend(solinit,v(2),'solution',parameters);
  end   
  % remove solver-specific information
  switch solinit.solver
    case 'bvp4c'
      solinit = rmfield(solinit,{'yp','solver'}); 
    case 'bvp5c'
      solinit = rmfield(solinit,{'idata','solver'});
  end
  return;
end

% Create a guess structure.
N = length(x);
if x(1) == x(N)
  error(message('MATLAB:bvpinit:XSameEndPts'))    
elseif x(1) < x(N)
  if any(diff(x) < 0)
    error(message('MATLAB:bvpinit:IncreasingXNotMonotonic'))
  end
else  % x(1) > x(N)
  if any(diff(x) > 0)
    error(message('MATLAB:bvpinit:DecreasingXNotMonotonic'))
  end
end

if nargin > 2
  params = parameters;
else
  params = [];
end

extraArgs = varargin;

mbcidx = find(diff(x) == 0);  % locate internal interfaces
ismbvp = ~isempty(mbcidx);  
if ismbvp
  Lidx = [1, mbcidx+1]; 
  Ridx = [mbcidx, length(x)];
end

if isnumeric(v) 
  w = v;
else
  if ismbvp
    w = feval(v,x(1),1,extraArgs{:});   % check region 1, only.
  else
    w = feval(v,x(1),extraArgs{:});
  end
end
[m,n] = size(w);
if m == 1
  L = n;
elseif n == 1
  L = m;
else
  error(message('MATLAB:bvpinit:SolGuessNotVector'))
end

yinit = zeros(L,N);
if isnumeric(v)
  yinit = repmat(v(:),1,N);
else 
  if ismbvp
    for region = 1:length(Lidx)
      for i = Lidx(region):Ridx(region)
        w = feval(v,x(i),region,extraArgs{:});
        yinit(:,i) = w(:);
      end  
    end        
  else  
    yinit(:,1) = w(:);
    for i = 2:N
      w = feval(v,x(i),extraArgs{:});
      yinit(:,i) = w(:);
    end
  end  
end

solinit.solver = 'bvpinit';
solinit.x = x(:)';  % row vector
solinit.y = yinit;
if ~isempty(params)  
  solinit.parameters = params;
end
solinit.yinit = v;   


