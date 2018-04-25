function varargout=propedit(varargin)

% Copyright 2012 The MathWorks, Inc.

st = dbstack(1);
if ~isempty(st)
    % TODO: Remove after plotinspector is supported
    for i = 1:numel(st)
        if strcmp(st(i).file, 'hgfeval.m') == 1
            return
        end
    end
end

nse = connector.internal.notSupportedError;
nse.throwAsCaller;