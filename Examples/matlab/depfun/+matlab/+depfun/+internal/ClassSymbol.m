classdef ClassSymbol < handle

    properties(SetAccess = protected)
    % Public read access
        ClassName               % Fully-qualified class name
        ClassDir                % Class directory
        ConstructorFile         % Full path to constructor 
        ClassType               % Type (UDD, MCOS, etc.) of the class
    end

    properties(Dependent)
        Symbol
        FileList                % The files belonging to the class
        FileCount               % How many files belong to the class
        FileType                % Types of the files (method, etc.)
    end
    
    methods (Static)
        function declareToxic(locations)
            ixf = matlab.depfun.internal.IxfVariables('/');
            locations = strrep(ixf.bind(locations),'/',filesep);
            toxicLocations(locations);
        end
    end
    
    methods (Access = private)
        
        function types = fileTypes(obj, files)
            import matlab.depfun.internal.MatlabType;
            
            atSep = [filesep '@'];
            fileCount = numel(files);
            types = repmat(MatlabType.NotYetKnown, 1, fileCount);
            for f=1:fileCount
                file = files{f};
                
                if isExecutable(file) && ...
             	   isempty(strfind(file, obj.ConstructorFile))
                    switch obj.ClassType
                        case MatlabType.UDDClass 
                            numAt = numel(strfind(file, atSep));
                            if numAt == 2
                                types(f) = MatlabType.UDDMethod; 
                            elseif numAt == 1
                                types(f) = MatlabType.UDDPackageFunction;
                            else
                                types(f) = obj.ClassType;
                            end
                        otherwise
                            types(f) = MatlabType.ClassMethod;
                    end
                else
                    % Not ideal, but the enumeration doesn't let us do much
                    % better. TODO: determine if we need to use Data,
                    % Ignorable and Extrinsic here, as appropriate.
                    types(f) = obj.ClassType;
                end
            end
        end
        
    end
    
    methods
        function files = get.FileList(obj)
            import matlab.depfun.internal.MatlabType;
           
            if obj.ClassType == MatlabType.UDDClass
                files = getUDDFiles(obj.ClassName, obj.ClassDir);
            else
                files = getClassFiles(obj.ClassName);
                % Single file MCOS classes may not be found by WHAT.
                if isempty(files)
                    files = { obj.ConstructorFile };
                end
            end
            files = unique(files);
        end
        
        function types = get.FileType(obj)
            import matlab.depfun.internal.MatlabType;

            % All the *.m files on the file list, except for the
            % constructor file (and schema files), are methods of the class.
            files = obj.FileList;
            types = fileTypes(obj, files);   
    
        end
        
        function n = get.FileCount(obj)
            n = numel(obj.FileList);
        end
        
        function sym = get.Symbol(obj)
            sym = matlab.depfun.internal.MatlabSymbol( ...
                  obj.ClassName, obj.ClassType, obj.ConstructorFile, ...
                  obj.ClassName, obj.ConstructorFile);
        end
    end
    
    methods
        function obj = ClassSymbol(qName, whichResult, type, classFile)
        % ClassSymbol Constructor for ClassSymbol objects. Initialize
        % methodList, fileList and constructorPath. Input: fully qualified
        % class name and file path used to determine class name.
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.requirementsConstants;
            
            obj.ClassName = qName;
            numInputs = nargin;
            if numInputs < 2 || numInputs > 4
                error(message('MATLAB:depfun:req:BadInputCount', ...
                              '2, 3 or 4', numInputs, ...
                              'matlab.depfun.internal.ClassSymbol'))
            end
            if numInputs < 3
                type = MatlabType.NotYetKnown;
            end
            
            if ~ischar(whichResult)
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                    2, class(whichResult), 'string'))
            end
            
            if isempty(whichResult)
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                    2, 'empty', 'string'))
            end
            
            % Use the classFile to derive the class directory when the constructor file exists.
            % Otherwise, use the whichResult to approximate the class directory.
            classDir = '';
            if numInputs > 3 && (matlab.depfun.internal.cacheExist(classFile, 'file') > 0)
                classDir = fileparts(classFile);
            elseif numInputs > 1 && ~isempty(whichResult) && ...
                    numel(whichResult) > 0
                sepIdx = strfind(whichResult, filesep);
                if ~isempty(sepIdx)
                    bI = [requirementsConstants.BuiltInStrAndATrailingSpace '('];
                    classDir = whichResult(1:sepIdx(end)-1);
                    if strncmp(bI,classDir,numel(bI))
                        classDir = [classDir ')'];
                    end
                end
            end
            obj.ClassDir = classDir;

            if numInputs > 3
                % In most cases, the class constructor file has been found
                % in an earlier step, so just pass it to avoid repeated
                % work.
                obj.ConstructorFile = classFile;
            else
                [~, obj.ConstructorFile] = className(whichResult);
            end                
            
            % If the input argument 'type' is passed in, we don't need to 
            % compute it again. In this case, the MatlabType represented by
            % 'type' can be any class type.
            if type == MatlabType.NotYetKnown
                obj.ClassType = classType(qName, whichResult);
            else
                obj.ClassType = type;
            end
        end
        
        function [files, types] = classFilesAndTypes(obj)
            files = obj.FileList;
            types = fileTypes(obj, files);            
        end
    end
