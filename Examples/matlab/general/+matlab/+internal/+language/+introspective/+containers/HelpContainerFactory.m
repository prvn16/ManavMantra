classdef HelpContainerFactory
    % HELPCONTAINERFACTORY - factory class that creates HelpContainer
    % objects based on the input.
    %
    %
    % HELPOBJ = MATLAB.INTERNAL.LANGUAGE.INTROSPECTIVE.CONTAINERS.HELPCONTAINERFACTORY.CREATE(FILEPATH) returns a HelpContainerFactory
    % object that stores all the relevant help information related to the
    % MATLAB file specified by FILEPATH.
    %
    % HELPOBJ = MATLAB.INTERNAL.LANGUAGE.INTROSPECTIVE.CONTAINERS.HELPCONTAINERFACTORY.CREATE(CLASSFILEPATH,
    % 'onlyLocalHelp', T/F)   If the flag onlyLocalHelp is set to TRUE, then
    % the created HELPCONTAINER object will contain the entire help
    % comments for all class members that meet the following requirements:
    %
    % Properties should not:
    %    - Have SetAccess and GetAccess attributes that are BOTH set to Private
    %    - Be inherited from any superclsses
    %
    % Methods must not be:
    %    - Hidden
    %    - Private
    %    - Defined in a superclass
    %    - Defined outside the classdef file
    %
    % By default, flag onlyLocalHelp is set to FALSE and the HELPCONTAINER
    % only stores the first line of help comments.
    %
    %
    % Remark:
    %   The onlyLocalHelp flag is ignored for MATLAB files that are not MATLAB
    %   Class Object System class definitions.
    
    %    Copyright 2009-2015 The MathWorks, Inc.

    methods (Static)
        function this = create(filePath, varargin)
            % CREATE - factory method that creates a helpContainer based on input filepath.
            % If the input file is a classdef file, then a CLASSHELPCONTAINER
            % is created, otherwise a FUNCTIONHELPCONTAINER is created.
            %
            % Examples
            %
            %   % Example 1: Create a HelpContainer for an M-function
            %
            % 	filePath = which('addpath.m');
            %	hC = matlab.internal.language.introspective.containers.HelpContainerFactory.create(filePath);
            %
            %   % Example 2: Create a HelpContainer for a classdef file
            %
            % 	filePath = which('RandStream.m');
            %
            %	hC = matlab.internal.language.introspective.containers.HelpContainerFactory.create(filePath, ...
            %                                               'onlyLocalHelp', true);
            %
            %   hC will not contain help information on properties/methods
            %   inherited from RandStream's superclass: the handle class
            %
            % NOTE:
            %   If the input file is NOT on the MATLAB Path, then CREATE
            %   returns a FUNCTIONHELPCONTAINER irrespective of the nature of the
            %   MATLAB file.
            if ~ischar(filePath)
                error('MATLAB:introspective:helpContainerFactory:InvalidFilePath','%s', ...
                    getString(message('MATLAB:introspective:extractHelpText:FilePathMustBeAString')));
            end
            
            % Check for onlyLocalHelp property pair
            p = inputParser;
            
            % p is case insensitive by default
            p.addParameter('onlyLocalHelp', false, @islogical);
            p.addParameter('metaInfo', []);
            
            p.parse(varargin{:});
            
            if isempty(p.Results.metaInfo)
                checkFilePath(filePath);
                metaInfo = getMetaInfo(filePath);
            else
                metaInfo = p.Results.metaInfo; 
            end
            
            if ~isempty(metaInfo) % filePath is a classdef file
                this = matlab.internal.language.introspective.containers.ClassHelpContainer(filePath, ...
                    metaInfo, p.Results.onlyLocalHelp);
            else
                this = matlab.internal.language.introspective.containers.FunctionHelpContainer(filePath);
            end
        end
    end
end

function checkFilePath(filePath)
    % CHECKFILEPATH - checks if input file path is valid
    pathStr = fileparts(filePath);
    
    if isempty(pathStr) || ~exist(filePath, 'file')
        error('MATLAB:introspective:helpContainerFactory:InvalidFilePath', '%s',...
            getString(message('MATLAB:introspective:extractHelpText:HelpContainerFactoryInvalidFilePath', filePath)));
    end
    
end

function metaInfo = getMetaInfo(filePath)
    % GETMETAINFO - returns the meta.class information if FILEPATH
    % corresponds to a classdef file, otherwise it returns an empty
    % array.
    [pathStr, fileName] = fileparts(filePath);
    noExtFile = fullfile(pathStr, fileName);
    if matlab.internal.language.introspective.isClassMFile(noExtFile)
        % True for both old and new MATLAB Class Object System
        qualifiedName = matlab.internal.language.introspective.containers.getQualifiedFileName(filePath);
        
        % metaInfo is empty for old MATLAB Class Object System classes.
        metaInfo = meta.class.fromName(qualifiedName);
    else
        metaInfo = [];
    end
end
