classdef (Hidden) EditorUtils
    %EDITORUTILS Static utility methods for matlab.desktop.editor functions
    %
    %   This function is unsupported and might change or be removed without
    %   notice in a future version.
    
    % These are utility functions to be used by matlab.desktop.editor
    % functions and are not meant to be called by users directly.
    
    % Copyright 2009-2011 The MathWorks, Inc.
    
    methods (Access = private)
        function obj = EditorUtils
            obj = [];
        end
    end
    
    methods (Static)
        function storageLocation = fileNameToStorageLocation(filename)
            %fileNameToStorageLocation Convert string file name to StorageLocation object.
            storageLocation = com.mathworks.widgets.datamodel.FileStorageLocation(filename);
        end
        
        function jea = getJavaEditorApplication
            %getJavaEditorApplication Return Java Editor application.
            jea = com.mathworks.mlservices.MLEditorServices.getEditorApplication;
        end
        
        function assertOpen(obj, variablename)
            %assertOpen Throw error if Editor Document is not open.
            try                
                assert(isa(obj, 'matlab.desktop.editor.Document'), ...
                    message('MATLAB:Editor:Document:InvalidDocumentInput', variablename));
                assert(~isempty(obj) && all([obj.Opened]), ...
                    message('MATLAB:Editor:Document:EditorClosed'));
            catch ex
                throwAsCaller(ex);
            end
        end
        
        function assertScalar(obj)
            %assertScalar Throw error for non-scalar input.
            try              
                assert(ischar(obj) || numel(obj) <= 1, ...
                    message('MATLAB:Editor:Document:NonScalarInput'));
            catch ex
                throwAsCaller(ex);
            end
        end
        
        function assertChar(obj, variablename)
            try
                assert(ischar(obj), ...
                    message('MATLAB:Editor:Document:NonStringInput', variablename));
            catch ex
                throwAsCaller(ex);
            end
        end
        
        function assertNumericScalar(input, variablename)
            try
                assert(isnumeric(input) && isscalar(input) && ~isnan(input), ...
                    message('MATLAB:Editor:Document:NonNumericScalarInput', variablename));
            catch ex
                throwAsCaller(ex);
            end
        end

        function assertLessEqualInt32Max(input, variablename)
            %assertLessEqualInt32Max Throw error if the input is greater than maximum of 32-bit integer.
            try
                assert(isnumeric(input) && isscalar(input) && ~isnan(input) && input <= intmax('int32'), ...
                    message('MATLAB:Editor:Document:Invalid32BitInteger', variablename));
            catch ex
                throwAsCaller(ex);
            end
        end
        
        cellArray = javaCollectionToArray(javaCollection)
    end
end

