classdef CompilerConfigurationFactory
%
    
% CompilerConfigurationFactory class is for creating CompilerConfigurations
%   CompilerConfigurationFactory is a class that creates
%   CompilerConfigurations and returns a set of them that satisfy the
%   inputs Lang, and List.
%
%   It has methods CompilerConfigurationFactory, the constructor and
%   process which returns a CompilerConfigurations.
%
%   See also MEX MEX.getCompilerConfigurations
%   MEX.CompilerConfigurationFactory.CompilerConfigurationFactory
%   MEX.CompilerConfigurationFactory.process

%   Copyright 2007-2011 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2013/07/23 01:17:20 $
%% ----------------------------------
    properties(SetAccess = private, GetAccess = private)
        Lang                            % Set of languages that are requested.
        List                            % Grouping of configurations requested.
        % The following properties may need to be overridden in a subclass
        RootOfStorageLocation           % Directory where storage files can be found
        DefaultStorageFileName          % Name of default options file
        PotentialStorageFileNames       % Cell array of all options file
        PatternOfStorageSetupFileNames  % Pattern of options file
    end %properties

    
%% ----------------------------------
    methods(Access = public)
%% ----------------------------------
        function obj = CompilerConfigurationFactory(Lang,List)
        %
        
        % CompilerConfigurationFactory constructor
        %   CompilerConfigurationFactory(LANG,LIST) creates CompilerConfigurationFactory
        %   whose process method creates CompilerConfigurations.
        %
        %   The constructor initializes properties and validates inputs.
        %   See help for MEX.getCompilerConfigurations for more information
        %   on input arguments.
        %
        %   See also MEX MEX.getCompilerConfigurations
        %   MEX.CompilerConfigurationFactory
        %   MEX.CompilerConfigurationFactory.process 

            if ~ischar(Lang)
                    error(message('MATLAB:CompilerConfiguration:invalidLang'));
            end

            if ischar(List) && any(strcmpi(List,{'selected','installed','supported','specified','default'}));
                obj.List = lower(List);
            else
                error(message('MATLAB:CompilerConfiguration:invalidList'))
            end
            
                     
            if ispc
                obj.RootOfStorageLocation = fullfile(matlabroot,'bin',computer('arch'),'mexopts');
                obj.DefaultStorageFileName = 'mexopts.bat';
                obj.PotentialStorageFileNames = {''};
                obj.PatternOfStorageSetupFileNames = '*opts.stp';
            else
                obj.RootOfStorageLocation = fullfile(matlabroot,'bin');
                obj.DefaultStorageFileName = 'mexopts.sh';
                obj.PotentialStorageFileNames = {'mexopts.sh'};
                obj.PatternOfStorageSetupFileNames = '';
            end
            
            if strcmpi(List,'specified')
                [path, name, ext] = fileparts(Lang);
                obj.RootOfStorageLocation = path;
                obj.DefaultStorageFileName = [name ext];
            end
                
            if strcmpi(List,'specified')
                Lang = 'any';
            end
            
            switch lower(Lang)
                case 'any'
                    obj.Lang = {'C','C++','Fortran'};
                case 'c'
                    obj.Lang = {'C','C++'};
                case {'cpp','c++'}
                    obj.Lang = {'C++'};
                case 'fortran'
                    obj.Lang = {'Fortran'};
                otherwise
                    error(message('MATLAB:CompilerConfiguration:invalidLang'));
            end

        end

