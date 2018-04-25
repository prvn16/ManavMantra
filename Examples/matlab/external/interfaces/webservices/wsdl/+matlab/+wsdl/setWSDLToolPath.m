function res = setWSDLToolPath(varargin)
%matlab.wsdl.setWSDLToolPath  Specify pathnames of createWSDLClient support tools
%   PATHS = matlab.wsdl.setWSDLToolPath(TOOL,PATH,...) specifies the PATH on your
%   system where you have installed the specified TOOL needed by
%   matlab.wsdl.createWSDLClient.  One or more TOOL/PATH pairs may be specified.
%   Values specified here are saved across sessions in your user preferences, so you
%   only need to specify these once.
%
%   Values of TOOL are:
%
%      JDK    the Java Development Kit.  You should download the JDK from:
%                 http://www.oracle.com/technetwork/java/javase/downloads/
%             and choose the latest release of JDK 7.  
%
%      CXF    the Apache CXF framework.  You should download CXF from:
%                 http://cxf.apache.org/download
%             and choose the latest release of 2.7.
%
%   Versions of the JDK or CXF other than those specified above have not been tested
%   to work with createWSDLClient.  
%
%   The return value PATHS, if specified, contains a struct with two named fields
%   containing the paths to the JDK and CXF.  When invoked without arguments, this
%   structure is always returned.
%
%   See also: matlab.wsdl.createWSDLClient

% Copyright 2014-2015 The MathWorks, Inc.

%  Undocumented behavior:
%   If a PATH is '-validate', throws an error if the path previously set for the
%   specified TOOL does not contain a valid version of the tool, or if the path was
%   never set.  Checking this for CXF automatically checks this for JDK as well.

