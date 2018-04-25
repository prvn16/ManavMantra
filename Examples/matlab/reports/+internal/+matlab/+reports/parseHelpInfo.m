function strc = parseHelpInfo( fileList, options )
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%PARSEHELPINFO Parse a list of files and up information about their help lines.
%
% s = parseHelpinfo(fileList, options)
%  fileList is a cell array of filenames to parse
%  options is a structure describing what information is to be included in the output struct;
%   options.displayHelpForMethods - display help information for subfunctions and methods
%   options.displayCopyright - display information about the file's copyright line
%   options.displayExamples - display information about example lines
%   options.displaySeeAlso - display information about the see also line

% Copyright 2009-2016 The MathWorks, Inc.

if ~isempty(fileList)
    previous_path = path;
    dir_to_analyze = fileparts(fileList{1});
    onCleanup(@() path(previous_path));
    addpath(dir_to_analyze);
end

strc = []; %#ok<*AGROW>
for n = 1:length(fileList)
    filename = fileList{n};
    [~, shortfilename, ~] = fileparts(filename);
    
    helpContainer = matlab.internal.language.introspective.containers.HelpContainerFactory.create(filename, 'onlyLocalHelp', true);
    strc(end+1).filename = filename;
    strc(end).shortfilename = shortfilename;
    strc(end).fullname = filename;
    strc(end).type = 'file';
    strc(end).help = code2html(helpContainer.getHelp);
    strc(end).description = code2html(helpContainer.getH1Line);
    
    %% copyright
    if options.displayCopyright
        strc(end).copyright = helpContainer.getCopyrightText;
        copyrightInfo = regexp(strc(end).copyright,'^\s*%\s*Copyright.*\s(\d+)-?(\d+)?(.*)$','tokens','once');
        if ~isempty(copyrightInfo)
            beginYear = str2double(copyrightInfo{1});
            if isempty(copyrightInfo{2})
                endYear = beginYear;
            else
                endYear = str2double(copyrightInfo{2});
            end
            
            strc(end).copyrightBeginYear = beginYear;
%             if isempty(endYear) || isnan(endYear)
%                 strc(end).copyrightEndYear = beginYear;
%             else
                strc(end).copyrightEndYear = endYear;
%             end
            strc(end).copyrightOrganization = copyrightInfo{3};
        end
    end
    
    %% see also and example
    [example, exampleLine, seeAlso, seeAlsoFcnList, seeAlsoLine] = getExampleAndSeeAlso(helpContainer, options);
    strc(end).example = example;
    strc(end).seeAlso = seeAlso;
    strc(end).exampleLine = exampleLine;
    strc(end).seeAlsoFcnList = seeAlsoFcnList;
    strc(end).seeAlsoLine = seeAlsoLine;
    
    %% methods
    if options.displayHelpForMethods && helpContainer.isClassHelpContainer
        mi = helpContainer.getMethodIterator;
        while mi.hasNext
            methodContainer = mi.next;
            strc(end+1).filename = filename;
            strc(end).shortfilename = methodContainer.Name;
            strc(end).fullname = [shortfilename '.' methodContainer.Name];
            strc(end).type = getString(message('MATLAB:codetools:reports:ClassMethod'));
            strc(end).help = code2html(methodContainer.getHelp);
            strc(end).description = code2html(methodContainer.getH1Line);
            
            [example, exampleLine, seeAlso, seeAlsoFcnList, seeAlsoLine] = getExampleAndSeeAlso(methodContainer, options);
            strc(end).example = example;
            strc(end).seeAlso = seeAlso;
            strc(end).exampleLine = exampleLine;
            strc(end).seeAlsoFcnList = seeAlsoFcnList;
            strc(end).seeAlsoLine = seeAlsoLine;
        end
    end
    
end % all files
end

function [example, exampleLine, seeAlso, seeAlsoFcnList, seeAlsoLine] = getExampleAndSeeAlso(helpContainer, options)
%% see also and example
example = '';
exampleLine = '';
seeAlso = '';
seeAlsoFcnList = '';
seeAlsoLine = '';

% Now we grep through the function line by line looking for
% copyright, example, and see-also information. Don't bother
% looking for these things in a subfunction.
% NOTE: This will not work for Japanese files

% Short-circuit the searches if the user doesn't want to see
% the result
if options.displayExamples
    exampleSuccessFlag = 0;
else
    exampleSuccessFlag = 1;
end

if options.displaySeeAlso
    seeAlsoSuccessFlag = 0;
else
    seeAlsoSuccessFlag = 1;
end

f = regexp(helpContainer.getHelp,'\n', 'split');

for i = 1:length(f)    
    if ~exampleSuccessFlag
        exTkn = regexpi(f{i},'^\s*(\s*examples?:?\s*\d*\s*)$','tokens','once');
        if ~isempty(exTkn)
            exampleStr = {' ',exTkn{1}};
            exampleLine = i;
            
            % Loop through and grep the entire example
            % We assume the example ends when there is a blank
            % line or when the comments end.
            exampleCompleteFlag = 0;
            for j = (i+1):length(f)
                codeTkn = regexp(f{j},'^\s*(\s*[^\s].*$)','tokens','once');
                if isempty(codeTkn)
                    exampleCompleteFlag = 1;
                else
                    exampleStr{end+1} = codeTkn{1};
                end
                if exampleCompleteFlag
                    break
                end
            end
            
            example = sprintf('%s\n',exampleStr{:});
            exampleSuccessFlag = 1;
        end
    end
     
    if ~seeAlsoSuccessFlag
        %g815237 - This is a workaround to account for the fact that not all of the
        %comments in our shipped MATLAB code are internationalized.  See
        %also, may or maynot be internationalized, but we want this report
        %to do the right thing regardless.  The english version of this
        %check can go away once we have internationalized all of our MATLAB
        %code comments.
        englishSeeAlso = 'See also';
        localizedSeeAlso = getString(message('MATLAB:codetools:reports:SeeAlsoOption'));
        seeAlsoString = '';
        if strfind(f{i},englishSeeAlso)
            seeAlsoString = englishSeeAlso;
        elseif strfind(f{i},localizedSeeAlso)
            seeAlsoString = localizedSeeAlso;
        end
        
        if ~isempty(seeAlsoString)
            seeTkn = regexpi(f{i},['^\s*\s*(' seeAlsoString ':? .*)$'],'tokens','once');
            if ~isempty(seeTkn)
                seeAlso = seeTkn{1};
                seeAlsoLine = i;
                % Remove the pattern "See also"
                seeFcns = strrep(seeTkn{1},seeAlsoString,'');
                seeAlsoFcnList = regexpi(seeFcns,'(\w+)','tokens');
            end
        end
    end
    
    if exampleSuccessFlag && seeAlsoSuccessFlag
        % No need to keep grep'ing once you've found everything
        break
    end
end % help in the file/function

end