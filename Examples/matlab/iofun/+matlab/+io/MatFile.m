classdef (Sealed) MatFile < dynamicprops 
%matlab.io.MatFile Save and load parts of variables in MAT-files.
%   matlab.io.MatFile objects allow you to load and save parts of variables
%   in a MAT-file. Working with part of a variable requires less memory
%   than working with its entire contents.
%
%   MATOBJ = matfile(FILENAME) constructs an object that can load or save
%   parts of variables in MAT-file FILENAME. MATLAB does not load any data
%   from the file into memory when creating the object. FILENAME can
%   include a full or partial path, otherwise matfile searches along the 
%   MATLAB path. If the file does not exist, MATLAB creates the file on
%   the first assignment to a variable.
%
%   MATOBJ = matfile(FILENAME,'Writable',ISWRITABLE) enables or disables
%   write access to the file. ISWRITABLE is logical TRUE (1) or FALSE (0).
%   By default, matfile opens existing files with read-only access, but
%   creates new MAT-files with write access.
%
%   Access variables in MAT-file FILENAME as properties of MATOBJ, with dot
%   notation similar to accessing fields of structs. The syntax for loading
%   part of variable VARNAME into variable SMALLERVAR is
%
%      SMALLERVAR = MATOBJ.VARNAME(INDICES)
%
%   Similarly, the syntax for saving NEWDATA into variable VARNAME is
%
%      MATOBJ.VARNAME(INDICES) = NEWDATA
%
%   Specify part of a variable by defining indices for every dimension.
%   Indices can be a single value, an equally spaced range of increasing
%   values, or a colon (:), such as:
%
%      MATOBJ.VARNAME(100:500, 200:600)
%      MATOBJ.VARNAME(:, 501:1000)
%      MATOBJ.VARNAME(1:2:1000, 80)
% 
%   Limitations:
%
%    * Using the END keyword when indexing causes MATLAB to load the entire
%      variable into memory. To find the dimensions of a variable without
%      loading, call SIZE with this syntax:
%
%      SIZEMYVAR = SIZE(MATOBJ,'VARNAME')
%             
%    * matlab.io.MatFile only supports partial loading and saving for
%      MAT-files in V7.3 format. If you index into a variable in a V7 (the
%      current default) or earlier MAT-file, MATLAB warns and temporarily
%      loads the entire contents of the variable. All MAT-Files created
%      with matfile use V7.3 format.
%
%    * matlab.io.MatFile does not support linear indexing, or indexing into
%      sparse arrays, cells of cell arrays, fields of structs, or 
%      user-defined classes.
%
%    * You cannot assign complex values to an indexed portion of a real
%      array.
%
%    * You cannot evaluate function handles with a matlab.io.MatFile object.
%
%   Methods:
%
%      size    - Array dimensions
%      who     - Names of variables
%      whos    - Names, sizes, and types of variables
%
%      Call methods with function syntax, such as size(matObj,'varName').
% 
%      HELP on methods is unavailable. Find syntax information using the
%      DOC command, such as: 
%
%      doc matlab.io.MatFile/size
% 
%   Properties:
%
%      Properties.Source    - Fully qualified path to the file.
%      Properties.Writable  - Whether to allow saving to the file. Logical
%                             TRUE (1) or FALSE (0).
%
%   Example:
%
%      % Create a MAT-file
%      myfile = fullfile(tempdir,'myfile.mat');
%      matObj = matfile(myfile,'Writable',true);
%
%      % Save into a variable in the file
%      matObj.savedVar(81:100, 81:100) = magic(20);
%
%      % Find the size of a variable in the file
%      [nrows, ncols]=size(matObj,'savedVar');
%
%      % Load data from a variable in the file
%      loadVar = matObj.savedVar(nrows-19:nrows, 86:95);
%
%   See also load, save.

