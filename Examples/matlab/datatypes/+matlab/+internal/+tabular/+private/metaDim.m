classdef (Sealed) metaDim < matlab.internal.tabular.private.tabularDimension
%METASDIM Internal class to represent a tabular's list of dimension.

% This class is for internal use only and will change in a
% future release.  Do not use this class.

    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Constant, GetAccess=public)
        propertyNames = {'DimensionNames'};
        requireLabels = true;
        requireUniqueLabels = true;        
    end
        
    properties(Constant, GetAccess={?tabular,?matlab.unittest.TestCase})
        % These are the names used by default by metaDim. However, tabular
        % classes may initialize their metaDim with whatever they want.
        dfltLabels = { getString(message('MATLAB:table:uistrings:DfltRowDimName')) ...
                       getString(message('MATLAB:table:uistrings:DfltVarDimName')) };        
    end
    
    properties(GetAccess=protected, SetAccess=private)
        % This property controls whether validation of dim names is lenient for backwards
        % compatibility, see checkAgainstVarLabels and fixLabelsForCompatibility for more details.
        backwardsCompatibility = false;
    end
    
    %===========================================================================
    methods
        function obj = metaDim(length,labels,backwardsCompatibility)
            % Technically, this is not a table dimension, it's more like a table
            % meta-dimension. But it's close enough to var and row names to
            % reuse the infrastructure. Always initialize with two default
            % names, and oriented as a row.
            import matlab.internal.datatypes.isCharStrings
            import matlab.internal.tabular.private.metaDim
            
            if nargin == 0
                length = 2;
                labels = metaDim.dfltLabels;
            elseif nargin == 1
                labels = metaDim.dfltLabels;
            else
                % This is the relevant parts of validateAndAssignLabels
                if ~isCharStrings(labels,true,false) % require cellstr, no empties
                    error(message('MATLAB:table:InvalidDimNames'));
                end
                labels = strtrim(labels(:)'); % a row vector, conveniently forces any empty to 0x1
                if (nargin > 2) && backwardsCompatibility % tables, for now
                    labels = obj.fixLabelsForCompatibility(labels);
                else % timetables
                    metaDim.makeValidName(labels,'error');
                    metaDim.checkDuplicateLabels(labels);
                    metaDim.checkReservedNames(labels);
                end
            end
            
            if nargin < 3 || (nargin==3 && ~backwardsCompatibility)
                obj = obj.init(length,labels);
            else
                obj = obj.initWithCompatibility(length,labels);
            end
        end

        %-----------------------------------------------------------------------
        function obj = initWithCompatibility(obj,length,labels)
            obj = obj.init(length,labels);
            obj.backwardsCompatibility = true;
        end
        
        %-----------------------------------------------------------------------
        function labels = defaultLabels(obj,indices)
            if nargin < 2
                indices = 1:obj.length;
            end
            labels = obj.dfltLabels(indices);
        end
        
        %-----------------------------------------------------------------------
        function obj = lengthenTo(obj,~,~)
            assert(false);
        end
        
        %-----------------------------------------------------------------------
        function s = getProperties(obj)
            % Same order as metaDim.propertyNames
            s.DimensionNames = obj.labels;
        end
        
        %-----------------------------------------------------------------------
        function obj = checkAgainstVarLabels(obj,varLabels,errorMode)
            import matlab.internal.datatypes.warningWithoutTrace
            % Pre-2016b, DimensionNames were not required to be distinct from VariableNames,
            % but now they are. If they conflict, modify DimensionNames and warn.
            [modifiedLabels,wasConflicted] = matlab.lang.makeUniqueStrings(obj.labels,varLabels,namelengthmax);
            if any(wasConflicted)
                if nargin > 2
                    switch errorMode
                        case 'silent'
                            % OK
                        case 'warn'
                            warningWithoutTrace(message('MATLAB:table:DuplicateDimNamesVarNamesWarn',obj.labels{find(wasConflicted,1)}));
                        case 'error'
                            error(message('MATLAB:table:DuplicateDimNamesVarNames',obj.labels{find(wasConflicted,1)}));
                        otherwise
                            assert(false);
                    end
                elseif obj.backwardsCompatibility % tables, for now
                    warningWithoutTrace(message('MATLAB:table:DuplicateDimnamesVarnamesBackCompat',obj.labels{find(wasConflicted,1)}));
                else % timetables
                    error(message('MATLAB:table:DuplicateDimNamesVarNames',obj.labels{find(wasConflicted,1)}));
                end
                obj.labels = modifiedLabels;
            end
        end
    end
    
    %===========================================================================
    methods (Access=protected)
        function obj = validateAndAssignLabels(obj,newLabels,dimIndices,fullAssignment,fixDups,fixEmpties,fixIllegal)
            import matlab.internal.datatypes.isCharString
            import matlab.internal.datatypes.isCharStrings
            
            if ~fullAssignment && isCharString(newLabels,fixEmpties)
                % Accept one character vector for (partial) assignment to one name, allow empty character vectors per caller.
                newLabels = { strtrim(newLabels) };
            elseif isCharStrings(newLabels,true,fixEmpties)
                % Accept a cellstr, allow empty character vectors per caller.
                newLabels = strtrim(newLabels(:)'); % a row vector, conveniently forces any empty to 0x1
            else
                error(message('MATLAB:table:InvalidDimNames'));
            end

            if fixEmpties
                % Fill in empty names if allowed, and make them unique with respect
                % to the other new names. If not allowed, an error was already thrown.
                [newLabels,wasEmpty] = fillEmptyNames(newLabels,dimIndices);
                newLabels = matlab.lang.makeUniqueStrings(newLabels,wasEmpty,namelengthmax);
            end
            
            if fixIllegal
                newLabels = obj.makeValidName(newLabels,'warn');
            else
                if obj.backwardsCompatibility % tables, for now
                    newLabels = obj.fixLabelsForCompatibility(newLabels);
                else % timetables
                    newLabels = obj.makeValidName(newLabels,'error');
                end
            end
            obj.checkReservedNames(newLabels);
            
            if fixDups
                % Make the new names (in their possibly modified form) unique with respect to
                % each other and to existing names.
                allNewLabels = obj.labels; allNewLabels(dimIndices) = newLabels;
                allNewLabels = matlab.lang.makeUniqueStrings(allNewLabels,dimIndices,namelengthmax);
                newLabels = allNewLabels(dimIndices);
            elseif fullAssignment
                % Check that the whole set of new names is unique
                obj.checkDuplicateLabels(newLabels);
            else
                % Check that the new names do not duplicate each other or existing names.
                allNewLabels = obj.labels; allNewLabels(dimIndices) = newLabels;
                obj.checkDuplicateLabels(newLabels,allNewLabels,dimIndices);
            end
            
            obj = obj.assignLabels(newLabels,fullAssignment,dimIndices);
        end
        
        %-----------------------------------------------------------------------
        function obj = makeUniqueForRepeatedIndices(obj,~)
            assert(false);
        end
        
        %-----------------------------------------------------------------------
        function throwRequiresLabels(obj) %#ok<MANU>
            msg = message('MATLAB:table:CannotRemoveDimNames');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidPartialLabelsAssignment(obj) %#ok<MANU>
            assert(false);
        end
        function throwIncorrectNumberOfLabels(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfDimNames');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIncorrectNumberOfLabelsPartial(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfDimNamesPartial');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIndexOutOfRange(obj) %#ok<MANU>
            msg = message('MATLAB:table:DimIndexOutOfRange');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwUnrecognizedLabel(obj,label) %#ok<INUSL>
            msg = message('MATLAB:table:UnrecognizedDimName',label{1});
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidLabel(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidDimName');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidSubscripts(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidDimSubscript');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
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
    methods(Static, Access={?tabular, ?matlab.unittest.TestCase})
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
                m = message('MATLAB:table:DuplicateDimNames',dup);
                throwAsCaller(MException(m.Identifier, '%s', getString(m)));
            end
        end
        
        function conflicts = checkReservedNames(labels)
            import matlab.internal.tabular.private.tabularDimension.checkReservedNames_impl
            
            conflicts = checkReservedNames_impl(labels);            
            if (nargout == 0) && any(conflicts)
                dup = labels{find(conflicts,1)};
                m = message('MATLAB:table:ReservedDimNameConflict',dup);
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
                        error(message('MATLAB:table:DimNameNotValidIdentifier',names{i}));
                    end
                end
                modified = false(size(names));
            else
                [validNames, modified] = matlab.lang.makeValidName(names);
                if any(modified)
                % Find first modified name
                firstModifiedName = names;
                if iscell(names)
                    firstModifiedName = names{find(modified,1)};
                end
                
                    switch modException % error or warn per level specified
                        case 'warn'
                            warningWithoutTrace(message('MATLAB:table:ModifiedDimnames',firstModifiedName));
                        otherwise
                            assert(false);
                    end
                end
            end
        end 
            
        function labels = fixLabelsForCompatibility(labels)
            % Pre-R2016b, DimensionNames had almost no constraints, but there are new
            % requirements to support new dot subscripting functionality added in R2016b.
            % The old defaults met those requirements, so if the names are not (now) valid,
            % they must have been intentionally changed from their old defaults (or perhaps
            % DimensionNames{1} came from a column header in a file). In any case, to avoid
            % breaking existing table code, modify any invalid names and warn.
            import matlab.internal.datatypes.warningWithoutTrace
            
            originalLabels = labels;
            % Pre-R2016b,names were not required to be valid MATLAB identifiers.
            [labels,wasMadeValid] = matlab.lang.makeValidName(labels);
            if any(wasMadeValid)
                warningWithoutTrace(message('MATLAB:table:DimNameNotValidIdentifierBackCompat',originalLabels{find(wasMadeValid,1)}));
            end
            % Pre-2016b, names were not required to be distinct from the list of reserved names.
            wasReserved = matlab.internal.tabular.private.metaDim.checkReservedNames(labels);
            if any(wasReserved)
                warningWithoutTrace(message('MATLAB:table:DimnamesReservedNameConflictBackCompat',originalLabels{find(wasReserved,1)}));
                labels(wasReserved) = matlab.lang.makeUniqueStrings(labels(wasReserved),labels(wasReserved),namelengthmax);
            end
        end
    end
end
%-----------------------------------------------------------------------
function [names,empties] = fillEmptyNames(names,indices)
empties = cellfun('isempty',names);
if any(empties)
    names(empties) = matlab.internal.tabular.private.metaDim.dfltLabels(indices(empties));
end
end
