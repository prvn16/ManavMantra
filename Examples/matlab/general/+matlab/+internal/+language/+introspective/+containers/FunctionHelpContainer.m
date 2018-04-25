classdef FunctionHelpContainer < matlab.internal.language.introspective.containers.abstractHelpContainer
    % FUNCTIONHELPCONTAINER - stores help information for an M-function.
    % FUNCTIONHELPCONTAINER stores help information for an M-function that
    % is not a MATLAB Class Object System class definition.
    %
    % Remark:
    % Creation of this object should be made by the static 'create' method
    % of matlab.internal.language.introspective.containers.HelpContainer class.
    %
    % Example:
    %    filePath = which('addpath');
    %    helpObj = matlab.internal.language.introspective.containers.HelpContainer.create(filePath);
    %
    % The code above constructs a FUNCTIONHELPCONTAINER object.
    
    % Copyright 2009-2015 The MathWorks, Inc.
    
    methods
        function this = FunctionHelpContainer(filePath)
            % constructor takes in 'filePath' and initializes the properties
            % inherited from the superclass.

            alternateHelpFunction = matlab.internal.language.introspective.getAlternateHelpFunction(filePath);
            if isempty(alternateHelpFunction)
                helpStr = builtin('helpfunc', filePath);
            else
                helpStr = matlab.internal.language.introspective.callHelpFunction(alternateHelpFunction, filePath);        
            end
            
            mainHelpContainer = matlab.internal.language.introspective.containers.atomicHelpContainer(helpStr);

            pkgClassNames = matlab.internal.language.introspective.containers.getQualifiedFileName(filePath);

            [folderPath, name] = fileparts(filePath);
            
            if matlab.internal.language.introspective.containers.isClassDirectory(folderPath)
                % True for non-local methods defined in @class folder
                mFileName = [pkgClassNames '.' name];
            else
                % This ensures that packaged MATLAB files are treated correctly.
                mFileName = pkgClassNames;
            end
        
            this = this@matlab.internal.language.introspective.containers.abstractHelpContainer(mFileName, filePath, mainHelpContainer);
        end
        
        function result = isClassHelpContainer(this) %#ok<MANU>
            % ISCLASSHELPCONTAINER - returns false because object is of
            % instance FunctionHelpContainer, not ClassHelpContainer
            result = false;
        end
    end
    
end

