classdef DisplayFormat
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for sprintf display format
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        FormatSpec;
    end
    
    methods
        function this = DisplayFormat(v)
            % superset of formatSpec for printf functions
            printSpec = '%(\d+\$)?[-+\s0#]?(\d+|\*)?(\.\d+)?[bt]?[diuoxfegcs]';
            
            % superset of formatSpec for scanf functions
            scanSpec = '%\*?\d*l?([diuoxfegcs]|\[\S*\])';
            
            if size(v, 1) == 1 && (ischar(v) || isstring(v)) ...
                && any(regexpi(v, [printSpec '|' scanSpec]))
                this.FormatSpec = v;
            else
                if ~strcmp(v, '1')
                    error(struct('identifier', 'DisplayFormat:Invalid', ...
                        'message', ['Invalid format specification: ' v]));
                end
            end
        end
        
        function v = getFormat(this)
            v = this.FormatSpec;
        end
    end
end
