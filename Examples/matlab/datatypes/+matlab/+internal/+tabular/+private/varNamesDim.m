classdef (Sealed) varNamesDim < matlab.internal.tabular.private.tabularDimension
%VARNAMESDIM Internal class to represent a tabular's variables dimension.

% This class is for internal use only and will change in a
% future release.  Do not use this class.

    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Constant, GetAccess=public)
        propertyNames = {'VariableNames'; 'VariableDescriptions'; 'VariableUnits'; 'VariableContinuity'};
        requireLabels = true;
        requireUniqueLabels = true;
    end
    
    properties(GetAccess=public, SetAccess=private)
        descrs = {}
        units = {}
        continuity = []; % Empty 0x0 enum
        
        % Having no descrs/units is not the same as a zero-length dimension that
        % has zero descrs/units.
        hasDescrs = false
        hasUnits = false
        hasContinuity = false
    end
    
    %===========================================================================
    methods
        function obj = varNamesDim(length,labels)
            import matlab.internal.datatypes.isCharStrings
            import matlab.internal.tabular.private.varNamesDim
            
            if nargin == 0
                length = 0;
                labels = cell(1,0);
            elseif nargin == 1
                labels = varNamesDim.dfltLabels(1:length);
            else            
                % This is the relevant parts of validateAndAssignLabels
                if ~isCharStrings(labels,true,false) % require cellstr, no empties
                    error(message('MATLAB:table:InvalidVarNames'));
                end
                labels = strtrim(labels(:)'); % a row vector, conveniently forces any empty to 0x1
                varNamesDim.makeValidName(labels,'error');
                varNamesDim.checkDuplicateLabels(labels);
                varNamesDim.checkReservedNames(labels);
            end            
            obj = obj.init(length,labels);
        end
        
        %-----------------------------------------------------------------------
        function obj = init(obj,dimLength,dimLabels,varDescriptions,varUnits,varContinuity)
            
            obj = init_impl(obj,dimLength,dimLabels);

            % Set the properties provided. For performance, first check the new
            % value is different from the current one, and avoid error checking
            % because the new values are ASSUMED already verified by the caller
            turnOffErrorCheck = true;
            if (nargin>=4) && ~isequal(obj.descrs, varDescriptions)
                obj = obj.setDescrs(varDescriptions, turnOffErrorCheck);
            end
            
            if (nargin>=5) && ~isequal(obj.units, varUnits)
                obj = obj.setUnits(varUnits, turnOffErrorCheck);
            end
            
            if (nargin>=6) && ~isequal(obj.continuity, varContinuity)
                obj = obj.setContinuity(varContinuity, turnOffErrorCheck);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = createLike(obj,dimLength,dimLabels)
            if nargin < 3
                obj = obj.createLike_impl(dimLength);
            else
                obj = obj.createLike_impl(dimLength,dimLabels);
            end
            obj.hasUnits = false;
            obj.units = {};
            obj.hasDescrs = false;
            obj.descrs = {};
            obj.hasContinuity = false;
            obj.continuity =  [];
        end
                
        %-----------------------------------------------------------------------
        function labels = defaultLabels(obj,indices)
            if nargin < 2
                indices = 1:obj.length;
            end
            labels = obj.dfltLabels(indices);
        end
        
        %-----------------------------------------------------------------------
        function obj = lengthenTo(obj,maxIndex,newLabels)
            newIndices = (obj.length+1):maxIndex;
            if nargin < 3
                % Create default names for the new vars, making sure they don't conflict with
                % existing names.
                newLabels = obj.dfltLabels(newIndices);
                newLabels = matlab.lang.makeUniqueStrings(newLabels,obj.labels,namelengthmax);
                obj.labels(1,newIndices) = newLabels(:);
            else
                % Assume that newLabels has already been checked by validateNativeSubscripts as
                % names. But still have to make sure the names are legal.
                for j = 1:numel(newLabels)
                    obj.checkReservedNames(newLabels{j});
                end
                obj.makeValidName(newLabels,'error');
                
                obj.labels(1,newIndices) = newLabels(:);
            end
            obj.length = maxIndex;
            
            % Per-var properties need to be lengthened.
            if obj.hasDescrs, obj.descrs(1,newIndices) = {''}; end
            if obj.hasUnits, obj.units(1,newIndices) = {''}; end
            if obj.hasContinuity, obj.continuity(1,newIndices) = 'unset'; end
        end
        
        %-----------------------------------------------------------------------
        function [indices,numIndices,maxIndex,isColon,updatedObj] = subs2inds(obj,subscripts,subsType,tData)
            %SUBS2INDS Convert table subscripts (labels, logical, numeric) to indices.
            try
                oldLength = obj.length;
                
                if nargin < 3, subsType = matlab.internal.tabular.private.tabularDimension.subsType.reference; end % subsType default to reference
                
                % Translate a table subscript object into actual subscripts. Even
                % though tabularDimension's sub2inds would do this, we need to know
                % if the original subscripts were numeric
                if isobject(subscripts)
                    if isa(subscripts,'vartype')
                        subscripts = subscripts.getSubscripts(obj,tData);
                    elseif isa(subscripts,'matlab.internal.tabular.private.subscripter')
                        subscripts = subscripts.getSubscripts(obj);
                    end
                end
                
                [indices,numIndices,maxIndex,isColon,updatedObj] = obj.subs2inds_impl(subscripts,subsType);
                
                if isnumeric(subscripts)
                    if maxIndex > oldLength
                        if any(diff(unique([oldLength indices(:)'])) > 1)
                            error(message('MATLAB:table:DiscontiguousVars'));
                        end
                    end
                    
                    % Translate logical and ':' to indices, since table var indexing is not done by
                    % the built-in indexing code
                elseif islogical(indices)
                    indices = find(indices);
                elseif ischar(indices) && strcmp(indices, ':')
                    indices = 1:obj.length;
                end
            catch ME
                throwAsCaller(ME)
            end
        end        
        
        %-----------------------------------------------------------------------
        function obj = selectFrom(obj,toSelect)
            %SELECTFROM Return a subset of a tableDimProps for the specified indices.
            % The indices might be out of order or repeated, that's OK.
            obj = obj.selectFrom_impl(toSelect);
            
            % Var-based or properties need to be selected. Make sure they stay
            % row vectors, even if selectFrom is empty.
            if obj.hasDescrs, obj.descrs = obj.descrs(1,toSelect); end
            if obj.hasUnits, obj.units = obj.units(1,toSelect); end
            if obj.hasContinuity, obj.continuity = obj.continuity(1,toSelect); end
        end
        
        %-----------------------------------------------------------------------
        function obj = deleteFrom(obj,toDelete)
            %DELETEFROM Return a subset of a tableDimProps with the specified indices removed.            
            obj = obj.deleteFrom_impl(toDelete);
            
            % Var-based or properties need to be shrunk.
            if obj.hasDescrs, obj.descrs(toDelete) = []; end
            if obj.hasUnits, obj.units(toDelete) = []; end
            if obj.hasContinuity, obj.continuity(toDelete) = []; end
        end
        
        %-----------------------------------------------------------------------
        function obj = assignInto(obj,obj2,assignInto)
            obj = obj.assignInto_impl(obj2,assignInto);
            obj = obj.moveProps(obj2,1:obj2.length,assignInto);
        end
        
        %-----------------------------------------------------------------------
        function s = getProperties(obj)
            % Same order as varNamesDim.propertyNames
            s.VariableNames = obj.labels;
            s.VariableUnits = obj.units;
            s.VariableDescriptions =  obj.descrs;
            s.VariableContinuity = obj.continuity;
        end
        
        %-----------------------------------------------------------------------
        function target = moveProps(target,source,fromLocs,toLocs)
            import matlab.tabular.Continuity
            
            if target.hasUnits
                if source.hasUnits
                    % Replace the specified target units with the source's
                    target.units(toLocs) = source.units(fromLocs);
                else
                    % Replace the specified target units with defaults
                    target.units(toLocs) = {''};
                end
            elseif source.hasUnits
                % Create property in target, assign source values into it
                target.units = repmat({''},1,target.length);
                target.units(toLocs) = source.units(fromLocs);
                target.hasUnits = true;
            else
                % Neither has units, leave it alone
            end
            if target.hasDescrs
                if source.hasDescrs
                    % Replace the specified target descrs with the source's
                    target.descrs(toLocs) = source.descrs(fromLocs);
                else
                    % Replace the specified target descrs with defaults
                    target.descrs(toLocs) = {''};
                end
            elseif source.hasDescrs
                % Create property in target, assign source descrs into it
                target.descrs = repmat({''},1,target.length);
                target.descrs(toLocs) = source.descrs(fromLocs);
                target.hasDescrs = true;
            else
                % Neither has descrs, leave it alone
            end
            if target.hasContinuity
                if source.hasContinuity
                    % Replace the specified target descrs with the source's
                    target.continuity(toLocs) = source.continuity(fromLocs);
                else
                    % Replace the specified target descrs with defaults
                    target.continuity(toLocs) = 'unset';
                end
            elseif source.hasContinuity
                % Create property in target, assign source descrs into it
                target.continuity = repmat(Continuity.unset,1,target.length);
                target.continuity(toLocs) = source.continuity(fromLocs);
                target.hasContinuity = true;
            else
                % Neither has continuity, leave it alone
            end
        end
        
        %-----------------------------------------------------------------------
        function target = mergeProps(target,source,fromLocs)
            % Copy the source's per-var properties to the target if the target
            % doesn't have them
            if ~target.hasDescrs && source.hasDescrs
                target = target.setDescrs(source.descrs(fromLocs));
            end
            if ~target.hasUnits && source.hasUnits
                target = target.setUnits(source.units(fromLocs));
            end
            if ~target.hasContinuity && source.hasContinuity
                target = target.setContinuity(source.continuity(fromLocs),false);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = setDescrs(obj,newDescrs,noErrorCheck)
            if (nargin<3) || (nargin==3 && ~noErrorCheck)
                if ~matlab.internal.datatypes.isCharStrings(newDescrs,true) % require a cell array, allow empty character vectors in that cell array
                    error(message('MATLAB:table:InvalidVarDescr'));
                elseif ~isempty(newDescrs) && numel(newDescrs) ~= obj.length
                    error(message('MATLAB:table:IncorrectNumberOfVarDescrs'));
                end
            end
            
            if obj.length == 0 && isequal(size(newDescrs),[1 0])
                % leave a 1x0 cell alone for a table with no vars
                obj.hasDescrs = true;
            elseif isempty(newDescrs)
                newDescrs = {}; % for cosmetics
                obj.hasDescrs = false;
            else
                newDescrs = strtrim(newDescrs(:))'; % a row vector
                obj.hasDescrs = true;
            end
            obj.descrs = newDescrs;
        end
        
        %-----------------------------------------------------------------------
        function obj = setUnits(obj,newUnits,noErrorCheck)
            if (nargin<3) || (nargin==3 && ~noErrorCheck)
                if ~matlab.internal.datatypes.isCharStrings(newUnits,true) % require a cell array, allow empty character vectors
                    error(message('MATLAB:table:InvalidUnits'));
                elseif ~isempty(newUnits) && numel(newUnits) ~= obj.length
                    error(message('MATLAB:table:IncorrectNumberOfUnits'));
                end
            end
            
            if obj.length == 0 && isequal(size(newUnits),[1 0])
                % leave a 1x0 cell alone for a table with no vars
                obj.hasUnits = true;
            elseif isempty(newUnits)
                newUnits = {}; % for cosmetics
                obj.hasUnits = false;
            else
                newUnits = strtrim(newUnits(:))'; % a row vector
                obj.hasUnits = true;
            end
            obj.units = newUnits;
        end
        
        function obj = setContinuity(obj,newContinuity,noErrorCheck)
            import matlab.tabular.Continuity
            
            if (nargin < 3) || ~noErrorCheck
                    if ~matlab.internal.datatypes.isCharStrings(newContinuity,true) && ...
                   ~isa(newContinuity,'matlab.tabular.Continuity') && ...
                       ~(isequal(newContinuity,[]) && isnumeric(newContinuity)) % [] is allowed for 'clearing' the entire property
                        error(message('MATLAB:table:InvalidContinuityAssignment'));
                    end
                
                if ~isempty(newContinuity) && numel(newContinuity) ~= obj.length
                    error(message('MATLAB:table:IncorrectNumberOfContinuity'));
                end
            end
            if  obj.length == 0 && isequal(size(newContinuity),[1 0])
                obj.hasContinuity = true;
                if iscellstr(newContinuity)
                    newContinuity = Continuity(newContinuity);
                end
 
            elseif isempty(newContinuity) && (isnumeric(newContinuity) || isa(newContinuity,'matlab.tabular.Continuity') || iscell(newContinuity))
                newContinuity = []; %convert {}, 0x0 Continuity to []
                obj.hasContinuity = false;
            else
                newContinuity = newContinuity(:)'; %convert everything to row vector
                % Convert the character vectors to the enumeration class
                if iscellstr(newContinuity)
                try
                        newContinuity = Continuity(newContinuity);
                catch
                        % Throw a custom error in the case the newContinuity cellstr is not accepted by Continuity.
                    error(message('MATLAB:table:InvalidContinuityValue'));
                end
                end
                obj.hasContinuity = true;
            end
            obj.continuity = newContinuity;
        end
    end
    
    %===========================================================================
    methods (Access=protected)
        function obj = validateAndAssignLabels(obj,newLabels,varIndices,fullAssignment,fixDups,fixEmpties,fixIllegal)
            import matlab.internal.datatypes.isCharString
            import matlab.internal.datatypes.isCharStrings
            
            if ~fullAssignment && isCharString(newLabels,fixEmpties)
                % Accept one character vector for (partial) assignment to one name, allow empty character vectors per caller.
                newLabels = { strtrim(newLabels) };
            elseif isCharStrings(newLabels,true,fixEmpties)
                % Accept a cellstr, allow empty character vectors per caller.
                newLabels = strtrim(newLabels(:)'); % a row vector, conveniently forces any empty to 0x1
            else
                error(message('MATLAB:table:InvalidVarNames'));
            end
            
            if fixEmpties
                % Fill in empty names if allowed, and make them unique with respect
                % to the other new names. If not allowed, an error was already thrown.
                % This is here to fill in missing variable names when reading from a file.
                [newLabels,wasEmpty] = fillEmptyNames(newLabels,varIndices);
                newLabels = matlab.lang.makeUniqueStrings(newLabels,wasEmpty,namelengthmax);
            end
            
            if fixIllegal
                exceptionMode = 'warnSaved';
            else
                exceptionMode = 'error';
            end
            originalLabels = newLabels;
            [newLabels,wasMadeValid] = obj.makeValidName(newLabels,exceptionMode);
            
            if fixDups
                % Make the new names (in their possibly modified form) unique with respect to
                % each other and to existing names.
                allNewLabels = obj.labels; allNewLabels(varIndices) = newLabels;
                allNewLabels = matlab.lang.makeUniqueStrings(allNewLabels,varIndices,namelengthmax);
                newLabels = allNewLabels(varIndices);
            elseif fullAssignment
                % Check that the whole set of new names is unique
                obj.checkDuplicateLabels(newLabels);
            else
                % Make sure invalid names that have been fixed do not duplicate any of the other new
                % names.
                newLabels = matlab.lang.makeUniqueStrings(newLabels,wasMadeValid,namelengthmax);
                % Check that the new names do not duplicate each other or existing names.
                allNewLabels = obj.labels; allNewLabels(varIndices) = newLabels;
                obj.checkDuplicateLabels(newLabels,allNewLabels,varIndices);
            end
            obj.checkReservedNames(newLabels);
            
            obj = obj.assignLabels(newLabels,fullAssignment,varIndices);
            
            if fixIllegal && any(wasMadeValid)
                if ~obj.hasDescrs
                    obj.descrs = repmat({''},1,obj.length);
                    obj.hasDescrs = true;
                end
                str = { getString(message('MATLAB:table:uistrings:ModifiedVarNameDescr')) };
                obj.descrs(varIndices(wasMadeValid)) = strcat(str, {' '''}, originalLabels(wasMadeValid), {''''});
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = makeUniqueForRepeatedIndices(obj,~)
            obj.labels = matlab.lang.makeUniqueStrings(obj.labels,{},namelengthmax);
        end
        
        %-----------------------------------------------------------------------
        function throwRequiresLabels(obj) %#ok<MANU>
            msg = message('MATLAB:table:CannotRemoveVarNames');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidPartialLabelsAssignment(obj) %#ok<MANU>
            assert(false);
        end
        function throwIncorrectNumberOfLabels(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfVarNames');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIncorrectNumberOfLabelsPartial(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfVarNamesPartial');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIndexOutOfRange(obj) %#ok<MANU>
            msg = message('MATLAB:table:VarIndexOutOfRange');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwUnrecognizedLabel(obj,label) %#ok<INUSL>
            msg = message('MATLAB:table:UnrecognizedVarName',label{1});
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidLabel(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidVarName');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidSubscripts(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidVarSubscript');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
    end
    
    %===========================================================================    
    methods (Static)
        function labels = dfltLabels(varIndices,oneName)
            %DFLTLABELS Default variable names for a table.
            prefix = getString(message('MATLAB:table:uistrings:DfltVarNamePrefix'));
            if nargin < 2 || ~oneName % return cellstr
                labels = matlab.internal.datatypes.numberedNames(prefix,varIndices,false); % row vector
            else % return one character vector
                labels = matlab.internal.datatypes.numberedNames(prefix,varIndices,true);
            end
        end
        
        function conflicts = checkReservedNames(labels)
            import matlab.internal.tabular.private.tabularDimension.checkReservedNames_impl
            
            conflicts = checkReservedNames_impl(labels);            
            if (nargout == 0) && any(conflicts)
                dup = labels{find(conflicts,1)};
                m = message('MATLAB:table:ReservedVarNameConflict',dup);
                throwAsCaller(MException(m.Identifier, '%s', getString(m)));
            end
        end
        
        function [validNames, modified] = makeValidName(names, modException)
            %MAKEVALIDNAME Construct valid MATLAB identifiers from input names
            %   MAKEVALIDNAME is a private function for table that wraps
            %   around MATLAB.LANG.MAKEVALIDNAME. It adds exception control
            %   for when input names contains invalid identifier.
            %
            %   MODEXCEPTION controls warning or error response when NAMES
            %   contains invalid MATLAB identifiers. Valid values for
            %   MODEXCEPTION are 'warn' and 'error', respectively meaning a
            %   warning or an error will be thrown when NAMES contain
            %   invalid identifiers.            
            import matlab.internal.datatypes.warningWithoutTrace;
            
            if strcmp(modException,'error')
                % If an invalid name should error, no point in calling makeValidName. Call
                % isvarname instead, faster when _all_ names are valid.
                validNames = names; % return the originals, or possibly error
                if ischar(names), names = { names }; end % unusual case, not optimized
                for i = 1:numel(names)
                    if ~isvarname(names{i})
                        error(message('MATLAB:table:VariableNameNotValidIdentifier',names{i}));
                    end
                end
                modified = false(size(names));
            else
                [validNames, modified] = matlab.lang.makeValidName(names);
                if any(modified)
                    switch modException % error or warn per level specified
                        case 'warn'
                            warningWithoutTrace(message('MATLAB:table:ModifiedVarnames'));
                        case 'warnSaved'
                            warningWithoutTrace(message('MATLAB:table:ModifiedAndSavedVarnames'));
                        otherwise
                            assert(false);
                    end
                end
            end
        end
    end

    %===========================================================================
    methods (Static, Access=protected)
        function x = orientAs(x)
            % orient as row
            if ~isrow(x)
                x = x(:)';
            end
        end
    end
    
    %===========================================================================
    methods (Static, Access={?matlab.unittest.TestCase})
        function [tf,duplicated] = checkDuplicateLabels(labels1,labels2,okLocs)
            import matlab.internal.tabular.private.tabularDimension.checkDuplicateLabels_impl            
            if (nargin == 1) % checkDuplicateLabels(labels1)
                duplicated = checkDuplicateLabels_impl(labels1);
            elseif (nargin == 3) % checkDuplicateLabels(labels1,labels2,okLocs)
                duplicated = checkDuplicateLabels_impl(labels1,labels2,okLocs);
            else % checkDuplicateLabels(labels1,labels2)
                duplicated = checkDuplicateLabels_impl(labels1,labels2); % least frequent syntax
            end
            
            tf = any(duplicated);
            
            if tf && (nargout == 0)
                dup = labels1{find(duplicated,1,'first')};
                m = message('MATLAB:table:DuplicateVarNames',dup);
                throwAsCaller(MException(m.Identifier, '%s', getString(m)));
            end
        end
    end
end

%-----------------------------------------------------------------------
function [names,empties] = fillEmptyNames(names,indices)
empties = cellfun('isempty',names);
if any(empties)
    names(empties) = matlab.internal.tabular.private.varNamesDim.dfltLabels(indices(empties));
end
end
