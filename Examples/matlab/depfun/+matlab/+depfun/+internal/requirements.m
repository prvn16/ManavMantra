function [parts, resources, exclusions] = ...
    requirements(items, varargin)
% REQUIREMENTS Analyze items and determine what they require to run.
%
%   [ parts, resources, exclusions ] = 
%               requirements(items [,target] [,'-p', path_limit], 
%                            ['-i', include_path])
%
% ITEMS: Cell array of files and/or directories to analyze for dependencies. 
%        Specify the file or directory names as relative or absolute path 
%        strings findable with WHICH or EXIST. 
%        As a special case, a single item may be specified as a string 
%        intead of a cell array.
%
% TARGET: The string name of a valid target: MCR, MATLAB, PCTWorker, etc.
%
% PATH_LIMIT: A list of directories from the MATLAB path; limits the 
%             search for the PARTS required by ITEMS to these directories 
%             and the directories in toolbox/matlab. The PATH_LIMIT
%             directoires must already be on the MATLAB path. They are
%             searched in the order they appear on the MATLAB path rather
%             than the order in which they appear in the PATH_LIMIT list. 
%             Specify directories as full paths or non-ambiguious relative 
%             paths. For example, use 'images' to refer to the Image 
%             Processing Toolbox because matlab/toolbox/images
%             is the root directory for that toolbox. If a sub-directory of 
%             a PATH_LIMIT directory is on the MATLAB path, it is added to 
%             the search path.
%
% INCLUDE_PATH: A list of directories added to the beginning or end of the
%               path. +i adds them to the head of the path, -i to the end.
%               Like PATH_LIMIT, the directory argument must be either a
%               string (a single directory) or a cell array of strings.
%
% -p and -I may appear multiple times in the argument list, in any order,
% but must always appear after the ITEMS argument, and must be followed by
% a string or cell array of strings.
%
% PARTS: A cell array of the "parts" (items, mostly) required to execute
%        the functions in the input ITEMS.
%
% RESOURCES: A cell array of the resources (resoures contain parts)
%            required to execute the functions in the input ITEMS.
%
% EXCLUSIONS: A cell array of parts that ITEMS requires but the TARGET 
%             forbids. These parts either cannot be shipped to any target
%             or are expected to be present in the specified TARGET
%             environment.

% Valid, if boring, values for all outputs.
parts = {};
resources = {};
exclusions = {};

% Special case error for zero inputs
if nargin == 0
    error(message('MATLAB:depfun:req:NoFilesToAnalyze'))
end

% Determine target, which we need to know in order to determine the number
% of possible inputs.
if nargin == 1
    target = 'None';
else
    target = varargin{1};
end

% target must be a string
if ~ischar(target)
    error(message('MATLAB:depfun:req:InvalidInputType', 2, class(target), ...
        'string'))
end

% Convert target input string to Target object and validate.
tgt = matlab.depfun.internal.Target.parse(target);
if (tgt == matlab.depfun.internal.Target.Unknown)
    error(message('MATLAB:depfun:req:BadTarget', target))
end

% Use the REQUIREMENTS database by default, but allow an environment variable
% to force slower and less accurate dynamic analysis. To skip database
% lookup, set the environment variable REQUIREMENTS_DATABASE to 0.
%
% UN*X: setenv REQUIREMENTS_DATABASE 0
% Windows: set REQUIREMENTS_DATABASE=0
%
% Leaving the variable unset or setting it to any value other than zero
% (including empty or NULL) causes REQUIREMENTS to use the database. I
% repeat, that means 'setenv REQUIREMENTS_DATABASE' will make REQUIREMENTS
% use the database. You must set this variable to zero to skip the database
% lookup.
%
% For R13b, the database only supports the MCR target. 
%
useDatabase = true;
reqDB = getenv('REQUIREMENTS_DATABASE');
if (~isempty(reqDB) && reqDB == '0') || ...
  tgt ~= matlab.depfun.internal.Target.MCR
    useDatabase = false;
end

