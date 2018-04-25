function [data, err] = validateXYData(data, dim)
% Validate that there are no duplicate or missing values.
% Called from set.XData, set.YData, setXYDisplayData, and heatmap function.

% Copyright 2016-2017 The MathWorks, Inc.

% Convert the data to strings.
err = MException.empty();
if ~isstring(data)
    % The data supplied are not already strings.
    % Attempt to cast it to string.
    try
        data = string(data);
    catch stringErr
        err = MException(message('MATLAB:graphics:heatmap:InvalidString', lower(dim)));
        err = addCause(err, stringErr);
    end
end

% Make sure there are no duplicate or missing values in the data.
if isempty(err)
    % Remove leading and trailing spaces from the strings.
    data = strtrim(data(:));
    
    if numel(data) ~= numel(unique(data))
        err = MException(message('MATLAB:graphics:heatmap:DuplicateValues', lower(dim)));
    elseif any(ismissing(data))
        err = MException(message('MATLAB:graphics:heatmap:MissingValues', lower(dim)));
    elseif any(data == "")
        % Empty strings or character vectors are treated as missing by
        % string and categorical classes, and they are ignored by the
        % categorical ruler.
        err = MException(message('MATLAB:graphics:heatmap:EmptyStrings', lower(dim)));
    else
        % Attempt to cast the data to categorical to make sure that no
        % errors will occur when setting the Categories property on the
        % categorical ruler.
        try
            categorical(data);
        catch categoricalErr
            err = MException(message('MATLAB:graphics:heatmap:InvalidCategoryNames', lower(dim)));
            err = addCause(err, categoricalErr);
        end
    end
end

end
