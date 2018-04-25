classdef(Sealed) TAPVersion13Plugin < matlab.unittest.internal.plugins.tap.InternalTAPPlugin
    %
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPVersion13Plugin(outputStream, includingPassingDiagnostics, verbosity, excludingLoggedDiagnostics)
            plugin@matlab.unittest.internal.plugins.tap.InternalTAPPlugin(outputStream, includingPassingDiagnostics, verbosity, excludingLoggedDiagnostics)
        end
    end
    
    properties(Access=private, Constant)
        HeaderCatalog = matlab.internal.Catalog('MATLAB:unittest:TAPVersion13YAMLDiagnostic');
    end
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.plugins.LinePrinter;
            plugin.Printer = LinePrinter(plugin.OutputStream);
            
            plugin.Printer.printLine('TAP version 13');
            runTestSuite@matlab.unittest.internal.plugins.tap.InternalTAPPlugin(plugin, pluginData);
        end
    end
    
    methods (Hidden, Access=protected)
        function printFormattedDiagnostics(plugin, eventRecords)
            if isempty(eventRecords)
                return;
            end
            
            plugin.printIndentedLine('---');
            if numel(eventRecords) == 1
                plugin.printSingleEventRecord(eventRecords);
            else
                plugin.printMultipleEventRecords(eventRecords);
            end
            plugin.printIndentedLine('...');
        end
    end
    
    methods(Access=private)
        function printSingleEventRecord(plugin, eventRecord)
            eventHeader = plugin.HeaderCatalog.getString('EventHeader');
            plugin.printIndentedLine(eventHeader);
            plugin.printDetailsOfEventRecord(eventRecord);
        end
        
        function printMultipleEventRecords(plugin, eventRecords)
            for k = 1:numel(eventRecords)
                eventHeader = plugin.HeaderCatalog.getString('NumberedEventHeader', k);
                plugin.printIndentedLine(sprintf('%s', eventHeader));
                plugin.printDetailsOfEventRecord(eventRecords(k));
            end
        end
        
        function printDetailsOfEventRecord(plugin, eventRecord)
            formatter = matlab.unittest.internal.plugins.tap.TAPVersion13Formatter;
            str = eventRecord.getFormattedReport(formatter);
            indention = '        ';
            plugin.Printer.printFormatted(appendNewlineIfNonempty(indent(str, indention)));
        end
        
        function printIndentedLine(plugin, varargin)
            plugin.Printer.printIndentedLine(varargin{:});
        end
    end
end

% LocalWords:  YAML formatter