function demoTopic = getDemoTopic(hp)
    demoTopic = '';
    [path, name] = fileparts(hp.fullTopic);
    if ~isempty(dir(fullfile(path, 'html', [name '.html'])))
        [path, demoTopic] = fileparts(hp.fullTopic);
        while ~strcmp(hp.fullTopic, matlab.internal.language.introspective.safeWhich(demoTopic))
            [path, demoDir] = fileparts(path);
            demoTopic = [demoDir, '/', demoTopic]; %#ok<AGROW>
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
