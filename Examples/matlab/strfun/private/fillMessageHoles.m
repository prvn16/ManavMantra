function me = fillMessageHoles(errorID, varargin)
    for i=1:numel(varargin)
        if ischar(varargin{i}) || isstring(varargin{i}) && isscalar(varargin{i})
            varargin{i} = getString(message(varargin{i}));
        end
    end
    me = message(errorID, varargin{:});
end