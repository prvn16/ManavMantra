function is3daxes = is3DAxes(obj)
% This undocumented function may be removed in a future release.

% Copyright 2015 The MathWorks, Inc.

is3daxes = ishghandle(obj,'axes') && ~isa(obj, 'matlab.graphics.illustration.ColorBar') && ...
      ~isa(obj, 'matlab.graphics.illustration.Legend') && ~is2D(obj);
