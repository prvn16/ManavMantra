function hueSaturationValueReducer(key, intermValIter, outKVSTore)
% Reduce function for the Hue Saturation Value MapReduce example.

% Copyright 1984-2015 The MathWorks, Inc.

    maxAvg = 0;
    maxImageFilename = '';

    % Loop over values for each key
    while hasnext(intermValIter)
        value = getnext(intermValIter);

        % Compare values to determine maximum
        if value.Avg > maxAvg
            maxAvg = value.Avg;
            maxImageFilename = value.Filename;
        end

    end

    % Add final key-value pair
    add(outKVSTore, ['Maximum ' key], maxImageFilename);
end