% Copyright 2011 The MathWorks, Inc.
    
    properties (SetAccess = private)
        %Properties - Properties that describe and affect the MatFile class.
        %
        %   Properties.Source    - Fully qualified path to the file.
        %   Properties.Writable  - Whether to allow saving to the file. Logical
        %                          TRUE (1) or FALSE (0).
        %
        %   Examples:
        %
        %     % Enable saving to an existing MAT-file.
        %     copyfile(which('durer.mat'), 'mycopy_durer.mat');
        %     durer = matfile('mycopy_durer.mat');
        %     durer.Properties.Writable = true;
        %    
        %     % View the location of a file.
        %     disp(durer.Properties.Source)
        %
        %   See also MatFile, load, save.
        Properties;

    end
    
    methods(Access = private, Hidden = true)

        function itDoes = sourceExists(obj)
            itDoes = exist(obj.Properties.Source,'file');
        end
        
        function info = getVariableInfoIfItExistsInSource(obj,varName)
            info = whos(obj, varName);
            if isempty(info)
                % varName is not in Source AND it's a method name
                if any(strcmp(varName, [methods(obj); {'size'; 'who'; 'whos'}]))
                    error(message('MATLAB:MatFile:DotSyntax', varName));
                end
                
                if ~sourceExists(obj)
                    error(message('MATLAB:MatFile:NoFile', varName, obj.Properties.Source));
                end
                                
                error(message('MATLAB:MatFile:VariableNotInFile', ...
                              varName, obj.Properties.Source));
            end
        end

        function output = inefficientPartialLoad(obj, indexingStruct, varName)
                warning(message('MATLAB:MatFile:OlderFormat', obj.Properties.Source, varName));
            output = loadEntireVariable(obj, varName);
            output = builtin('subsref', output, indexingStruct(2:end));
        end

        function output = loadEntireVariable(obj, varName)
            varsFromFile = load(obj.Properties.Source, varName, '-mat');
            output = varsFromFile.(varName);
        end
        
        function inefficientPartialSave(obj, indexingStruct, varName, value)
            % Get value into a temporary structure varsFromFile.  This
            % will use memory.
            warning(message('MATLAB:MatFile:OlderFormat', obj.Properties.Source, varName));
            if ~isempty(whos(obj, varName))
                varsFromFile = load(obj.Properties.Source, varName, '-mat');
            else
                varsFromFile.(varName) = [];
            end
            
            % Modify the temporary
            try
                varsFromFile.(varName) = builtin('subsasgn', varsFromFile(1).(varName), indexingStruct(2:end), value);
            catch caughtException
                if strcmp(caughtException.identifier,'MATLAB:subsassigndimmismatch')
                    newException = MException('MATLAB:save:sizeMismatch', '%s', getString(message('MATLAB:save:sizeMismatch')));
                    throw(newException)
                end
                throw(caughtException)
            end
            
            % Save the new data back to file
            save(obj.Properties.Source, '-fromStruct', varsFromFile, '-append');
        end

        function saveEntireVariable(obj, varName, value)
            varsFromFile.(varName) = value;
            if sourceExists(obj)
                flag = '-append';
            else
                flag = '-v7.3';
            end
            save(obj.Properties.Source, '-fromStruct', varsFromFile, flag);
        end
                
        function addDynamicProperty(obj, propName)
            try
                propMeta = obj.addprop(propName);
                propMeta.Transient = true;
            catch caughtException
                % Suppress PropertyInUse error.
                if ~strcmp(caughtException.identifier, 'MATLAB:class:PropertyInUse')
                    rethrow(caughtException);
                end
            end
        end
        
        function varargout = genericWho(obj, fcnHan, fcnName, varargin)
            nargoutchk(0,1);
            validateFirstArgIsObj(obj, fcnName);
            if ~sourceExists(obj)
                % Use '~' to represent a variable name that is not possible
                % to generate empty return value of the right type.
                [varargout{1:nargout}] = fcnHan('~');
            else
                [varargout{1:nargout}] = fcnHan('-file', ...
                                       obj.Properties.Source, varargin{:});
            end
            
        end
        
        function caughtException = overrideCaughtMessages(obj, caughtException, varName)
            if strcmp(caughtException.identifier,'MATLAB:Subset:ImproperIndexCell')
                try
                    varInfo = getVariableInfoIfItExistsInSource(obj, varName);
                    dims = length(varInfo.size);
                    caughtException = MException('MATLAB:MatFile:NeedsAllDims', '%s',...
                        getString(message('MATLAB:MatFile:NeedsAllDims', varName, dims)));
                catch secondCaughtException
                    if strcmp(secondCaughtException.identifier,'MATLAB:MatFile:VariableNotInFile')
                        caughtException = MException('MATLAB:MatFile:NeedsAllDimsDoesntExist', '%s',...
                            getString(message('MATLAB:MatFile:NeedsAllDimsDoesntExist', varName)));                    
                    end
                    % If it's not VariableNotInFile, then let the original ImproperIndexCell
                    % exception through.
                end
            end
        end
                               
    end % end methods(Access = private, Hidden = true)
    
    methods(Access = public, Hidden = true)

        function varargout = who(obj, varargin)
