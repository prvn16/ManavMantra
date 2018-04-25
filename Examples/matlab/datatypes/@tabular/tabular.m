classdef (AllowedSubclasses = {?timetable ?table}) tabular < matlab.mixin.internal.indexing.DotParen & matlab.internal.datatypes.saveLoadCompatibility
% Internal abstract superclass for table and timetable.
% This class is for internal use only and will change in a future release. Do not use this class.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties(Constant, Access='protected') % *** may go back to private if every instance is in tabular
        arrayPropsDflts = struct('Description', {''}, ...
                                 'UserData'   , []);
    end
    
    properties(Abstract, Constant, Access='protected')
        % Constant properties are not persisted when serialized
        propertyNames
        defaultDimNames
        dispRowLabelsHeader
    end

    properties(Abstract, Access='protected')
        metaDim
        rowDim
        varDim
        data
        arrayProps
    end

    properties(Dependent, SetAccess='protected')
        %PROPERTIES Table or timetable metadata properties.
        %   T.Properties, where T is a table or a timetable, is a scalar struct containing the
        %   following metadata:
        %
        %       Description           - A character vector describing the table
        %       UserData              - A variable containing any additional information associated
        %                               with the table.  You can assign any value to this property.
        %       DimensionNames        - A two-element cell array of character vectors containing names
        %                               of the dimensions of the table
        %       VariableNames         - A cell array containing names of the variables in the table
        %       VariableDescriptions  - A cell array of character vectors containing descriptions of
        %                               the variables in the table
        %       VariableUnits         - A cell array of character vectors containing units for the
        %                               variables in table
        %       RowNames (tables)     - A cell array of nonempty, distinct character vectors containing
        %                               names of the rows in the table
        %       RowTimes (timetables) - A datetime or durations vector containing times associated
        %                               with each row in the timetable
        %
        %   See also TABLE, TIMETABLE.
        Properties
    end
    methods % dependent property get methods
        function val = get.Properties(a)
            val = getProperties(a);
        end
    end
    
    methods(Hidden)
        function props = getProperties(t)
            % This function is for internal use only and will change in a future release.
            % Do not use this function. Use t.Properties instead.
            import matlab.internal.datatypes.mergeScalarStructs
            props = mergeScalarStructs(t.arrayProps, ...
                                       t.metaDim.getProperties(), ...
                                       t.varDim.getProperties(), ...
                                       t.rowDim.getProperties());
            props = orderfields(props,t.propertyNames);
        end
        
        function t = setProperties(t,s)
            %SET Set some or all table properties from a scalar struct.
            % This function is for internal use only and will change in a future release.
            % Do not use this function. Use t.Properties instead.
            if ~isstruct(s) || ~isscalar(s)
                error(message('MATLAB:table:InvalidPropertiesAssignment'));
            end
            fnames = fieldnames(s);
            for i = 1:length(fnames)
                fn = fnames{i};
                t = t.setProperty(fn,s.(fn));
            end
        end

        % Allows tab completion after dot to suggest variables
        function p = properties(t)
            % This will be called for properties of an instance, but the built-in will
            % be still be called for the class name.  It will return just Properties,
            % which is correct.

            pp = [t.varDim.labels(:); 'Properties'; t.metaDim.labels(:)];
            if nargout == 0
                % get 1 or 0 newlines based on format loose/compact
                line_ending = repmat(newline,1,strcmp(matlab.internal.display.formatSpacing,'loose'));
                fprintf([line_ending '%s\n' line_ending], getString(message('MATLAB:ClassUstring:PROPERTIES_FUNCTION_LABEL',class(t))));
                fprintf('    %s\n',pp{:});
                fprintf(line_ending);
            else
                p = pp;
            end
        end
        function f = fieldnames(t), f = properties(t); end
        function f = fields(t),     f = properties(t); end
        
        function vars = getVars(t,asStruct)
            % This function is for internal use only and will change in a future release.
            % Do not use this function. Use table2struct(t,'AsScalar',true) instead.
            if nargin < 2 || asStruct
                vars = cell2struct(t.data,t.varDim.labels,2);
            else
                vars = t.data;
            end
        end
        
        % Methods we don't want to clutter things up with
        e = end(t,k,n)
        B = repelem(A,M,N,varargin)
        disp(t,bold,indent,fullChar,nestedLevel)
        display(obj, name)
        [varargout] = subsref(t,s)
        t = subsasgn(t,s,b)
        
        % These functions are for internal use only and will change in a
        % future release.  Do not use these functions.
        b = dotParenReference(t,vn,s1,s2,varargin)
        sz = numArgumentsFromSubscript(t,s,context)
        [vars,varData,sortMode,sortModeStrs,varargout] = sortrowsFlagChecks(t,doIssortedrows,vars,sortMode,varargin)
        [vars,varData,sortMode,labels,varargin] =  topkrowsFlagChecks(a,vars,sortMode,varargin)
                
        %% Variable Editor methods
        % These functions are for internal use only and will change in a
        % future release.  Do not use these functions.
        varargout  = variableEditorGridSize(t)
        [names,indices,classes,iscellstr,charArrayWidths] = variableEditorColumnNames(t)
        rowNames   = variableEditorRowNames(t)
        [code,msg] = variableEditorRowDeleteCode(t,workspaceVariableName,rowIntervals)
        [code,msg] = variableEditorColumnDeleteCode(t,workspaceVariableName,columnIntervals)
        t          = variableEditorPaste(t,rows,columns,data)
        t          = variableEditorInsert(t,orientation,row,col,data)
        [code,msg] = variableEditorSetDataCode(t,workspaceVariableName,row,col,rhs)
        [code,msg] = variableEditorUngroupCode(t,varName,col)
        [code,msg] = variableEditorGroupCode(t,varName,startCol,endCol)
        metaData   = variableEditorMetadata(t)
        [code,msg] = variableEditorMetadataCode(t,varName,index,propertyName,propertyString)
        [code,msg] = variableEditorRowNameCode(t,varName,index,rowName)
        [code,msg] = variableEditorSortCode(t,varName,tableVariableNames,direction)
        [code,msg] = variableEditorMoveColumn(t,varName,startCol,endCol)
                
        %% Error stubs
        % Methods to override functions and throw helpful errors
        function d = double(d), throwInvalidNumericConversion(d); end
        function d = single(d), throwInvalidNumericConversion(d); end
        function t = length(varargin),     throwUndefinedLengthError(varargin{1}); end %#ok<STOUT>
        function t = sort(varargin),       throwUndefinedSortError(varargin{1}); end %#ok<STOUT>
        function t = transpose(varargin),  throwUndefinedError(varargin{1}); end %#ok<STOUT>
        function t = ctranspose(varargin), throwUndefinedError(varargin{1}); end %#ok<STOUT>
        function t = permute(varargin),    throwUndefinedError(varargin{1}); end %#ok<STOUT>
        function t = reshape(varargin),    throwUndefinedError(varargin{1}); end %#ok<STOUT>
        function t = plot(t), error(message('MATLAB:table:NoPlotMethod',class(t),class(t))); end
    end % hidden methods block
        
    methods(Abstract, Hidden, Static)
        t = empty(varargin)
        
        % These functions are for internal use only and will change in a
        % future release.  Do not use these functions.
        t = fromScalarStruct(s)
        t = init(vars, numRows, rowLabels, numVars, varnames)
    end % abstract hidden static methods block
    
    methods(Access = 'protected')
        t = setDescription(t,newDescr)
        t = setUserData(t,newData)

        [varargout] = subsrefParens(t,s)
        [varargout] = subsrefBraces(t,s)
        [varargout] = subsrefDot(t,s)
        t = subsasgnParens(t,s,b,creating,deleting)
        t = subsasgnBraces(t,s,b)
        t = subsasgnDot(t,s,b,deleting)

        b = extractData(t,vars,like,a)
        t = replaceData(t,x,vars)
        
        writeTextFile(t,file,args)
        writeXLSFile(t,xlsfile,ext,args)
        
        varIndices = getVarOrRowLabelIndices(t,varSubscripts,allowEmptyRowLabels)
        varData = getVarOrRowLabelData(t,varIndices,warnMsg)
        [group,glabels,glocs] = table2gidx(a,avars,reduce)
        varIndex = subs2indsErrorHandler(a,varName,ME,callerID)
        
        function errID = throwSubclassSpecificError(~,msgid,varargin)
            % THROWSUBCLASSSPECIFICERROR is called by overloads in the subclasses and returns an
            % MException that is specific to the subclass which can then be returned to the
            % caller or thrown.
            try
                msg = message(['MATLAB:' msgid],varargin{:});
            catch ME
                if strcmp(ME.identifier,'MATLAB:builtins:MessageNotFound')
                    % This function should never be called with a non-existant ID
                    assert(false);
                else
                    rethrow(ME);
                end
            end
            errID = MException(msg.Identifier,msg.getString());
        end
        
        function t = initInternals(t, vars, nrows, rowLabels, nvars, varnames)
            % INITINTERNALS Fills an empty tabular object with data and dimension objects. This
            % function is for internal use only and will change in a future release.  Do not use
            % this function.
            try
                t.rowDim = t.rowDim.createLike(nrows,rowLabels);
                t.varDim = t.varDim.createLike(nvars,varnames); % error if invalid, duplicate, or empty
                t.data = vars;
            catch ME
                throwAsCaller(ME)
            end
        end
    end % protected methods block
    
    methods(Abstract, Access = 'protected')
        b = cloneAsEmpty(a)
        
        % Used by summary method
        rowLabelsStruct = summarizeRowLabels(t);
        printRowLabelsSummary(t,rowLabelsStruct);
    end % abstract protected methods block
    
    methods(Access = 'private')
        varIndex = getGroupingVarOrTime(t,varName)
        [varargout] = getProperty(t,name,createIfEmpty)
        t = setProperty(t,name,p)
        t = lengthenTo(t,newLen)
    end
    
    methods (Static, Hidden)
        vars = container2vars(c)
    end % static hidden methods block
    
    methods(Static, Access = 'protected')
        b = lengthenVar(a,n)
        [ainds,binds] = table2midx(a,b)
        [leftVars,rightVars,leftVarDim,rightVarDim,leftKeyVals,rightKeyVals,leftKeys,rightKeys] ...
                = joinUtil(a,b,type,leftTableName,rightTableName, ...
                           keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied);
        [c,il,ir] = joinInnerOuter(a,b,leftOuter,rightOuter,leftKeyvals,rightKeyvals, ...
                                   leftVars,rightVars,leftKeys,rightKeys,leftVarnames,rightVarnames)
        
        function [numVars, numRows] = countVarInputs(args)
        %COUNTVARINPUTS Count the number of data vars from a tabular input arg list
            import matlab.internal.datatypes.isCharString
            argCnt = 0;
            numVars = 0;
            numRows = 0;
            while argCnt < length(args)
                argCnt = argCnt + 1;
                arg = args{argCnt};
                if isCharString(arg) % matches any character vector, not just a parameter name
                    % Put that one back and start processing param name/value pairs
                    argCnt = argCnt - 1; %#ok<NASGU>
                    break
                elseif isa(arg,'function_handle')
                    error(message('MATLAB:table:FunAsVariable'));
                else % an array that will become a variable in t
                    numVars = numVars + 1;
                end
                numRows_j = size(arg,1);
                if argCnt == 1
                    numRows = numRows_j;
                elseif ~isequal(numRows_j,numRows)
                    error(message('MATLAB:table:UnequalVarLengths'));
                end
            end % while argCnt < numArgs, processing individual vars
        end
        
        function vars = createVariables(types,sz)
            % Create variables of the specified types, of the specified height,
            % for a preallocated table, filled with each type's default value.
            nrows = sz(1);
            nvars = sz(2);
            vars = cell(1,nvars); % a row vector
            for ii = 1:nvars
                type = types{ii};
                if strcmp(type,'cellstr') || strcmp(type,'char')
                    if strcmp(type,'char')
                        % Special case: replace 'char' with 'cellstr', with a warning. A char
                        % array is tempting but not a good choice for text data in a table.
                        matlab.internal.datatypes.warningWithoutTrace(message('MATLAB:table:PreallocateCharWarning'));
                    end
                    % cellstr is a special case that's not actually a type name.
                    vars{ii} = repmat({''},nrows,1);
                else
                    if nrows > 0 % lengthenVar requires n > 0
                        % Use lengthenVar to create a var of the correct height. Not
                        % all types have their name as a constructor, e.g. double.
                        % So instead of creating a scalar instance to lengthen,
                        % create an empty instance.
                        try
                            % Create 0x0, lengthenVar will turn it into an Nx1, but
                            % would turn a 1x0 into an  Nx0 empty.
                            emptyVar = eval([type '.empty(0,0)']);
                        catch ME
                            throwAsCaller(preallocationClassErrorException(ME,type));
                        end
                        % lengthenVar creates an instance of var_ii that is nrows-by-1,
                        % filled in with the default (not necessarily "missing") value.
                        try
                            vars{ii} = tabular.lengthenVar(emptyVar,nrows);
                        catch
                            % lengthenVar failed, but we can still create an nrows-by-0 instance.
                            vars{ii} = eval([type '.empty(nrows,0)']); % don't use reshape, may not be one
                        end
                    else
                        try
                            vars{ii} = eval([type '.empty(0,1)']);
                        catch ME
                            throwAsCaller(preallocationClassErrorException(ME,type));
                        end
                    end
                end
            end
        end
        
        function numRows = verifyCountVars(vars)
            % Error check vars and return the number of rows
            numRows = 0;
            for i = 1:numel(vars)
                var = vars{i};
                numRows_i = size(var,1);

                if isa(var,'function_handle')
                    error(message('MATLAB:table:FunAsVariable'));
                end

                if i == 1
                    numRows = numRows_i;
                else
                    if ~isequal(numRows,numRows_i)
                        error(message('MATLAB:table:UnequalVarLengths'));
                    end
                end
            end 
        end
        
        function warnIfAmbiguousText(vars,numRows,pnames)
            if numRows == 1
                % Check to see if any scalar text in the single row
                % construction matches a parameter name. If so,
                % warn about the ambiguity.
                for k = 1:numel(vars)
                    if ischar(vars{k}) 
                        pNameMatch = strcmpi(vars{k},pnames);
                        if any(pNameMatch)
                            warning(message('MATLAB:table:ScalarTextAmbiguity', pnames{find(pNameMatch,1)}));
                            break;
                        end
                    end
                end
            end
        end
        
        function s = handleFailedToLoadVars(s,numRows,numVars,varNames)
            % Detect if some variables failed to load and replace those
            % variables with numRows-by-0 empty double
            
            % Tabular variables always have the same consistent number of
            % rows. When a variable's number of rows is inconsistent with
            % numRows, the variable _must_ have failed to load properly --
            % likely because the class is not defined in loading session.
            % Replace data in failed-to-load variables with numRows-by-0
            % empty double to maintain integrity of the tabular instance
            isVarNumRowsMismatch = false(1,numVars);
            for i = 1:numVars
                isVarNumRowsMismatch(i) = (size(s.data{i},1)~=numRows);
            end
            
            if any(isVarNumRowsMismatch)
                s.data(isVarNumRowsMismatch) = {zeros(numRows,0)};
                
                if (nnz(isVarNumRowsMismatch)==1)
                    matlab.internal.datatypes.warningWithoutTrace(message('MATLAB:tabular:CannotLoadVariable',varNames{isVarNumRowsMismatch}));
                else
                    matlab.internal.datatypes.warningWithoutTrace(message('MATLAB:tabular:CannotLoadVariables'));
                end
            end
        end
    end % static protected methods block
    
    methods(Static, Access = 'private')
        tf = iscolon(indices)
        name = matchPropertyName(name,propertyNames,exact)
        a_arrayProps = mergeArrayProps(a_arrayProps,b_arrayProps)
        flag = setmembershipFlagChecks(args)
        var = writetableMatricize(var)
    end % static private methods block
    
    methods(Access = ?matlab.unittest.TestCase)
        function b = extractDataTestHook(t,vars)
            b = extractData(t,vars);
        end
    end % test hooks block
