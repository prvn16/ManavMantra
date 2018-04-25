classdef atomicHelpPart < handle
    %ATOMICHELPPART - Stores information specific to one part of M-help.
    %ATOMICHELPPART stores the following:
    %* The text in the help part
    %* The title pertaining to that help part
    %* The type of help part
    
    % Copyright 2009 The MathWorks, Inc.    
    properties (SetAccess = private)
        helpStr = '';
        title = '';
        enumType = 0;
    end
    
    methods
        function this = atomicHelpPart(title, helpStr, enumType)
            % ATOMICHELPPART - constructs an ATOMICHELPPART with the
            % default values.
            % ATOMICHELPPART(TITLE, HELPSTR, ENUMTYPE) - constructs an
            % ATOMICHELPPART and initializes its properties to those passed
            % in as input.
            switch nargin
            case 0,
                % leave defaults
            case 3,
                this.helpStr = helpStr;
                this.title = title;
                this.enumType = enumType;
            otherwise,
                error(message('MATLAB:introspective:atomicHelpPart:InvalidNargin'));
            end
        end
      
        function helpStr = getText(this)
            % GETTEXT - returns the stored text content as a string
            helpStr = this.helpStr;
        end
        
        function titleText = getTitle(this)
            % GETTITLE - returns the stored title text as a string
            titleText = this.title;
        end
        
        function replaceText(this, newStr)
            % REPLACETEXT - updates the stored help text with input string.
            if ~ischar(newStr)
                error(message('MATLAB:introspective:atomicHelpPart:InvalidInput'));
            end
            
            this.helpStr = newStr;
        end
        
        function clearPart(this)
            this.helpStr = '';
            this.title   = '';
        end
    end
end