function varargout = guidemfile(varargin)

%GUIDEMFILE Support function for GUIDE. GUI support code.

%   Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,inf);
 
 
try    
    [varargout{1:nargout}] = feval(varargin{:});
catch me
    % guidefunc handles the error
    rethrow(me);
end
 
%
%----------------------------------------------------------------------
%
function contents = getFileContentsNoSave(filename)
% get contents of file on disk; don't save editor's changes
fid = fopen(filename);
if fid == -1
    error(message('MATLAB:guide:CodeFileNotFound', filename));
else
    contents = native2unicode(fscanf(fid, '%c'));
    fclose(fid);
end
 
%
%----------------------------------------------------------------------
%
function contents = getFileContents(filename, fcontents)
% This is the only place where we READ the file from disk.
 
if ~isempty(fcontents)
    contents = fcontents;
else
    % If this file is currently open in the MATLAB editor and has
    % unsaved changes, we need to force a save in the editor before
    % loading the file ourselves (to catch any changes).
    % TODO: We should prompt the user the first time, with a "don't
    % ask me again" dialog.
    editorObj = matlab.desktop.editor.findOpenDocument(filename);
    if ~isempty(editorObj)
        % Note that this will throw an error if the file cannot be saved.
        editorObj.save;
    end

    contents = getFileContentsNoSave(filename);
end
 
%
%----------------------------------------------------------------------
%
function writeFileContents(filename, contents)
 
[filepath, funcname, ext] = fileparts(filename);
 
fid = fopen(filename, 'w');
if fid == -1
    error(message('MATLAB:guide:CodeFileNotWritable', filename));
else
    fprintf(fid, '%s', contents);
    fclose(fid);
end
 
% Now that we've changed the file, reload it in the editor,
% QUIETLY, if it is already open:
editorObj = matlab.desktop.editor.openDocument(filename);
editorObj.reload;
 
% clear this function out of the parser cache - we might be
% calling it right away if we're about to activate.
clear(funcname);
 
 
%
%----------------------------------------------------------------------
%
function opts = getOptions(filename, contents, options)
% if this file was generated in an older version of GUIDE, let the
% code in the m-file be truth for our defaults, otherwise, use options
% as they are passed in.
 
% seed output with the values passed in
opts = options;
 
guts = getFileContents(filename, contents);
 
% update version field
ind = findVersionString(filename,guts);
if ~isempty(ind)
    opts.version = guts(ind(1):ind(2));
end
 
if options.release < 13
    % update syscolorfig field (1 if special string found; 0 otherwise)
    opts.syscolorfig = 0;
    ind = findSyscolorString(filename,guts);
    if ~isempty(ind)
        opts.syscolorfig = 1;
    end
 
    % update singleton field only if 'openfig' is found
    % (1 if openfig(..., 'reuse'); 0 otherwise)
    ind = findConstructorString(filename,guts);
    if ~isempty(ind)
        opts.singleton = 0;
        if ~isempty(findstr(guts(ind(1):ind(2)), '''reuse'''))
            opts.singleton = 1;
        end
    end
 
    % update blocking field (1 if 'uiwait' found)
    ind = findBlockingString(filename,guts,options);
    if ~isempty(ind)
        opts.blocking = 1;
    end
else
    % update singleton field
    ind = findSingletonString(filename,guts);
    if ~isempty(ind)
        % this should be the string 'gui_Singleton = X;'
        % eval it and try to use the gui_Singleton as a variable
        % default to Singleton == 1 if the variable does not get created
        eval(guts(ind(1):ind(2)),'gui_Singleton = 1;');
        if gui_Singleton == 1
            opts.singleton = 1;
        else
            opts.singleton = 0;
        end
    end
end
 
%
%----------------------------------------------------------------------
%
function [funcnames, linenums_out] = getFunctionNames(file_contents) %%%%%%%%%%%%%%
% should recognize funcs of the form:
% "function funcname"
% "function out = funcname"
% "function funcname(in)"
% "function out = funcname(in)"
% with or without trailing comment characters on the line
 
% replace CRs with NLs so we don't have to worry about this below
% file_contents(find(file_contents == CR)) = NL;
% add trailing newline (internally only) so we don't have to worry
file_contents(end + 1) = NL;
 
% find all occurrences of the word 'function' at begin of line:
funcs = findstr(file_contents, [NL 'function']) + 1;
line_ends = find(file_contents == NL);
 
funcnames = {};
 
linenums=[];
for i = funcs
    linesahead = find(line_ends < i);
    linenums(end+1) = length(linesahead)+1;
    this_line = file_contents(i:(line_ends(linenums(end))));

    % strip off trailing comment (if any)
    comments = find(this_line == '%');
    if ~isempty(comments)
        this_line = this_line(1:(comments(1)-1));
    end
 
    % strip away input args (if any):
    paren = find(this_line == '(');
    if ~isempty(paren)
        this_line = this_line(1:(paren(1) - 1));
    end
 
    % strip away output args (if any), otherwise strip away word 'function':
    equalsign = find(this_line == '=');
    if ~isempty(equalsign)
        this_line = this_line((equalsign(1) + 1):end);
    else
        this_line = this_line(9:end);
    end
 
    % finally strip away all whitespace:
    this_line = this_line(~isspace(this_line));
 
    funcnames{end+1} = this_line;
end
if nargout == 2
    linenums_out = linenums;
end
 
 
%
%----------------------------------------------------------------------
%
function isDirty = isMFileDirty(filename)
%isMFileDirty Checks to see if the given file is open and dirty
editorObj = matlab.desktop.editor.findOpenDocument(filename);
if ~isempty(editorObj)
    isDirty = editorObj.Modified;
else
    isDirty = false;
end
 
%
%----------------------------------------------------------------------
%
function [header, body] = splitHeaderBody(contents)
% look for the first line that doesn't start with a comment,
% and return everything up to that in "header", and the remainder
% in "body".  If the function has no help at the top, and no H1
% line, then only the function declaration will be returned in
% header.  If the function has all help and no code, then body will
% be empty.
lines = find(contents == NL);
non_comments = contents(lines(1:end-1)+1) ~= '%';
headerEnd = min([lines(non_comments) length(contents)]);
header = contents(1:headerEnd);
body = contents((headerEnd+1):end);
 
%
%----------------------------------------------------------------------
% Replace occurrences of a string with another one
%       contents: the string whose 'source' strings needs to be replaced
%       source: the string to search for in contents
%       target: the string replacing 'source'
%
%       policy: 'loose' or 'strict'. Default is 'loose'
%               'loose' implies: strfind(lower(contents), lower(source))
%               'strict' implies: strfind(contents, source)
%       scope: 'comment', 'function', 'code', or 'all'. Indicates where to look
%               for source. 'comment' will only replace string in comments,
%               'function' replacing string in function definition, 'code'
%               replacing string in real code. 'all' looks everywhere.
%               Default is 'all'.    
function result = stringReplace(contents, source, target, policy, scope)
 
if nargin < 5
    scope = 'all';
end
 
if nargin < 4
    policy = 'loose';
end
 
match =[];
if strcmpi(scope, 'all')
    match = getStringLocation(contents, source, policy);
else
    incomment  = strcmpi(scope,'comment');
    infunction = strcmpi(scope,'function');
    incode  = strcmpi(scope,'code');
    subfunctions = getFunctionNames(contents);
 
    NL = 10;
    lineends = strfind(contents, NL);
 
    head = 1;
    for i=1:length(lineends)
        tail = lineends(i);
        line = contents(head:tail);
 
        shortline = line;
        spaces = (shortline==' ');
        shortline(spaces)=[];
 
        if ~isempty(shortline)
            index = strfind(shortline, 'function');
            if (~isempty(index) && index(1) ==1)
                isfunction = 1;
            else
                isfunction = 0;
            end
            iscomment = (shortline(1) == '%');
            iscode = (~iscomment & ~isfunction);
            if (incomment == 1 && iscomment == incomment) ...
                    || (infunction ==1 && isfunction == infunction) ...
                    || (incode==1 && iscode == incode)
                searchfor = source;
                found = getStringLocation(line, searchfor, policy);
 
                if ~isempty(found)
                    % do not do string replace if the target function is
                    % already exists in the m file
                    if (infunction ==1 && isfunction == infunction)
                        rest = line(found(1):end);
                        nameend = strfind(rest, '(');
                        if isempty(nameend)
                            nameend = strfind(rest, ' ');
                        end
                        if isempty(nameend)
                            nameend = strfind(rest, NL);
                        end
                        if ~isempty(nameend)
                            subname = rest(1:(nameend(1)-1));
                            targetname = [target, subname((length(searchfor)+1):end)];
                            spaces = (targetname==' ');
                            targetname(spaces)=[];
                            alreadyexist = 0;
                            % do not use i. It is used in the out loop
                            for k=1:length(subfunctions)
                                if strcmp(targetname, char(subfunctions(k)))
                                    alreadyexist =1 ;
                                    break;
                                end
                            end
                            if ~alreadyexist
                                match=[match, found+head-1];
                            end
                        end
                    else
                        match=[match, found+head-1];
                    end
                end
            end
        end
        head = lineends(i) +1;
    end
end
 
if ~isempty(match)
    head = 1;
    result ='';
    for i=1:length(match)
        thisend = (match(i) + length(source)-1);
        this  = contents(match(i):thisend);
 
        if strcmp(this, source)
            result = [result,contents(head:(match(i)-1)), target];
        elseif strcmp(this, upper(source))
            result = [result,contents(head:(match(i)-1)), upper(target)];
        elseif strcmpi(this, source)
            result = [result,contents(head:(match(i)-1)), lower(target)];
        else
            result = [result,contents(head:(match(i)-1)), this];
        end
        head = match(i) + length(source);
    end
    result = [result, contents(head: end)];
else
    result = contents;
end
 
%
%----------------------------------------------------------------------
% Helper function for stringReplace
% Returns index of searchfor in source. Does whole word match
function found = getStringLocation(source, searchfor, policy)
%
if nargin < 3
    policy = 'loose';
end
 
if strcmpi(policy, 'strict')
    found = strfind(source, searchfor);
else
    % default
    found = strfind(lower(source), lower(searchfor));
end
 
% implement whole-word match
filtered =[];
% do not use i. It is used in the out loop
for j=1:length(found)
    index = found(j);
    endIndex = index + length(searchfor);
    
    OK =1;
    if (index -1)>0
        previous = source(index-1);
        if isletter(previous) || ('0' <= previous && previous <= '9') || (previous == '_')
            OK = 0;
        end
    end
    if (index + length(searchfor))<=length(source)
        next = source(index + length(searchfor));
        if isletter(next) || ('0' <= next && next <= '9') || (next == '_')
            OK = 0;
        end
    end
 
    if OK
        filtered = [filtered, index];
    end
end
found = filtered;
 
 
 
%----------------------------------------------------------------------
%
function updateFile(fig, filename)
% takes a .fig file name, and generates or updates the
% corresponding mfile.  If the mfile doesn't exist yet, create the
% main function.  If the mfile does exist, update the main function
% as necessary.  Then, append any new callback subfunctions.
% Called whenever we choose "save" or "activate" or "edit Callback"
% in the layout editor.  Also called if we modify any mfile options
% in the application options, and hit OK.
% This is the only place where we ever WRITE the file to disk.
 