%WHO    Names of variables in MAT-File.
%   DETAILS = WHO(MATOBJ) lists all variables in the MAT-file associated
%   with MATOBJ. DETAILS is a cell array of variable name strings.
%
%   DETAILS = WHO(MATOBJ,VARIABLES) lists the specified variables. Use one
%   of these forms for VARIABLES:
%
%      VAR1,...,VARN    Comma-separated list of variable name strings.
%                       Use the '*' wildcard to match patterns.
%                       For example, who(MATOBJ,'A*') lists all variables
%                       that start with A.
%                                   
%      '-regexp', EXPR  Regular expressions that describe variable names.
%
%   Example:
%
%      durer = matfile('durer.mat');
%      who(durer)
%
%   See also matfile, whos, size, clear, clearvars, save, load.
            try
                [varargout{1:nargout}] = genericWho(obj, @who, 'WHO', varargin{:});
            catch caughtException
                throw(caughtException);
            end
        end

        function varargout = whos(obj, varargin)
%WHOS   Names, sizes, and types of variables in MAT-File. 
%   DETAILS = WHOS(MATOBJ) returns information about all variables in the
%   MAT-file associated with MATOBJ.
%
%   DETAILS = WHOS(MATOBJ,VARIABLES) returns information about the
%   specified variables.
%
%   Input Arguments:
%      MATOBJ     Object created by calling the MATFILE function.
%
%      VARIABLES  Names of variables in a MAT-File. Use one of these forms:
%                 VAR1,...,VARN    Comma-separated list of variable name
%                                  strings. Use the '*' wildcard to match
%                                  patterns. For example, whos(MATOBJ,'A*')
%                                  lists all variables that start with A.                                   
%                 '-regexp', EXPR  Regular expressions that describe
%                                  variable names.
% 
%   Output Argument:
%      DETAILS  Structure with these fields:
%               name        Variable name.
%               size        Dimensions of the variable.
%               bytes       Number of bytes allocated for the array when
%                           you load the entire variable.
%               class       Class (data type) of the variable
%               global      Whether the variable is global (TRUE or FALSE).
%               sparse      Whether the variable is sparse.
%               complex     Whether the value is complex.
%               nesting     Structure with two fields:
%                           function  Name of function that defines the
%                                     variable.
%                           level     Nesting level of the function.
%               persistent  Whether the variable is persistent.
%
%   Examples:
%
%      durer = matfile('durer.mat');
%      info = whos(durer, 'X');
%      sizeX = info.size
%      nDimsX = length(sizeX)
% 
%   See also matfile, who, size, clear, clearvars, save, load.
            try
                [varargout{1:nargout}] = genericWho(obj, @whos, 'WHOS', varargin{:});
            catch caughtException
                throw(caughtException);
            end
        end

        function varargout = size(obj, varargin)
