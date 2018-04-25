classdef AlertDiagnosticDisplayHelper < matlab.mixin.CustomDisplay & ...
                                        matlab.unittest.internal.constraints.IDAndMessageDiagnosticDisplayHelper
    properties
        Arguments;
    end
    
    methods
        function obj = AlertDiagnosticDisplayHelper(id, msg, args)
            obj = obj@matlab.unittest.internal.constraints.IDAndMessageDiagnosticDisplayHelper(id, msg);
            obj.Arguments = args;
        end
    end
end