[filepath, funcname, ext] = fileparts(filename);
mname = fullfile(filepath, [funcname,'.m']);
 
% get the source figure file name. For template, it is saved in the
% 'template' field of GUI options. For existing GUI, it is saved in the
% 'lastFilename' field.
new_options = guideopts(fig);
oldfilename = '';
if isfield(new_options, 'template')
    if exist(new_options.template,'file')
        oldfilename = new_options.template; 
    else
        % remove template so that we do not try to read from it
        new_options = rmfield(new_options, 'template');
    end
elseif isfield(new_options, 'lastFilename') 
    oldfilename = new_options.lastFilename; 
end
 
if ~isempty(oldfilename)
    [oldfilepath, oldfuncname, oldext] = fileparts(oldfilename);
    oldmfile = fullfile(oldfilepath, [oldfuncname,'.m']);
    if exist(oldmfile)
        % use which to return the absolute file path and name
        oldmfile = char(com.mathworks.util.FileUtils.absolutePathname(oldmfile));
        [oldfilepath, oldfuncname, mext] = fileparts(oldmfile);
        
        new_options.lastSavedFile = oldmfile;
        guideopts(fig, new_options);
    end
end
 
 
% Take care of saveAs issues before doing the regular save stuff
isSaveAs = 0;
if isfield(new_options, 'template')
    isSaveAs = 1;
    [p, f, e] = fileparts(new_options.template);
    fname = fullfile(p, [f,'.m']);
    %we will remove 'template' flag after update template content.
    %     new_options = rmfield(new_options, 'template');
elseif isfield(new_options, 'lastSavedFile')
    fname = new_options.lastSavedFile;
    if ispc
        if ~strcmpi(mname, fname)
            isSaveAs = 1;
        end
    else
        if ~strcmp(mname, fname)
            isSaveAs = 1;
        end
    end
end
 
if  isSaveAs
    % get a copy of the latest SAVED changes, before we get a copy of
    % the latest unsaved changes (which forces a save as a
    % side-effect).  We want to make the new file based on the latest
    % changes in the editor, but we don't want the old file to
    % contain those changes - so after we force the save and get the
    % latest contents for the save as, we put back the previous
    % version.
    if guidemfile('isMFileDirty', fname)
        old_contents = getFileContentsNoSave(fname);
        contents =  getFileContents(fname,[]);
        % restore the old file to its last saved state, getting rid of
        % unsaved changes in the editor that were saved as a side-effect
        % of our reading it:
        writeFileContents(fname, old_contents);
    else
        contents =  getFileContentsNoSave(fname);
    end
 
    [p, oldnname, e] = fileparts(fname);    
    % convert all occurrences of the old function name with new
    % function name, preserving case:
    % old -> new (all lowercase)
    % OLD -> NEW (all uppercase)    
    contents = replaceContentStrings(contents, getStringReplacementStruct(oldnname, funcname,APPLICATION));    
 
    % convert all callbacks containing calls to old fcn with calls to
    % new fcn:
    renameCallbacks(handle(findall(fig)), oldnname, funcname);
 
    % now write out the modified version of the old mfile to the new name:
    writeFileContents(mname, contents);
    
end
 
bringEditorForward = 0;
 
if exist(mname)
    prev_contents = getFileContents(mname,[]);
 
    if new_options.release < 13
        % if the MFile already exists, treat any options in it as the
        % TRUTH, overriding what is contained in the options struct (which
        % may be stale).  BUT: if the 'override' flag exists in the
        % options struct, that means we've just come from the App Options
        % dialog, and we want to change what's in the Mfile.
        mfile_options = getOptions(mname,[],new_options);
 
        % allow figure's current color to override the MFile's system
        % color setting:
        if ~isequal(get(fig, 'color'),...
                get(0,'defaultuicontrolbackgroundcolor'))
            mfile_options.syscolorfig = 0;
        end
 
        % If the new_options struct has the override field set, honor the
        % settings in it without checking what's in the MFile (remember
        % to clear that flag so next time we honor the mfile).
        if new_options.override
            new_options.override = 0;
        else
            % allow changes to the mfile to override fields in the stored
            % mfile_options structure:
            fields = {'singleton','syscolorfig','blocking'};
            for i=1:length(fields)
                if isfield(mfile_options, fields{i})
                    new_options.(fields{i}) = mfile_options.(fields{i});
                end
            end
        end
    end
    contents = updateFileContents(mname, prev_contents, new_options, fig);
else
    prev_contents = '';
    contents = makeFileContents(filename, new_options);
    bringEditorForward = 1;
end
 
if new_options.callbacks
    contents = appendCallbacks(contents, fig, funcname, new_options);
end
 
%remove 'template' flag after first time load from template
if isfield(new_options, 'template')
    new_options = rmfield(new_options, 'template');
end
 
guideopts(fig, new_options);
 
needToSave = ~contentsEqual(mname, prev_contents, contents);
 
if needToSave || isSaveAs
 
    if needToSave
        writeFileContents(mname, contents);
    end
 
    % Bring the editor forward.
    if bringEditorForward || isSaveAs
        matlab.desktop.editor.openDocument(mname);
        if isSaveAs
            % close the previous filename in editor:
            editorObj = matlab.desktop.editor.findOpenDocument(new_options.lastSavedFile);
            if ~isempty(editorObj)
                editorObj.close;
            end
        end
    end
 
    new_options.lastSavedFile = mname;
    guideopts(fig, new_options);
 
end
 
%
%----------------------------------------------------------------------
%
function answer = onPath(filepath)
% determine whether the function is on the path (if not, someone
% else will want to add it to the path)
 
mlpath = lower([path pathsep]);
filepath = lower(filepath);
if isempty(findstr([filepath, pathsep],mlpath)) &&...
        ~strcmp(pwd, filepath)
    answer = 0;
else
    answer = 1;
end
 
 
%
%----------------------------------------------------------------------
%
function answer = contentsEqual(filename, contents1, contents2)
% compare two functions IGNORING the version strings:
 
ind = findVersionString(filename,contents1);
if ~isempty(ind)
    contents1(ind(1):ind(2)) = '';
end
ind = findVersionString(filename,contents2);
if ~isempty(ind)
    contents2(ind(1):ind(2)) = '';
end
answer = isequal(contents1, contents2);
 
%
%----------------------------------------------------------------------
%
function contents = updateFileContents(filename, contents, options, fig)
% Given the current contents of a file, and the selected options,
% modify the main function so that it matches the options.
% Includes singleton mode, system-color mode, and blocking mode.
% also generate a newer version string.  The new options are passed
% in, and we compare them to the previous options
 
prev_options = getOptions(filename,contents,options);
 
% replace the version string
contents = updateVersionString(filename, contents);
 
%if the file it is first time read from template file
%remove copyright line
if isfield(options, 'template')
    contents = removeCopyrightLine(filename, contents);
end
 
if options.release < 13
    % change constructor (if necessary and if possible)
    if(isfield(prev_options,'singleton') &&...
            prev_options.singleton ~= options.singleton)
        ind = findConstructorString(filename,contents);
        if ~isempty(ind)
            contents = [contents(1:(ind(1)-1)),...
                makeConstructorString(options.singleton), ...
                contents((ind(2)+1):end)];
        end
    end
 
    % insert/remove syscolor block
    if options.syscolorfig ~= prev_options.syscolorfig
        if prev_options.syscolorfig
            % remove it
            ind = findSyscolorString(filename,contents);
            if ~isempty(ind)
                contents = [contents(1:(ind(1)-1)),contents((ind(2)+1):end)];
            end
        else
            % insert it after openfig
            ind = findSignatureHead(filename,contents, 'matlab.hg.internal.openfigLegacy', 1);
            if ~isempty(ind)
                ind = findNextOccurrenceOfCharacter(contents, ind, NL);
                contents = [contents(1:(ind+1)), ...
                    makeSyscolorString(1), NL, ...
                    NL, ...
                    contents((ind+2):end)];
            end
        end
    end
 
    % insert/remove blocking block
    if options.blocking ~= prev_options.blocking
        if prev_options.blocking
            % remove it
            ind = findBlockingString(filename,contents,options);
            if ~isempty(ind)
                contents = [contents(1:(ind(1)-1)),contents((ind(2)+1):end)];
            end
        else
            % put it just before: the
            %   the 'varargout{', or
            %   the first 'else/end', or
            %   'if nargout',
            % whichever comes first:
            ind = min([findstr(contents, 'varargout{'),...
                findstr(contents, [NL 'else']),...
                findstr(contents, 'if nargout'),...
                findstr(contents, [NL 'end'])]);
            ind = findPreviousOccurrenceOfCharacter(contents, ind, NL);
            contents = [contents(1:ind), NL, ...
                makeBlockingString(1,options), NL, ...
                NL, ...
                contents((ind+1):end)];
        end
    end
else
    % change the Singleton line
    if(prev_options.singleton ~= options.singleton)
        ind = findSingletonString(filename,contents);
        if ~isempty(ind)
            contents = [contents(1:(ind(1)-1)), NL, ...
                makeSingletonString(options.singleton), NL, ...
                contents((ind(2)+1):end)];
        end
    end
end
 
%
%----------------------------------------------------------------------
%
function replaceMfileStrings(filename, sourcestring, targetstring)
if exist(filename,'file')
    [path, file,ext] = fileparts(filename);
    if strcmp(ext,'.m')
        mcode = replaceContentStrings(fileread(filename), getStringReplacementStruct(sourcestring, targetstring, APPLICATION));
        fid = fopen(filename,'w');
        fprintf(fid,'%s',mcode);
        fclose(fid);
    end
end
 
 
function mcode = replaceContentStrings(mcode, replacementArray)
if ~isempty(replacementArray) && ~isempty(mcode)
 
    for i = 1 : length(replacementArray)
        policy = replacementArray(i).policy;
        if ~policy
            policy ='loose';
        end
 
        scope = replacementArray(i).scope;
        if ~scope
            scope ='all';
        end
 
        % replace old filename with new name
        mcode = stringReplace(mcode, replacementArray(i).source, replacementArray(i).target, policy, scope);
 
        % update version string
        if isfield(replacementArray(i), 'version')
            if replacementArray(i).version
                mcode = updateVersionString(replacementArray(1).target, mcode);
            end
        end
 
        % update copyright string
        if isfield(replacementArray(i), 'copyright')
            if replacementArray(i).copyright
                mcode = removeCopyrightLine(replacementArray(1).target, mcode);
            end
        end
    end
end
 
%%
%----------------------------------------------------------------------
%
function ind = findCopyrightString(filename,contents)
% return start and end index of copyright string (or [] if not found)
% consider the whole line from the beginning of the string to the
% \n to be the version string.
ind = [];
prefix = getCopyrightPrefix;
len = length(prefix);
ver_begin = findSignatureHead(filename,contents, prefix, 0);
if ~isempty(ver_begin)
    ver_end = ver_begin + len;
    line_end = findNextOccurrenceOfCharacter(contents, ver_end, NL);
    ind = [ver_begin, line_end +1];
end
 
