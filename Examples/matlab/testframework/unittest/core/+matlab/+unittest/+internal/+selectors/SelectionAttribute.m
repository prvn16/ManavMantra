classdef SelectionAttribute < matlab.mixin.Heterogeneous
    % SelectionAttribute - Visitor interface for TestSuite selection attributes.
    %   By default, the result of visiting an attribute (i.e., calling an
    %   "accepts" method) is true (select). Each Visitor subclass can
    %   override one of the "accepts" methods to define its notion of what
    %   visiting that attribute means.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Data
    end
    
    methods (Access=protected)
        function attribute = SelectionAttribute(data)
            attribute.Data = data;
        end
    end
    
    methods
        function result = acceptsBaseFolder(~,~)
            result = true;
        end
        
        function result = acceptsName(~,~)
            result = true;
        end
        
        function result = acceptsParameter(~,~)
            result = true;
        end
        
        function result = acceptsSharedTestFixture(~,~)
            result = true;
        end
        
        function result = acceptsTag(~,~)
            result = true;
        end
        
        function result = acceptsProcedureName(~,~)
            result = true;
        end
        
        function result = acceptsSuperclass(~,~)
            result = true;
        end
    end
end