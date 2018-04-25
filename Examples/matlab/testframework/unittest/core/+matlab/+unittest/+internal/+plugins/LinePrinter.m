classdef(Hidden) LinePrinter < matlab.unittest.internal.plugins.Printer
    %This class is undocumented.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    methods
        function printer = LinePrinter(varargin)
            printer = printer@matlab.unittest.internal.plugins.Printer(varargin{:});
        end
    end
    
    methods(Sealed)
        function printEmptyLine(printer)
            printer.printLine('');
        end
        
        function printLine(printer, str)
            if ischar(str)
                printer.print('%s\n', str);
            else
                printer.printFormatted(sprintf('%s\n', str));
            end
        end
        
        function printIndentedLine(printer, str, varargin)
            import matlab.unittest.internal.diagnostics.indent;
            
            if ischar(str)
                str = indent(str, varargin{:});
            else
                str = str.indent(varargin{:});
            end
            
            printer.printLine(str);
        end
    end
end