%% ----------------------------------
        function aCompilerConfigurationArray = process(obj)
        % MEX.CompilerConfigurationFactory.process returns CompilerConfigurations
        %    The process method returns CompilerConfigurations for the Lang
        %    and List that were used to create the
        %    CompilerConfigurationFactory object.
        %
        %   See also MEX MEX.getCompilerConfigurations
        %   MEX.CompilerConfigurationFactory
        %   MEX.CompilerConfigurationFactory.CompilerConfigurationFactory 
            persistent CachedCSelect;
            persistent CachedTimeStamp;

            isSelectedC = strcmp(obj.List, 'selected') && ...
                          length(obj.Lang) == 2 && ...
                          strcmp(obj.Lang(1), 'C') && strcmp(obj.Lang(2), 'C++');

            if (isSelectedC && obj.ifCachedCSelectValid(CachedCSelect, CachedTimeStamp))
                aCompilerConfigurationArray = CachedCSelect;
                return;
            end

            aCompilerConfigurationArray = [];
            
            storageLocations = identify(obj);

            for index = 1:length(storageLocations)

                rawTextFromStorage = fileread(storageLocations{index});
                
                basicStructArray = getBasicStructArray(obj, rawTextFromStorage, storageLocations{index});

                % getBasicStructArray returns an empty if storage doesn't
                % contain the requested Language, so short circuit the loop.
                if isempty(basicStructArray)
                     continue;
                end
                
                detailsStruct = getFullDetailsStruct(obj, rawTextFromStorage);
                
                if( ispc )
                    fileName = regexpi( rawTextFromStorage, 'keyFileName:\s*(?<name>\S+)\.BAT', 'names' );
                    name = fileName.name;
                    if( strcmpi( name(length(name)-3:end), 'opts' ))
                        name = name( 1:end-4 );
                    end
                    basicStructArray.ShortName = name;
                    basicStructArray.MexOpt = storageLocations{index};
                    basicStructArray.Priority = obj.priority(name);
               else
                   name = 'mex'; % for unix
                   [basicStructArray.ShortName] = deal(name);
                   [basicStructArray.MexOpt] = deal(storageLocations{index});
                   [basicStructArray.Priority] = deal(obj.priority(name));
               end

                newBasicStructArray = [];
                for numberOfLangs=1:length(basicStructArray)
                    basicStructArray(numberOfLangs).Location = determineLocation(obj, storageLocations{index}, basicStructArray, detailsStruct);
                    % If LIST is "Installed" but Location could not be determined, then don't add basicStructArray to array.
                    if ~(strcmp(obj.List,'installed') && isempty(basicStructArray(numberOfLangs).Location))
                        newBasicStructArray = [newBasicStructArray basicStructArray(numberOfLangs)]; %#ok<AGROW>
                    end
                end

                detailsStructArray = populateDetailsStructArray(obj,detailsStruct,newBasicStructArray);                
                tempCompilerConfigurationArray = package(obj,newBasicStructArray,detailsStructArray);
                aCompilerConfigurationArray = [aCompilerConfigurationArray tempCompilerConfigurationArray]; %#ok<AGROW>

            end
            
            if (isSelectedC && ~isempty(aCompilerConfigurationArray))
                CachedCSelect = aCompilerConfigurationArray;
                fileDirInfo = dir(aCompilerConfigurationArray(1).MexOpt);
                CachedTimeStamp = fileDirInfo.datenum;
                mlock;
            end
        end
        
%% ----------------------------------
    end %methods public

    
%% ----------------------------------
    methods(Access = private, Sealed)
%% ----------------------------------
        function isvalid = ifCachedCSelectValid(obj, CachedCSelect, CachedTimeStamp)
            % isvalid = ifCachedCSelectValid( FILENAME, lastTimeStamp)
            % Returns 1 if the file in CachedCSelect is still the choice of this time 
            % and has the same timestamp as lastTimeStamp

            isvalid = false;
            
            if (isempty(CachedCSelect))
                return;
            end
            
            fileName = CachedCSelect.MexOpt;
            fileDirInfo = dir(fileName);
            if (~exist(fileName,'file') || fileDirInfo.datenum > CachedTimeStamp)
                return;
            end
            
            % If the cached file is not changed, then check if file of higher priority exists
            % First check current dir
            fileInPwd = fullfile(pwd, obj.DefaultStorageFileName);
            fileInPwdExist = exist(fileInPwd, 'file');
            if (fileInPwdExist && ~strcmp(fileInPwd, fileName))
                return;
            end

            % If no setup file exists in current dir, check prefdir
            if (~fileInPwdExist)
                fileInPrefDir = fullfile(prefdir, obj.DefaultStorageFileName);
                if ~strcmp(fileName, fileInPrefDir)
                    if (exist(fileInPrefDir, 'file'))
                        return;
                    else
                        fileInStorageLocation = fullfile(obj.RootOfStorageLocation, obj.DefaultStorageFileName);
                        if (~strcmp(fileName, fileInStorageLocation))
                            return;
                        end
                    end
                end
            end

            isvalid = true;
            return;
        end
        