end

%-------------------------------------------------------------------------
% Class variables
function locations = toxicLocations(locations)
    persistent polluted
    if nargin == 1
        polluted = locations;
    end
    locations = polluted;
end

%-------------------------------------------------------------------------
% Local functions
function files = getUDDFiles(className, uddDir)
% getClassDirFiles Get all the files in the class directory and those in
% the private directory, if the class directory contains a private directory.
% If classDir is empty, return an empty cell array.
%
% classDir may be a cell array of multiple class directories. 
    files = {};

    function fList = getClassFiles(d)
        fList = getDirContents(d);
        fList = fullfile(d, fList);

        % If there is a private folder in the @-directory,
        % add all the files in that private folder.
        [privateFiles, privateDirName] = getPrivateFiles(d);
        privateFiles = strcat(privateDirName,filesep,privateFiles);
        
        fList = [fList; privateFiles];   
        fList = fList';
    end

    if iscell(uddDir)
        for k=1:numel(uddDir)
            files = [files getClassFiles(uddDir{k})]; %#ok
        end
    elseif ~isempty(uddDir) && numel(uddDir) > 0
        files = getClassFiles(uddDir);
    end
    
    % Add constructor, if it exists.
    dotIdx = strfind(className,'.');
    if ~isempty(dotIdx)
        dotIdx = dotIdx(end);
        className = className((dotIdx+1):end);
    end
    constuctorFile = strcat(uddDir, filesep, className, '.m');
    if matlab.depfun.internal.cacheExist(constuctorFile,'file')
        files = [files {constuctorFile}];
    end
end

function files = getClassFiles(className)

    import matlab.depfun.internal.requirementsConstants
    
    fs = filesep;
    files = {};
    whatName = strrep(className,'.','/');
    whatResult = what(whatName);
    classDirs = strcat({whatResult.path}, fs);
    
    % Some directories are toxic -- they create a lot of work for no
    % reward. For example, the Symbolic Toolbox extends the @double
    % directory. Yet the Symbolic Toolbox is not deployable. For the MCR
    % target, the Symbolic Toolbox directories are toxic.
    keepOut = toxicLocations;
    for t = 1:numel(keepOut)
        keep = cellfun('isempty', strfind(classDirs, keepOut{t}));
        classDirs = classDirs(keep);
        whatResult = whatResult(keep);
    end
    
    % WHAT may find extraneous directories -- toss them out of the club. A
    % class directory must have at least one @-sign in it.
    keep = ~cellfun('isempty',strfind(classDirs, [fs '@']));
    classDirs = classDirs(keep);
    whatResult = whatResult(keep);
    
    % Some fileds in the WHAT result may not always be available, e.g, mlx. 
    wfIdx = cellfun(@(f)isfield(whatResult,f), requirementsConstants.whatFields);
    wf = requirementsConstants.whatFields(wfIdx);

    % Full paths to all files
    for k=1:numel(classDirs)
        clsDir = classDirs{k};
        % G1083008: If a relative path is added to MATLAB path, WHAT
        % returns relative path.
        if ~isfullpath(clsDir)
            tmp = fullfile(pwd, clsDir);
            if exist(tmp,'dir')==7
                clsDir = tmp;
            end
        end
        
        wr = whatResult(k);
        
        dirFiles = cellfun(@(f)(wr.(f))', wf, 'UniformOutput', false);
        dirFiles = [ dirFiles{:} ];
        
        % dirFiles must be a row vector or stcat will fail.
        files = [files{:} strcat(clsDir, dirFiles)];
    
        % Get private files, and prepend <classDir>/private to each.
        pvtFiles = getPrivateFiles(clsDir);        
        if ~isempty(pvtFiles)
            pvtDir = fullfile(clsDir, 'private');
            files = [files strcat([pvtDir fs], pvtFiles')]; %#ok
        end
    end
end
