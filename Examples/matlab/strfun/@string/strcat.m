function t = strcat(varargin)
%STRCAT String horizontal concatenation.
%   T = STRCAT(S1,S2,...), when any of the inputs is a string array,
%   returns a string array by concatenating corresponding elements
%   of S1,S2, etc.  The inputs must all have the same size
%   (or any can be a scalar).

%   Copyright 2016-2017 The MathWorks, Inc.

    % Convert string arguments, replacing <missing> values.
    isScalarMissing = false;
    isNonscalarMissing = false;
    for idx = 1:numel(varargin)
        if isstring(varargin{idx})
            mis = ismissing(varargin{idx});
            if any(mis(:))
                if isscalar(varargin{idx})
                    isScalarMissing = true;
                    varargin{idx} = '';
                else
                    isNonscalarMissing = true;
                    nonscalarMisIdx = mis;
                    str = varargin{idx};
                    str(nonscalarMisIdx) = '';
                    varargin{idx} = cellstr(str);
                end
            else
                varargin{idx} = cellstr(varargin{idx});
            end
        end
    end

    % Use the cell or char method of strcat, converting back to string.
    try
        t = string(strcat(varargin{:}));
    catch e
        throw(e);
    end

    % Restore <missing> values.
    if isScalarMissing
        % Everything is missing.
        t(:) = missing;
    elseif isNonscalarMissing
        % Entire value is missing.
        t(nonscalarMisIdx) = missing;
    end

end
