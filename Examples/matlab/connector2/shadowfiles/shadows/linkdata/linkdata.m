function varargout = linkdata(varargin)
% Copyright 2011 The MathWorks, Inc.
    
if nargout == 1 && (nargin == 0 || (nargin == 1 && ishghandle(varargin{1})))
    % The only supported syntax is querying a figure's linkdata state,
    % which always returns 'off'.
    if isempty(which('graphics.linkdata'))
        varargout{1} = matlab.graphics.internal.LinkData('off');
    else
        varargout{1} = graphics.linkdata('off');
    end
else

    st = dbstack(1);
    if ~isempty(st)
        % TODO: Remove after linkdata is supported
        for i = 1:numel(st)
            if strcmp(st(i).file, 'hgfeval.m') == 1
                return
            end
        end
    end

    nse = connector.internal.notSupportedError;
    nse.throwAsCaller;
end

