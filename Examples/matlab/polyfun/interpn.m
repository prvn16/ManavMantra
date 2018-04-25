function Vq = interpn(varargin)
%INTERPN N-D interpolation (table lookup).
%
%   Some features of INTERPN will be removed in a future release.
%   See the R2012a release notes for details.
% 
%   Vq = INTERPN(X1,X2,X3,...,V,X1q,X2q,X3q,...) interpolates to find Vq,
%   the values of the underlying N-D function V at the query points in
%   arrays X1q,X2q,X3q,etc.  For an N-D V, INTERPN should be called with
%   2*N+1 arguments.  Arrays X1,X2,X3,etc. specify the points at which
%   the data V is given.  Out of range values are returned as NaN's.
%   X1q,X2q,X3q,etc. must be arrays of the same size or vectors.  Vector
%   arguments that are not the same size, and have mixed orientations
%   (i.e. with both row and column vectors) are passed through NDGRID to
%   create the X1q,X2q,X3q,etc. arrays.  INTERPN works for all N-D arrays
%   with 2 or more dimensions.
%
%   Vq = INTERPN(V,X1q,X2q,X3q,...) assumes X1=1:SIZE(V,1),X2=1:SIZE(V,2),etc.
%
%   Vq = INTERPN(V,K) returns the interpolated values on a refined grid
%   formed by repeatedly halving the intervals K times in each dimension.
%   This results in 2^K-1 interpolated points between sample values.
%
%   Vq = INTERPN(V) is the same as INTERPN(V,1).
%
%   Vq = INTERPN(...,METHOD) specifies alternate methods.  The default
%   is linear interpolation.  Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - linear interpolation
%     'spline'  - spline interpolation
%     'cubic'   - cubic interpolation as long as the data is uniformly
%                 spaced, otherwise the same as 'spline'
%     'makima'  - modified Akima cubic interpolation
%   
%   Vq = INTERPN(...,METHOD,EXTRAPVAL) specifies a method and a value for
%   Vq outside of the domain created by X1,X2,...  Thus, Vq will equal 
%   EXTRAPVAL for any value of X1q,X2q,.. that is not spanned by X1,X2,...
%   respectively.  A method must be specified for EXTRAPVAL to be used, the
%   default method is 'linear'.
%
%   INTERPN requires that X1,X2,X3,etc. be monotonic and plaid (as if
%   they were created using NDGRID).  X1,X2,X3,etc. can be non-uniformly
%   spaced.
%
%   For example, interpn may be used to interpolate the function:
%      f = @(x,y,z,t) t.*exp(-x.^2 - y.^2 - z.^2);
%
%   Build the lookup table by evaluating the function f on a grid
%   constructed by ndgrid:
%      [x,y,z,t] = ndgrid(-1:0.2:1,-1:0.2:1,-1:0.2:1,0:2:10);
%      v = f(x,y,z,t);
%
%   Construct a finer grid:
%      [xq,yq,zq,tq] = ndgrid(-1:0.05:1,-1:0.08:1,-1:0.05:1,0:0.5:10);
%
%   Interpolate f on the finer grid by using splines:
%      vq = interpn(x,y,z,t,v,xq,yq,zq,tq,'spline');
%
%   And finally, visualize the function:
%      nframes = size(tq, 4);
%      for j = 1:nframes
%         slice(yq(:,:,:,j), xq(:,:,:,j), zq(:,:,:,j), vq(:,:,:,j),0,0,0);
%         caxis([0 10]);
%         M(j) = getframe;
%      end
%      movie(M); 
%
%   Class support for data inputs: 
%      float: double, single
%
%   See also INTERP1, INTERP2, INTERP3, NDGRID,
%            griddedInterpolant, scatteredInterpolant.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin >= 3 && (ischar(varargin{end-1})||(isstring(varargin{end-1}) && isscalar(varargin{end-1}))) && ...
             ~(isnumeric(varargin{end}) && isscalar(varargin{end}))
     error(message('MATLAB:interpn:InvalidExtrapval'))
end

% Parse the method and extrap val
[narg, method, ExtrapVal] = methodandextrapval(varargin{:});
stripNaNsForCubics = strcmpi(method,'spline') || strcmpi(method,'makima');
if stripNaNsForCubics 
    extrap = method;
else
    extrap = 'none';
end
% At this point the options are as follows:
% interpn(V,NTIMES)  => narg == 2
% interpn(V,X1q, X2q, X3q,. . . .)  => narg == ndim(V) + 1
% interpn(X1, X2, X3,. . . V, X1q, X2q, X3q,. . . .) 

