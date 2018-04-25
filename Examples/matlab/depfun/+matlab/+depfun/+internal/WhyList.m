classdef WhyList < handle

    properties (Access = private)
        % Map (per target) of the listed items.
        List = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % List of all possible reasons an item might be in the map (for
        % a given target);
        Reason = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % Map (per target) from list to reason.
        Index = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        
        % Error if the list is empty when it shouldn't be
        EmptyListError = 'MATLAB:depfun:req:InternalEmptyWhyList';

    end

    properties(Constant)
        allTargets = 'all';
        DefaultReason = 'You can''t handle the truth.';
    end

    methods (Access = private)

        % Determine if fcn is listed by a target-specific or
        % target-agnostic rule. Simple pattern-matching -- look for the
        % text of a listing "pattern" in the name of the file containing
        % the function. If we find the pattern substring, set listed to
        % true and return the index of the pattern that matched.
        %
        % fcn may be either a scalar string or a cell array of strings.
        % If fcn is a cell array, both listed and match will be vectors
        % with the same number of elements. (This sort of assumes that
        % fcn will always be 1xN or Mx1 -- which it should be. If it is
        % allowed to be MxN, then the all(listed) test must change to
        % all(all(listed)), which seems like a waste of cycles.)
        function [listed, match] = listedBy(obj, target, fcn)
            % Determine, up front, if we're analyzing one or many fcns.
            vectorize = false;
            if iscell(fcn)
                vectorize = true;
                listed = false(1,numel(fcn));
                match = zeros(1,numel(fcn));
            else
                listed = false;
                match = 0;
            end

            k = 0;
            % If this list has rules for this target, see if any of them
            % match the file names in fcn.
            if ~isempty(obj.List) && isKey(obj.List, target)
                k = 1;
                % Get the list of rules for this target
                elist = obj.List(target);
                % Until we know that all the inputs match rules on the
                % list or we come to the end of the rules...
                while all(listed) == false && k <= length(elist)
                    matched = regexp(fcn, elist{k}, 'once');
                    % If fcn is a cell array, matched will be one too.
                    % Create a logical array with TRUE where an element of
                    % fcn matched the rule elist{k}.
                    if vectorize
                        matched = ~cellfun('isempty', matched);
                        % Record the index (k) of the FIRST match for each
                        % matched fcn.
                        firstMatch = ~listed & matched;
                        match(firstMatch) = k;
                        
                        % Now mark the fcn as listed.
                        listed = listed | matched;
                    else
                        listed = ~isempty(matched);
                        match = k;
                    end
                    % Examine the next rule.
                    k = k + 1;
                end
            end
        end
    end

    methods (Access = public)

        function obj = WhyList(emptyListErr)
            if nargin > 0
                obj.EmptyListError = emptyListErr;
            end

            obj.List = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            obj.Reason = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            obj.Index = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        end

        function append(obj, list, target, whyFcn)
            % Append a list of items to the current list. An item may be
            % may be listed for one or more targets, so maintain a set of
            % targets.
            if isKey(obj.List, target)
                % Add the new listing patterns to the list of patterns for
                % this target.
                obj.List(target) = [ obj.List(target), list{:} ];
                                        
                % Add the new listing reason to the list of listing reasons
                % for this target.
                obj.Reason(target) = [ obj.Reason(target), feval(whyFcn) ];
                                 
                % Extend the listing reason lookup index to include the new
                % reason and files. With this index in place, we can map a
                % file index (its position in the list) to a reason
                % in constant time. (See isListed for the exciting
                % details.)
                obj.Index(target) = [ obj.Index(target), ...
                    ones(1,numel(list)) * numel(obj.Reason(target)) ];
            else
                obj.List(target) = list(1:end);
                obj.Index(target) = ones(1,numel(list));
                obj.Reason(target) = { feval(whyFcn) };
            end
        end

        function [listed, why] = isListed(obj, target, fcn)

            if ischar(target)
                target = matlab.depfun.internal.Target.parse(target);
            end
            
            if ~isnumeric(target)
                target = matlab.depfun.internal.Target.int(target);
            end
            
            why = struct([]);
            fcn = strrep(fcn,'\','/');  % Rules lists uses /
            
            % Check the target-specific list, and the all-targets list.
            [listed, k] = listedBy(obj, target, fcn);
            if ~listed
                [listed, k] = listedBy(obj, obj.allTargets, fcn);
                if listed, target = obj.allTargets; end
            end
 
            % If fcn is a cell array, listed and k will be vectors. In that
            % case, why should be a vector too.
            if any(listed)
                if isKey(obj.Index, target)
                    range = obj.Index(target);
                    % containers.Map is not vectorized.
                    for j=1:numel(k)
                        if isKey(obj.Reason, target)
                            if listed(j)
                                n = range(k(j));
                                reason = obj.Reason(target);
                                elist = obj.List(target);
                                why(j).identifier = reason{n}.identifier;
                                why(j).message = reason{n}.message;
                                why(j).rule = elist{k(j)};
                            end
                        else
                            error(message(obj.EmptyListError, target));
                        end
                    end
                end
            end
        end
        
        function why = getReason(obj, target)
            why = obj.Reason(target);
        end
        
    end

end
