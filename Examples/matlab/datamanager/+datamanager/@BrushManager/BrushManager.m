classdef BrushManager < handle
    
   % Copyright 2016 The MathWorks, Inc.
    properties
        SelectionTable
        VariableNames
        DebugMFiles
        DebugFunctionNames
        ArrayEditorVariables
        ArrayEditorSubStrings
        UndoData
        ApplicationData
        FactoryValue = false
    end
    
    methods (Access = private)
        function h = BrushManager()
        end
        
    end
    methods (Static)
        function h = getInstance()
            % Brushmanager is a singleton
            mlock
            persistent bManager;
            if isempty(bManager)
                bManager = datamanager.BrushManager();
                com.mathworks.page.datamgr.brushing.ArrayEditorManager.addArrayEditorListener;
            end
            h = bManager;
        end
    end    
end