if narg == 1 || narg == 2
   %  interp2(V,NTIMES)   
   V = varargin{1};
   sizeofv = size(V);
   ndimsv = ndims(V);
   if narg == 1
       ntimes = 1;
   else
       ntimes = floor(varargin{2}(1));
   end
   
   if ~isscalar(ntimes) || ~isreal(ntimes) 
      error(message('MATLAB:interpn:NtimesInvalid'));
   end
   
   if isvector(V)
       Xq = {(1:1/(2^ntimes):numel(V))};
   else
       Xq = cell(1,ndimsv);
       for i=1:ndimsv
         Xq{i} = (1:1/(2^ntimes):sizeofv(i));
       end
       Xq{2} = Xq{2}'; % Flip orientation to denote compact grid
   end
   
   X = ndgridvectors(V);
   if stripNaNsForCubics
      [X, V] = stripnanwrapper(X,V);
   end
   [V, origvtype] = convertv(V,method, Xq);
   F = griddedInterpolant(X,V,method,extrap);
else
   arg1 = varargin{1};
   ndimsarg1 = ndims(arg1);
   if ~isvector(arg1) && narg == (ndimsarg1+1)
       % interpn(V,X1q,X2q,X3q,...)
       V = varargin{1};
       Xq = varargin(2:narg);
       X = ndgridvectors(V);
       if stripNaNsForCubics
         [X, V] = stripnanwrapper(X,V);
       end
       [V, origvtype] = convertv(V,method, Xq);
       F = griddedInterpolant(X,V,method,extrap);
   elseif rem(narg,2) == 1
       % interpn(X1,X2,X3, ... V,X1q,X2q,X3q, ...) 
       mididx = ceil(narg/2);
       X = varargin(1:(mididx-1));
       V = varargin{mididx};
       Xq = varargin((mididx+1):narg);
       [V, origvtype] = convertv(V,method, Xq);
       if stripNaNsForCubics
         [X,V] = stripnanwrapper(X,V);
       end
       [X, V] = checkmonotonic(X{:},V);
       if all(cellfun(@isvector,X))
           F = griddedInterpolant(X, V, method,extrap);
       else
           F = griddedInterpolant(X{:}, V, method,extrap);
       end
   else
        error(message('MATLAB:interpn:nargin'));
   end
end

if strcmpi(method,'cubic') && strcmpi(F.Method,'spline')
    % Uniformity condition not met
   gv = F.GridVectors;
   gv = gv.';
   FV = F.Values;
   [X, V] = stripnanwrapper(gv,FV);
   F = griddedInterpolant(X,V,'spline');
end


% Now interpolate
scopedWarnOff = warning('off', 'MATLAB:griddedInterpolant:MeshgridEval2DWarnId');
restoreWarnOff = onCleanup(@()warning(scopedWarnOff));
iscompact = compactgridformat(Xq{:});
if iscompact || (strcmpi(F.Method,'spline') && isscalar(Xq{1}))
    Vq = F(Xq);
    if numel(Xq) == 1 
        if isrow(Xq{1})
            Vq = Vq.';
        end
    end     
else
    Vq = F(Xq{:});
end

if ~isempty(ExtrapVal)
% If ExtrapVal is provided, impose the extrapolation value to the queries
% that lie outside the domain.
  Vq = imposeextrapval(Xq, F.GridVectors, Vq, ExtrapVal,iscompact); 
end

if ~strcmp(origvtype,'double') && ~strcmp(origvtype,'single')
    Vq = cast(Vq,origvtype);
end

function [X, V] = stripnanwrapper(X,V)
    numvbefore = numel(V);
    if isvector(V)
         ndimsbefore = 1;
    else
         ndimsbefore = ndims(V);
    end
    [X, V] = stripnansforspline(X{:},V);
    numvafter = numel(V);
    if numvbefore > numvafter
        warning(message('MATLAB:interpn:NaNstrip'));
    end
    
    if isempty(V)
        ndimsafter = 0;     
    elseif isvector(V)
        ndimsafter = 1;
    else
        ndimsafter = ndims(V);
    end  
    
    if ndimsbefore > ndimsafter
         error(message('MATLAB:interpn:NotEnoughPointsNanStrip'));
    end
end

function [V, origvtype] = convertv(V,method, Xq)
    origvtype = class(V);
    if isfloat(V)
        return
    end
    if (strcmpi(method,'nearest'))
        V = double(V);
    else
        allscalar = true;
        for j = 1:numel(Xq)
           if ~isscalar(Xq{j})
              allscalar = false;
           end
        end
        if allscalar
            V = double(V);
        end
    end
end    
    
end
