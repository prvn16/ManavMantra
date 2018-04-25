function args = gatherIfNecessary(varargin)
%gatherIfNecessary  Conditionally gather data from gpuArray.
%   [...] = gatherIfNecessary(...) gathers GPU data as necessary from an
%   arbitrary number of inputs.  Input values that were not on the GPU are
%   returned unchanged.

%   Copyright 2012 The MathWorks, Inc.

args = cellfun( @gather, varargin, 'UniformOutput', false );

end
