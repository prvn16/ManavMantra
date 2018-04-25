function x=initialMesh(~,xlims,gran,scale)
% This internal function is subject to change without notice

%initialMesh  Distribute points evenly along axis, taking into account log scaling

% Copyright 2017 The MathWorks, Inc.
  if strcmp(scale,'log')
    x = real(logspace(log10(xlims(1)), log10(xlims(2)), gran));
  else
    x = linspace(xlims(1), xlims(2), gran);
  end
end
