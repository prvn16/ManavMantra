classdef TableDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented and may change in a future release.
    
    % TableDiagnostic - Diagnostic containing a table.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Table table;
        Header string;
    end
    
    methods
        function diag = TableDiagnostic(aTable, aHeader)
            diag.Table = aTable;
            diag.Header = aHeader;
        end
        
        function diagnose(diag)
            import matlab.unittest.internal.diagnostics.getValueDisplay;
            
            tableDisplay = regexprep(getValueDisplay(diag.Table), '^.*?table[^\r\n]*\n*','');
            diag.DiagnosticText = sprintf('%s\n%s', diag.Header, tableDisplay);
        end
    end
end
