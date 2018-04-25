function hueSaturationValueMapper(data, info, intermKVStore)
% Map function for the Hue Saturation Value MapReduce example.

% Copyright 1984-2015 The MathWorks, Inc.
    if ~ismatrix(data)
        hsv = rgb2hsv(data);

        % Extract Hue values
        h = hsv(:,:,1);

        % Extract Saturation values
        s = hsv(:,:,2);

        % Extract Brightness values
        v = hsv(:,:,3);

        % Find average of HSV values
        avgH = mean(h(:));
        avgS = mean(s(:));
        avgV = mean(v(:));

        % Add intermediate key-value pairs
        add(intermKVStore, 'Average Hue', struct('Filename', info.Filename, 'Avg', avgH));
        add(intermKVStore, 'Average Saturation', struct('Filename', info.Filename, 'Avg', avgS));
        add(intermKVStore, 'Average Brightness', struct('Filename', info.Filename, 'Avg', avgV));
    end
end