%% ----------------------------------
        function p = priority(obj, shortName)
            
            win64keys = {'MSVC100','MSVC110','MSVC90','MSSDK71','INTELC13MSVS2010','INTELC13MSVS2012','INTELC13MSSDK71','INTELC12MSVS2010','INTELC12MSVS2008','INTELC12MSSDK71','INTELC11MSVS2008','MSVC80',...
                        'INTELF13MSVS2010','INTELF13MSVS2012','INTELF13MSSDK71','INTELF12MSVS2010','INTELF12MSVS2008','INTELF12MSVS2008SHELL','INTELF12MSSDK71','INTELF11MSVS2008','INTELF11MSVS2008SHELL'};
            win64vals = {'A','B','C','D','E','F','G','H','I','J','K','L',...
                         'A','B','C','D','E','F','G','H','I'};
            win64PriorityMap = containers.Map( win64keys, win64vals, 'UniformValues', false );
            
            win32keys = {'MSVC100','MSVC110','MSVC90','MSSDK71','INTELC13MSVS2010','INTELC13MSVS2012','INTELC13MSSDK71','LCC','INTELC12MSVS2010','INTELC12MSVS2008','INTELC12MSSDK71','INTELC11MSVS2008','MSVC80','OPENWATC'...
                        'INTELF13MSVS2010','INTELF13MSVS2012','INTELF13MSSDK71','INTELF12MSVS2010','INTELF12MSVS2008','INTELF12MSVS2008SHELL','INTELF12MSSDK71','INTELF11MSVS2008','INTELF11MSVS2008SHELL'};
            win32vals = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N'...
                         'A','B','C','D','E','F','G','H','I'};
            win32PriorityMap = containers.Map( win32keys, win32vals, 'UniformValues', false );
            
            unixkeys = {'mex'};
            unixvals = {'A'};
            unixPriorityMap = containers.Map( unixkeys, unixvals, 'UniformValues', false );
            
            arch = computer('arch');

            if( strcmpi( arch, 'win64' ) )
                p = win64PriorityMap( shortName ); 
            elseif( strcmpi( arch, 'win32' ) )
                p = win32PriorityMap( shortName ); 
            else
                p = unixPriorityMap( shortName );
            end
        end

%% ----------------------------------
        function pathsToStorage = identify(obj)
            switch obj.List
                case {'selected','specified'}
                    pathsToStorage = {fullfile(pwd,obj.DefaultStorageFileName)};
                    
                    if ~exist(pathsToStorage{:},'file')
                        pathsToStorage = {fullfile(prefdir,obj.DefaultStorageFileName)};
                        
                        if ~exist(pathsToStorage{:},'file')
                            pathsToStorage = {fullfile(obj.RootOfStorageLocation,obj.DefaultStorageFileName)};
                            
                            if ~exist(pathsToStorage{:},'file')
                                error(message('MATLAB:CompilerConfiguration:NoSelectedOptionsFile'))
                            end
                        end
                    end

                case {'supported','installed'}
                    if ispc
                        % Get list of options files that have STP files in RootOfStorageLocation
                        allSTPFiles = dir(fullfile(obj.RootOfStorageLocation,obj.PatternOfStorageSetupFileNames));
                        fullFileSTPFiles = cellfun(@(x)fullfile(obj.RootOfStorageLocation,x),...
                            {allSTPFiles.name},'UniformOutput',false);
                        pathsToStorage = regexprep(fullFileSTPFiles','\.stp','\.bat');
                    else
                        % Get list of options files from list in obj.PotentialStorageFileNames
                        pathsToStorage = cellfun(@(x)fullfile(obj.RootOfStorageLocation,x),...
                            obj.PotentialStorageFileNames,'UniformOutput',false);
                    end
                case {'default'}
                    if ispc
                        [~, defaultCompiler] = system('echo %MWE_DEFAULT_C%');
                        pathsToStorage = {fullfile(matlabroot,'bin',computer('arch'),'mexopts', strcat(defaultCompiler,'opts.bat'))};
                        if ~exist(pathsToStorage{:},'file')
                            error(message('MATLAB:CompilerConfiguration:NoSelectedOptionsFile'))
                        end
                    else
                        % Get list of options files from list in obj.PotentialStorageFileNames
                        pathsToStorage = cellfun(@(x)fullfile(obj.RootOfStorageLocation,x),...
                            obj.PotentialStorageFileNames,'UniformOutput',false);
                    end
            end
            
        end

%% ----------------------------------
        function basicStructArray = getBasicStructArray(obj, rawTextFromStorage, storageLocation)
            
            basicStructArray = [];
            
            if ~ispc
                %Get the section of the options for for the given architecture.
                rawTextFromStorage = regexp(rawTextFromStorage,[computer('arch') '(.*?)\;\;'],'match','once');
            end

            % Test for current storage type and warn otherwise.
            storageversionNumber = str2double(regexp(rawTextFromStorage,'\s*(?:rem|#)\s+StorageVersion: ([\d\.]+)','tokens','once'));
            if isempty(storageversionNumber) || storageversionNumber < 1.0
                warning(message('MATLAB:CompilerConfiguration:OldStyleStorage', storageLocation));
                return
            elseif storageversionNumber > 1
                warning(message('MATLAB:CompilerConfiguration:storageTooNew', storageLocation));
                return                
            end

            % Get KEYS and VALUES and put into an array for each language
            for numberOfLanguages = 1:length(obj.Lang)
                % The following regular expression is matching the following pattern:
                % a) A comment string, either rem or #.
                % b) A key of the form C++keyName, where Name is capture, for example.
                % c) A colon and then optionally a whitespace character that is not a NEWLINE or Carriage Return.
                % d) The value associate with the key which can be anything that is not a NEWLINE or Carriage Return.
                propsStruct = regexp(rawTextFromStorage,...
                    ['\s*(?:rem|#)\s+' regexptranslate('escape',obj.Lang{numberOfLanguages})...
                    'key(?<KEYS>\w*):(?:(?![\r\n])\s)*(?<VALUES>[^\r\n]*)'],'names');

                if ~isempty(propsStruct)
                    % Manipulate output of REGEXP into a structure
                    basicStructTemp = {propsStruct.KEYS; propsStruct.VALUES};
                    basicStruct = struct(basicStructTemp{:});

                    basicStructArray = [basicStructArray basicStruct]; %#ok<AGROW>
                end
            end
        end
