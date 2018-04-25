function out = open(name)
%OPEN	 Open file in appropriate application.
%   OPEN NAME opens the file or variable specified by NAME in the 
%   appropriate application. For example, variables open in the Variables 
%   Editor, MATLAB code files open in the MATLAB Editor, and Simulink 
%   models open in Simulink. 
%
%   If NAME is a MAT-file, MATLAB returns the variables in NAME to a 
%   structure.
%   
%   If NAME does not include an extension, MATLAB searches for variables 
%   and files according to the function precedence order.
%
%   A = OPEN(NAME) returns a structure if NAME is a MAT-file or a figure
%   handle if NAME if a figure. Otherwise, OPEN returns an empty array.
%
%   Examples:
%
%     open f2                   First looks for a variable named f2, then 
%                               looks on the path for a file named f2.slx, 
%                               f2.mdl, f2.mlapp, f2.mlx, or f2.m.  Error 
%                               if can't find any of these.
%
%     open f2.mat               Error if f2.mat is not on path.
%
%     open d:\temp\data.mat     Error if data.mat is not in d:\temp.
%
%
%   OPEN is user-extensible.  To open a file with the extension ".XXX",
%   OPEN calls the helper function OPENXXX, that is, a function
%   named 'OPEN', with the file extension appended.
%
%   For example,
%      open('foo.log')       calls openlog('foo.log')
%      open foo.log          calls openlog('foo.log')
%
%   You can create your own OPENXXX functions to set up handlers 
%   for new file types.  OPEN will call whatever OPENXXX function 
%   it finds on the path.
%
%   See also EDIT, LOAD, OPENFIG, OPENVAR, WHICH, WINOPEN.
%

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,1);
name = convertStringsToChars(name);

[m,n] = size(name);

if ~ischar(name) || ~(m == 1 || (m == 0 && n ==0))
    error(message('MATLAB:open:invalidInput'));
end

% In WHICH, files take precedence over variables, but we want
% variables to take precedence in OPEN.  This forces an EXIST
% check on the variable name before we do anything else.
exist_var = evalin('caller', ...
                        ['exist(''' strrep(name, '''','''''') ''', ''var'')']);

% If we found a variable that matches, use that.  Open the variable, and
% get out.
if exist_var == 1
    evalin('caller', ['openvar(''' name ''', ' name ');']);
    return;
end

% We did not find a variable match.  Use files.
fullpath = whichWrapper(name);

% Check to see if it is a help file
if ~isFile(fullpath) && ~hasExtension(name)
     fullpath = whichWrapper([name '.mlx']);
     if(isempty(fullpath))
        fullpath = whichWrapper([name '.m']);
     end
end

% Find fully qualified paths or files without extensions.
if isempty(fullpath) && isFile(name)
    fullpath = name;
end

if isempty(fullpath)
    % which did not find it and exist didn't find it either
    error(message('MATLAB:open:fileNotFound', name))
end


%check if user specified extension
%If it is not on the path, then exist only returns a name if the match is
%exact.  If it is on the path, then exist may return a match which has an
%extension, when none was specified.  In that case, call which with a '.'
%appended, so that we can see if the exact match is available.
[~, ~, tmpExt] = fileparts(name);
if isempty(tmpExt)
    %Get all files/dirs which have just the name
    tmpPath = whichWrapper([name '.'], '-all');
    if ~isempty(tmpPath)
        for i = 1:length(tmpPath)
            %If we find a file, set the path to it, and stop.  This means
            %we find files in the same order as which -all returns them.
            if isFile(tmpPath{i})
                fullpath = tmpPath{i};
                break;
            end
        end
    end;
end;

if ~isFile(fullpath)
    error(message('MATLAB:open:fileNotFound', fullpath));
else
    % let finfo decide the filetype
    [~, openAction] = finfo(fullpath);
    if isempty(openAction)
        openAction = @defaultopen;
     % edit.m does not opens p files
     % check here if the .p extension was supplied by the user
     % If the user did not specify .p then which command appended the .p and 
     % we need to strip it off before calling openp.
     elseif strcmp(openAction, 'openp')
        [~,~,ext] = fileparts(name);
        % g560308/g479211 is there wasn't an extension specified and a .p file
        % was found, then search for an associated .m file.
        if ~strcmp(ext, '.p')
           fullpath = fullpath(1:end-2);
           % if the .m file associated with the .p file does not exist, error out.
           if ~isFile([fullpath, '.m'])
              error(message('MATLAB:open:openFailure', [fullpath,'.p']));
           end

        end
        
    end
    
    try
        % if opening a mat file be sure to fetch output args
        if isequal(openAction, 'openmat') || nargout
            out = feval(openAction,fullpath);
        else
            feval(openAction,fullpath);
        end
    catch exception
        % we only want the message from the exception, not the stack trace
        error('MATLAB:open:openFailure', '%s', exception.message);
    end
end 

%------------------------------------------
% Helper method that determines if filename specified has an extension.
% Returns 1 if filename does have an extension, 0 otherwise
function result = hasExtension(s)

[~,~,ext] = fileparts(s);
result = ~isempty(ext);

%------------------------------------------
% WHICH may error out with some input string like '.', '.m', etc,
% Simply ignore the errors and return an empty cell.
function result = whichWrapper(name, varargin)
try
    result = which(name, varargin{:});
    if ischar(result) && ~isempty(result)
        % redo which on the result, to filter non-paths
        result = which(result);
        [~, whichName] = fileparts(result);
        if isempty(regexpi(name, ['\<', whichName, '\>'], 'once'))
            result = '';
        end
    end
catch exception  %#ok<NASGU>
    result = '';
end

%------------------------------------------
function out = defaultopen(name)
% Default action to open unrecognized file types.

% To import files by default, uncomment the following line.
%out = uiimport(name);

% To edit files by default, uncomment the following line.
out = []; edit(name);

%------------------------------------------
function result = isFile(path)
    existType = exist(path,'file');
    result = existType ~= 0 && existType ~= 7;