function compareGeneratedCodeToFileCode (currentGeneratedCode, mlappFilePath, originalRelease, currentRelease)
% compares the code in currentGeneratedCode to the code in the mlapp file provided
% by mlappFilePath
%
% Copyright 2017 The MathWorks, Inc.

    import appdesigner.internal.codegeneration.*

    % Build the titles
    [~, name, extension] = fileparts(mlappFilePath);
    titleForOriginalCode = [name,extension,' (',originalRelease,')'];
    titleForCurrentCode = [name,extension,' (',currentRelease,')'];

    originalGeneratedCode = getAppFileCode(mlappFilePath);

    % Create the comparison sources
    s1 = createDiffContent(titleForOriginalCode, originalGeneratedCode);
    s2 = createDiffContent(titleForCurrentCode, currentGeneratedCode );

    % Set up the comparison definition and disable merging
    sel = com.mathworks.comparisons.selection.ComparisonSelection(s1,s2);
    allowMerging = com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging.getInstance();
    sel.setValue(allowMerging, java.lang.Boolean.FALSE)
    sel.setComparisonType(com.mathworks.comparisons.register.type.ComparisonTypeText());

    % Start the comparison
    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(sel);

end

function diffContent = createDiffContent(title, textToCompare)
    diffContent = com.mathworks.comparisons.source.impl.StringSource(title, textToCompare, []);
end