%% ----------------------------------
        function newtext = replaceRegistryLookup(obj, text) %#ok<INUSL>
            
            pat = '''\.registry_lookup\("(?<Key>[^"]+)"\s*,\s*"(?<Value>[^"]+)"\)\.''';
            [startpos, endpos, ~, ~, ~, regs] = regexp( text, pat );    %Should be at most only one match here

            if (length(regs) < 1)
                newtext = text;
            else
                try
                    value = winqueryreg( 'HKEY_LOCAL_MACHINE', regs.Key, regs.Value );
                catch mExpObj
					value = '';
                end
                %replace
                newtext = [text(1:startpos-1) value text(endpos+1:end)];
            end
        end

%% ----------------------------------
        function [shell, arg] = cmdlineShell(obj, shortName, location)
            shell = '';
            arch = computer('arch');
            arg = '';
            if( strncmpi( shortName, 'msvc', 4 ) )
                % TODO WHY DO WE NEED THIS? CAN WE DO SOMETHING DIFFERENT USING
                % SETENV
                if (strcmpi( arch, 'win32' ) && strcmpi(shortName, 'msvc90'))
                    shell = fullfile (location, '\Common7\Tools\vsvars32.bat');
                else
                    shell = fullfile (location, '\VC\vcvarsall.bat');
                end
				if( strcmpi( arch, 'win64' ) )
					arg = 'AMD64';
				elseif ( strcmpi( arch, 'win32' ) )
					arg = 'x86';
				end
			elseif( strncmpi( shortName, 'intel', 5 ) )
				if (length(shortName) > 5 && strcmpi(shortName(6), 'c'))
					shell = fullfile (location, '\bin\iclvars.bat');
				elseif (length(shortName) > 5 && strcmpi(shortName(6), 'f'))
					shell = fullfile (location, '\bin\ifortvars.bat');
				end
				if( strcmpi( arch, 'win64' ) )
					arg = 'intel64';
				elseif ( strcmpi( arch, 'win32' ) )
					arg = 'ia32';
				end
            end
        
        end

%% ----------------------------------
        function detailsStruct  = getFullDetailsStruct(obj, rawTextFromStorage)  
            if ispc
                detailsStructTemp = regexp(rawTextFromStorage,...
                    '(?<!rem )set (?<KEY>\w*)=(?<VALUE>[\w\S ]*)\r*\n+','names');
            else
                firstPart = regexp(rawTextFromStorage,'^.*case "\$Arch','match','once');
                archPart = regexp(rawTextFromStorage,[computer('arch') '\>(.*?);;'],'match','once');
                pattern = '(?<KEY>\w+)=([''"])?(?<VALUE>[^''"\r\n]+)(?(2)[''"])';
                firstPartStruct = regexp(firstPart,pattern,'names');
                archPartStruct = regexp(archPart,pattern,'names');
                detailsStructTemp = [firstPartStruct archPartStruct];
            end
            detailsStruct = expandEnvironmentVariables(detailsStructTemp);
            
            detailsStruct.SetEnv = obj.replaceRegistryLookup(rawTextFromStorage);
        end
        
