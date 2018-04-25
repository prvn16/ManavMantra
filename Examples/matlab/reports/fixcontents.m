function fixcontents(fname,action,target)
%FIXCONTENTS  Helper function for CONTENTSRPT
%   FIXCONTENTS(fname, action, target)
%   action and target can both be vectors of the same length.

% Copyright 1984-2016 The MathWorks, Inc.

if nargin==0
    fname = 'Contents.m';
    action = 'all';
end

postFixPrettyPrintFlag = false;

if strcmp(action,'prettyprint')
    action = {action};
    target = {};

elseif strcmp(action,'all')
    dirname = fileparts(fname);
    if isempty(dirname)
        dirname = pwd;
    end
    if isempty(dir(fname))
        makecontentsfile(dirname)
        return
    end
    action = {};
    target = {};
    [ct, ex, dr] = auditcontents(dirname);

    for n = 1:length(ct)
        if ~isempty(ct(n).action)
            action{end+1} = ct(n).action;
            target{end+1} = ct(n).mfilename;
        end
    end
    for n = 1:length(ex)
        action{end+1} = 'append';
        fileStr = regexprep(ex(n).contentsline,'-.*$','');
        target{end+1} = fileStr;
    end

    postFixPrettyPrintFlag = true;

else
    action = {action};
    target = {target};
end


% Read in the Contents.m file
f = textread(fname,'%s','delimiter','\n','whitespace','');

for i = 1:length(action)
    switch action{i}
        case 'update'
            theTarget = target{i};
            [null,theShortTarget] = fileparts(theTarget);

            for j = 1:length(f)
                % First check to see if it is a description, file, or blank
                if isempty(f{j})
                    f{j} = '';
                end

                if ~isempty(regexp(f{j},['^\%\s*' theShortTarget '\s+-\s+.*$'],'once'))
                    descr = getdescription([theTarget '.m']);

                    ndx = strfind(f{j},' - ');
                    if ~isempty(ndx)
                        f{j} = [f{j}(1:(ndx-1)) ' - ' descr];
                    end
                    break
                end
            end

        case 'updatefromcontents'
            % Copy the description line from the Contents.m file

            fname2 = [target{i} '.m'];
            [null,theShortTarget] = fileparts(target{i});
            f2 = getmcode(fname2);
            oldDescrFromFile = getdescription(fname2,0);


            for j = 1:length(f)
                % Step through the Contents file line by line until you
                % come to the target
                tk = regexp(f{j},['^\%\s*' theShortTarget '\s+-\s+(.*)$'],'tokens','once');
                if ~isempty(tk)
                    newDescrFromContents =  [upper(theShortTarget) ' ' tk{1}];
                    f2 = insertNewDescr(f2,oldDescrFromFile,newDescrFromContents);
                end
            end

            writefile(fname2,f2)

        case 'remove'
            theTarget = target{i};
            for j = 1:length(f)
                if isempty(f{j})
                    f{j} = '';
                end
                % First check to see if it is a description, file, or blank
                if ~isempty(regexp(f{j},['^\%\s*' theTarget '\s+-\s+.*$'],'once'))
                    f{j} = [];
                    break
                end
            end

        case 'append'
            filename = target{i};
            filename(filename==32) = [];
            descr = getdescription([filename '.m']);
            f{end+1} = ['%' target{i} '- ' descr];

        case 'prettyprint'
            ct = parsecontentsfile(fname);
            maxNameLen = 0;
            for j = 1:length(ct)
                if ct(j).ismfile
                    maxNameLen = max(length(ct(j).mfilename), maxNameLen);
                end
            end
            maxNameLenStr = num2str(maxNameLen);

            f = {};
            for j = 1:length(ct)
                if ct(j).ismfile
                    f{end+1} = sprintf(['%%   %-' maxNameLenStr 's - %s'], ...
                        ct(j).mfilename, ct(j).description);
                else
                    f{end+1} = ct(j).text;
                end
            end

        otherwise
            error(message('MATLAB:filebrowser:FixContentsUnknownOption', action{ i }))
    end

end
writefile(fname,f)

% Once all the other changes are made, we may want to run the prettyprint
% alignment code
if postFixPrettyPrintFlag
    fixcontents(fname,'prettyprint');
end


% =========================================================================
function writefile(fname,f)
%WRITEFILE  Save file to disk.

lineSep = char(java.lang.System.getProperty('line.separator'));

[fid, errMsg] = fopen(fname,'w');
if fid < 0
    error('MATLAB:filebrowser:FixContentsOpenFailed', errMsg)
else
    for n = 1:length(f)
        fprintf(fid,'%s%s', f{n}, lineSep);
    end
    fclose(fid);
end



% =========================================================================
function fileOut = insertNewDescr(fileIn,oldDescr,newDescr)

if isempty(oldDescr)
    % If there is no help, clone the first line
    fileOut = [fileIn(1); fileIn];

    % Determine if this is a script or a function
    if isempty(regexp(fileIn{1},'^function\s'))
        % If it's a script, help should go on line 1
        fileOut{1} = ['%' newDescr];
    else
        % If it's a function, help should go on line 2
        fileOut{2} = ['%' newDescr];
    end
    return
end

% If an H1 line already exists, find it and replace it.

fileOut = fileIn;
for n = 1:length(fileIn)
    lineContent = regexprep(fileIn{n},'^%\s*','');
    if strcmp(lineContent,oldDescr)
        fileOut{n} = ['%' newDescr];
        break
    end
end
