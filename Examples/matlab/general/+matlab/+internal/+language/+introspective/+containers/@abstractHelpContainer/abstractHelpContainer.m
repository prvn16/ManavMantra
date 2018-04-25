classdef abstractHelpContainer < handle
    % ABSTRACTMFILEHELPCONTAINER - abstract base class used to represent a
    % help container associated with a specific MATLAB file.

    % Copyright 2009-2015 The MathWorks, Inc.

    properties (SetAccess = protected)
        % mFileName - stores package and/or class qualified name of MATLAB file.
        mFileName;
        
        mFilePath; % stores the full path to the source MATLAB file.
        mainHelpContainer; % container stores the main help information.
    end

    properties (Access = private)
        copyrightText = ''; % stores the MATLAB file's copyright text, if any.
        copyrightExtracted = false;
    end

    methods (Abstract)
        result = isClassHelpContainer(this);
    end
    
    methods

        function this = abstractHelpContainer(mFileName, mFilePath, mainHelpContainer)
            this.mFileName = mFileName;
            this.mFilePath = mFilePath;
            this.mainHelpContainer = mainHelpContainer;
        end

        outputMFilePath = exportToMFile(this, outputDir);

        detectedChange = compareHelp(this, prevFilePath);

        function result = hasNoHelp(this)
            % HASNOHELP - returns true if help is empty and false otherwise.
            result = this.mainHelpContainer.hasNoHelp;
        end
        
        function helpStr = getHelp(this)
            % GETHELP - returns the stored help as a string.
            helpStr = this.mainHelpContainer.getHelp();
        end
        
        function h1Line = getH1Line(this)
            % GETH1LINE - returns the H-1 line from stored help comments.
            h1Line = this.mainHelpContainer.getH1Line();
        end
        
        function copyrightText = getCopyrightText(this)
            % GETCOPYRIGHTTEXT - returns copyright text in main help.

            if ~this.copyrightExtracted
                fileContents = matlab.internal.getCode(this.mFilePath);
                this.copyrightText = regexpi(fileContents, '^\s*%\s*(copyright.*)', 'lineanchors', 'dotexceptnewline', 'match', 'once');
                this.copyrightExtracted = true;
            end

            copyrightText = this.copyrightText;
        end
 
        function updateHelp(this, newHelpStr)
        % UPDATEHELP - updates the help comments stored in helpContainer
            this.mainHelpContainer.updateHelp(newHelpStr);
        end
 
    end
end