%%
%----------------------------------------------------------------------
%
function str = getCopyrightPrefix
str = 'Copyright';
 
%%
%----------------------------------------------------------------------
%
function result = removeCopyrightLine(filename, contents)
 
copyRightIndex = findCopyrightString(filename, contents);
if ~isempty(copyRightIndex)
    %find the first index of copyright line
    startCopyrightIndex = findPreviousOccurrenceOfCharacter(contents, copyRightIndex(1), '%');
    endCopyrightIndex = findNextOccurrenceOfCharacter (contents, copyRightIndex(2) + 1, '%');
 
    result = [contents(1:startCopyrightIndex-1), ...
        contents(endCopyrightIndex:end)];
end
 
%
%----------------------------------------------------------------------
%
function str = AUTOMATIC
str = '%automatic';
 
 
%
%----------------------------------------------------------------------
%
function setAutoCallback(h, cb)
setAutoGeneratedCallbackString(h, cb, AUTOMATIC);
com.mathworks.services.ObjectRegistry.getLayoutRegistry.change({handle(h)});
%com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
 
 
%
%----------------------------------------------------------------------
%
function chooseCopyCallbacks(fig, hOriginalVec, hDupVec)
 
options = guideopts(fig);
% for j=1:length(hDupVec)
%     % For external controls, always set the callbacks of the newly copied
%     % objects to AUTOMATIC because those properties will not be saved when
%     % save the GUI (instance properties). For HG objects, this is done only
%     % in FIG/MATLAB code file format so that the AUTOMATIC string will not be saved
%     % in the FIG file.
%     h = hOriginalVec{j};
%     if isExternalControl(h) | (options.mfile & options.callbacks)
%         callbacks = getCallbackProperties(h);
%         for i=1:length(callbacks)
%             if ~isempty(get(h, callbacks{i}))
%                 setAutoCallback(hDupVec(j), callbacks{i});
%             end
%         end
%     end
% end
 
if options.mfile && options.callbacks
    %We decided not to copy any callbacks when we do a copy/paste in
    %layout. Here we remove all the callbacks. If later we need to support
    %certain behavior for callbacks for copy/paste, we can make that change
    %here.
    for j=1:length(hDupVec)
        if ~isExternalControl(hOriginalVec(j))
            callbacks = getCallbackProperties(hDupVec(j));
            for i=1:length(callbacks)
                setAutoGeneratedCallbackString(hDupVec(j), callbacks{i}, []);
            end
        end
    end
      
    % choose default AUTOMATIC callbacks. If users delete the default callback,
    % here is another change to add it.
    guidemfile('chooseAutoCallbacks',hDupVec);
end
 
%
%----------------------------------------------------------------------
%
function chooseAutoCallbacks(hVec)
for h = hVec(:)'
    if strcmp(get(h,'Type'),'uicontrol')
        style = get(h,'Style');
        if strcmp(style, 'frame') || strcmp(style,'text')
            % frames and text objects have callbacks but they never execute
            continue;
        end
        if strcmp(style, 'popupmenu') || strcmp(style, 'listbox') || strcmp(style, 'edit') || strcmp(style,'slider')
            % automatically put in the create fcn for white bg handling
            setAutoCallback(h,'CreateFcn');
        end
 
        if (~((strcmp(style,'radiobutton') || strcmp(style,'togglebutton')) && isbuttongroup(get(h,'parent'))))
            setAutoCallback(h,'Callback');
        end
    end
end
 
%
%----------------------------------------------------------------------
% If newFunc name is not given, all auto generated callbacks will be
% renamed to AUTOMATIC
function renameCallbacks(hVec, oldFunc, newFunc)
if nargin < 3
    newFunc = AUTOMATIC;
end
changed_h ={};
 
for h = hVec(:)'
    callbacks = getCallbackProperties(h);
    for cb = callbacks(:)'
        newCallback = renameThisCallback(h,cb{:},oldFunc,newFunc,true);
        if ~isempty(newCallback)
            changed_h{end+1} = handle(h);
        end
    end
end
if ~isempty(changed_h)
    com.mathworks.services.ObjectRegistry.getLayoutRegistry.change(changed_h);
%    com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
end

%
%----------------------------------------------------------------------
% Rename the callback of given object h from oldFunc to newFunc. 
% If newFunc name is not given, all auto generated callbacks will be
% renamed to AUTOMATIC
function newCallback = renameThisCallback(h, callbackName, oldFunc, newFunc, renameNow)

newCallback = '';
oldLen = length(oldFunc);

if ishghandle(h)
    val = getAutoGeneratedCallbackString(h, callbackName);
    if ischar(val) && strncmp(val, oldFunc, oldLen) && ...
            (...
            length(val) == oldLen ||...
            val(oldLen+1) == ' '   ||...
            val(oldLen+1) == '('    ...
            )
        if isequal(newFunc, AUTOMATIC);
            newVal = newFunc;
        else
            newVal = [newFunc, val((oldLen + 1):end)];
        end
        newCallback = setAutoGeneratedCallbackString(h, callbackName, newVal,renameNow);
    end
end
%
%----------------------------------------------------------------------
%
function loseAutoCallbacks(hVec)
changed_h={};
for h = hVec(:)'
    callbacks = getCallbackProperties(h);
    for cb = callbacks(:)'
        if isAutoCallback(h, cb{:})
            setAutoGeneratedCallbackString(h, cb{:}, '');
            changed_h{end+1}=handle(h);
        end
    end
end
if ~isempty(changed_h)
    com.mathworks.services.ObjectRegistry.getLayoutRegistry.change(changed_h);
    %com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
end
 
 
%
%----------------------------------------------------------------------
%
function external = isExternalControl(h)
 
external = 0;
 
% ActiveX does not support application data
if any(ishghandle(h))
    try
        external = isappdata(h, 'Control');
    catch
        external = 0;
    end
end
 
%
%----------------------------------------------------------------------
%
function info = getExternalControlInfo(obj)
 
info =[];
 
if isExternalControl(obj)
    info = getappdata(obj, 'Control');
end
 
%
%----------------------------------------------------------------------
%
function callbacks = getCallbackProperties(h)
% h can be a valid HG handle or a handle structure for HG object. The later
% is used by printdmfile.
 
callbacks = [];
uitype = '';
uistyle = '';
 
if ishghandle(h)
    if isExternalControl(h)
        info = getExternalControlInfo(h);
        uitype = info.Type;
        uistyle = info.Style;
    else
        uitype = get(handle(h),'Type');
        if ishghandle(h,'uicontrol')
            uistyle = get(h,'Style');
        elseif isbuttongroup(h)
            uitype = 'uibuttongroup';
        end
    end
elseif isstruct(h)
    if isfield(h,'type')
        uitype = h.type;
    end
    try
        info = h.properties.ApplicationData.Control;
        uitype = info.Type;
        uistyle = info.Style;
    catch
    end
elseif ischar(h) && strcmpi(h,APPLICATION)
    uitype = APPLICATION;
end
 
if ~isempty(uitype)
    common = {'CreateFcn'; 'DeleteFcn'; 'ButtonDownFcn'};
    switch uitype
        case 'activex'
            if ishghandle(h)
                info = getExternalControlInfo(h);
                control = info.Instance;
                eventlist = events(control);
                if ~isempty(eventlist)
                    callbacks = fieldnames(eventlist);
                end
            end
        case APPLICATION
            callbacks = ...
                {'OpeningFcn'
                'OutputFcn'};
        case 'figure'
            callbacks = [common
                {'WindowButtonDownFcn'
                'WindowButtonMotionFcn'
                'WindowButtonUpFcn'
                'WindowKeyPressFcn'
                'WindowKeyReleaseFcn'
                'WindowScrollWheelFcn'
                'KeyPressFcn'
                'KeyReleaseFcn'
                'SizeChangedFcn'
                'CloseRequestFcn'}];
        case {'uimenu','uicontextmenu'}
            callbacks = [{'Callback'}; common];
        case 'axes'
            callbacks = common;
        case 'uicontrol'
            if strcmpi(uistyle, 'frame') || strcmpi(uistyle, 'text')
                callbacks = common;
            else
                callbacks = [{'Callback'};common;{'KeyPressFcn'};];
            end
        case 'uipanel'
            callbacks = [common
                {'SizeChangedFcn'}];
        case 'uibuttongroup'
            callbacks = [common
                {'SizeChangedFcn'
                'SelectionChangedFcn'}];
        case 'uicontainer'
            callbacks = common;
        case 'uitoolbar'
            callbacks = common;
        case 'uitoggletool'
            callbacks = [common
                {'ClickedCallback'
                 'OnCallback'
                 'OffCallback'}];
        case 'uipushtool'
            callbacks = [common
                {'ClickedCallback'}];
        case 'uitable'
            callbacks = [{'CellEditCallback'
                'CellSelectionCallback'}
                common
                {'KeyPressFcn'}];
    end
end
 
