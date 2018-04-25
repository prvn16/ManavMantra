function eq = areVariablesEqual(oldData, newData)
    % AREVARIABLESEQUAL Compare variables to see if they have changed.
    %
    % eq = internal.matlab.variableeditor.areVariablesEqual(oldVar, newVar)
    % Compares variables oldVar and newVar to see if they have changed.
    % Uses isequal unless one or both of the variables are tall variables,
    % or if they are structs which contain tall variables.  (isequal throws
    % an exception for tall variables).
    %
    %   Copyright 2016 The MathWorks, Inc.
    eq = false;
    try
        if istall(oldData) || istall(newData)
            if ~(istall(oldData) && istall(newData))
                % If one is tall and the other isn't, consider this a
                % data change.
                eq = false;
            else
                % If they are both tall variables, use the additional data
                % about the tall variables (underlying data class/size) to
                % see if there was a change
                eq = areTallVariablesEqual(oldData, newData);
            end
        elseif isstruct(oldData) && isstruct(newData)
            try
                L = lasterror; %#ok<*LERR>
                % Use try/catch to improve performance.  If there are no talls, this
                % will be successful and will perform quicker than the comparisons needed
                % for tall variable support
                eq = isequaln(oldData, newData);
            catch
                lasterror(L);
                if isequal(sort(fields(oldData)), sort(fields(newData))) && ...
                        isequal(length(oldData), length(newData))
                    f = fields(oldData);
                    for idx = 1:length(oldData)
                        % Need to check for structs with tall variables in them,
                        % since this will fail if we try to do isequal on them.
                        % (This may not be common for user workflow, but the
                        % Workspace Browser will have structs with tall variables
                        % when the user has tall variables in their workspace)
                        oldTallFields = cellfun(@(x) istall(oldData(idx).(x)), f, ...
                            'ErrorHandler', @errhandler);
                        newTallFields = cellfun(@(x) istall(newData(idx).(x)), f, ...
                            'ErrorHandler', @errhandler);
                        if isequal(oldTallFields, newTallFields)
                            for i = 1:length(f)
                                if oldTallFields(i)
                                    eq = areTallVariablesEqual(oldData(idx).(f{i}), newData(idx).(f{i}));
                                else
                                    eq = internal.matlab.variableeditor.areVariablesEqual(...
                                        oldData(idx).(f{i}), newData(idx).(f{i}));
                                end
                                
                                if ~eq
                                    break;
                                end
                            end
                        else
                            % Tall fields in the struct are no longer the same
                            eq = false;
                        end
                    end
                else
                    % Both are structs, but fields or lengths are different
                    eq = false;
                end
            end
        else
            % For non-tall variables, we can use isequal to check for
            % the data changing
            eq = isequaln(oldData, newData);
        end
    catch
        eq = false;
    end
end

function eq = areTallVariablesEqual(oldData, newData)
    % If both variables are tall, use the tall information
    % to see if there was a change.  This is a struct
    % containing the class and size of the variable, as
    % well as a preview if its available.  If this struct
    % changes, we can assume the data changed in some way.
    oldTallInfo = matlab.bigdata.internal.util.getArrayInfo(oldData);
    newTallInfo = matlab.bigdata.internal.util.getArrayInfo(newData);
    eq = isequaln(oldTallInfo, newTallInfo);
end

function val = errhandler(err, a, b) %#ok<INUSD>
    % If there are any errors with the struct fields, consider them to be
    % different.
    val = false;
end

