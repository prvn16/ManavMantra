classdef TAPOriginalFormatPlugin < matlab.unittest.internal.plugins.tap.InternalTAPPlugin
    %
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPOriginalFormatPlugin(outputStream, includingPassingDiagnostics, verbosity, excludingLoggedDiagnostics)
            plugin@matlab.unittest.internal.plugins.tap.InternalTAPPlugin(outputStream, includingPassingDiagnostics, verbosity, excludingLoggedDiagnostics)
        end
        
    end
    
    methods(Access=protected)
        function printFormattedDiagnostics(plugin, eventRecords)
            import matlab.unittest.internal.plugins.tap.TAPVersion12Formatter;
            import matlab.unittest.internal.diagnostics.FormattableString;
            
            reports = arrayfun(@(r)r.getFormattedReport(TAPVersion12Formatter), ...
                eventRecords, 'UniformOutput', false);
            report = join([FormattableString.empty, reports{:}], newline);
            
            plugin.Printer.printFormatted(appendNewlineIfNonempty(indent(report,'# ')));
        end
    end
end

% LocalWords:  Formattable