classdef (Sealed) rowNamesDim < matlab.internal.tabular.private.tabularDimension
%ROWNAMESDIM Internal class to represent a table's rows dimension.

% This class is for internal use only and will change in a
% future release.  Do not use this class.

    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Constant, GetAccess=public)
        propertyNames = {'RowNames'};
        requireLabels = false;
        requireUniqueLabels = true;        
    end
    
    %===========================================================================
    methods
        function obj = rowNamesDim(length,labels)
            import matlab.internal.datatypes.isCharStrings
            
            labelsArg = { };
            if nargin == 0
                length = 0;
            elseif nargin == 1
                % OK
            else
                % This is the relevant parts of validateAndAssignLabels
                if ~isCharStrings(labels,true,false) % require cellstr, no empties
                    error(message('MATLAB:table:InvalidRowNames'));
                elseif isequal(labels,{})
                    % OK
                else
                    labels = strtrim(labels(:)); % a col vector, conveniently forces any empty to 0x1
                    matlab.internal.tabular.private.rowNamesDim.checkDuplicateLabels(labels);
                    labelsArg = { labels };
                end
            end            
            obj = obj.init(length,labelsArg{:});
            
            % Row names are optional, and tabularDimension's default is [],
            % replace that with an empty cellstr.
            if ~obj.hasLabels
                obj.labels = {};
            end
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
                % If the table has row names, create default names for the new rows, making sure
                % they don't conflict with existing names. If the table has no row names, leave
                % them that way.
                if obj.hasLabels
                    newLabels = obj.dfltLabels(newIndices);
                    newLabels = matlab.lang.makeUniqueStrings(newLabels,obj.labels);
                    obj.labels(newIndices,1) = newLabels(:);
                end
            else
                % If the original table doesn't have row names, create default names.
                if ~obj.hasLabels
                    obj.labels = obj.dfltLabels(1:obj.length);
                    obj.hasLabels = true;
                end
                
                % Assume that newLabels has already been checked by validateNativeSubscripts.
                obj.labels(newIndices,1) = newLabels(:)';
            end
            obj.length = maxIndex;
        end
        
        %-----------------------------------------------------------------------
        function s = getProperties(obj)
            % Same order as rowNamesDim.propertyNames
            s.RowNames = obj.labels;
        end
    end
    
    %===========================================================================
    methods (Access=protected)
        function obj = validateAndAssignLabels(obj,newLabels,rowIndices,fullAssignment,fixDups,fixEmpties,~)
            import matlab.internal.datatypes.isCharString
            import matlab.internal.datatypes.isCharStrings
            try
                if ~fullAssignment && isCharString(newLabels,fixEmpties)
                    % Accept one character vector for (partial) assignment to one name, allow empty character vectors per caller.
                    newLabels = { strtrim(newLabels) };
                elseif isCharStrings(newLabels,true,fixEmpties)
                    if fullAssignment && isequal(newLabels,{}) % Accept {} to remove row names
                        obj.labels = {}; % force a 0x0, for cosmetics
                        obj.hasLabels = false;
                        return
                    end
                    % Accept a cellstr, allow empty character vectors per caller.
                    newLabels = strtrim(newLabels(:)); % a col vector, conveniently forces any empty to 0x1
                else
                    error(message('MATLAB:table:InvalidRowNames'));
                end
                
                if fixEmpties
                    % Fill in empty names if allowed, and make them unique with respect
                    % to the other new names. If not allowed, an error was already thrown.
                    [newLabels,wasEmpty] = fillEmptyNames(newLabels,rowIndices);
                    newLabels = matlab.lang.makeUniqueStrings(newLabels,wasEmpty,namelengthmax);
                end
                
                if fixDups
                    % Make the new names unique with respect to each other and to existing names (if any).
                    newAndOldLabels = obj.labels;
                    if isempty(newAndOldLabels)
                        newLabels = matlab.lang.makeUniqueStrings(newLabels,1:length(newLabels),inf);
                    else
                        newAndOldLabels(rowIndices) = newLabels;
                        newAndOldLabels = matlab.lang.makeUniqueStrings(newAndOldLabels,rowIndices,inf);
                        newLabels = newAndOldLabels(rowIndices);
                    end
                elseif fullAssignment
                    % Check that the whole set of new names is unique
                    obj.checkDuplicateLabels(newLabels);
                else
                    % Check that the new names do not duplicate each other or existing names.
                    newAndOldLabels = obj.labels; newAndOldLabels(rowIndices) = newLabels;
                    obj.checkDuplicateLabels(newLabels,newAndOldLabels,rowIndices);
                end
                
                obj = obj.assignLabels(newLabels,fullAssignment,rowIndices);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = makeUniqueForRepeatedIndices(obj,indices)
            % Sort the row indices, then find the first occurrence of each unique index
            % and the length of each group of indices.
            [sindices,ord] = sort(indices);
            [~,startLoc] = unique(sindices);
            groupLens = diff([startLoc; length(indices)+1]);
            
            % Number the rows from 0:length(group), within each group.
            numbers = cumsum(ones(size(indices))) - repelem(startLoc,groupLens,1); % force repelem to create a column
            
            % Create suffixes to make repeated names unique, and put the suffixes back into
            % the original order.
            suffixes = sprintfc('_%-d',numbers);
            suffixes(startLoc) = {''}; % no suffix for first occurrence
            suffixes(ord) = suffixes;
            
            % Append to the names. No concern for length, row names need not be valid identifiers.
            obj.labels = strcat(obj.labels,suffixes);
        end
        
        %-----------------------------------------------------------------------
        function throwRequiresLabels(obj)
            assert(false);
        end
        function throwInvalidPartialLabelsAssignment(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidPartialRowNamesAssignment');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIncorrectNumberOfLabels(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfRowNames');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIncorrectNumberOfLabelsPartial(obj) %#ok<MANU>
            msg = message('MATLAB:table:IncorrectNumberOfRowNamesPartial');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwIndexOutOfRange(obj) %#ok<MANU>
            msg = message('MATLAB:table:RowIndexOutOfRange');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwUnrecognizedLabel(obj,label) %#ok<INUSL>
            msg = message('MATLAB:table:UnrecognizedRowName', label{1});
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidLabel(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidRowName');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
        function throwInvalidSubscripts(obj) %#ok<MANU>
            msg = message('MATLAB:table:InvalidRowSubscript');
            throwAsCaller(MException(msg.Identifier,msg.getString()));
        end
    end
    
    %===========================================================================
    methods(Static, Access=protected)
        function x = orientAs(x)
            % orient as column
            if ~iscolumn(x)
                x = x(:);
            end
        end
    end
    
    %===========================================================================
    methods(Static, Access={?tabular,?matlab.unittest.TestCase})
        function labels = dfltLabels(rowIndices,oneName)
            %DFLTLABELS Default row names for a table.
            
            %   Copyright 2012-2016 The MathWorks, Inc.
            
            prefix = getString(message('MATLAB:table:uistrings:DfltRowNamePrefix'));
            if nargin < 2 || ~oneName % return cellstr
                labels = matlab.internal.datatypes.numberedNames(prefix,rowIndices,false)'; % column vector
            else % return one character vector
                labels = matlab.internal.datatypes.numberedNames(prefix,rowIndices,true);
            end
        end
    
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
                throwAsCaller(MException( message('MATLAB:table:DuplicateRowNames',dup)));
            end
        end
    end
end

%-----------------------------------------------------------------------
function [names,empties] = fillEmptyNames(names,indices)
empties = cellfun('isempty',names);
if any(empties)
    names(empties) = matlab.internal.tabular.private.rowNamesDim.dfltLabels(indices(empties));
end
end
