function structs = concatStructs(structs, stringParser)
% concatStructs concatenates dissimilar structs in a cell vector of structs into a
% struct vector, if possible.
%
%   If all the elements are structs or some are structs and some are strings (and
%   stringParser is set), return a vector of structs which has the union of all the
%   fields.
%
%   If they are of the same matlab.mixin.Heterogeneous class, returns them as a
%   vector. 
%
%   If they are incomparable types, leaves them as a cell array (returns the input).
%
%   The result has the same number of elements as the input.
%    
%    structs       cell array of objects, structures and/or strings
%
%    stringParser  (optional) if structs{i} contains a string, convert it to a struct 
%                  using this function.  If unspecified, all structs must be
%                  structures.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2017 The MathWorks, Inc.

    if ~isempty(structs)
        % If strings and structs are returned,
        % force all elements to be a struct with the same members, with the string
        % becoming a struct of one element whose name is structFields(1) or if
        % missing, 'Arg_1'.
        try
            % First try horzcat, which works if all structs have the same fields or
            % they have a common matlab.mixin.Hetergeneous class.
            % TBD: This code has a flaw because horzcat will try to do conversions,
            % which we don't want in this case.
            altValue = [structs{:}];
            if ischar(altValue) 
                % if the result is a char, all inputs were char vectors, so make it a
                % string vector
                structs = string(structs);
            elseif isstring(altValue)
                structs = altValue;
            else
                % Othwerwise, if it's not a string vector, we have the result of concatenated
                % structs. If there is only one field called 'Arg_1', then it means all elements
                % had just one member and there were no = signs, so this should really be an
                % array of strings, not structs.
                fns = fieldnames(altValue);
                if isscalar(fns) && strcmp(fns{1}, 'Arg_1')
                    structs = [altValue.Arg_1];
                else
                    structs = altValue;
                end
            end
        catch 
            % horzcat didn't work.  This means at least some structs have missing
            % fields or some were structs and some were strings.  Make a map of all field names.
            map = containers.Map();
            for i = 1 : length(structs)
                item = structs{i};
                if ischar(item) || isstring(item)
                    if nargin > 1
                        % item is a string and we have a string parser, so; try to parse it
                        item = stringParser(item);
                    else
                        validateattributes(structs{i},{'struct'},{},'concatStructs');
                    end
                else
                end
                fnames = fieldnames(item);
                for j = 1 : length(fnames)
                    map(fnames{j}) = 1;
                end
            end
            keys = map.keys();
            % add the missing fields to each element
            for i = 1 : length(structs)
                item = structs{i};
                if isstring(item)
                    % item was just a string, so make it into a struct with one unnamed argument
                    item = struct('Arg_1',item);
                else
                    assert(isstruct(item));
                end
                for j = 1 : length(keys)
                    fname = keys{j};
                    if ~isfield(item, fname)
                        item.(fname) = [];
                    else
                    end
                end
                structs{i} = item;
            end
            try
                % Do horzcat once more. This will succeed if everything was converted to a
                % struct. 
                structs = [structs{:}];
            catch 
                % Some items were left as strings, so just return cell array
            end
        end
    end
end