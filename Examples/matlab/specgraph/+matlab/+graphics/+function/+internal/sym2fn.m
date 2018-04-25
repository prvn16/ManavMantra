function fn = sym2fn(sf,varargin)
  % internal helper function

  % Convert sym input to a function that first tries evaluating in MATLAB (for speed),
  % falling back to symbolic evaluation if needed. Take care to also work for constants.

  % Copyright 2015 The MathWorks, Inc.
  if nargin > 1
    vars = [varargin{:}];
    while any(strcmp(vars,'~'))
      vars{find(strcmp(vars,'~'),1)} = mupadmex('genident()',0);
    end
    var_f = sym(vars);
  else
    var_f = symvar(sf,2);
  end
  if isempty(var_f)
    var_f = sym('x');
  end

  f2 = feval(symengine,'symobj::unapplyPlotFunction',sf,var_f);
  try
    if isempty(symvar(sf))
      f1 = @(x,~) ones(size(x))*double(sf);
    else
      state1 = warning('off','symbolic:generate:FunctionNotVerifiedToBeValid');
      state2 = warning('off','symbolic:generate:IndefiniteIntegral');
      tmp = onCleanup(@() [warning(state2), warning(state1)]);
      f1 = matlabFunction(sf,'Vars',var_f);
    end
    fn = @(varargin) tryBoth(f1,f2,varargin{:});
  catch ME
    if strcmp(ME.identifier,'symbolic:generate:UnitsMustBeConsistent')
      rethrow(ME)
    end
    fn = @(varargin) double(feval(symengine,'symobj::evalForPlot',f2,varargin{:}));
  end
  % make sure the function is vectorized
  try
    switch numel(var_f)
    case 1
      fnX = fn(1:3);
      good = isequaln(fnX, [fn(1), fn(2), fn(3)]);
    case 2
      fnX = fn(1:3,4:6);
      good = isequaln(fnX, [fn(1,4), fn(2,5), fn(3,6)]);
    case 3
      fnX = fn(1:3,4:6,7:9);
      good = isequaln(fnX, [fn(1,4,7), fn(2,5,8), fn(3,6,9)]);
    end
  catch
    good = false;
  end
  if ~good
    fn = @(varargin) arrayfun(fn,varargin{:});
  end
end

% helper to first try calling matlabFunction-generated code, falling back on symengine-evaluation
function y = tryBoth(f1, f2, varargin)
  try
    y = double(feval(f1,varargin{:}));
  catch
    y = double(feval(symengine,'symobj::evalForPlot',f2,varargin{:}));
  end
end
