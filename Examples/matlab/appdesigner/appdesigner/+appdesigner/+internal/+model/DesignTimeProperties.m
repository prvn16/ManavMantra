classdef DesignTimeProperties < handle
    %DESIGNTIMEPROPERTIES This is a class that handles
    % AppDesigner specific design time properties for the component,
    % such as generating code, CodeName or GroupId.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        % AppDesigner specific design time properties for the
        % component
        % CodeName of the component
        CodeName = '';
        
        % GroupId of the component belongs to
        GroupId = '';
        
        % AppDesigner specific design time properties for the
        % component code generation
        ComponentCode = {};
    end

end