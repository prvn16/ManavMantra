classdef (Hidden) LiveEditorUtilities
    % LiveEditorUtilities - utilities for Live Editor
    
    methods (Static)        
        executionTime = execute(javaRichDocument, fileName)
        [javaRichDocument, cleanupObj, browserObj] = open(fileName, reuse)        
        [javaRichDocument, cleanupObj, executionTime] = openAndExecute(fileName)
        fileName = resolveFileName(fileName)
        save(javaRichDocument, fileName)        
        saveas(javaRichDocument, fileName, varargin)
        [javaRichDocument, webWindow] = createDocument()
    end
    
end