%SIZE   Size of array.
%   ALLDIMS = SIZE(MATOBJ,VARIABLE) returns the size of each dimension of
%   the specified variable in the file corresponding to MATOBJ. ALLDIMS is
%   a 1-by-m vector, where m = ndims(VARIABLE).
% 
%   [DIM1,...,DIMN] = SIZE(MATOBJ,VARIABLE) returns the sizes of each
%   dimension in separate output variables DIM1,...,DIMN.
%
%       If N > NDIMS(MATOBJ.VARIABLE), SIZE returns ones in the "extra"
%       output variables corresponding to NDIMS(VARIABLE)+1 through N.
% 
%       If N < NDIMS(MATOBJ.VARIABLE), DIMN contains the product of the 
%       sizes of dimensions N through NDIMS(VARIABLE).
% 
%   SELECTEDDIM = SIZE(MATOBJ,VARIABLE,DIM) returns the size of the
%   specified dimension.
% 
%   Note:
%   
%   Do not call SIZE with the syntax SIZE(MATOBJ.VARNAME). This syntax
%   loads the entire contents of variable VARNAME into memory. For very
%   large variables, this load operation results in Out of Memory errors.
%
%   Examples:
%
%      durer = matfile('durer.mat');
%      [nrows, ncols] = size(durer, 'X')
%
%      mfObj = matfile('temp.mat','Writable',true);
%      mfObj.X = rand(2,3,4);
%      d = size(mfObj,'X')               % returns  d = [2 3 4]
%      [m1,m2,m3,m4] = size(mfObj,'X')   % m1 = 2, m2 = 3, m3 = 4, m4 = 1
%      [m,n] = size(mfObj,'X')           % m = 2, n = 12
%      m2 = size(mfObj,'X',2)            % m2 = 3
%
%   See also matfile, whos, who, save load, length, ndims, numel.
            narginchk(1,3);
            try
                validateFirstArgIsObj(obj, 'SIZE');
                if (nargin == 1) || (nargin == 2 && ~ischar(varargin{1}))
                    % These conditions amount to inquiring about the size of
                    % the object itself.
                    [varargout{1:nargout}] = builtin('size', obj, varargin{:});
                elseif nargin == 2
                    % Inquiry about variables in the object.
                    info = getVariableInfoIfItExistsInSource(obj, varargin{1});
                    if nargout <= 1
                        % Get all the dimensions in a single array.
                        varargout{1} = info.size;
                    else
                        % Return dimensions that fit into the request
                        % number of output arguments.
                        sizeArray = info.size;
                        dims = length(sizeArray);
                        if nargout > dims
                            % Request more outputs than dimensions in the
                            % variable. Loop only as many dims as there are.
                            outputElements = 1:dims;
                            % Populate the remaining trailing singleton
                            % dimensions.
                            [varargout{dims+1:nargout}] = deal(1);
                        else
                            % Requested fewer outputs than dims in
                            % variable. Loop over all the outputs except
                            % the last which is a product of all the
                            % remaining dimensions.
                            outputElements = 1:nargout-1;
                            varargout{nargout} = prod(sizeArray(nargout:dims));
                        end
                        varargout(outputElements) = num2cell(sizeArray(outputElements));
                    end
                else  % nargin == 3
                    % Inquiry about a specified dimension of variables in
                    % the object.
                    dim = varargin{2};
                    validateattributes(dim,{'numeric'},{'scalar','positive','integer'})
                    info = getVariableInfoIfItExistsInSource(obj, varargin{1});
                    if length(info.size) >= dim
                        varargout{1} = info.size(dim);
                    else
                        % When dim requested exceeds the dimensions of the
                        % variable then the trailing dimensions are singleton.
                        varargout{1} = 1;
                    end
                end
            catch caughtException
                throw(caughtException)
            end
        end
        
        function obj = MatFile(Source, varargin)
            
            narginchk(1, inf);
          
            obj.Properties = matlab.io.matfile.Properties(resolveSource(Source));
            
            % Validate, parse, and set param-value pairs
            parseInputs = inputParser;
            parseInputs.addParameter('Writable', obj.Properties.Writable);
            parseInputs.parse(varargin{:});
            try
                obj.Properties.Writable = parseInputs.Results.Writable;
            catch caughtException
                throw(caughtException);
            end
            
            varInfo = whos(obj);
            if any(strcmp('Properties',{varInfo.name}))
                % If file already has a variable named "Properties" warn
                % that it is inaccessible.
                warning(message('MATLAB:MatFile:SourceHasReservedNameConflict', obj.Properties.Source));
            end
            % Make variables into properties
            for i=1:length(varInfo)
                addDynamicProperty(obj, varInfo(i).name)
            end
        end
        
        function varargout = subsref(obj, indexingStruct)
            varName = indexingStruct(1).subs;
            try
                if strcmp(varName,'Properties')
                    % Special cases for obj.Properties
                    if length(indexingStruct)> 1 && ~isequal(indexingStruct(2).type, '.')
                        error(message('MATLAB:MatFile:NoIndexingIntoProperties'));
                    else
                        [varargout{1:nargout}] = builtin('subsref', obj, indexingStruct);
                    end
                else
                    validateVariableIndexing(indexingStruct)
                    varInfo = getVariableInfoIfItExistsInSource(obj, varName);
                    switch length(indexingStruct)
                    case 1 % No indexing into the variable
                        [varargout{1:nargout}] = loadEntireVariable(obj, varName);
                    case 2
                        if ~strcmp(indexingStruct(2).type, '()')
                            error(message('MATLAB:MatFile:NotSmoothIndexing', varName));
                        end
                        checkForOverriddenIndexing(varInfo, 'subsref');
                        % createMetaDescriptionOfIndexing is called outside
                        % the following condition because it enforces
                        % common limitations on indexing.
                        varSubset = createMetaDescriptionOfIndexing(varName, varInfo, indexingStruct);
                        if obj.Properties.SupportsPartialAccess
                            [varargout{1:nargout}] = matlab.internal.language.partialLoad(obj.Properties.Source, varSubset, '-mat');
                        else
                            [varargout{1:nargout}] = inefficientPartialLoad(obj, indexingStruct, varName);
                        end
                    otherwise
                        error(message('MATLAB:MatFile:NotSmoothIndexing', varName));   
                    end
                end
            catch caughtException
                caughtException = overrideCaughtMessages(obj, caughtException, varName);
                throwAsCaller(caughtException)
            end
        end

        function obj = subsasgn(obj, indexingStruct, value)
            % the only time it trips into this IF block, is when 'value' is
            % a MatFile object, and obj doesn't already exist. e.g.
            %   >> obj(1) = matfile('foo.mat','Writable',true)
            %
            % This works as long as we cannot create empty MatFile objects
            % and we cannot create arrays (even somehow)
            if isequal(obj, [])
                error(message('MATLAB:MatFile:NoObjectArrays'));
            end
            
            varName = indexingStruct(1).subs;

            try
                % Handle the deletion on MATLAB's side, then write over the
                % variable on the the MatFile side.
                if strcmp(indexingStruct(1).type,'.') ...
                        && numel(indexingStruct) > 1 ...
                        && builtin('_isEmptySqrBrktLiteral',value)
                    
                    value = loadEntireVariable(obj, varName);
                    value = subsasgn(value,indexingStruct(2:end),[]);
                    indexingStruct(end) = [];
                end
            
                if strcmp(varName,'Properties')
                    % Special cases for obj.Properties
                    if length(indexingStruct)==1
                        error(message('MATLAB:MatFile:ReservedNameConflict'));
                    elseif indexingStruct(2).type ~= '.'
                        error(message('MATLAB:MatFile:NoIndexingIntoProperties'));
                    else
                        obj = builtin('subsasgn',obj, indexingStruct, value);
                    end
                else
                    if ~obj.Properties.Writable
                        error(message('MATLAB:MatFile:ObjectNotWritable', varName, varName));
                    end
                    validateVariableIndexing(indexingStruct)
                    switch length(indexingStruct) 
                        case 1 % No indexing into the variable
                            saveEntireVariable(obj, varName, value)
                        case 2
                            if ~strcmp(indexingStruct(2).type, '()')
                                error(message('MATLAB:MatFile:NotSmoothIndexing', varName));
                            end
                            varInfo = whos(obj, varName);
                            checkForOverriddenIndexing(varInfo, 'subsasgn');
                            varSubset = createMetaDescriptionOfIndexing(varName, varInfo, indexingStruct);

                            if obj.Properties.SupportsPartialAccess
                                matlab.internal.language.partialSave(obj.Properties.Source, value, varSubset);
                            else
                                inefficientPartialSave(obj, indexingStruct, varName, value)
                            end
                        otherwise
                            error(message('MATLAB:MatFile:NotSmoothIndexing', varName));      
                    end
                    addDynamicProperty(obj, varName);
                end
            catch caughtException
                caughtException = overrideCaughtMessages(obj, caughtException, varName);
                throwAsCaller(caughtException)
            end
        end

        function disp(obj)
            
            if ~isscalar(obj) || ~isvalid(obj)
                disp@dynamicprops(obj);
                return;
            end
            
            className = class(obj);
            if matlab.internal.display.isHot
                fprintf('  <a href="matlab:help %1$s">%1$s</a>\n',className);
            else
                fprintf('  %s\n',className);
            end
            
            fprintf('\n  Properties:\n');
            
            % Get names of properties and variables.
            propNames = properties(obj.Properties);
            propNamesLabels = strcat('Properties.',propNames);
            varInfo = whos(obj);
            
            % Generate display of names "LHS"
            allNames = strjust(char([propNamesLabels; {varInfo.name}']), 'right');
            rows = size(allNames,1); 
            lhs = [repmat(' ',rows,4) strcat(allNames,':') repmat(' ',rows,1)];

            % Get size and type of properites and variables
            propValues = cell(length(propNames),1);
            for i = 1:length(propNames)
                propValues{i} = mat2str(obj.Properties.(propNames{i}));
            end
            varSize = cellfun(@sizeToString, {varInfo.size}, 'UniformOutput', false);

            % Generate display of values "RHS"
            if ~isempty(varSize)
                sizeAndTypeStr = [char(varSize), repmat(' ',length(varInfo),1),...
                                  char({varInfo.class})];
                sizeAndTypeStr = strcat('[', sizeAndTypeStr, ']');
                rhs = char(char(propValues),sizeAndTypeStr);
            else
                rhs = char(propValues);
            end
            
            % Combine and display
            disp([lhs,rhs]);
                        
            if matlab.internal.display.isHot
                fprintf('\n  <a href="matlab:methods %s">Methods</a>\n',className)
            end
            
            fprintf('\n')
            
        end

        function varargout = horzcat(obj, varargin)                        %#ok<MANU,STOUT> Knowingly not using input or output.
            error(message('MATLAB:MatFile:CannotConcatenate'));
        end
        function varargout = vertcat(obj, varargin)                        %#ok<MANU,STOUT> Knowingly not using input or output.
            error(message('MATLAB:MatFile:CannotConcatenate'));
        end
        function varargout = cat(obj, varargin)                            %#ok<MANU,STOUT> Knowingly not using input or output.
            error(message('MATLAB:MatFile:CannotConcatenate'));
        end
        
        % Methods that we inherit, but do not want to show
        function out = findobj(obj1, obj2)
            out = findobj@handle(obj1, obj2);
        end
        function out = findprop(obj1, obj2)
            out = findprop@handle(obj1, obj2);
        end
        function out = addlistener(obj1, obj2)
            out = addlistener@handle(obj1, obj2);
        end
        function out = notify(obj1, obj2)
            out = notify@handle(obj1, obj2);
        end
        function delete(obj)
            delete@handle(obj);
        end
        function out = addprop(obj1, obj2)
            out = addprop@dynamicprops(obj1, obj2);
        end
        function out = eq(obj1, obj2)
            out = eq@dynamicprops(obj1, obj2);
        end
        function out = ge(obj1, obj2)
            out = ge@dynamicprops(obj1, obj2);
        end
        function out = gt(obj1, obj2)
            out = gt@dynamicprops(obj1, obj2);
        end
        function out = le(obj1, obj2)
            out = le@dynamicprops(obj1, obj2);
        end
        function out = lt(obj1, obj2)
            out = lt@dynamicprops(obj1, obj2);
        end
        function out = ne(obj1, obj2)
            out = ne@dynamicprops(obj1, obj2);
        end
        
    end % end methods(Access = public, Hidden = true)

    methods(Access = public, Hidden = true, Static)

        function varargout = empty(obj, varargin)                          %#ok<STOUT,INUSD> Knowingly not using input or output.
            error(message('MATLAB:MatFile:NoEmptyMatFiles'));
        end
        
    end % end methods(Access = public, Hidden = true, Static)
    
end

function sourceName = resolveSource(sourceName)
    try
        sourceName = matlab.internal.language.findFullMATFilename(sourceName);
    catch caughtException
        throwAsCaller(caughtException);
    end

    [~, ~, ext]=fileparts(sourceName);
    if ~exist(sourceName, 'file') && isempty(ext)
        sourceName = [sourceName '.mat'];
    end
end

function validateVariableIndexing(indexingStruct)
    if ~strcmp(indexingStruct(1).type, '.')
        error(message('MATLAB:MatFile:VarAccessOp'));
    end

    if ~ischar(indexingStruct(1).subs)
        error(message('MATLAB:MatFile:VarAccessName'));
    end
end

function varSubset = createMetaDescriptionOfIndexing(varName, varInfo, indexingStruct) 
    %createMetaDescriptionOfIndexing is a method that process the
    %   request indexing operations passed in through subsref and
    %   subsasgn.  It returns a meta description of the indexing in
    %   the form of a VariableSubset.
    
    % Currently we only support one level of indexing after the initial ".".
    % So depthOfIndexing starts and ends at 2.  In the future this might be an
    % array that loops.
    depthOfIndexing = 2;
    indexExpression = indexingStruct(depthOfIndexing).subs;
    if iscellstr(indexExpression) && ~any(strcmp(indexExpression,':'))
        % indexExpression is a char for struct/obj field
        % indexing.
        subsets = matlab.internal.language.Subset(indexingStruct(depthOfIndexing).type, {indexExpression});
    else
        % indexExpression is a cell for numeric/logical indexing.
        numberOfDims = length(indexExpression);
        boundsTriplet = cell(1,numberOfDims);
        for dim = 1:numberOfDims
            % Reduce indexExpression for the given dim from a
            % potentially large indexVector to a bounds and
            % stride triplet.
            indexVector = indexExpression{dim};
            stride = 1;
            if strcmp(indexVector, ':')
                % For colon bounds are the entire
                % indexExpression for the given dim.
                minBound = 1;
                if isempty(varInfo)
                    error(message('MATLAB:MatFile:colonLHS'));
                end
                maxBound = varInfo.size(dim);
                if maxBound == 0
                    error(message('MATLAB:MatFile:emptyVariableWithColonIndex', varName));
                end
            else
                if ~isnumeric(indexVector)
                    error(message('MATLAB:MatFile:IndexMustBeNumeric',varName, class(indexVector)));
                end
                % For a vector of indices define bounds and
                % stride.
                maxBound = max(indexVector);
                minBound = min(indexVector);
                if numel(indexVector)>1
                    % The difference between the first elements
                    % of an indexVector is the stride.
                    stride = indexVector(2) - indexVector(1);
                end
                if isempty(indexVector)
                    error(message('MATLAB:MatFile:emptyIndex', varName));
                end
                    
                if ~isequal(indexVector(:)', minBound:stride:maxBound) || stride <= 0
                    error(message('MATLAB:MatFile:SubsetBoundsAndIntervals', varName));
                end
                if minBound <= 0 || ~all(floor([minBound, stride, maxBound])==[minBound, stride, maxBound]) % isint
                    error(message('MATLAB:MatFile:badsubscript'));
                end
            end
            boundsTriplet{dim} = [minBound stride maxBound];
        end
        % Create Subset for numeric/logical indexing
        subsets = matlab.internal.language.Subset(indexingStruct(depthOfIndexing).type, boundsTriplet);
    end
    varSubset = matlab.internal.language.VariableSubset(varName, subsets);
end

function validateFirstArgIsObj(obj, methodName)
    if ~isa(obj, 'matlab.io.MatFile')
        % First argument must be a MatFile
        error(message('MATLAB:MatFile:InputNotMatFile', methodName));
    end
end

function prettySize = sizeToString(sizeValue)
    dims = length(sizeValue);
    switch dims
        case 0
            prettySize = ' - ';
        case {1,2}
            prettySize = sprintf('%dx%d', sizeValue(1), sizeValue(2));
        otherwise
            prettySize = sprintf('%d-D',dims);
    end
end

function checkForOverriddenIndexing(varInfo, method)
    % If a non-"built-in" class overrides the input method issue an error about indexing.
    if ~isempty(varInfo) && ~any(strcmp({'double', 'single', 'logical', 'cell', 'struct', 'char',...
            'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}, varInfo.class))
        metainfo = metaclass(varInfo.class);
        if any(strcmp({metainfo.MethodList.Name}, method));
            error(message('MATLAB:MatFile:overriddenIndexing', varInfo.name, varInfo.class, varInfo.name));
        end
    end
end