%
%----------------------------------------------------------------------
%
function contents = appendCallbacks(contents, fig, funcname, options)
% traverse the tree of objects, looking for any callback containing
% '%automatic'.  Replace that callback property with the "magic
% incantation" to get into the subfunction, and append that
% subfunction (if it doesn't already exist).
 
subfcncallback = 'function %s(hObject, eventdata, handles)';
 
% arrange handles in desired order: uicontrol Callbacks + menu Callbacks +
% toolbar Callback
filter.includeParent=1;
filter.uiobjectOnly=0;
filter.sortByType=1;

% need to work around a HG2 problem G641396 for now
children = findAllChildFromHere(fig, filter);
all_h=[];
for i=1:length(children)
    all_h = [all_h; handle(children(i))];
end

% Form a index array into the old tag data for all objects in the GUI
% (all_h) for performance improvement (16 faster). See g393596
oldTagData = getappdata(fig, 'initTags');
matchIndex = zeros(length(all_h),1);
if ~isempty(oldTagData)
    % It is possible several objects use the same tag. Therefore, we need
    % to loop through oldTagData instead of all_h
    for k=1:length(oldTagData)
        taghandles = oldTagData(k).handle;
        for l=1:length(taghandles)
            found= find(all_h == taghandles(l));
            if ~isempty(found)
                matchIndex(found)=k;
            end
        end 
    end
end

% for performance reasons, get the initial list once and append newly added
% callbacks as they are added
existingSubfuncs = getFunctionNames(contents);

% trim trailing new lines, leave only one
lastone= length(contents);
while lastone>0
    if contents(end) == NL
%       contents = contents(1:end-1);
        contents(end) = [];        
    else
        break;
    end
    lastone= length(contents);
end
contents(end+1)= NL;

changed_h={};
for i = 1:length(all_h)
 
    callbacks = getCallbackProperties(all_h(i));
    this_tag = get(all_h(i),'tag');
    objtype = get(all_h(i),'type');

    if matchIndex(i)== 0
       orig_tag = this_tag;
    else
       orig_tag = oldTagData(matchIndex(i)).tag;
    end
    
    for cb = 1:length(callbacks)
        if isAutoCallback(handle(all_h(i)),callbacks{cb})
            this_cb = callbacks{cb};
            % find out what the callback was before this.  If it was
            % already a call into this function, just put it back, else,
            % construct a subfunction for it:
            PREVIOUS_CALLBACK = ['preserve',lower(this_cb)];
            body = getappdata(all_h(i), PREVIOUS_CALLBACK);
 
            [p,n,e]=fileparts(getCBMfileName(fig,body));
            if strcmp(n, funcname)
                % put it back if it was already a call into this file:
                setAutoGeneratedCallbackString(all_h(i),this_cb,body);
            else
                % Check if the object's tag is a valid variable name - if
                % not, then skip this callback, and issue a warning to the
                % user prompting them to change the tag if they want a
                % callback.  When OK is pressed on the warning dialog, jump
                % to that object's tag property in the inspector:
                if ~isvarname(this_tag)
                    warnfig = warndlg(...
                        sprintf(getString(message('MATLAB:guide:guidemfile:InvalidTagValue', this_cb,get(all_h(i),'type'),this_tag))),...
                        getString(message('MATLAB:guide:ComponentName')));
                    setappdata(warnfig, 'GUIDEInspectMe',all_h(i));
                    set(warnfig,'deletefcn','guidemfile(''delayedInspectTag'')');
                    continue
                end 
                
                changed_h{end+1} = all_h(i);
 
                % Now add the subfunction to this file (if it doesn't
                % already exist):
                subfcnLookup = [orig_tag '_' this_cb];
                subfcn = [this_tag '_' this_cb];
                
                autoCallbackString = formAutoGeneratedCallbackString(all_h(i),this_cb,funcname);

                hasSubFcn = any(strcmp(subfcnLookup, existingSubfuncs));
                
                aliasMap = struct('SizeChangedFcn', 'ResizeFcn',...
                                  'SelectionChangedFcn', 'SelectionChangeFcn');
                              
                % Don't generate callback if the callback is an alias. This
                % is for backwards compatiblility with HG1
                if isfield(aliasMap, this_cb)
                    subfcnLookup = strrep(subfcnLookup, this_cb, aliasMap.(this_cb));
                    hasAliasFcn = any(strcmp(subfcnLookup, existingSubfuncs));
                    if hasAliasFcn
                        % Use the HG1 auto callback string since this callback was created in HG1 (g1192448)
                        autoCallbackString = formAutoGeneratedCallbackStringHG1(all_h(i),this_cb,funcname);
                    end
                    hasSubFcn = hasSubFcn || hasAliasFcn;
                end
                
                setAutoGeneratedCallbackString(all_h(i),this_cb,autoCallbackString);
                
                if ~hasSubFcn
                    fcndeclaration = sprintf(subfcncallback, subfcn);
 
                    if ~isempty(body)
                        body = [NL,body];
                    end
                    if strcmp(objtype,'uicontrol')
                        style = get(all_h(i),'style');
                    else
                        style = objtype;
                    end
                    contents = [
                        contents, NL, ...
                        NL, ...
                        makeFunctionPreComment(all_h(i), callbacks{cb},objtype,style,this_tag), ...
                        fcndeclaration, NL, ...
                        makeFunctionPostComment(all_h(i), callbacks{cb},objtype,style,this_tag), ...
                        body
                        ];
                    %add the newly added function to the list
                    existingSubfuncs{end+1} =subfcn;
                end % end if callback subfunction needs to be appended
            end % end if callback was already calling into this file
 
            if isappdata(all_h(i), PREVIOUS_CALLBACK)
                rmappdata(all_h(i), PREVIOUS_CALLBACK);
            end
        end % end converting %automatic callback    
    end % end WHILE loop over all callbacks on this object
    % Check if the callback needs updating
    oldTag = orig_tag;
    newTag = this_tag;
    if ~strcmp(oldTag, newTag)
        replacement = getStringReplacementStruct(oldTag, newTag, all_h(i));
        contents = replaceContentStrings(contents, replacement);
    end  
end % end loop over all objects
 
if ~isempty(changed_h)
    com.mathworks.services.ObjectRegistry.getLayoutRegistry.change(changed_h);
%    com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
end
%
%----------------------------------------------------------------------
%
function delayedInspectTag
warnfig = gcbo;
inspectMe = getappdata(gcbo,'GUIDEInspectMe');
inspect(inspectMe);
com.mathworks.mlservices.MLInspectorServices.activateInspector
com.mathworks.mlservices.MLInspectorServices.selectProperty(java.lang.String('Tag'));
 
%
%----------------------------------------------------------------------
%
function n = NL
n = 10; % ascii newline character
 
%
%----------------------------------------------------------------------
%
function c = CR
c = 13; % ascii carriage-return character
 
%
%----------------------------------------------------------------------
%
function contents = makeFileContents(filename, options)
% Generate the main function the first time through:
 
[path, filename, ext] = fileparts(filename);
FILENAME = upper(filename);
contents =[ 'function varargout = ' filename '(varargin)',NL,...
    '%' FILENAME ' MATLAB code file for ' filename '.fig',NL,...
    '%      ' FILENAME ', by itself, creates a new ' FILENAME ' or raises the existing',NL,...
    '%      singleton*.',NL,...
    '%',NL,...
    '%      H = ' FILENAME ' returns the handle to a new ' FILENAME ' or the handle to',NL,...
    '%      the existing singleton*.',NL,...
    '%',NL,...
    '%      ' FILENAME '(''Property'',''Value'',...) creates a new ' FILENAME ' using the',NL,...
    '%      given property value pairs. Unrecognized properties are passed via',NL,...
    '%      varargin to ' filename '_OpeningFcn.  This calling syntax produces a',NL,...
    '%      warning when there is an existing singleton*.',NL,...
    '%',NL,...
    '%      ' FILENAME '(''CALLBACK'') and ' FILENAME '(''CALLBACK'',hObject,...) call the',NL,...
    '%      local function named CALLBACK in ' FILENAME '.M with the given input',NL,...
    '%      arguments.',NL,...
    '%',NL,...
    '%      *See GUI Options on GUIDE''s Tools menu.  Choose "GUI allows only one',NL,...
    '%      instance to run (singleton)".',NL,...
    '%',NL,...
    '% See also: GUIDE, GUIDATA, GUIHANDLES',NL,...
    '',NL,...
    '% Edit the above text to modify the response to help ' filename '',NL,...
    '',NL,...
    '% ', makeVersionString,NL,...
    '',NL,...
    makeGuiInitializationCode(filename, options) ...
    makeOpeningFcn(filename), ...
    makeOutputFcn(filename)];
 
 
 
%
%----------------------------------------------------------------------
%
function guiMainCode = makeGuiInitializationCode(filename, options)
 
guiMainCode=[...
    '% Begin initialization code - DO NOT EDIT',NL,...
    'gui_Singleton = ', num2str(options.singleton),';',NL,...
    'gui_State = struct(''gui_Name'',       mfilename, ...',NL,...
    '                   ''gui_Singleton'',  gui_Singleton, ...',NL,...
    '                   ''gui_OpeningFcn'', @', filename,'_OpeningFcn, ...',NL,...
    '                   ''gui_OutputFcn'',  @', filename,'_OutputFcn, ...',NL,...
    '                   ''gui_LayoutFcn'',  [], ...',NL,...
    '                   ''gui_Callback'',   []);',NL,...
    'if nargin && ischar(varargin{1})',NL,...
    '   gui_State.gui_Callback = str2func(varargin{1});',NL,...
    'end',NL,...
    '',NL,...
    'if nargout',NL,...
    '    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});',NL,...
    'else',NL,...
    '    gui_mainfcn(gui_State, varargin{:});',NL,...
    'end',NL,...
    '% End initialization code - DO NOT EDIT',NL,...
    '',NL,...
    '',NL];
 
%    'gui_Name  = mfilename;',NL,...
%    'gui_main;',NL,...
 
%
%----------------------------------------------------------------------
%
function openingFcn = makeOpeningFcn(filename)
import com.mathworks.toolbox.matlab.guide.LayoutPrefs;
 
preComment = '';
postComment = '';
if (LayoutPrefs.getLayoutBooleanPref(LayoutPrefs.COMMENTS))
    preComment = ['% --- Executes just before ' filename ' is made visible.',NL];
    postComment = ['% This function has no output args, see OutputFcn.',NL,...
        '% hObject    handle to figure',NL,...
        '% eventdata  reserved - to be defined in a future version of MATLAB',NL,...
        '% handles    structure with handles and user data (see GUIDATA)',NL,...
        '% varargin   unrecognized PropertyName/PropertyValue pairs from the',NL,...
        '%            command line (see VARARGIN)',NL];
end
 
openingFcn=[...
    preComment,...
    'function ' filename '_OpeningFcn(hObject, eventdata, handles, varargin)',NL,...
    postComment,...
    '', NL, ...
    '% Choose default command line output for ' filename,NL,...
    'handles.output = hObject;',NL,...
    '',NL,...
    '% Update handles structure',NL,...
    'guidata(hObject, handles);',NL,...
    '',NL,...
    '% UIWAIT makes ' filename ' wait for user response (see UIRESUME)',NL,...
    '% uiwait(handles.figure1);',NL];
 
%
%----------------------------------------------------------------------
%
function outputFcn = makeOutputFcn(filename)
import com.mathworks.toolbox.matlab.guide.LayoutPrefs;
 
preComment = '';
postComment = '';
if (LayoutPrefs.getLayoutBooleanPref(LayoutPrefs.COMMENTS))
    preComment = ['% --- Outputs from this function are returned to the command line.',NL];
    postComment = ['% varargout  cell array for returning output args (see VARARGOUT);',NL,...
        '% hObject    handle to figure',NL,...
        '% eventdata  reserved - to be defined in a future version of MATLAB',NL,...
        '% handles    structure with handles and user data (see GUIDATA)',NL];
end
 
outputFcn=[...
    '',NL,...
    '',NL,...
    preComment,...
    'function varargout = ' filename '_OutputFcn(hObject, eventdata, handles)',NL,...
    postComment,...
    '',NL,...
    '% Get default command line output from handles structure',NL,...
    'varargout{1} = handles.output;',NL];
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 VERSION handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeVersionString
prefix = getVersionPrefix;
verStr = '2.5';
dateStr = date;
timeVec = clock;
timeStr = sprintf('%02d:%02d:%02d',fix(timeVec(4:6)));
str = sprintf('%s%s %s %s',prefix,verStr,dateStr,timeStr);
 
 
%
%----------------------------------------------------------------------
%
function result = updateVersionString(filename, contents)
 
result = contents;
ind = findVersionString(filename,contents);
if ~isempty(ind)
    result = [contents(1:(ind(1)-1)),...
        makeVersionString,NL,...
        contents((ind(2)+1):end)];
end
 
 
%
%----------------------------------------------------------------------
%
function ind = findVersionString(filename,contents)
% return start and end index of version string (or [] if not found)
% consider the whole line from the beginning of the string to the
% \n to be the version string.
ind = [];
prefix = getVersionPrefix;
len = length(prefix);
ver_begin = findSignatureHead(filename,contents, prefix, 0);
if ~isempty(ver_begin)
    ver_end = ver_begin + len;
    line_end = findNextOccurrenceOfCharacter(contents, ver_end, NL);
    ind = [ver_begin, line_end];
end
 
function str = makeSingletonString(is_singleton)
if is_singleton
    str = 'gui_Singleton = 1;';
else
    str = 'gui_Singleton = 0;';
end
 
%
%----------------------------------------------------------------------
%
function str = getVersionPrefix
str = 'Last Modified by GUIDE v';
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                CONSTRUCTOR handling                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeConstructorString(is_singleton)
if is_singleton
    arg = 'reuse';
else
    arg = 'new';
end
str = sprintf('matlab.hg.internal.openfigLegacy(mfilename,''%s'',varargin{:});',arg);
 
%
%----------------------------------------------------------------------
%
function ind = findConstructorString(filename,contents)
 
ind = [];
const_start = findSignatureHead(filename,contents, 'openfig',1);
if ~isempty(const_start)
    const_end = const_start + 6;
    if contents(const_end + 1) == '('
        closeparen = findNextOccurrenceOfCharacter(contents, const_start,')');
        const_end = closeparen;
        if contents(const_end + 1) == ';'
            const_end = const_end + 1;
        end
    end
    ind = [const_start const_end];
end
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                SYSCOLOR handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeSyscolorString(is_syscolorfig)
 
if is_syscolorfig
    str = sprintf('%s\n%s', getSyscolorComment,getSyscolorCode);
else
    str = '';
end
 
%
%----------------------------------------------------------------------
%
function str = getSyscolorComment %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = '% Use system color scheme for figure:';
 
%
%----------------------------------------------------------------------
%
function str = getSyscolorCode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = 'set(fig,''Color'',get(0,''DefaultUicontrolBackgroundColor''));';
 
%
%----------------------------------------------------------------------
%
function ind = findSyscolorString(filename,contents) %%%%%%%%%%%%%%%%%%%%%
comment = findLineExtent(contents, findSignatureHead(filename,contents, getSyscolorComment, 0));
code = findLineExtent(contents, findSignatureHead(filename,lower(contents), lower(getSyscolorCode),1));
if isempty(code)
    code = findLineExtent(contents, findStrWithSpacing(lower(contents), lower(getSyscolorCode)));
end
 
ind = [min([comment code]) max([comment code])];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BLOCKING handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = getBlockingComment
str = '% Wait for callbacks to run and window to be dismissed:';
function str = getBlockingCode(options)
str = 'uiwait(fig);';
 
%
%----------------------------------------------------------------------
%
function str = makeBlockingString(is_blocking,options)
if is_blocking
    str = sprintf('%s\n%s',getBlockingComment, getBlockingCode(options));
else
    str = '';
end
 
%
%----------------------------------------------------------------------
%
function ind = findBlockingString(filename,contents,options)
lines = [findLineExtent(contents, findSignatureHead(filename,contents,getBlockingComment, 0)),...
    findLineExtent(contents, findSignatureHead(filename,contents,getBlockingCode(options), 0))];
ind = [min(lines), max(lines)];
 
%
%----------------------------------------------------------------------
%
function ind = findSingletonString(filename,contents)
lines = findLineExtent(contents, findSignatureHead(filename,contents,'gui_Singleton =',0));
ind = [min(lines), max(lines)];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             STRING SEARCHING UTILITIES                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind = findLineExtent(contents, pos) %%%%%%%%%%%%%%%%%%%%%%
if isempty(pos)
    ind = [];
else
    ind = [findPreviousOccurrenceOfCharacter(contents, pos, NL),...
        findNextOccurrenceOfCharacter(contents, pos, NL)];
end
 
%
%----------------------------------------------------------------------
%
function ind = findNextOccurrenceOfCharacter(contents, pos, character)
occurrences = find(contents == character);
% only care about the first one
ind = occurrences(min(find(occurrences>pos(1))));
 
%
%----------------------------------------------------------------------
%
function ind = findPreviousOccurrenceOfCharacter(contents, pos, character)
occurrences = find(contents == character);
% only care about the first one
ind = occurrences(max(find(occurrences<pos(1))));
 
%
%----------------------------------------------------------------------
%
function index = findSignatureHead(filename,contents, signature, inCommand)
persistent warnedFlags;
 
index = [];
 
% get the positions of occurrence of signature
occurrences = findstr(contents, signature);
counter = 0;
 
% process each occurrence
candidates = [];
 
% if inCommand ==1, ignore occurrences of signature in comments
if (inCommand)
    thisLine =[];
    numOccurrences = length(occurrences);
    while ( ~isempty(contents) && counter < numOccurrences)
        [thisLine,contents] = strtok(contents, NL);
 
        % search each line
        newPos = findstr(thisLine, signature);
 
        % add to candidates if signature string is not in comments
        for i=1:length(newPos)
            if (isempty(findstr(thisLine(1:newPos(i)),'%')))
                candidates = [candidates; occurrences(counter+1)];
            end
        end
 
        % index into the accurate positions of the signature in occurrences
        counter = counter + length(newPos);
    end
else
    % search everywhere, including comments
    candidates = occurrences;
end
 
% show warning dialog if first time detection of multiple copies of signature
if (~isempty(candidates))
    index = candidates(1);
 
    % form signature field name
    field = signature;
    field(find(~isletter(field))) =[];
    % structure field name length must less than 31
    % should chose longer enough to form unique field names
    if length(field) > 30
        field = field(1:30);
    end
 
    name = fliplr(filename);
    name(find(~isletter(name))) =[];
    if length(name) > 30
        name = name(1:30);
    end
 
    if (length(candidates) > 1)
        % maintain warning structure
        % warning flags is per m file
        if (isempty(warnedFlags))
            warnedFlags = struct(name,struct('Function', name));
        elseif  ~isfield(warnedFlags, name)
            warnedFlags.(name) =  struct('Function', name);
        end
 
        % show warning dialog if first time detection
        if (length(field) > 0 && ~isfield(eval(['warnedFlags.',name]), field))
            myFlags = eval(['warnedFlags.',name]);
            myFlags.(field) = 1;
            warnedFlags.(name) = myFlags;
            warndlg(sprintf('%s',getString(message('MATLAB:guide:guidemfile:MultipleSystemStringCopy', filename, signature))),...
                    getString(message('MATLAB:guide:ComponentName')));
        end
    else
        % remove the corresponding field so that changes later can still cause warning dialog
        if (~isempty(warnedFlags) && isfield(warnedFlags, name) && isfield(eval(['warnedFlags.',name]), field))
            myFlags = eval(['warnedFlags.',name]);
            myFlags = rmfield(myFlags,field);
            warnedFlags.(name) = myFlags;
        end
    end
end
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    OTHER UTILITIES                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mname = getCBMfileName(fig, cb)
% parse callback of the form: FUNCTION('SUBFUNCTION',...)
% returning the full path to the Mfile named FUNCTION
mname = '';
if ~isempty(cb)
    funcname_end = min([find(cb==' '),find(cb == '('),length(cb)+1]);
    mcommand = cb(1:(funcname_end-1));
 
    figfile = get(fig,'filename');
    if isempty(figfile)
        mname = which(mcommand);
    else
        [p,f,e] = fileparts(figfile);
        mname = fullfile(p,[f, '.m']);
    end
end
 
%
%----------------------------------------------------------------------
%
function cbname = getCBSubfunctionName(cb)
cbname = '';
quotes = find(cb=='''');
if length(quotes) >= 2
    cbname = cb((quotes(1)+1):(quotes(2)-1));
end
 
%
%----------------------------------------------------------------------
%
function lineno = getSubfunctionLineNumber(mname, cbname)
contents = getFileContents(mname,[]);
[names, linenos] = getFunctionNames(contents);
ind = strmatch(cbname, names, 'exact');
if length(ind) == 1
    %  lineno = length(find(find(contents==NL) < ind)) + 1;
    lineno = linenos(ind);
else
    lineno = 0;
end
 
%
%----------------------------------------------------------------------
%
function scrollToCBSubfunction(fig, obj, whichCb)
if ~isAutoCallback(obj, whichCb)
    currentCb = getAutoGeneratedCallbackString(handle(obj),whichCb);
    
    mfunc = getCBMfileName(fig, currentCb);
    subfunc = getCBSubfunctionName(currentCb);
    if ~isempty(mfunc) && ~isempty(subfunc)
        [p,f,e] = fileparts(mfunc);
        where = strfind(strtrim(currentCb),f);
        if ~isempty(where) && where(1)==1 
            lineno = getSubfunctionLineNumber(mfunc,subfunc);
            % Find HG1 callbacks for backward compatibility
            if(~lineno && (isequal(whichCb,'SelectionChangedFcn')||...
                                isequal(whichCb, 'SizeChangedFcn')))
                if(strfind(subfunc, 'SelectionChangedFcn'))
                    subfunc = strrep(subfunc, 'SelectionChangedFcn','SelectionChangeFcn');
                end
                if(strfind(subfunc, 'SizeChangedFcn'))
                    subfunc = strrep(subfunc, 'SizeChangedFcn','ResizeFcn');
                end
                lineno = getSubfunctionLineNumber(mfunc,subfunc);
            end
                

            if lineno
                matlab.desktop.editor.openAndGoToLine(mfunc, lineno);
            else
                warndlg(...
                    sprintf(getString(message('MATLAB:guide:guidemfile:FailToLocateGivenFunction', subfunc, mfunc, whichCb,subfunc))), ...
                    getString(message('MATLAB:guide:ComponentName')));
            end
        end
    end        
end
 
 
%
%----------------------------------------------------------------------
%
function preComment = makeFunctionPreComment(hObject, callbackName, objType, objStyle, objTag)
import com.mathworks.toolbox.matlab.guide.LayoutPrefs;
 
lineLength = 70;
preComment ='';
 
if (LayoutPrefs.getLayoutBooleanPref(LayoutPrefs.COMMENTS))
    preComment = ['% ' ones(1,lineLength-2)*abs('-')];
    switch callbackName
        case 'Callback'
            switch objStyle
                case {'pushbutton','togglebutton','radiobutton','checkbox'}
                    preComment = sprintf('%% --- Executes on button press in %s.', objTag);
                case 'edit'
                    preComment = sprintf([
                        '% --- Executes when user selects %s and presses enter.  Also executes\n', ...
                        '% --- if user changes contents and clicks outside %s.'], objTag, objTag);
                case 'text'
                    % use default, text objects do not fire callbacks
                case 'slider'
                    preComment = sprintf('%% --- Executes on slider movement.');
                    % use default, frame objects do not fire callbacks
                case {'listbox', 'popupmenu'}
                    preComment = sprintf('%% --- Executes on selection change in %s.', objTag);
                otherwise
                    % use default, unknown object type
            end
        case 'CreateFcn'
            preComment = sprintf('%% --- Executes during object creation, after setting all properties.');
        case 'DeleteFcn'
            preComment = sprintf('%% --- Executes during object deletion, before destroying properties.');
        case 'ButtonDownFcn'
            switch objType
                case 'uicontrol'
                    preComment = sprintf([
                        '%% --- If Enable == ''on'', executes on mouse press in 5 pixel border.\n', ...
                        '%% --- Otherwise, executes on mouse press in 5 pixel border or over %s.'], objTag);
                case 'figure'
                    preComment = sprintf('%% --- Executes on mouse press over figure background.');
                case 'axes'
                    preComment = sprintf('%% --- Executes on mouse press over axes background.');
                otherwise
                    % use default, unknown object type
            end
        case {'WindowButtonDownFcn', 'WindowButtonUpFcn'}
            preComment = sprintf([
                '%% --- Executes on mouse press over figure background, over a disabled or\n', ...
                '%% --- inactive control, or over an axes background.']);
        case 'WindowButtonMotionFcn'
            preComment = sprintf('%% --- Executes on mouse motion over figure - except title and menu.');
        case 'WindowKeyPressFcn'
            preComment = sprintf('%% --- Executes on key press with focus on %s or any of its controls.', objTag);
        case 'WindowKeyReleaseFcn'
            preComment = sprintf('%% --- Executes on key release with focus on %s or any of its controls.', objTag);
        case 'WindowScrollWheelFcn'
            preComment = sprintf('%% --- Executes on scroll wheel click while the figure is in focus.');
        case 'KeyPressFcn'
            preComment = sprintf('%% --- Executes on key press with focus on %s and none of its controls.', objTag);
        case 'KeyReleaseFcn'
            preComment = sprintf('%% --- Executes on key release with focus on %s and none of its controls.', objTag);
        case 'SizeChangedFcn'
            preComment = sprintf('%% --- Executes when %s is resized.', objTag);
        case 'ResizeFcn'
            preComment = sprintf('%% --- Executes when %s is resized.', objTag);
        case 'CloseRequestFcn'
            preComment = sprintf('%% --- Executes when user attempts to close %s.', objTag);
        case 'SelectionChangeFcn'
            preComment = sprintf('%% --- Executes when selected object is changed in %s.', objTag);
        case 'SelectionChangedFcn'
            preComment = sprintf('%% --- Executes when selected object is changed in %s.', objTag);
        case 'CellEditCallback'
            preComment = sprintf('%% --- Executes when entered data in editable cell(s) in %s.', objTag);
        case 'CellSelectionCallback'
            preComment = sprintf('%% --- Executes when selected cell(s) is changed in %s.', objTag);
        otherwise
            % use default, unknown callback type
    end
    preComment = [preComment, NL];
end
 
%
%----------------------------------------------------------------------
%
function postComment = makeFunctionPostComment(hObject, callbackName, objType, objStyle, objTag)
import com.mathworks.toolbox.matlab.guide.LayoutPrefs;
 
postComment = '';

% add comments
if (LayoutPrefs.getLayoutBooleanPref(LayoutPrefs.COMMENTS))
    if isExternalControl(hObject)
        eventdata = sprintf('%% eventdata  structure with parameters passed to COM event listener\n');
    elseif hasEventData(objType, objStyle, callbackName)
        typehelp = upper(class(handle(hObject)));
        if strfind(typehelp,'UIBUTTONGROUP')
            typehelp = 'UIBUTTONGROUP';
        end
        eventdata = sprintf('%% eventdata  structure with the following fields (see %s)\n%s', ...
            typehelp, makeEventdataComment(objType, objStyle, callbackName));
    else
        eventdata = sprintf('%% eventdata  reserved - to be defined in a future version of MATLAB\n');
    end
    postComment = sprintf([
        '%% hObject    handle to %s (see GCBO)\n%s', ...
        '%% handles    structure with handles and user data (see GUIDATA)\n'], ...
        objTag, eventdata);
    switch callbackName
        case 'Callback'
            switch objStyle
                case 'pushbutton'
                    % use default
                case {'togglebutton','radiobutton','checkbox'}
                    postComment = sprintf( [
                        '%s\n', ...
                        '%% Hint: get(hObject,''Value'') returns toggle state of %s\n', ...
                        ], postComment, objTag);
                case 'edit'
                    postComment = sprintf( [
                        '%s\n', ...
                        '%% Hints: get(hObject,''String'') returns contents of %s as text\n', ...
                        '%%        str2double(get(hObject,''String'')) returns contents of %s as a double\n', ...
                        ], postComment, objTag, objTag);
                case 'text'
                    % use default, text objects do not fire callbacks
                case 'slider'
                    postComment = sprintf( [
                        '%s\n', ...
                        '%% Hints: get(hObject,''Value'') returns position of %s\n', ...
                        '%%        get(hObject,''Min'') and get(hObject,''Max'') to determine range of %s\n', ...
                        ], postComment, objStyle, objStyle);
                case 'frame'
                    % use default, frame objects do not fire callbacks
                case {'listbox','popupmenu'}
                    postComment = sprintf( [
                        '%s\n', ...
                        '%% Hints: contents = cellstr(get(hObject,''String'')) returns %s contents as cell array\n', ...
                        '%%        contents{get(hObject,''Value'')} returns selected item from %s\n', ...
                        ], postComment, objTag, objTag);
                otherwise
                    % use default, unknown object type
            end
        case 'CreateFcn'
            postComment = sprintf([
                '%% hObject    handle to %s (see GCBO)\n', ...
                '%% eventdata  reserved - to be defined in a future version of MATLAB\n', ...
                '%% handles    empty - handles not created until after all CreateFcns called\n'], ...
                objTag);
 
            switch objStyle
                case 'axes'
                    postComment = sprintf( [
                        '%s\n', ...
                        '%% Hint: place code in OpeningFcn to populate %s\n', ...
                        ], postComment, objTag);
            end
 
        case 'DeleteFcn'
            % use default
        case 'ButtonDownFcn'
            switch objType
                case 'uicontrol'
                    % use default
                case 'figure'
                    % use default
                case 'axes'
                    % use default
                otherwise
                    % use default, unknown object type
            end
        case 'WindowButtonDownFcn'
            % use default
        case 'WindowButtonMotionFcn'
            % use default
        case 'WindowButtonUpFcn'
            % use default
        case 'KeyPressFcn'
            % use default
        case 'KeyReleaseFcn'
            % use default
        case 'SizeChangedFcn'
            % use default
        case 'ResizeFcn'
            % use default
        case 'CloseRequestFcn'
            % use default
        case 'SelectionChangedFcn'
            % reflect uibuttongroup's current behavior.
            postComment = sprintf([
                '%% hObject    handle to the selected object in %s \n%s', ...
                '%% handles    structure with handles and user data (see GUIDATA)\n'], ...
                objTag, eventdata);
        otherwise
            % use default, unknown callback type
    end
 
end
 
% add example code for certain callbacks
switch callbackName
    case 'CreateFcn'
        switch objStyle
            case {'listbox', 'popupmenu', 'edit'}
                postComment = sprintf( [
                    '%s\n', ...
                    '%% Hint: %s controls usually have a white background on Windows.\n', ...
                    '%%       See ISPC and COMPUTER.\n', ...
                    'if ispc && isequal(get(hObject,''BackgroundColor''), get(0,''defaultUicontrolBackgroundColor''))\n', ...
                    '    set(hObject,''BackgroundColor'',''white'');\n', ...
                    'end\n', ...
                    ], postComment, objStyle);
            case 'slider'
                postComment = sprintf( [
                    '%s\n', ...
                    '%% Hint: %s controls usually have a light gray background.\n', ...
                    'if isequal(get(hObject,''BackgroundColor''), get(0,''defaultUicontrolBackgroundColor''))\n', ...
                    '    set(hObject,''BackgroundColor'',[.9 .9 .9]);\n', ...
                    'end\n', ...
                    ], postComment, objStyle);
 
        end
    case 'CloseRequestFcn'
        postComment = sprintf( [
            '%s\n', ...
            '%% Hint: delete(hObject) closes the figure\n', ...
            'delete(hObject);\n', ...
            ], postComment);
end

%
%----------------------------------------------------------------------
%
function has = hasEventData(type, style, callbackName)
switch callbackName
    case {  'WindowScrollWheelFcn',...
            'KeyPressFcn',...
            'SelectionChangeFcn',...
            'KeyReleaseFcn',...
            'CellEditCallback',...
            'CellSelectionCallback',...
            'WindowKeyPressFcn',...
            'WindowKeyReleaseFcn'}
        has = true;
    otherwise
        has = false;
end

%----------------------------------------------------------------------
%
function eventdata = makeEventdataComment(type, style, callbackName)
eventdata ='';
switch callbackName
    case {'KeyPressFcn', 'WindowKeyPressFcn'}
        eventdata = sprintf('%%\tKey: %s\n%%\tCharacter: %s\n%%\tModifier: %s\n', ...
        'name of the key that was pressed, in lower case', ...
        'character interpretation of the key(s) that was pressed',...
        'name(s) of the modifier key(s) (i.e., control, shift) pressed');         
    case {'KeyReleaseFcn', 'WindowKeyReleaseFcn'}
        eventdata = sprintf('%%\tKey: %s\n%%\tCharacter: %s\n%%\tModifier: %s\n', ...
        'name of the key that was released, in lower case', ...
        'character interpretation of the key(s) that was released',...
        'name(s) of the modifier key(s) (i.e., control, shift) released'); 
    case 'WindowScrollWheelFcn'
        eventdata = sprintf('%%\tVerticalScrollCount: %s\n%%\tVerticalScrollAmount: %s\n', ...
        'signed integer indicating direction and number of clicks', ...
        'number of lines scrolled for each click');         
    case 'SelectionChangeFcn'
        eventdata = sprintf('%%\tEventName: %s\n%%\tOldValue: %s\n%%\tNewValue: %s\n', ...
        'string ''SelectionChanged'' (read only)', ...
        'handle of the previously selected object or empty if none was selected',...
        'handle of the currently selected object');         
    case 'CellEditCallback'
        eventdata = sprintf('%%\tIndices: %s\n%%\tPreviousData: %s\n%%\tEditData: %s\n%%\tNewData: %s\n%%\tError: %s\n', ...
        'row and column indices of the cell(s) edited', ...
        'previous data for the cell(s) edited',...
        'string(s) entered by the user',...
        'EditData or its converted form set on the Data property. Empty if Data was not changed',...
        'error string when failed to convert EditData to appropriate value for Data');         
    case 'CellSelectionCallback'
        eventdata = sprintf('%%\tIndices: %s\n', ...
        'row and column indices of the cell(s) currently selecteds');         
end

%
%----------------------------------------------------------------------
%
% Try to find System Color string - in case user inserted spaces.
% contents - contents of MATLAB code file.
% str      - string that is being searched for.
function codeIndex = findStrWithSpacing(contents, str)
 
% Initialize variables.
codeIndex = [];
 
% Determine if defaultUicontrolBackgroundColor is in contents.
% If not codeIndex = [] and return.
codeIndex = findstr('defaultuicontrolbackgroundcolor', contents);
if isempty(codeIndex)
    return
end
 
% Determine if the remaining contents of the DefaultUicontrolBackgroundColor
% line is str.
 
% Remove spaces.
str((str == ' ')) = '';
 
% Extract the line.
for i = 1:length(codeIndex)
    index = findLineExtent(contents, codeIndex(i));
    contentsLine = contents(index(1)+1:index(2)-1);
 
    % Remove spaces.
    contentsLine((contentsLine == ' ')) = '';
 
    % Compare - Return index if the same otherwise return [] (initialized value).
    if strcmp(str, contentsLine)
        codeIndex = index(1)+1;
        return;
    end
end
 
% If defaultUicontrolBackgroundColor is found but it is not part
% of the entire string need to reset codeIndex to empty.
codeIndex = [];
 
 
% *************************************************************************
% find all children of a given HG object with the designated filter(s)
% *************************************************************************
function children = findAllChildFromHere(parent, filter)
 
parent =double(parent);
children = [];
 
if nargin <=1
    filter = [];
end
if ~isfield(filter, 'includeParent')
    filter.includeParent = 0;
end
if ~isfield(filter, 'recursiveSearch')
    filter.recursiveSearch = 1;
end
if ~isfield(filter, 'childrenInReverseOrder')
    filter.childrenInReverseOrder = 1;
end
if ~isfield(filter, 'uiobjectOnly')
    filter.uiobjectOnly = 1;
end
if ~isfield(filter, 'uicontainerOnly')
    filter.uicontainerOnly = 0;
end
if ~isfield(filter, 'includeHiddenHandles')
    filter.includeHiddenHandles = 1;
end
if ~isfield(filter, 'serializableOnly')
    filter.serializableOnly = 1;
end
if ~isfield(filter, 'sortByType')
    filter.sortByType = 0;
end
 
%do not search for axes child
if strcmpi(get(parent,'type'),'axes')
    if filter.includeParent ==1
        children = parent;
    else
        children =[];
    end
    return;
end
 
if filter.recursiveSearch == 1
    % need to search for children layer by layer and the order
    % of all children in each layer should be reversed
    if filter.includeParent ==1
        childlist(1) =double(parent);
    else
        childlist =[];
    end
    mychildren =[];
    if ~isempty(allchild(parent))    
        if filter.childrenInReverseOrder
            mychildren = flipud(allchild(parent));
        else
            mychildren = allchild(parent);
        end   
    end
    while (~isempty(mychildren))        
        %do not include new Hg2 objects
        
        newobjtypes = {'hggroup', 'annotationpane', ...
                       'arrowshape', 'doubleendarrowshape', ...
                       'textarrowshape', 'lineshape', 'ellipseshape',...
                       'rectangleshape', 'textboxshape'};
                                        
        for i = 1:numel(newobjtypes)
            mychildren(ishghandle(mychildren,newobjtypes{i})) = [];
        end
        childlist = [childlist;mychildren];
        
        % do not include axes children
        mychildren(ishghandle(mychildren,'axes')) = [];
        if filter.childrenInReverseOrder
            temp = flipud(mychildren);
        else
            temp = mychildren;
        end
        mychildren = [];
        for i=1:length(temp)
            if ~isempty(allchild(temp(i)))
                if filter.childrenInReverseOrder
                    mychildren = [mychildren; flipud(allchild(temp(i)))];
                else
                    mychildren = [mychildren; allchild(temp(i))];
                end
            end
        end
    end
else
    childlist = flipud(allchild(parent));
end

%remove all children that do not have Type property (HG2 adds child
%like that)
if ~isempty(childlist)
    childlist(ishghandle(childlist,'hggroup')) =[];
    childlist(~isprop(childlist,'Type')) =[];
end

if ~isempty(childlist) && filter.serializableOnly ==1
    notin = find(ismember(get(childlist,'Serializable'),{'off'}));
    childlist(notin)=[];
end
 
if ~isempty(childlist) && filter.includeHiddenHandles ~= 1
    notin = find(ismember(get(childlist,'HandleVisibility'),{'off'}));
    childlist(notin)=[];
end
 
if ~isempty(childlist) && filter.sortByType
    menu = find(ismember(get(childlist,'Type'),{'uimenu'}));
    contextmenu = find(ismember(get(childlist,'Type'),{'uicontextmenu'}));
    toolbar = find(ismember(get(childlist,'Type'),{'uitoolbar'}));
    toggletool = find(ismember(get(childlist,'Type'),{'uitoggletool'}));
    pushtool = find(ismember(get(childlist,'Type'),{'uipushtool'}));    
    
    notin=[menu; contextmenu; toolbar; toggletool; pushtool];
    childlistcopy = childlist;
    childlistcopy(notin)=[];
    
    childlist=[childlistcopy;childlist(menu);childlist(contextmenu);childlist(toolbar);childlist(toggletool);childlist(pushtool)];
end

if ~isempty(childlist) && filter.uiobjectOnly ==1
    notin = find(ismember(get(childlist,'Type'),{'uimenu'}));
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uicontextmenu'}))];
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uitoolbar'}))];
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uitoggletool'}))];
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uipushtool'}))];
    childlist(notin)=[];
end
 
if ~isempty(childlist) && filter.uicontainerOnly ==1
    notin = find(ismember(get(childlist,'Type'),{'uicontrol'}));
    notin = [notin; find(ismember(get(childlist,'Type'),{'axes'}))];
    childlist(notin)=[];
end
 
% filter out all uicontrols used as panel title
titles=[];
if ~isempty(childlist)
    % parent itself may be a panel and it may not be in the list.
    % we need to remove its TitleHandle too if it is a panel.
    handlelist = childlist;
    if filter.includeParent == 0
        handlelist(end+1) = parent;
    end
    for i=1:length(handlelist)
        h= handle(handlelist(i));
        if ishghandle(h,'uipanel') || isbuttongroup(h)
            titles(end+1) = i;
        end
    end
end

if ~isempty(childlist)
    children = double(childlist);
end
 
function string = APPLICATION
 
string = 'application';
 
% *************************************************************************
% get the replacement structs when doing a tag replacement
% *************************************************************************
function replacements=getStringReplacementStruct(fromthis, changeto, forwhom)
% This function is used for tag change and saveas.
callbacks = getCallbackProperties(forwhom);
 
% first replace fromthis in comments with changeto
replacementCount = int16(1);
replacements(replacementCount) = struct('source',fromthis,...
    'target', changeto,...
    'policy','loose',...
    'scope','comment',...
    'version', false);
if ischar(forwhom)&& strcmpi(APPLICATION, forwhom)
    if ~isempty(callbacks)
        for i=1:length(callbacks)
        replacementCount = replacementCount +1;
        replacements(replacementCount) = struct('source',strcat(fromthis, '_', callbacks(i)),...
            'target', strcat(changeto, '_', callbacks(i)),...
            'policy','loose',...
            'scope','comment',...
            'version', false);
        end
    end
end
 
% second replace fromthis_FunctionName in code with
% changeto_FunctionName
if ischar(forwhom)&& strcmpi(APPLICATION, forwhom)
    % GUI MATLAB code file top level function
    replacementCount = replacementCount +1;
    replacements(replacementCount) = struct('source',fromthis,...
        'target', changeto,...
        'policy','strict',...
        'scope','function',...
        'version', true);
end
if ~isempty(callbacks)
    for i=1:length(callbacks)
    replacementCount = replacementCount +1;
    replacements(replacementCount) = struct('source',strcat(fromthis, '_', callbacks(i)),...
        'target', strcat(changeto, '_', callbacks(i)),...
        'policy','strict',...
        'scope','function',...
        'version', false);
    end
end
 
% third update code. 
if ischar(forwhom)&& strcmpi(APPLICATION, forwhom) 
    % For saveas, replace fromthis_FunctionName in code with
    % changeto_FunctionName. Maybe we should do this for all 
    if ~isempty(callbacks)
        for i=1:length(callbacks)
        replacementCount = replacementCount +1;
        replacements(replacementCount) = struct('source',strcat(fromthis, '_', callbacks(i)),...
            'target', strcat(changeto, '_', callbacks(i)),...
            'policy','strict',...
            'scope','code',...
            'version', false);
        end
    end
else
    %For tag change ,replace handles.fromthis in code with handles.changeto
    replacementCount = replacementCount +1;
    replacements(replacementCount) = struct('source',['handles.', fromthis],...
        'target', ['handles.', changeto],...
        'policy','strict',...
        'scope','code',...
        'version', false);
end
 
% *************************************************************************
% we should be able add something like uitoolfactory('getinfo', TOOLID)
% to replace these two functions
% *************************************************************************
function toolid = getToolbarToolID(toolinfo)
    toolid = [toolinfo.group, '.',toolinfo.name];
 
% *************************************************************************
%
% *************************************************************************
function toolinfo = getToolbarToolInfo(toolorid)
    toolinfo = struct;
    if ishghandle(toolorid)
        if isPredefinedToolbarTool(toolorid)
            toolinfo = getToolbarToolInfo(getappdata(toolorid,TOOLBARTOOLID));
        end        
    else
        % Get group and name from full ID
        [idgroup,idname] = strtok(toolorid,'.');
        if ~isempty(idname)
            idname = idname(2:end);
        end
 
        % Cycle through each item
        mToolInfo = uitoolfactory('getinfo');
        for n = 1:length(mToolInfo);
            info = mToolInfo(n);
            if strcmp(info.group,idgroup) && strcmp(info.name,idname);
                 toolinfo = info;
                 break;
            end
        end    
    end
 
% *************************************************************************
%
% *************************************************************************
function  initializeToolbarToolDefaultCallback(finaltool, toolid)
    setappdata(finaltool,TOOLBARTOOLID,toolid);
    
    if ~isempty(toolid)
        toolinfo = getToolbarToolInfo(toolid);
        if ~isempty(toolinfo)
            callbacks = guidemfile('getCallbackProperties', finaltool);
            track =[];
            for i=1:length(callbacks)
                % this property is used by this predefined tool
                if isfield(toolinfo, 'properties') && isfield(toolinfo.properties, callbacks{i})
                    defined = strtrim(toolinfo.properties.(callbacks{i}));
                    saved = strtrim(get(finaltool, callbacks{i}));
                    if isequal(defined, saved)
                        set(finaltool, callbacks{i}, DEFAULTCALLBACK);
                        track.(callbacks{i}) = DEFAULTCALLBACK;
                    end
                end
            end
            setappdata(finaltool,'CallbackInUse',track);
        end
    end
 
% *************************************************************************
% prompt the user to the change of default implementation of any
% predefined tool
% *************************************************************************
function changeToolbarToolDefaultCallback(fig, h,name,value)
    % change the property
    isfhandle =false;
    callbacks = guidemfile('getCallbackProperties', h);
    
    if nargin==4
       % from View button or callback edit field
       try
           % is this a valid function handle?
           f= functions(value);
            % GUIDE generates auto-callback
           if ~isempty(f.file) 
               isfhandle =true;
               if isAutoCallback(h, name, DEFAULTCALLBACK) 
                    set(h,name, ''); 
               end
           end
       catch 
           % set specific value
            if ~isempty(find(ismember(callbacks,name)))
                % if it is callback
                %need to set the old callback format on object              
                value = toggelGeneratedCallbackSignature(h, name,value,false);                  
                setAutoGeneratedCallbackString(h,name,value);
            else
                set(h, name, value);
            end           
       end       
    else
       % from inspector, property already set
    end
 
    if isPredefinedToolbarTool(h)
        % determine whether we need to show confirmation dialog and restore
        % default if asked
        toolinfo = getToolbarToolInfo(h);
        properties = fieldnames(toolinfo.properties);
        callbackinuse = getappdata(h,'CallbackInUse');
        for i=1:length(properties)
            found = false;
            if ~isempty(find(ismember(callbacks,properties{i})))
                % callback property
                if isstruct(callbackinuse) && ...
                   isfield(callbackinuse,properties{i}) && ...
                   isequal(callbackinuse.(properties{i}), DEFAULTCALLBACK) && ...
                   ~isAutoCallback(h,properties{i}) && ...
                   ~isAutoCallback(h,properties{i},DEFAULTCALLBACK)
 
                    found = true;
                    % change from the default
                    if guidefunc('okToProceed', fig, 'Callback')
                        if isfhandle
                            value(h,name);
                        end
                    else
                        set(h, properties{i}, DEFAULTCALLBACK); 
                    end
 
                else
                    if isfhandle
                        value(h,name);
                    end
                end
 
                % update callbackinuse
                if isfield(callbackinuse,properties{i})
                    callbackinuse.(properties{i}) = getAutoGeneratedCallbackString(h,properties{i});
                    setappdata(h,'CallbackInUse', callbackinuse);
                end
 
                if found
                    break;
                end    
            end
        end
    else
        if isfhandle
            value(h,name);
        end
    end
 
% *************************************************************************
% whether this callback if used by this predefined tool
% *************************************************************************
function used = isToolbarToolPredefinedCallback(h,name)
    used =false;
    if isPredefinedToolbarTool(h)
        info = getToolbarToolInfo(getappdata(h,TOOLBARTOOLID));
        if isfield(info.properties, name)
            used = true;
        end
    end
 
% *************************************************************************
%
% *************************************************************************
function predefined = isPredefinedToolbarTool(tool)
    predefined = false;
    toolid = getappdata(tool,TOOLBARTOOLID);
    if ~isempty(toolid)
        info = getToolbarToolInfo(toolid);
        if ~isempty(info) && isfield(info, 'properties')
            predefined =true;
        end
    end
    
 
    
% *************************************************************************
%
% *************************************************************************
function str = DEFAULTCALLBACK
    str = '%default';
 
% *************************************************************************
%
% *************************************************************************
function str = TOOLBARTOOLID
    str = 'toolid';
 
function restoreToolbarToolPredefinedCallback(fig)
    if ishghandle(fig)
        children = getToolbarToolInFigure(fig);
        for i=1:length(children)            
            if isPredefinedToolbarTool(children(i))
                toolinfo = getToolbarToolInfo(getappdata(children(i),TOOLBARTOOLID));                
                callbacks = getCallbackProperties(children(i));
    
                for j=1:length(callbacks)
                    % this property is used by this predefined tool
                    if isfield(toolinfo.properties, callbacks{j})
                        if isAutoCallback(children(i), callbacks{j}, DEFAULTCALLBACK)
                            % restore to the predefined callback available
                            % on the specific MATLAB version
                            set(children(i), callbacks{j}, toolinfo.properties.(callbacks{j}));
                        end
                    end
                end
            end
        end        
    end
 
function children = getToolbarToolInFigure(fig)
    children =[];
    if ishghandle(fig)
        show = get(0, 'showhiddenhandles');
        set(0, 'showhiddenhandles', 'on');
 
        toolbars = findobj(allchild(fig), 'flat', 'type', 'uitoolbar', 'serializable', 'on');
        children = [];
        for i=1:length(toolbars)
            children=[children; findobj(allchild(toolbars(i)), 'flat', 'serializable', 'on')];
        end
        children = [flipud(toolbars); flipud(children)];
    end
    set(0, 'showhiddenhandles', show);

% *************************************************************************
% Reset those callbacks generated by GUIDE to AUTOMATIC so that they can be
% regenerated
% *************************************************************************
function resetAutoCallback(list, file, lastTag)

list =handle(list);
for i=1:length(list)
    h= list(i);
    if nargin<3
        tag = get(h,'Tag');
    else
        tag = lastTag{i};
    end
    callbacks = getCallbackProperties(h);
    if ~isempty(callbacks)
        head = [file,'(''', tag];
        for j=1:length(callbacks)
            value = getAutoGeneratedCallbackString(h, callbacks(j));
            if strncmp(value, head, length(head))
                setAutoCallback(h,char(callbacks(j)));
            end
        end
    end
end

% *************************************************************************
% Detect whether the callback has a value that recognizable by GUIDE
% *************************************************************************
function auto=isAutoCallback(h, callback, target)
if nargin <3
    target = AUTOMATIC;
end

auto =false;
value = get(handle(h),callback);
if ischar(value)
    auto = isequal(strtrim(value),target);
end


% *************************************************************************
% Return the callback string that is generated by GUIDE and will be 
% evaluated when the callback is triggered
% *************************************************************************
function value = getAutoGeneratedCallbackString(h,callback)

value = get(handle(h), callback);

if iscell(value)
   value =value{1};
end     

if ~ischar(value)
   try
       fstr = func2str(value);
       value = strrep(strtrim(fstr), '@(hObject,eventdata)','');
       if isbuttongroup(h) && (isequal(callback,'SelectionChangeFcn') || isequal(callback,'SelectionChangedFcn'))
            % due to limitation of uibuttongroup, we provide the selection
            % object as hObject in old GUIs. This is needed for
            % compatibility
           value = strrep(value, 'get(hObject,''SelectedObject'')','hObject');
       end
       value = toggelGeneratedCallbackSignature(h,callback,value,false);
   catch
       value ='';
   end
end
    
% *************************************************************************
% set the auto-generated callback on the given object. This is where a
% string version of auto-generated callback is converted to a function
% handle
% *************************************************************************
function value = setAutoGeneratedCallbackString(h,callback, value, setNow)

if nargin <4
    setNow = true;
end

h=handle(h);
if isAutoGeneratedCallbackString(h,callback, value)
    value = toggelGeneratedCallbackSignature(h,callback,value, true);
    if isbuttongroup(h) && (isequal(callback,'SelectionChangeFcn') || isequal(callback,'SelectionChangedFcn'))
        % due to limitation of uibuttongroup, we provide the selection
        % object as hObject in old GUIs. This is needed for
        % compatibility
        value = strrep(value, 'hObject', 'get(hObject,''SelectedObject'')');
    end
    value = str2func(['@(hObject,eventdata)' value]);              
end

if setNow
    set(h,callback,value);
end

% *************************************************************************
% 
% *************************************************************************
function value = toggelGeneratedCallbackSignature(obj, callback, value, old2new)

if ischar(value)
    signature = getAutoGeneratedCallbackSignature(obj,callback);
    if old2new
        index = strfind(strtrim(value),signature);
        if ~isempty(index)
            value = strrep(strtrim(value),signature, ',hObject,eventdata,guidata(hObject)');
        end
    else
        index = strfind(strtrim(value),',hObject,eventdata,guidata(hObject)');
        if ~isempty(index)
            value = strrep(strtrim(value),',hObject,eventdata,guidata(hObject)',signature);
        end
    end
end

% *************************************************************************
% return true if the given string is GUIDE auto generated callback 
% *************************************************************************
function auto = isAutoGeneratedCallbackString(obj, callback, value)
if nargin<3,  value = getAutoGeneratedCallbackString(handle(obj), callback); end

auto =  ~isempty(value) && ischar(value) && ...
        ~isempty(strfind(strtrim(value),getAutoGeneratedCallbackSignature(obj,callback)));

    
% *************************************************************************
% return true if the callback is something GUIDE generated
% *************************************************************************
function generated = isAutoGeneratedCallback(obj,callback, filename)
generated = isempty(get(handle(obj),callback)) || ...
            isAutoCallback(obj,callback) || ...
            isAutoCallback(obj,callback, DEFAULTCALLBACK) || ...
            (isequal(callback, 'CloseRequestFcn') && isequal('closereq', get(handle(obj), callback))) || ...
            isequal(getAutoGeneratedCallbackString(obj,callback), formAutoGeneratedCallbackString(obj, callback,filename))||...
            isAutoGeneratedCallbackHG1(obj,callback, filename);

% *************************************************************************
% return true if the callback is something GUIDE generated in HG1 for
% specific properties that have changed. This is here to assist backwards
% compatibility with HG1 GUIS opened in HG2
% *************************************************************************
function generated = isAutoGeneratedCallbackHG1(obj,callback, filename)
generated = isequal(getAutoGeneratedCallbackString(obj,callback), formAutoGeneratedCallbackStringHG1(obj, callback,filename));
        
        
        
% *************************************************************************
% return true if the callback is a button group managed callback
% *************************************************************************
function managed = isManagedButtonGroupCallback(obj,callback, filename)
value = get(handle(obj),callback);
managed =   isbuttongroup(get(obj,'parent')) && ...
            ~isempty(value) && ...
            iscell(value) && ...
            isa(value{1}, 'function_handle') && ...
            isequal(func2str(value{1}), 'manageButtons');
        
        
% *************************************************************************
% return the GUIDE auto-generated callback string
% *************************************************************************
function result = formAutoGeneratedCallbackString(obj, callback, filename)
result ='';

[p,funcname,e] = fileparts(filename);
thisTag = get(handle(obj),'tag');
if isvarname(thisTag)
    % construct a callback property value for the object
    subfcn = [thisTag '_' callback];
    
    result = [funcname, '(''', subfcn, '''', getAutoGeneratedCallbackSignature(obj,callback), ')'];
end

% *************************************************************************
% return the GUIDE auto-generated callback string for backward
% compatibility
% *************************************************************************
function result = formAutoGeneratedCallbackStringHG1(obj, callback, filename)
result = formAutoGeneratedCallbackString(obj, callback, filename);


if isequal(callback,'SizeChangedFcn')
    % for ResizeFcn
    result = strrep(result, 'SizeChangedFcn','ResizeFcn');
    
elseif isequal(callback,'SelectionChangedFcn')

    % for SelectionChangeFcn 
    result = strrep(result, 'SelectionChangedFcn','SelectionChangeFcn');
end


% *************************************************************************
% 
% *************************************************************************
function signature = getAutoGeneratedCallbackSignature(obj,callback)
objType = get(handle(obj),'type');
signature =',gcbo,[],guidata(gcbo)';
if strcmp(objType,'figure') && strcmp(callback,'CloseRequestFcn')
    signature = ',gcbf,[],guidata(gcbf)';
end

function convertCallbackToFunctionHandle(filename, fig)
% Replace GUIDE generated callbacks with function handle for
% retrieving the available event data of HG callbacks, if any
handles = guihandles(fig);
names = fieldnames(handles);
for k=1:length(names)
    % it is possible several objects use the same Tag
    objs= handles.(char(names(k)));
    for i=1:length(objs)
        obj = objs(i);
        callbacks = guidemfile('getCallbackProperties',obj);
        for j=1:length(callbacks)
            callback = char(callbacks{j});
            value = get(obj,callback);
            if ~isempty(value) && ischar(value)
                value = strtrim(value);
                % find signature of GUIDE generated callback
                if strfind(value,filename)==1
                     setAutoGeneratedCallbackString(obj,callback, value);
                end
            end
        end
    end
end

function tf = isbuttongroup(obj)
tf = isa(handle(obj),'matlab.ui.container.ButtonGroup');

% January 7th, 2009 - file is changed from binary to ascii
