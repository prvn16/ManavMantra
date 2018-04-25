classdef(Hidden,HandleCompatible) MainFileMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % MainFile - Character vector that specifies the name of the main file for the HTML report
        %
        %   The MainFile property specifies the name given to the main file of the
        %   generated HTML report. This property is read only and can be set only
        %   through the constructor.
        MainFile = 'index.html';
    end
    
    properties(Constant,Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods(Access=protected)
        function mixin = MainFileMixin(varargin)
            import matlab.unittest.internal.mixin.MainFileMixin;
            parser = MainFileMixin.ArgumentParser;
            parser.parse(varargin{:});
            mixin.MainFile = char(parser.Results.MainFile);
        end
    end
    
    methods(Hidden,Static)
        function validateMainFile(mainFileName)
            validateattributes(mainFileName,{'char','string'},{'scalartext'},'','MainFile');
            mainFileName = regexprep(char(mainFileName),'[\\\/]',filesep);
            [folder,~,fileExt] = fileparts(mainFileName);
            if ~isempty(folder)
                error(message('MATLAB:unittest:TestReportPlugin:SlashesNotAllowed'));
            end
            if ~any(strcmpi(fileExt,{'.html','.htm'}))
                error(message('MATLAB:unittest:TestReportPlugin:InvalidMainFileExtension'));
            end
        end
    end
end

function parser = createArgumentParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('MainFile', 'index.html', ...
    @matlab.unittest.internal.mixin.MainFileMixin.validateMainFile);
end

% LocalWords:  scalartext unittest
