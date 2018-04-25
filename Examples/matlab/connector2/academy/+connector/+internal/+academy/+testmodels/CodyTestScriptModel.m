classdef CodyTestScriptModel
    % The TestScriptFileModel utilizes static analysis in order to retrieve
    % the test content contained inside test code sections.
    
    %  Copyright 2015 The MathWorks, Inc.
    
    properties(SetAccess = immutable)
        FileContents
        Name
    end

    properties(Dependent, SetAccess=immutable)
        ScriptName
    end

    methods(Static)
        
        function tf = isScript(tree)
            tf = false;
            
            % files with parse errors are not test scripts
            if tree.anykind('ERR')
                return;
            end
            
            % classes aren't scripts
            if tree.anykind('CLASSDEF')
                return
            end
            
            %functions aren't scripts
            if tree.anykind('FUNCTION')
                return
            end
            
            tf = true;
            
        end
        
        
        function model = fromString(contents, scriptName)
            import connector.internal.academy.testmodels.CodyTestScriptModel;
            import connector.internal.academy.testmodels.CodyNoTestCellScriptModel;
            import connector.internal.academy.testmodels.CodyTestCellScriptModel;
            
            parseTree = mtree(contents, '-cell');
            testCellLocations = CodyTestScriptModel.locateCodeSections(parseTree);
            if isempty(testCellLocations)
                model = CodyNoTestCellScriptModel.fromString(contents, scriptName);
            else
                model = CodyTestCellScriptModel.fromString(contents, scriptName, testCellLocations);
            end
            
        end
        function locations = locateCodeSections(parseTree)
            
            locations = []; 
            if parseTree.isnull
                return;
            end
            
            thisNode = parseTree.select(1);
            while ~isempty(thisNode)
                if (thisNode.iskind('CELLMARK'))
                    line = thisNode.lineno;
                    locations = [locations, line]; %#ok<AGROW>
                end
                thisNode = thisNode.Next;
            end
        end 
    end
    
    methods
        
        function model = CodyTestScriptModel(contents, scriptName)
            model.FileContents = contents;
            model.Name         = scriptName;
        end   
        
        function scriptName = get.ScriptName(model)
            scriptName = model.Name;
        end        
    end
    
    
end
