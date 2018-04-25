function cgprechecks(x, num_cgargs, cg_options)
%CGPRECHECKS  Sanity checks for the Computational Geometry commands.
% The checks are applied to DELAUNAY, VORONOI, CONVHULL

% Copyright 1984-2017 The MathWorks, Inc.

if num_cgargs < 1
    error(message('MATLAB:cgprechecks:NotEnoughInputs'));
end

if ( num_cgargs > 1 && ~isempty(cg_options) )
    if ~iscellstr(cg_options) && ~isstring(cg_options)
        error(message('MATLAB:cgprechecks:OptsNotStringCell'));
    end
end

if ~isnumeric(x)
    error(message('MATLAB:cgprechecks:NonNumericInput'));
end

if issparse(x)
    error(message('MATLAB:cgprechecks:Sparse'));
end

if ~isreal(x)
    error(message('MATLAB:cgprechecks:Complex'));
end
 
if any(isinf(x(:)) | isnan(x(:)))
  error(message('MATLAB:cgprechecks:CannotAcceptInfOrNaN'));
end

if ndims(x) > 2
    error(message('MATLAB:cgprechecks:NonTwoDInput'));
end

[m,n] = size(x);

if m < n+1
  error(message('MATLAB:cgprechecks:NotEnoughPts'));
end
