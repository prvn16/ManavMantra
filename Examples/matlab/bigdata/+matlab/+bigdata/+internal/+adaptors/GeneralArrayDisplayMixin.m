%GeneralArrayDisplayMixin Provides displayImpl for general array types.

%   Copyright 2016 The MathWorks, Inc.

classdef GeneralArrayDisplayMixin
    methods
        function displayImpl(~, context, ~)
            doDisplay(context);
        end
    end
end