% Possible input combinations:
%   1.  items
%   2.  items, target
%   3.  items, target, '-p', path_limit
%   4.  items, target, '-I', include_path
%   5.  items, target, '-c', components
%   6.  items, target, '-p', path_limit, '-I', include_path
%   7.  items, target, '-p', path_limit, '-I', include_path, '-c', components
%
% Not an exhaustive list. -p, -I and -c are optional and can appear in any
% order. Items must appear first, always. If target is specified, it must
% be second.
%
% Extract the items and target, and pass the rest, unprocessed, to the 
% SearchPath constructor.

% Validate input count -- at least one, no more than eight.
maxArg = 8;
narginchk(1,maxArg);

% ITEMS should be a cell array of strings. As a special case, allow a
% single file name string (wrap it in a cell array).
if ~iscell(items)
    if ischar(items) 
        items = { items };
    end
end

% Create a SearchPath object to scope the MATLAB path to the appropriate
% directories. Only necessary when -p or -I appears in the argument list,
% which happens whenever there are more than two arguments (in a
% well-formed call to requirements -- but we let the error detection code
% in SearchPath take care of checking the putative path manipulation
% arguments).
% If nargin <= 2 (nothing is specified), it should use the current path.
if tgt == matlab.depfun.internal.Target.MCR ...
       || tgt == matlab.depfun.internal.Target.Deploytool
       % G1367573 - Unify the search path used by MCC and Deploytool
    if nargin > 2
        s = matlab.depfun.internal.SearchPath('MCR', varargin{2:end});
    else
        s = matlab.depfun.internal.SearchPath('MCR');
    end
    
    % Create an onCleanup object to ensure the MATLAB path is restored even
    % if an error occurs while computing the Completion. The onCleanup
    % function runs on normal function return also, so path restoration
    % occurs in either case.
    p = path;
    restorePath = onCleanup(@()path(p));
    
    % Suppress warnings related to path

    if (feature('IsPM2.0'))
        orgState = warning;
        warning('off', 'MATLAB:mpath:packageDirectoriesNotAllowedOnPath');
        warning('off', 'MATLAB:mpath:privateDirectoriesNotAllowedOnPath');
        warning('off', 'MATLAB:mpath:methodDirectoriesNotAllowedOnPath');
    else
        orgState = warning('off', 'MATLAB:dispatcher:pathWarning');
    end
    restoreWarn = onCleanup(@()warning(orgState));
    
    % Set MATLAB's path to the SearchPath's PathString 
    % This may cause MATLAB:dispatcher:nameConflict warnings. It is the
    % caller's responsiblity to disable these, if necessary.
    path(s.PathString);
end

if getenv('REQUIREMENTS_VERBOSE')
    disp('Items: ');
    fprintf(1,'%s\n', sprintf(' %s', items{:}));
    if nargin > 1
        disp('Arguments:');
        for n = 2:nargin-1
            if ischar(varargin{n})
                fprintf(1,'  %s\n', varargin{n});
            elseif iscell(varargin{n})
                aN = varargin{n};
                for k = 1:numel(aN)
                    fprintf(1,'  ');
                    disp(aN{k});
                end
            end
        end
    end
    
    path
end

% Suppress external API related warnings thrown by the dispatcher 
externalAPIwarnID = { 'MATLAB:Python:PythonUnavailable' ...
                      'MATLAB:NET:InvalidFrameworkVersion' };
externalAPIwarnOrgState = cellfun(@(w)warning('off', w), externalAPIwarnID);
restoreexternalAPIwarn = ...
    onCleanup(@()arrayfun(@(s)warning(s), externalAPIwarnOrgState));

% matlab.depfun.internal.ClassSet has three persistent variables holding
% function handles which in turn hold the Completion object in memory 
% even if REQUIREMENTS is finished. That prevents the destructor of 
% Completion being called. As a result, the DependencyDepot objects 
% stored in Completion and Schema cannot be destructed, which leaves 
% the database connected.
% Explicitly clearing persistent variables used in file ClassSet.m below
% is a patch. The refactoring will be done by g1309462.
clearClassSet = onCleanup(@()clear('ClassSet'));

if useDatabase
    % use the database
    c = matlab.depfun.internal.Completion(items, tgt, 'useDatabase');
else
    % do not use the database
    c = matlab.depfun.internal.Completion(items, tgt);
end

if nargout == 1
    parts = c.parts();
elseif nargout >= 2
    [parts, resources.products, resources.platforms] = c.requirements(); 
end
if nargout > 2
    exclusions = c.excludedFiles();
end