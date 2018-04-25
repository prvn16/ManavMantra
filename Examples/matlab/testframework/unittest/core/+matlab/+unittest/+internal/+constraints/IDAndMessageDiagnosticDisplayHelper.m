classdef IDAndMessageDiagnosticDisplayHelper < matlab.mixin.CustomDisplay
    properties
        Identifier;
        Message;
    end
    
    methods
        function obj = IDAndMessageDiagnosticDisplayHelper(id, msg)
            obj.Identifier = id;
            
            % We only want to display the first line in the message
            obj.Message = regexprep(msg,'[\n\r].*$','...');
        end
    end
    
    methods(Access=protected)
        function h = getHeader(~)
            h = '';
        end
    end
end