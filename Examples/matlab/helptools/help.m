function [out, docTopic] = help(varargin)
    %  HELP Display help text in Command Window.
    %     HELP, by itself, lists all primary help topics. Each primary topic
    %     corresponds to a folder name on the MATLAB search path.
    %
    %     HELP NAME displays the help for the functionality specified by NAME,
    %     such as a function, operator symbol, method, class, or toolbox.
    %     NAME can include a partial path.
    %
    %     Some classes require that you specify the package name. Events,
    %     properties, and some methods require that you specify the class
    %     name. Separate the components of the name with periods, using one
    %     of the following forms:
    %
    %         HELP CLASSNAME.NAME
    %         HELP PACKAGENAME.CLASSNAME
    %         HELP PACKAGENAME.CLASSNAME.NAME
    %
    %     If NAME is the name of both a folder and a function, HELP displays
    %     help for both the folder and the function. The help for a folder
    %     is usually a list of the program files in that folder.
    %
    %     If NAME appears in multiple folders on the MATLAB path, HELP displays
    %     information about the first instance of NAME found on the path.
    %
    %     NOTE:
    %
    %     In the help, some function names are capitalized to make them 
    %     stand out. In practice, type function names in lowercase. For
    %     functions that are shown with mixed case (such as javaObject),
    %     type the mixed case as shown.
    %
    %     EXAMPLES:
    %
    %     help close           % help for the CLOSE function
    %     help database/close  % help for CLOSE in the Database Toolbox
    %     help database        % list of functions in the Database Toolbox 
    %                          % and help for the DATABASE function
    %     help containers.Map.isKey   % help for isKey method
    %
    %     See also DOC, DOCSEARCH, LOOKFOR, MATLABPATH, WHICH.

    %   Copyright 1984-2012 The MathWorks, Inc.
    
    process = helpUtils.helpProcess(nargout, nargin, varargin);
    if isnumeric(process.inputTopic)
        process.inputTopic = inputname(process.inputTopic);
    end
      
    try %#ok<TRYNC>
        % no need to tell customers about internal errors
        
        process.wsVariables = evalin('caller', 'whos');
        
        process.getHelpText;
        
        process.prepareHelpForDisplay;
    end

    if nargout > 0
        out = process.helpStr;
        if nargout > 1
            docTopic = process.docTopic;
        end
    end
end
