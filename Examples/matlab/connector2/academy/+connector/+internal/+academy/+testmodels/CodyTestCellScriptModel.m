classdef CodyTestCellScriptModel < connector.internal.academy.testmodels.CodyTestScriptModel
    % The TestCellScriptFileModel is a TestScriptFileModel that describes
    % script based tests that separate tests based on cell markers
    
    %  Copyright 2015 The MathWorks, Inc.
    
    
    properties(Dependent, SetAccess=immutable)
        TestCellNames
        TestCellContent
        ImplicitCellContent
    end

    properties(SetAccess=immutable)
        TestCellExecutionCode = '';
        ImplicitCellExecutionCode = '';
    end
    
    properties(GetAccess=private, SetAccess=immutable)
        TestCellLocations
    end
    
    methods(Static)
        function model = fromString(contents, scriptName, cellLocations)
            model = connector.internal.academy.testmodels.CodyTestCellScriptModel(contents, scriptName, cellLocations);
        end
    end
    
    
    methods

        function content = get.TestCellContent(model)
            
            allCode = textToCellstr(model.FileContents);
            startLines = model.TestCellLocations;
            endLines = [startLines(2:end)-1, numel(allCode)];
            
            numSections = numel(startLines);
            content = cell(numSections,1);
            for idx = 1:numSections
                thisCell = allCode(startLines(idx):endLines(idx));
                content{idx} = cellstrToText(thisCell);
            end
        end
        function names = get.TestCellNames(model)
            import matlab.lang.makeValidName;
            import matlab.lang.makeUniqueStrings;
            
            allCode = textToCellstr(model.FileContents);
            startLineCode = allCode(model.TestCellLocations);            
            startLineCode = regexprep(startLineCode, '^\s*(%{2}|.*)\s*', '');
            names = makeUniqueStrings(makeValidName(startLineCode),{}, namelengthmax);
        end
        function content = get.ImplicitCellContent(model)
            startLines = model.TestCellLocations;
            allCode = textToCellstr(model.FileContents);
            content = cellstrToText(allCode(1:startLines(1)-1));
        end
    end
    
    methods(Access=private)
        function model = CodyTestCellScriptModel(contents, scriptName, testCellLocations)
            model = model@connector.internal.academy.testmodels.CodyTestScriptModel(contents, scriptName);
            model.TestCellLocations = testCellLocations;
        end
    end
    
    
end

function cellstr = textToCellstr(text)
cellstr = strsplit(text, '\n', 'CollapseDelimiters', false)';
end

function text = cellstrToText(cellstr)
text = strjoin(cellstr(:)', '\n');
end

