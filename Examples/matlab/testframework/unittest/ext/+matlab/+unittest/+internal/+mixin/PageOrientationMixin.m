classdef(Hidden,HandleCompatible) PageOrientationMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % PageOrientation - Character vector that specifies the page orientation of the report
        %
        %   The PageOrientation property specifies the page orientation of the
        %   report and can be set to either 'landscape' or 'portrait'. This
        %   property is read only and can be set only through the constructor.
        PageOrientation = 'portrait';
    end
    
    properties(Constant,Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods(Access=protected)
        function mixin = PageOrientationMixin(varargin)
            import matlab.unittest.internal.mixin.PageOrientationMixin;
            parser = PageOrientationMixin.ArgumentParser;
            parser.parse(varargin{:});
            mixin.PageOrientation = char(parser.Results.PageOrientation);
        end
    end
end

function parser = createArgumentParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('PageOrientation', 'portrait', ...
    @(x) ((ischar(x) && isrow(x)) || (isstring(x) && isscalar(x))) && ...
    ismember(x,{'portrait','landscape'}));
end