%   If the JAVA_HOME or CXF_HOME environment variable is set, its value will be used
%   in place of an unspecified JDK or CXF, respectively.

    setting = settings;
    if nargin > 0
        s = setting.matlab;
        if ~hasGroup(s, 'internal')
            s.addGroup('internal')
        end
        s = s.internal;
        % Because validating CXF requires a valid JDK, reorder the arguments in args
        % so that the JDK is always handled first
        args(2) = struct('tool',[],'path',[]);
        for argno = 1 : 2 : nargin
            tool = validatestring(varargin{argno}, {'JDK','CXF'}, 'setWSDLToolPath', ...
                'TOOL', argno);
            if argno == nargin
                error(message('MATLAB:webservices:PathMissingFor', tool));
            end
            if strcmp(tool,'JDK')
                argIndex = 1;
            elseif strcmp(tool,'CXF')
                argIndex = 2;
            end
            path = varargin{argno+1};
            validateattributes(path(~isspace(path)), {'char'}, {'nonempty','row'}, 'webservices', tool);
            path = strtrim(path);
            args(argIndex).tool = tool;
            if ~strcmp(path,'-validate')
                % Make path absolute
                filePath = java.io.File(path);
                if ~filePath.isAbsolute
                    path = fullfile(pwd,path);
                end
            end
            args(argIndex).path = path;
        end
            
        % args(1) has JDK info; args(2) has CXF info
        for argno = 1 : 2
            tool = args(argno).tool;
            if ~isempty(tool)
                path = args(argno).path;
                key = [tool 'Directory']; % key name is JDKDirectory, CXFDirectory
                warned = false;
                validate = strcmp(path,'-validate');
                if validate
                    if ~s.hasSetting(key)
                        if strcmp(tool,'JDK') 
                            homeEnv = 'JAVA_HOME';
                        else
                            homeEnv = 'CXF_HOME';
                        end
                        path = getenv(homeEnv);
                        if isempty(path)
                            error(message('MATLAB:webservices:ToolUnspecified',tool));
                        end
                    else 
                        path = setting.matlab.internal.(key).ActiveValue;%settings.matlab.internal.get(key);
                        if ~exist(path,'dir')
                            error(message('MATLAB:webservices:ToolNotFound',tool,path));
                        end
                    end
                else
                    if ~exist(path,'dir')
                        % If folder not found, just warn.  Allows setting to be made
                        % before folder is actually created.
                        warning(message('MATLAB:webservices:FolderNotFound', path));
                        warned = true;
                    end
                    if ~s.hasSetting(key)
                        s.addSetting(key,'hidden',true);
                    end
                end
                % If we haven't already warned about folder not found, validate that
                % the path exists and has the correct version.
                if ~warned
                    switch tool
                        case 'JDK'
                            checkVersion(path, 'java', 'JDK', '-version', ...
                                    '^.*ava version "([^"]+)"', '1.7')
                        case 'CXF'
                            % We can't check for a valid CXF version without setting
                            % JAVA_HOME to a valid JDK version, because the 'wsdl2java
                            % -v' command requires JAVA_HOME to be set, so check JDK
                            % first by recursively calling ourselves.  If there is
                            % something wrong with the JDK don't bother checking the
                            % version of CXF unless -validate explicitly specified.
                            % If -validate not specified, we don't want to warn/error 
                            % on setting the CXF due to a bad JDK.
                            e = [];
                            try 
                                % save the old warning state as well as the warning
                                % itself becasue the JDK check below may change the
                                % warning
                                oldwarn = warning('off','MATLAB:webservices:CouldNotDetermineToolVersion');
                                warnStateCleanup = onCleanup(@() warning(oldwarn));
                                [oldlastmsg, oldlastid] = lastwarn;
                                warnMsgCleanup = onCleanup(@() lastwarn(oldlastmsg,oldlastid));
                                lastwarn('');
                                paths = matlab.wsdl.setWSDLToolPath('JDK','-validate'); 
                            catch e
                                % On JDK version or not found error, throw only if
                                % -validate specified.  Otherwise be silent. The user
                                % should already have found out about the JDK error when
                                % it was set, and anyway he'll find out when
                                % createWSDLClient is called.
                                if validate
                                    rethrow(e);
                                end
                            end
                            if isempty(e)
                                % JDK good or we couldn't determine its version (in which
                                % case lastwarn is set)
                                [jdkWarnMsg,jdkWarnId] = lastwarn; % save JDK test warning
                                % If the test below is false, warnMsgCleanup will restore
                                % lastwarn to what it was before, instead of leaving the
                                % JDK warning set, as we don't want to issue any JDK
                                % warnings when setting CXF, unless asked to validate.
                                if isempty(jdkWarnId) || validate
                                    % If no JDK warning or we're asked to validate, then
                                    % validate the CXF version.  Must set JAVA_HOME to do
                                    % this.
                                    oldJavaHome = getenv('JAVA_HOME');
                                    if isempty(oldJavaHome)
                                        oldJavaHome = '';
                                    end
                                    javaHomeCleanup = onCleanup(@() setenv('JAVA_HOME', oldJavaHome));
                                    setenv('JAVA_HOME',paths.JDK);
                                    lastwarn(''); % clear so we can get checkVersion warning
                                    % looks for xxx in: 'Apache CXF xxx'; this may warn
                                    % but warnings still suppressed
                                    checkVersion(path, 'wsdl2java', 'CXF', '-v', ...
                                                 '^.*Apache CXF[^\d]*([\w.]+)', '2.7');
                                    [cxfWarnMsg,cxfWarnId] = lastwarn;
                                    clear warnStateCleanup % restore previous warning state
                                    % Restore lastwarn and cancel its onCleanup handler
                                    clear warnMsgCleanup
                                    clear javaHomeCleanup 
                                    if isempty(cxfWarnId) 
                                        % if CXF checks out and didn't warn, but JDK
                                        % warned and validate specified, issue JDK
                                        % warning
                                        if ~isempty(jdkWarnId) && validate
                                            warning(jdkWarnId,'%s',jdkWarnMsg);
                                        end
                                    else
                                        % CXF warned, so issue that warning
                                        warning(cxfWarnId,'%s',cxfWarnMsg);
                                    end
                                end
                            end
                    end
                end
                % Come here only after we determine it's good or we decided not to
                % check
                if ~validate
                    s.(key).PersonalValue = path; 
                end
            end
        end 
    end
    if nargin == 0 || nargout > 0
        try
            res.JDK = setting.matlab.internal.JDKDirectory.ActiveValue;
        catch 
            res.JDK = getenv('JAVA_HOME');
        end
        try
            res.CXF = setting.matlab.internal.CXFDirectory.ActiveValue;
        catch 
            res.CXF = getenv('CXF_HOME');
        end
    end
end

function checkVersion(path,file,tool,versionArg,matchExp,versionNeeded)
% Throw an error if the version number of the tool at path is not right.  
% If the tool found but the version can't be determined, just warn.

%
% path          directory containing tool (from setting)
% file          name of the executable command, sans extension ('wsdl2java' or 'java')
% tool          'JDK' or 'CXF'
% versionArg    the parameter to the command at path that prints the version
% matchExp      regexp whose first token match is the version number in the output
% versionNeeded beginning characters of the required version number
% warned        don't issue warning if set

    fullPath = fullfile(path, 'bin', file);
    if (ispc && ~exist([fullPath '.bat'],'file') && ~exist([fullPath '.exe'],'file')) || ...
        ~ispc && ~exist(fullPath,'file') 
        error(message('MATLAB:webservices:CouldNotFindTool',path,tool));
    end
    [status,msg] = system(['"' fullPath '" ' versionArg]);
    if status ~= 0
        error(message('MATLAB:webservices:CouldNotExecuteTool',fullPath,msg));
    end
    version = regexp(msg, matchExp, 'tokens');
    if isempty(version) 
        warning(message('MATLAB:webservices:CouldNotDetermineToolVersion',tool,path,msg));
    else
        % Check that matched token begins with desired version number
        version = version{1}{1};
        match = strfind(version, versionNeeded);
        if isempty(match) || match ~= 1
            error(message('MATLAB:webservices:WrongToolVersion', ...
                          tool, path, version, versionNeeded));
        end
    end
end
