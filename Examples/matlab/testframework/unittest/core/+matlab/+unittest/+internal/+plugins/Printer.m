classdef(Hidden) Printer
    %This class is undocumented.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        OutputStream
    end
    
    methods
        function printer = Printer(outputStream)
            if nargin < 1
                outputStream = matlab.unittest.plugins.ToStandardOutput;
            else
                validateattributes(outputStream,{'matlab.unittest.plugins.OutputStream'},...
                    {'scalar'},'','OutputStream');
            end
            printer.OutputStream = outputStream;
        end
    end
    
    methods(Sealed)
        function print(printer, varargin)
            printer.OutputStream.print(varargin{:});
        end
        
        function printFormatted(printer, formattableStr)
            printer.OutputStream.printFormatted(formattableStr);
        end
    end
end

% LocalWords:  formattable
