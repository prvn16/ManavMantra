classdef (AllowedSubclasses = {?matlab.internal.tabular.private.rowNamesDim, ...
                               ?matlab.internal.tabular.private.rowTimesDim, ...
                               ?matlab.internal.tabular.private.varNamesDim, ...
                               ?matlab.internal.tabular.private.metaDim}) tabularDimension
%tabularDimension Internal abstract class to represent a tabular's dimension.

% This class is for internal use only and will change in a
% future release.  Do not use this class.

    %   Copyright 2016-2017 The MathWorks, Inc.
        
    properties(Abstract, Constant, GetAccess=public)
        propertyNames
        requireLabels
        requireUniqueLabels
    end
    
    properties(GetAccess=public, SetAccess=protected)
        % SetAccess=protected because subclass lengthenTo methods write to these
        length
        labels
        
        % Distinguish between not having labels and a zero-length dimension with no labels.
        hasLabels = false
    end
    
    properties(Constant, GetAccess=public)
        subsType = struct('reference',0,'assignment',1,'deletion',2)
    end
    
    %===========================================================================
    methods        
        function obj = init(obj,dimLength,dimLabels)
        % INIT is called by both the dimension objects' constructor and
        % tabular objects' loadobj method. In the latter case, because 
        % a default dimension object is already constructed, it is faster
        % to 'initialize' through INIT rather reconstruct a new one
            if nargin == 2
                obj = init_impl(obj,dimLength);
            else
                obj = init_impl(obj,dimLength,dimLabels);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = createLike(obj,dimLength,dimLabels)
            %CREATELIKE Create a tabularDimension of the same kind as an existing one.
            if nargin < 3
                obj = obj.createLike_impl(dimLength);
            else
                obj = obj.createLike_impl(dimLength,dimLabels);
            end
        end
                
        
        %-----------------------------------------------------------------------
        function obj = removeLabels(obj)
            if obj.requireLabels
                obj.throwRequiresLabels();
            else
                obj.labels = {}; % optional labels is usually names
                obj.hasLabels = false;
            end
        end
        
        %-----------------------------------------------------------------------
        function labels = emptyLabels(obj,num)
            % EMPTYLABELS Return a vector of empty labels of the right kind.
            
            % Default behavior assumes the labels are names, subclasses with
            % non-name labels need to overload.
            labels = obj.orientAs(repmat({''},num,1));
        end
        
        %-----------------------------------------------------------------------
        function labels = textLabels(obj,indices)
            % TEXTLABELS Return the labels converted to text.
            
            % Default behavior assumes the labels are names, subclasses with
            % non-name labels need to overload.
            if nargin < 2
                labels = obj.labels;
            else
                labels = obj.labels(indices);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = selectFrom(obj,toSelect)
            %SELECTFROM Return a subset of a tableDimimension for the specified indices.
            % The indices might be out of order, that's OK or repeated, that's handled.
            obj = obj.selectFrom_impl(toSelect);
        end
        
        %-----------------------------------------------------------------------
        function obj = deleteFrom(obj,toDelete)
            obj = obj.deleteFrom_impl(toDelete);
        end        
        
        %-----------------------------------------------------------------------
        function obj = assignInto(obj,obj2,assignInto)
            obj = obj.assignInto_impl(obj2,assignInto);
        end
        
        %-----------------------------------------------------------------------
        function target = moveProps(target,source,fromLocs,toLocs) %#ok<INUSD>
            % MOVEPROPS Assign values from a tableDimension's properties into another's.
            % Replace property values in the target with values from the source,
            % across all properties that this dimension manages. If a property
            % that exists in the source doesn't exist in the target, first create
            % it in the target filled with default values. If a property that
            % exists in the target doesn't exist in the source, replace the target
            % values with default values. If a property doesn't exist in either,
            % do nothing for that property.
            %
            % Labels are not replaced.
            
            % By default, there are no properties (other than labels).
        end
        
        %-----------------------------------------------------------------------
        function target = mergeProps(target,source,fromLocs) %#ok<INUSD>
            % MERGEPROPS Merge a tableDimension's properties into another's.
            % Create properties that don't exist in the target using the
            % corresponding properties from the source (if the latter exist).
            % Properties that are already present in the target are left alone.
            % Labels are left alone.
            
            % By default, there are no properties (other than labels).
        end
        
        %-----------------------------------------------------------------------
        function obj = setLabels(obj,newLabels,subscripts,fixDups,fixEmpties,fixIllegal)
            %SETLABELS Modify, overwrite, or remove a tableDimProps's labels.
            if nargin < 6
                % Should illegal labels be modified to make them legal?
                fixIllegal = false;
                if nargin < 5
                    % Should empty labels be filled in wth default labels?
                    fixEmpties = false;
                    if nargin < 4
                        % Should duplicate labels be made unique?
                        fixDups = false;
                    end
                end
            end
            
            % Subscripts equal to [] denotes a full assignment while the edge case of a
            % partial assignment to zero labels requires a 1x0 or 0x1 empty.
            fullAssignment = (nargin == 2) || isequal(subscripts,[]);
            if fullAssignment % replacing all labels
                indices = 1:obj.length;
            elseif obj.hasLabels % replacing some labels
                indices = obj.subs2inds(subscripts);
                if islogical(indices)
                    % subs2inds leaves logical untouched, validateAndAssignLabels requires indices
                    indices = find(indices);
                end
            else % don't allow a subscripted assignment to an empty property
                obj.throwInvalidPartialLabelsAssignment();
            end
            
            % Check the type of the new labels, and convert them to the canonical type as
            % necessary (and allowed). If this is a full assignment of a 0x0, and removing
            % the labels is allowed, validateLabels leaves the shape alone, otherwise it
            % reshapes to a vector of the appropriate orientation.
            obj = obj.validateAndAssignLabels(newLabels,indices,fullAssignment,fixDups,fixEmpties,fixIllegal);
        end
        
        %-----------------------------------------------------------------------
        function [indices,numIndices,maxIndex,isColon,updatedObj] = subs2inds(obj,subscripts,subsType)
            try
                if nargin < 3, subsType = obj.subsType.reference; end % subsType default to reference (0)
                if nargout < 5
                    [indices,numIndices,maxIndex,isColon] = obj.subs2inds_impl(subscripts,subsType);
                else
                    [indices,numIndices,maxIndex,isColon,updatedObj] = obj.subs2inds_impl(subscripts,subsType);
                end
            catch ME
                throwAsCaller(ME)
            end
        end
    end
       
    %===========================================================================
    methods (Access=protected)
        function obj = init_impl(obj,dimLength,dimLabels)
            obj.length = dimLength;            
            if nargin == 3
                if isvector(dimLabels) && (numel(dimLabels) == dimLength)
                    obj.hasLabels = true;
                    obj.labels = obj.orientAs(dimLabels);
                else
                    obj.throwIncorrectNumberOfLabels();
                end
            end
        end
        
        function [indices,numIndices,maxIndex,isColon,updatedObj] = subs2inds_impl(obj,subscripts,subsType)
            %SUBS2INDS Convert table subscripts (labels, logical, numeric) to indices.
            
            % Translate a table subscript object into actual subscripts
            if isa(subscripts,'matlab.internal.tabular.private.subscripter')
                subscripts = subscripts.getSubscripts(obj);
            end
            
            if isnumeric(subscripts) || islogical(subscripts)                
                isColon = false;
                indices = subscripts(:);
                
                % Leave numeric and logical indices alone.
                if isnumeric(indices)
                    if any(isnan(indices))
                        error(message('MATLAB:badsubscript',getString(message('MATLAB:badsubscriptTextRange'))));
                    end
                    numIndices = numel(indices);
                    maxIndex = max(indices);
                else % logical
                    numIndices = sum(indices);
                    maxIndex = find(indices,1,'last');
                end
                
                switch subsType
                    case obj.subsType.reference
                        if maxIndex > obj.length
                            obj.throwIndexOutOfRange();
                        elseif nargout > 4
                            updatedObj = obj.selectFrom(indices);
                        end
                    case obj.subsType.assignment
                        if nargout > 4
                            if maxIndex > obj.length
                                updatedObj = obj.lengthenTo(maxIndex);
                            else
                                updatedObj = obj;
                            end
                        end
                    case obj.subsType.deletion
                        if maxIndex > obj.length
                            obj.throwIndexOutOfRange();
                        elseif nargout > 4
                            updatedObj = obj.deleteFrom(indices);
                        end
                    otherwise
                        assert(false);
                end
                
            elseif ischar(subscripts) && strcmp(subscripts, ':')
                % Leave ':' alone.
                isColon = true;
                indices = subscripts;
                numIndices = obj.length;
                maxIndex = obj.length;
                
                if nargout > 4
                    updatedObj = obj;
                end    
                
            else % "native" subscripts, i.e. names or times
                isColon = false;
                
                % Translate labels into indices.
                [subscripts,indices] = obj.validateNativeSubscripts(subscripts);
                numIndices = numel(indices);
                maxIndex = max(indices(:));
                
                switch subsType
                    case obj.subsType.reference
                        if nnz(indices) < numIndices
                            if obj.requireUniqueLabels
                                newLabels = unique(subscripts(~indices),'stable');
                                obj.throwUnrecognizedLabel(newLabels(1));
                            end
                            indices = indices(indices>0);
                        end
                        if nargout > 4
                            updatedObj = obj.selectFrom(indices);
                        end
                    case obj.subsType.assignment
                        if nnz(indices) < numIndices
                            [newLabels,~,newIndices] = unique(subscripts(~indices),'stable');
                            indices(~indices) = obj.length + newIndices;
                            maxIndex = max(indices(:));
                            if nargout > 4
                                updatedObj = obj.lengthenTo(maxIndex,newLabels);
                            end
                        elseif nargout > 4
                            updatedObj = obj;
                        end
                    case obj.subsType.deletion
                        if nnz(indices) < numIndices
                            newLabels = unique(subscripts(~indices),'stable');
                            obj.throwUnrecognizedLabel(newLabels(1));
                        elseif nargout > 4
                            updatedObj = obj.deleteFrom(indices);
                        end
                    otherwise
                        assert(false);
                end      
            end
            indices = obj.orientAs(indices);
        end
        
        %-----------------------------------------------------------------------
        function obj = selectFrom_impl(obj,toSelect)
            %SELECTFROM_IMPL implements tabularDimension's SELECTFROM method
            import matlab.internal.datatypes.isUniqueNumeric
            
            if obj.hasLabels
                obj.labels = obj.orientAs(obj.labels(toSelect));
                
                % Only numeric subscripts can lead to repeated rows (thus labels), no
                % need to check otherwise.
                if isnumeric(toSelect) && ~isUniqueNumeric(toSelect)
                    obj = obj.makeUniqueForRepeatedIndices(toSelect);
                end
                
                obj.length = numel(obj.labels);
            elseif isnumeric(toSelect)
                obj.length = numel(toSelect);
            elseif islogical(toSelect)
                obj.length = sum(toSelect);
            elseif ischar(toSelect) && strcmp(toSelect, ':')
                % leave obj.length alone
            else
                assert(false);
            end            
        end
                    
        %-----------------------------------------------------------------------
        function obj = deleteFrom_impl(obj,toDelete)
            %DELETEFROM_IMPL implements tabularDimension's DELETEFROM method
            if obj.hasLabels
                obj.labels(toDelete) = [];
                obj.labels = obj.orientAs(obj.labels);
            end
            keepIndices = 1:obj.length;
            keepIndices(toDelete) = [];
            obj.length = numel(keepIndices);
        end
        
        %-----------------------------------------------------------------------
        function obj = assignInto_impl(obj,obj2,assignInto)
            %ASSIGNINTO_IMPL implements tabularDimension's ASSIGNINTO method
            if obj.hasLabels && obj2.hasLabels
                obj.labels(assignInto) = obj2.labels;
            elseif obj.hasLabels % && ~obj2.hasLabels
                obj.labels(assignInto) = obj2.emptyLabels(obj2.length); % *** creates invalid labels
            elseif obj2.hasLabels % && ~obj.hasLabels
                obj.labels = obj.emptyLabels(obj.length);
                obj.labels(assignInto) = obj2.labels;
                obj.hasLabels = true;
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = createLike_impl(obj,dimLength,dimLabels)
            %CREATELIKE_IMPL implements tabularDimension CREATELIKE method.
            obj.length = dimLength;
            if nargin < 3
                if obj.hasLabels
                    % This creates an invalid set of empty labels that must be set.
                    obj.labels = obj.emptyLabels(dimLength); % *** creates invalid labels
                else
                    obj.hasLabels = false;
                    obj.labels = obj.labels([]);
                end
            else
                obj = obj.setLabels(dimLabels,[]);
            end
        end
        
        %-----------------------------------------------------------------------
        function obj = assignLabels(obj,newLabels,fullAssignment,indices)
            if fullAssignment
                if isvector(newLabels)
                    % The number of new labels has to match what's being assigned to.
                    if numel(newLabels) ~= obj.length
                        obj.throwIncorrectNumberOfLabels();
                    end
                    obj.hasLabels = true;
                    obj.labels = newLabels;
                else % a 0x0
                    % Full assignment of a 0x0 clears out the existing labels, if allowed above by
                    % the subclass's validateLabels.
                    obj.labels = newLabels([]); % force a 0x0, for cosmetics
                    obj.hasLabels = false;
                end
            else % subscripted assignment
                % The number of new labels has to match what's being assigned to.
                if numel(newLabels) ~= numel(indices)
                    obj.throwIncorrectNumberOfLabelsPartial();
                end
                obj.labels(indices) = newLabels;
            end
        end
        
        %-----------------------------------------------------------------------
        function [subscripts,indices] = validateNativeSubscripts(obj,subscripts)
            import matlab.internal.datatypes.isCharStrings
            
            % Default behavior assumes the labels are names, subclasses with
            % non-name labels need to overload.
            if ischar(subscripts) % already weeded out ':'
                if isrow(subscripts)
                    subscripts = { subscripts };
                else
                    obj.throwInvalidLabel();
                end
            elseif isCharStrings(subscripts) % require a cell array, don't allow empty character vectors in it
                % OK
            else
                obj.throwInvalidSubscripts();
            end
            
            indices = zeros(size(subscripts));
            labs = obj.labels;
            for i = 1:numel(indices)
                indFirstMatch = find(strcmp(subscripts{i},labs), 1);
                if indFirstMatch
                    indices(i) = indFirstMatch;
                end
            end
        end
    end
    
    methods (Abstract)
        labels = defaultLabels(indices);
        obj = lengthenTo(obj,maxIndex,newLabels)
        s = getProperties(obj)
    end
    
    methods (Abstract, Access=protected)
        obj = validateAndAssignLabels(obj,newLabels,indices,fullAssignment,fixDups,fixEmpties,fixIllegal)
        obj = makeUniqueForRepeatedIndices(obj,indices)
                
        throwRequiresLabels(obj)
        throwInvalidPartialLabelsAssignment(obj)
        throwIncorrectNumberOfLabels(obj)
        throwIncorrectNumberOfLabelsPartial(obj)
        throwIndexOutOfRange(obj)
        throwUnrecognizedLabel(obj,label)
        throwInvalidLabel(obj)
        throwInvalidSubscripts(obj)
    end
    
    methods (Static, Abstract, Access=protected)
        x = orientAs(x); % Reshape x as a vector in the specified orientation
    end
    
    %===========================================================================      
    methods (Static, Access=protected)
        function duplicated = checkDuplicateLabels_impl(labels1,labels2,okLocs)
            %CHECKDUPLICATELABELS_IMPL Check for duplicated names.
            
            % Check for any duplicate names in names1
            if nargin == 1 % checkDuplicateLabels_impl(labels1)
                % names1 is always a cellstr
                duplicated = false(size(labels1));
                [labels1,lids] = sort(labels1);
                duplicated(2:end) = strcmp(labels1(1:end-1),labels1(2:end));
                duplicated(lids) = duplicated; % put back in the original order
                % Check if any name in names1 is already in names2.  This does not check if
                % names1 contains duplicates within itself
            elseif nargin == 2 % checkDuplicateLabels_impl(labels1,labels2)
                % names2 is always a cellstr
                if ischar(labels1) % names1 is either a single character vector ...
                    duplicated = any(strcmp(labels1, labels2));
                else             % ... or a cell array of character vectors
                    duplicated = false(size(labels1));
                    for i = 1:length(labels1)
                        duplicated(i) = any(strcmp(labels1{i}, labels2));
                    end
                end
                
                % Check if any name in names1 is already in names2, except that names1(i) may
                % be at names2(okLocs(i)).  This does not check if names1 contains duplicates
                % within itself
            else % nargin == 3, checkDuplicateLabels_impl(labels1,labels2,okLocs)
                % names2 is always a cellstr
                if ischar(labels1) % names1 is either a single character vector ...
                    tmp = strcmp(labels1, labels2); tmp(okLocs) = false;
                    duplicated = any(tmp);
                else             % ... or a cell array of character vectors
                    duplicated = false(size(labels1));
                    for i = 1:length(labels1)
                        tmp = strcmp(labels1{i}, labels2); tmp(okLocs(i)) = false;
                        duplicated(i) = any(tmp);
                    end
                end
            end
        end
        
        function conflicts = checkReservedNames_impl(labels)
            %CHECKRESERVEDNAMES_IMPL Check if variable names conflict with reserved names.
            reservedNames = {'VariableNames' 'RowNames' 'Properties'};
            if ischar(labels) % names is either a single character vector ...
                conflicts = any(strcmp(labels, reservedNames));
            else             % ... or a cell array of character vectors
                conflicts = false(size(labels));
                for i = 1:length(reservedNames)
                    conflicts = conflicts | strcmp(reservedNames{i}, labels);
                end
            end
        end
    end
end