end % classdef

%-----------------------------------------------------------------------------
function throwUndefinedLengthError(obj,varargin)
st = dbstack;
name = regexp(st(2).name,'\.','split');
m = message('MATLAB:table:UndefinedLengthFunction',name{2},class(obj));
throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end % function

%-----------------------------------------------------------------------------
function throwUndefinedSortError(obj,varargin)
st = dbstack;
name = regexp(st(2).name,'\.','split');
m = message('MATLAB:table:UndefinedSortFunction',name{2},class(obj));
throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end % function

%-----------------------------------------------------------------------------
function throwUndefinedError(obj,varargin)
st = dbstack;
name = regexp(st(2).name,'\.','split');
m = message('MATLAB:table:UndefinedFunction',name{2},class(obj));
throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end % function

%-----------------------------------------------------------------------------
function throwInvalidNumericConversion(obj,varargin)
st = dbstack;
name = regexp(st(2).name,'\.','split');
m = message('MATLAB:table:InvalidNumericConversion',name{2},class(obj));
throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end % function

%-----------------------------------------------------------------------------
function ME = preallocationClassErrorException(ME,type)
if strcmp(ME.identifier,'MATLAB:undefinedVarOrClass')
    theMatch = matlab.internal.language.introspective.safeWhich(type,false);
    if isempty(theMatch)
        ME = MException(message('MATLAB:table:PreAllocationUndefinedClass',type));
    else
        [~,theMatch,~] = fileparts(theMatch);
        ME = MException(message('MATLAB:table:PreAllocationClassnameCase',type,theMatch));
    end
else
    ME = MException(message('MATLAB:table:InvalidPreallocationVariableType',type,ME.message));
end
end % function