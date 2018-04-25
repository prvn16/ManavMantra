classdef atomicHelpContainer < handle
    % ATOMICHELPCONTAINER - class used to store and retrieve help
    % information for 1 single entity.
    
    % Copyright 2009 The MathWorks, Inc.
    properties (Access = private)
        helpStr = '';
    end
    
    methods
        function this = atomicHelpContainer(helpStr)
            % AHC = MATLAB.INTERNAL.LANGUAGE.INTROSPECTIVE.CONTAINERS.ATOMICHELPCONTAINER creates an
            % ATOMICHELPCONTAINER object with an empty help string stored.
            %
            % AHC = MATLAB.INTERNAL.LANGUAGE.INTROSPECTIVE.CONTAINERS.ATOMICHELPCONTAINER(HELPSTR) creates
            % an ATOMICHELPCONTAINER object that stores HELPSTR.
            narginchk(1,1);
            
            checkInputHelpString(helpStr);
            
            this.helpStr = helpStr;
        end
        
        function helpStr = getHelp(this)
            % GETHELP - returns the stored help string.
            helpStr = this.helpStr;
        end
        
        function helpStr = getH1Line(this)
            % GETH1LINE - returns H-1 line string extracted from stored member help.
            helpStr = matlab.internal.language.introspective.containers.extractH1Line(this.helpStr);
        end
        
        function result = hasNoHelp(this)
            % HASNOHELP - returns a boolean indicating whether object has no help
            % HASNOHELP returns true if help stored is empty and false
            % otherwise.
            result = isempty(this.helpStr);
        end
        
        function clearHelp(this)
            % CLEARHELP - empties the help stored in ATOMICHELPCONTAINER.
            this.helpStr = '';
        end
        
        function updateHelp(this, newHelpStr)
            % UPDATEHELP - updates the help stored in ATOMICHELPCONTAINER.
            checkInputHelpString(newHelpStr);
            
            if ~isempty(regexp(newHelpStr, '^\S', 'once', 'lineanchors'))
                newHelpStr = regexprep(newHelpStr, '^.', ' $0', 'lineanchors', 'dotexceptnewline');
            end
            
            this.helpStr = newHelpStr;
        end
    end
end

function checkInputHelpString(newHelpStr)
    % CHECKINPUTHELPSTRING - helper method that checks that input is valid
    if ~ischar(newHelpStr)
        error(message('MATLAB:introspective:atomicHelpContainer:InvalidInput'));
    end
end