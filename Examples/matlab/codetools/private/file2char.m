function c = file2char(filename)

% Copyright 1984-2014 The MathWorks, Inc.

[~,~,ext] = fileparts(filename);

if isequal(ext, '.mlx')
    c = matlab.internal.getCode(filename);
else
    f = fopen(filename);
    c = fread(f,'uint8=>uint8')';              %Read in BYTES using default encoding
    fclose(f);
    
    encodingMatch = regexp(native2unicode(c, 'US-ASCII'),'charset=([A-Za-z0-9\-\.:_])*','tokens','once'); %Detect charset in the file
    
    try
        native2unicode(255,char(encodingMatch));    %Validate the encodingMatch is valid and supported
    catch
        encodingMatch= {};                          %If not valid, set it to empty
        % A warning msg can be added here if needed.
    end
    
    if isempty(encodingMatch)
        locale = feature('locale');
        encodingMatch{1} = locale.encoding;         % Set charset to default encoding if charset not found/invalid in the file
    end
    
    c = native2unicode(c,char(encodingMatch));      % Set charset to what is detected in the file
end