%% ----------------------------------
        function location = determineLocation(obj, storageLocation, basicStruct, detailStruct)
            
            if ~ispc
                location = '';
                return
            end
            
            locationPerlFile = fullfile(matlabroot,'toolbox','matlab','general','+mex_legacy','getCompilerPath.pl');

            if strcmp(obj.List,'selected')
                storageLocation = fullfile(obj.RootOfStorageLocation,lower(basicStruct.FileName));
                outputType = 'environmentVariable';
            else
                outputType = 'location';
            end
            
            if (ispc && strncmp(pwd,'\\',2)) % UNC path
                origPWD = cd('C:');
                goBackToOrigPWD = onCleanup(@()cd(origPWD));
            end
            
            [outputValue, success] = perl(locationPerlFile,'-matlabroot',matlabroot,...
                                          '-storageLocation',storageLocation,'-outputType',outputType);
            if success~=1
                error(message('MATLAB:CompilerConfigurationFactory:perlError', outputValue));
            end
            
            if strcmp(obj.List,'selected')
                location = detailStruct.(outputValue);
            else
                location = outputValue;
            end

        end 

%% ----------------------------------
    end %methods private

    
    methods(Access = protected)
%% ----------------------------------
        function aCompilerConfiguration = package(obj, basicStruct, detailStuct, systemDetailStruct)  %#ok<INUSD,INUSL>
        % This method will potentially be overridden to call a derivatives
        % of the CompilerConfiguration classes below. It is likely that
        % this method will be entirely replaced.
        
            aCompilerConfiguration = mex_legacy.CompilerConfiguration.empty(1,0);
        
            for numberOfLanguages = 1:length(basicStruct)
                ccDetails = mex_legacy.CompilerConfigurationDetails(detailStuct(numberOfLanguages));
                tempCompilerConfiguration = mex_legacy.CompilerConfiguration(basicStruct(numberOfLanguages),ccDetails);
                aCompilerConfiguration = [aCompilerConfiguration tempCompilerConfiguration]; %#ok<AGROW>
            end
        end

