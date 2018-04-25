 function whichTopic = safeWhich(topic, isCaseSensitive)
    
    if nargin < 2
        isCaseSensitive = false;
    end
    
    [~, name, ext] = fileparts(topic);
    if ~isempty(ext)
        whichTopic = casedWhich(topic, isCaseSensitive, false);
        if ~isempty(whichTopic)
            [~, ~, whichExt] = fileparts(whichTopic);
            if ~strcmpi(ext, whichExt)
                whichTopic = '';
            end
        end
    else
        [whichTopic, descriptor] = casedWhich(topic, isCaseSensitive, true);
        [~, whichName, whichExt] = fileparts(whichTopic);
        if ~strcmpi(name, whichName)
            whichTopic = '';
        end
        isPFile = strcmp(whichExt, '.p');
        if isempty(whichTopic) || (~isempty(descriptor) && (strcmp(whichExt, '.m') || isPFile)) || strcmp(whichExt(2:end), mexext)
            dotMTopic = casedWhich([topic '.m'], isCaseSensitive, false);
            if ~isempty(dotMTopic) && ~(isPFile && strcmp(dotMTopic(1:end-1), whichTopic(1:end-1)))
                whichTopic = dotMTopic;
            end
        end
    end
end

function [result, descriptor] = casedWhich(topic, isCaseSensitive, ignoreExtension) 
    result = '';
    descriptor = '';
    if isempty(regexp(topic, '\)\s*$', 'once'))
        try %#ok<TRYNC> which may throw if topic is unreadable
            if isCaseSensitive

                [allWhich, allWhichDescriptors] = which(topic,'-all');

                % Filter out results that aren't a case match
                generalizeSeperators = regexprep(topic, '\W*', '\\W\*');

                if ignoreExtension
                    generalizeSeperators = [generalizeSeperators '\.[^.]+$'];
                end

                allWhichMatches = regexp(allWhich, ['\<' generalizeSeperators '$'], 'once');

                filterCells = cellfun('isempty', allWhichMatches);

                allWhich(filterCells) = [];
                allWhichDescriptors(filterCells) = [];

                % if topic is a path with a private function, don't filter out private functions
                if isempty(regexp(topic, '[\\/]', 'once'))
                    filterCells = strncmpi(allWhichDescriptors,'private', 7);
                    allWhich(filterCells) = [];
                    allWhichDescriptors(filterCells) = [];
                end

                if ~isempty(allWhich)
                    result = allWhich{1};
                    descriptor = allWhichDescriptors{1};
                end
            else
                [result, descriptor] = which(topic);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.