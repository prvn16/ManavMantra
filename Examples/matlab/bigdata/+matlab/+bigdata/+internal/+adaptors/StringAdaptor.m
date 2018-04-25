%StringAdaptor Adaptor for string data.

% Copyright 2017 The MathWorks, Inc.
classdef StringAdaptor < ...
        matlab.bigdata.internal.adaptors.AbstractAdaptor & ...
        matlab.bigdata.internal.adaptors.GeneralArrayParenIndexingMixin & ...
        matlab.bigdata.internal.adaptors.GeneralArrayDisplayMixin

    methods (Access = protected)
        
        function m = buildMetadataImpl(obj)
            m = matlab.bigdata.internal.adaptors.NumericishMetadata(obj.TallSize);
        end
        
    end
    
    methods
        
        function obj = StringAdaptor()
            obj@matlab.bigdata.internal.adaptors.AbstractAdaptor('string');
        end

        function varargout = subsrefBraces(~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:SubsrefBracesNotSupported'));
        end
        function obj = subsasgnBraces(~, ~, ~, ~, ~) %#ok<STOUT>
            error(message('MATLAB:bigdata:array:SubsasgnBracesNotSupported'));
        end
        
        function names = getProperties(~)
            names = cell(0,1);
        end

    end

    methods (Access = protected)
        % Build a sample of the underlying data.
        function sample = buildSampleImpl(~, ~, sz)
            sample = repmat("1", sz);
        end
    end
end