%% ----------------------------------        
        function detailsStructArray = populateDetailsStructArray(obj, detailsStruct, basicStruct)  %#ok<INUSL>
        % This method will potentially be overridden to add additional
        % details properties.  It is likely that this parent method will
        % bee called first to have fields added to the work that it
        % does.  One might find the following line of code useful for
        % the purpose.
        % detailsStructArray = populateDetailsStructArray@mex.CompilerConfigurationFactory(obj, detailsStruct, basicStruct);

            function field=safeGetField(Struct,fieldName)
                if isfield(Struct,fieldName)
                    field=Struct.(fieldName);
                else
                    field=[];
                end
            end
            detailsStructArray = struct; %prevents array growth warning

            for numberOfLanguages = 1:length(basicStruct)
                if ispc
                    detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.COMPILER;
                    detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.COMPFLAGS;
                    detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.OPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.DEBUGFLAGS;
                    
                    detailsStructArray(numberOfLanguages).LinkerExecutable = detailsStruct.LINKER;
                    detailsStructArray(numberOfLanguages).LinkerFlags = detailsStruct.LINKFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerOptimizationFlags = detailsStruct.LINKOPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerDebugFlags = detailsStruct.LINKDEBUGFLAGS;
                    detailsStructArray(numberOfLanguages).SetEnv = detailsStruct.SetEnv;
                    [detailsStructArray(numberOfLanguages).CommandLineShell, detailsStructArray(numberOfLanguages).CommandLineShellArg] = ...
                        obj.cmdlineShell(basicStruct(numberOfLanguages).ShortName, basicStruct(numberOfLanguages).Location);
                    
                    detailsStruct = expandEnvironmentVariables1(detailsStruct);
                    detailsStructArray(numberOfLanguages).SystemDetails.SystemPath = detailsStruct.PATH;
                    detailsStructArray(numberOfLanguages).SystemDetails.LibraryPath = safeGetField(detailsStruct,'LIB');
                    detailsStructArray(numberOfLanguages).SystemDetails.IncludePath = safeGetField(detailsStruct,'INCLUDE');
                    detailsStructArray(numberOfLanguages).SystemDetails.TargetArch = detailsStruct.MW_TARGET_ARCH;
                    detailsStructArray(numberOfLanguages).SystemDetails.RenameObjectFlag = detailsStruct.NAME_OBJECT;
                    detailsStructArray(numberOfLanguages).SystemDetails.LinkLibraryLocation = detailsStruct.LIBLOC;
                    detailsStructArray(numberOfLanguages).SystemDetails.LinkOutputFlagAndDLLName = detailsStruct.NAME_OUTPUT;
                    
                    if isfield(detailsStruct,'POSTLINK_CMDS')
                        detailsStructArray(numberOfLanguages).SystemDetails.POSTLINK_CMDS = detailsStruct.POSTLINK_CMDS;
                        postLinkCommandNumber = 1;
                        oldWarnState = warning('off','MATLAB:nonIntegerTruncatedInConversionToChar');
                        while isfield(detailsStruct,['POSTLINK_CMDS' num2str(postLinkCommandNumber)])
                            fieldName = (['POSTLINK_CMDS' num2str(postLinkCommandNumber)]);
                            detailsStructArray(numberOfLanguages).SystemDetails.((fieldName)) = detailsStruct.(fieldName);
                            postLinkCommandNumber = postLinkCommandNumber+1;
                        end
                        warning(oldWarnState);
                    end
                    
                    %LINK_FILE
                    %LINK_LIB
                    %RSP_FILE_INDICATOR
                    %RC_COMPILER
                    %RC_LINKER
                    
                elseif (isfield(basicStruct,'Language') && ~isempty(basicStruct(numberOfLanguages).Language))
                    switch basicStruct(numberOfLanguages).Language
                        case 'C'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.CC;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.CFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.COPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.CDEBUGFLAGS;
                        case 'C++'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.CXX;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.CXXFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.CXXOPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.CXXDEBUGFLAGS;
                        case 'Fortran'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.FC;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.FFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.FOPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.FDEBUGFLAGS;
                    end
                    detailsStructArray(numberOfLanguages).LinkerExecutable = detailsStruct.LD;
                    detailsStructArray(numberOfLanguages).LinkerFlags = detailsStruct.LDFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerOptimizationFlags = detailsStruct.LDOPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerDebugFlags = detailsStruct.LDDEBUGFLAGS;                                       
                    detailsStructArray(numberOfLanguages).SetEnv = detailsStruct.SetEnv;
                    detailsStructArray(numberOfLanguages).CommandLineShell = '';
                    detailsStructArray(numberOfLanguages).CommandLineShellArg = '';
                end
            end
        end
        
%% ----------------------------------

    end %methods protected
    
end %classdef


%% ----------------------------------
% Helper functions (Private subfunctions)
%% ----------------------------------
function structOfExpandedVars = expandEnvironmentVariables(inputStruct)

    structOfExpandedVars = struct;

    for index = 1:length(inputStruct)
        if ~any(strcmp(inputStruct(index).KEY,fieldnames(structOfExpandedVars)))
            % This branch is that the field name has not been
            % encountered yet, then add the field.
            structOfExpandedVars.(inputStruct(index).KEY) = inputStruct(index).VALUE;
        else
            % If the field already exists in the structure, then
            % expand it and override the old value.
            envVarKey = regexptranslate('escape',inputStruct(index).KEY);
            oldEnvValue = regexptranslate('escape',structOfExpandedVars.(inputStruct(index).KEY));
            if ispc
                envVarPattern = ['%' envVarKey '%'];
            else
                envVarPattern = ['\$' envVarKey];
            end
            structOfExpandedVars.(inputStruct(index).KEY) = regexprep(inputStruct(index).VALUE,envVarPattern,oldEnvValue);
        end
    end

end


function inputStruct = expandEnvironmentVariables1(inputStruct)

    envsAsFieldnames = fieldnames(inputStruct);
    
    for index = 1:length(envsAsFieldnames)
        for inner = 1:length(envsAsFieldnames)
            inputStruct.(envsAsFieldnames{index}) = ...
                regexprep(inputStruct.(envsAsFieldnames{index}), ...
                ['%' envsAsFieldnames{inner} '%'], ...
                regexptranslate('escape',inputStruct.(envsAsFieldnames{inner})));
        end
    end
end
