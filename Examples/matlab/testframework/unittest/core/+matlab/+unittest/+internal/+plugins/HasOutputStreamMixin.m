classdef(Hidden) HasOutputStreamMixin < handle
    % This class is undocumented and may change in the future.
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(Dependent, Hidden, GetAccess=protected, SetAccess=immutable)
        OutputStream;
    end
    
    properties(Access=private)
        InternalOutputStream = [];
    end
    
    methods
        function stream = get.OutputStream(mixin)
            import matlab.unittest.plugins.ToStandardOutput;
            stream = mixin.InternalOutputStream;
            if isempty(stream)
                stream = ToStandardOutput;
                mixin.InternalOutputStream = stream;
            end
        end
    end
    
    methods(Hidden, Access=protected)
        function mixin = HasOutputStreamMixin(outputStream)
            if nargin > 0
                validateattributes(outputStream,{'matlab.unittest.plugins.OutputStream'},...
                    {'scalar'},'','OutputStream');
                mixin.InternalOutputStream = outputStream;
            end
        end
    end
end