classdef InteractionHistory < matlab.mixin.Heterogeneous & matlab.mixin.CustomDisplay
    % InteractionHistory - Interface for mock object interaction history.
    %
    %   InteractionHistory is the interface for representing interactions with
    %   mock objects. Interactions include method calls, property
    %   modifications, and property accesses. The framework constructs
    %   instances of the class, so there is no need to construct this class
    %   directly.
    %
    %   InteractionHistory properties:
    %       Name - Method or property name.
    %
    %   InteractionHistory methods:
    %       forMock - Obtain history from a mock object.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable, GetAccess=protected)
        ClassName (1,1) string;
    end
    
    properties (SetAccess=immutable)
        % Name - Method or property name.
        %
        %   The Name property is a string scalar indicating the name of the mock
        %   object method or property involved in the interaction.
        Name (1,1) string;
    end
    
    methods (Static, Sealed)
        function history = forMock(mock)
            % forMock - Obtain history from a mock object.
            %
            %   history = matlab.mock.InteractionHistory.forMock(MOCK) returns an array
            %   of InteractionHistory objects indicating the recorded mock object
            %   interactions. Each element in the array corresponds to one method call,
            %   property access, or property modification. The array elements are
            %   ordered with the first element indicating the first recorded
            %   interaction. This method only returns interactions with
            %   publicly-visible methods and properties.
            
            import matlab.mock.InteractionHistory;
            
            label = builtin("matlab.mock.internal.getLabel", mock);
            if ~isa(label, "matlab.mock.internal.MockObjectRole")
                error(message("MATLAB:mock:InteractionHistory:InputMustBeValidMock"));
            end
            
            catalog = label.InteractionCatalog;
            allInteractions = catalog.getAllVisibleInteractions;
            history = [InteractionHistory.empty(1,0), allInteractions.Value];
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function history = InteractionHistory(className, name)
            history.ClassName = className;
            history.Name = name;
        end
        
        function header = getHeader(history)
            header = getHeader@matlab.mixin.CustomDisplay(history);
        end
        
        function displayNonScalarObject(history)
            displayNonScalarObject@matlab.mixin.CustomDisplay(history);
        end
        
        function groups = getPropertyGroups(history)
            import matlab.mixin.util.PropertyGroup;
            propertyList = history.getPropertyList;
            groups = PropertyGroup(propertyList);
        end
        
        function footer = getFooter(history)
            import matlab.unittest.internal.diagnostics.indent;
            
            if isempty(history)
                footer = '';
                return;
            end
            
            header = string(getString(message("MATLAB:mock:InteractionHistory:InteractionSummary")));
            interactionSummary = join(history.getDisplaySummary, newline);
            footer = header + newline + indent(interactionSummary, "  ") + newline;
            footer = char(footer);
        end
    end
    
    methods (Hidden, Sealed)
        function summary = getDisplaySummary(history)
            summary = arrayfun(@getElementDisplaySummary, history);
            summary = [string.empty(1,0), summary(:).'];
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name'};
        end
    end
    
    methods (Abstract, Hidden, Access=protected)
        summary = getElementDisplaySummary(historyElement);
    end
    
    methods (Abstract, Hidden)
        bool = describedBy(historyElement, behavior);
    end
end

% LocalWords:  unittest
