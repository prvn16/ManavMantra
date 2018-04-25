function checks = codeAnalyzerChecks()
%codeAnalyzerChecks gets a table of checks used by the Code Compatibility Report.

%   Copyright 2017 The MathWorks, Inc.

    caChecks = builtin('_getCodeAnalyzerChecks');
    allChecks = struct2table(caChecks);

    % Get deprecation checks.
    findDep = @(x)(strcmpi(x,'COMPAT') | strcmpi(x,'OLDAPI'));
    indexDepChecks = findDep(allChecks.CategoryIdentifier);
    depChecks = allChecks(indexDepChecks, :);

    % Get incomplete analysis errors, tree creation errors, and syntax errors.
    findChecks = @(x)(strcmpi(x,'INTRN') | strcmpi(x,'TREECREATE') | strcmpi(x,'SYNTAX'));
    indexInternalChecks = findChecks(allChecks.CategoryIdentifier);
    activeChecks = allChecks(indexInternalChecks, :);

    % Create complete list of active checks.
    activeChecks = [activeChecks; depChecks];

    % Get documentation commands for checks
    docColumn = matlab.internal.codecompatibilityreport.documentationColumn(activeChecks.MessageIdentifier);

    columnNames = {'Identifier','Description','Documentation','Severity','CategoryIdentifier','CategoryDescription'};
    checks = table( categorical(activeChecks{:,'MessageIdentifier'}), ...
                    string(activeChecks{:,'MessageDescription'}), ...
                    docColumn, ...
                    categorical(activeChecks{:,'Severity'}), ...
                    categorical(activeChecks{:,'CategoryIdentifier'}), ...
                    string(activeChecks{:,'CategoryDescription'}), ...
                    'VariableNames', columnNames);
end
