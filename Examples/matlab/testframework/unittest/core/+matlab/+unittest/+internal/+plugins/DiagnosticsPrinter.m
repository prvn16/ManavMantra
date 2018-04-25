classdef(Hidden) DiagnosticsPrinter < matlab.unittest.internal.plugins.LinePrinter
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access=private)
        DiagnosticCatalog = matlab.internal.Catalog('MATLAB:unittest:Diagnostic');
        QualificationDelimiter = repmat('=',1,80);
        MaxVerbosityNameLength = getMaxVerbosityNameLength();
    end
    
    methods
        function diagnosticsPrinter = DiagnosticsPrinter(varargin)
            diagnosticsPrinter = diagnosticsPrinter@matlab.unittest.internal.plugins.LinePrinter(varargin{:});
        end
    end
    
    methods(Sealed)
        function printQualificationReport(printer, testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings,headerMessage, stack)
            import matlab.unittest.internal.diagnostics.BoldableString;
            
            printer.printLine(printer.QualificationDelimiter);
            
            printer.printLine(BoldableString(headerMessage));
            
            % Print Core Diagnostics
            printer.printCoreDiagnostics(testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings);
            
            % Print Stack
            printer.printStackInfo(printer.DiagnosticCatalog.getString('StackInformationHeader'), stack);
            
            printer.printLine(printer.QualificationDelimiter);
        end
        
        function printAssumptionFailure(printer, testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings, summaryHeaderMessage, detailsHeaderMessage, stack)
            import matlab.unittest.internal.plugins.LoggingStream;
            import matlab.unittest.internal.plugins.DiagnosticsPrinter;
            import matlab.unittest.internal.diagnostics.createCommandWindowHyperlink;
            import matlab.unittest.internal.diagnostics.AlternativeRichString;
            import matlab.unittest.internal.diagnostics.MessageString;
            
            printer.printLine(printer.QualificationDelimiter);
            
            printer.printLine(summaryHeaderMessage);
            
            % Print the first user diagnostic, if any, with an inline header
            if ~isempty(testDiagnosticStrings)
                printer.printIndentedLine(MessageString('MATLAB:unittest:Diagnostic:TestDiagnostic', testDiagnosticStrings(1)));
            end
            
            % Print details link
            detailsStream = LoggingStream;
            diagnosticPrinterForDetails = DiagnosticsPrinter(detailsStream);
            diagnosticPrinterForDetails.printAssumptionDetailsLink(testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings,detailsHeaderMessage, stack);
            richLog = enrich(detailsStream.FormattableLog);
            link = sprintf('%s\n', createCommandWindowHyperlink(char(richLog.Text), ...
                printer.DiagnosticCatalog.getString('AssumptionFailureDetails')));
            details = AlternativeRichString('', link);
            printer.printFormatted(details);
            
            printer.printLine(printer.QualificationDelimiter);
        end
        
        function printUncaughtException(printer, headerMessage, id, exceptionReport,additionalDiagnosticStrings)
            import matlab.unittest.internal.diagnostics.BoldableString;
            
            printer.printLine(printer.QualificationDelimiter);
            
            printer.printLine(BoldableString(headerMessage));
            printer.printEmptyLine;
            
            printer.printIndentedLine(getHeaderWithDashes(printer.DiagnosticCatalog.getString('ErrorIDHeader')));
            printer.printIndentedLine(sprintf('''%s''', id));
            printer.printEmptyLine;
            
            printer.printIndentedLine(getHeaderWithDashes(printer.DiagnosticCatalog.getString('ErrorHeader')));
            printer.printIndentedLine(exceptionReport);
            
            additionalDiagnosticHeader = printer.DiagnosticCatalog.getString('AdditionalDiagnosticHeader');
            printer.printDiagnosticResults(additionalDiagnosticHeader, additionalDiagnosticStrings);
            
            printer.printLine(printer.QualificationDelimiter);
        end
        
        function printLoggedDiagnostics(printer, diagnosticStrings, verbosity, description, hideTimestamp, timestamp, hideLevel, numStackFrames, stack)
            numDiags = numel(diagnosticStrings);
            
            printer.print('%s%s%s%s%s', ...
                printer.getVerbosityString(verbosity, hideLevel), ...
                description, ...
                printer.getDescriptionTimestampSpace(description, hideTimestamp), ...
                printer.getTimestampString(hideTimestamp, timestamp), ...
                printer.getDescriptionTimestampColon(description, hideTimestamp));
            
            % When there is more than one Diagnostic, each one (including
            % the first) goes on its own line. We also insert a newline
            % when the first diagnostic extends to multiple lines. Assume
            % that enriching the string doesn't change the number of
            % newlines present.
            needNewline = false;
            if numDiags > 0
                needNewline = numDiags > 1 || ...
                    contains(char(diagnosticStrings(1)), newline);
            end
            
            if needNewline
                printer.printEmptyLine;
            end
            
            % Print the actual logged diagnostic(s)
            for idx = 1:numDiags
                printer.printLine(diagnosticStrings(idx));
            end
            
            if numStackFrames > 0
                printer.printLogStack(stack, numStackFrames);
            end
            
            % Also print a newline at the end of the multi-line message.
            % This helps set the logged diagnostics apart from other text.
            if needNewline
                printer.printEmptyLine;
            end
        end
    end
        
    methods(Access=protected)
        function printCoreDiagnostics(printer, testDiagnosticStrings, frameworkDiagnosticStrings,additionalDiagnosticStrings)
            testDiagnosticHeader = printer.DiagnosticCatalog.getString('TestDiagnosticHeader');
            frameworkDiagnosticHeader = printer.DiagnosticCatalog.getString('FrameworkDiagnosticHeader');
            additionalDiagnosticHeader = printer.DiagnosticCatalog.getString('AdditionalDiagnosticHeader');
            
            printer.printDiagnosticResults(testDiagnosticHeader, testDiagnosticStrings);
            printer.printDiagnosticResults(frameworkDiagnosticHeader, frameworkDiagnosticStrings);
            printer.printDiagnosticResults( additionalDiagnosticHeader, additionalDiagnosticStrings);    
        end
        
        function printAssumptionDetailsLink(printer, testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings, detailsHeaderMessage, stack)
            import matlab.unittest.internal.diagnostics.BoldableString;
            
            printer.printEmptyLine();
            printer.printLine(printer.QualificationDelimiter);
            
            printer.printLine(BoldableString(detailsHeaderMessage));
            
            printer.printCoreDiagnostics(testDiagnosticStrings, frameworkDiagnosticStrings, additionalDiagnosticStrings);
            
            printer.printStackInfo(printer.DiagnosticCatalog.getString('StackInformationHeader'), stack);
            
            printer.printLine(printer.QualificationDelimiter);
            printer.printEmptyLine();
        end
        
        function printDiagnosticResults(printer, header, diagnosticStrings)
            for idx = 1:numel(diagnosticStrings)
                if strlength(diagnosticStrings(idx).Text) ~= 0
                    formattableString = diagnosticStrings(idx);
                    printer.printEmptyLine;
                    printer.printIndentedLine(getHeaderWithDashes(header));
                    printer.printIndentedLine(formattableString);
                end
            end
        end
        
        function printStackInfo(printer, headerText, stack)    
            import matlab.unittest.internal.diagnostics.createStackInfo;
            
            if isempty(stack)
                return;
            end
            
            printer.printEmptyLine;
            printer.printIndentedLine(getHeaderWithDashes(headerText));
            printer.printIndentedLine(createStackInfo(stack));
        end
        
        function str = getVerbosityString(printer, verbosity, hideLevel)
            if hideLevel
                str = '';
            else
                verbosity = matlab.unittest.Verbosity(verbosity);
                verbosityString = char(verbosity);
                padding = repmat(' ', 1, printer.MaxVerbosityNameLength - numel(verbosityString));
                str = sprintf('%s[%s] ', padding, verbosityString);
            end
        end
        
        function str = getDescriptionTimestampSpace(~, description, hideTimestamp)
            if isempty(description) || hideTimestamp
                str = '';
            else
                str = ' ';
            end
        end
        
        function str = getTimestampString(~, hideTimestamp, timestamp)
            if hideTimestamp
                str = '';
            else
                str = sprintf('(%s)', datestr(timestamp, 'yyyy-mm-ddTHH:MM:SS'));
            end
        end
        
        function str = getDescriptionTimestampColon(~, description, hideTimestamp)
            if isempty(description) && hideTimestamp
                str = '';
            else
                str = ': ';
            end
        end
        
        function printLogStack(printer, stack, numStackFrames)
            import matlab.unittest.internal.diagnostics.createStackInfo;
            
            if isempty(stack)
                return;
            end
            
            % Print the header
            catalog = matlab.internal.Catalog('MATLAB:unittest:LoggingPlugin');
            printer.printIndentedLine(catalog.getString('StackInformation'));
            
            % Starting from the top of the stack, print as many frames as
            % requested, up to the total number of stack frames present.
            stack = stack(1:min(end,numStackFrames));
            printer.printIndentedLine(createStackInfo(stack));
        end
    end
end

function str = getHeaderWithDashes(header)
import matlab.unittest.internal.diagnostics.wrapHeader;
validateattributes(header, {'char'}, {'2d'}, '', 'inputString');
str = wrapHeader(header);
end

function len = getMaxVerbosityNameLength()
[~, strs] = enumeration('matlab.unittest.Verbosity');
len = size(char(strs), 2);
end

% LocalWords:  yyyy THH strs Diags Boldable Formattable
