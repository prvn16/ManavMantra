classdef (Hidden,HandleCompatible) CoverageFormatMixin < matlab.unittest.internal.mixin.NameValueMixin
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties (Hidden,GetAccess = protected, SetAccess=private)
        % Format - a matlab.unittest.plugins.codecoverage.CoverageFormat instance.
        % Stores code coverage report format.
        Format matlab.unittest.plugins.codecoverage.CoverageFormat
    end
    methods (Hidden, Access=protected)
        function mixin = CoverageFormatMixin()
            mixin = mixin.addNameValue('Producing',@setFormat);
        end
    end
end
function mixin = setFormat(mixin, theFormat)
validateattributes(theFormat,{'matlab.unittest.plugins.codecoverage.CoverageFormat'},...
    {'row','nonempty'},'','CoverageFormat');
mixin.Format = theFormat;
end

