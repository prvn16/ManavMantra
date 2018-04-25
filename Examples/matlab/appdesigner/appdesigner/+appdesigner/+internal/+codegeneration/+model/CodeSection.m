classdef CodeSection < handle
           
    %CodeSection a class to hold a particular section of code  (e.g.  the
    %editable section of user-defined properties and functions
    
    % Copyright 2015 The MathWorks, Inc.

    properties    
        % a cell array of strings of the code content
        Code
    end
    
    properties
        %  properties in this block are required for 16a apps only but must be
        %  set appropriately in each release to support forwards
        %  compatibility of opening newer apps in 16a
        
        % determines whether this section of code exists in the app file.
        Exist = false;
        
        % the type of code being saved (e.g. 'EditableSection')
        Type
    end
    
    methods
        
        function obj = CodeSection(type, code)
            % constructor
            obj.Type = type;
            obj.Code = code;
        end
        
    end
end

