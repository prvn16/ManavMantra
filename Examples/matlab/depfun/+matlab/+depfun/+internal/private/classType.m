function type = classType(qName, whichResult)
% classType Given a qualified name and the result of calling WHICH on 
% that name determine if the name represents a class, and if so, what kind
% of class (UDD, MCOS, OOPS).
%
% The reported class type (for the same qName) may differ depending on the
% input whichResult. If qName identifies a UDD class with a built-in
% constructor, a whichResult containing @s will result in a class type of
% UDDClass, while a whichResult containing the string 'built-in' will
% result in a class type of BuiltinClass. 
%
    import matlab.depfun.internal.MatlabType;
    import matlab.depfun.internal.requirementsConstants;
    
    fs = filesep; % Surprisingly expensive, when called thousands of times
    
    % Have we seen this class already?
    type = matlab.depfun.internal.MatlabSymbol.classType(qName);
    if type ~= MatlabType.NotYetKnown
        return;
    end
    
    % Is qName a built-in class? Check the class file text.
    % It's built-in if both of these conditions are true:
    %   * The word built-in appears in the which result 
    %   * The word 'method' or the @-sign appears in the which result OR
    %     EXIST thinks it is a class.
    if ~isempty(strfind(whichResult, requirementsConstants.BuiltInStr)) && ...
       ((~isempty(strfind(whichResult, requirementsConstants.MethodStr)) || ...
        ~isempty(strfind(whichResult,[fs '@']))) || existClass(qName))

        % UDD classes may look like built-ins.
        type = classUsingBuiltinCTOR(whichResult);
        if type == MatlabType.NotYetKnown
            if strncmp(qName, 'NET.', 4) ...
                 || strncmp(qName, 'System.', 7)
                type = MatlabType.DotNetAPI;
            elseif strncmp(qName, 'py.', 3)                    
                type = MatlabType.PythonAPI;
            else
                type = MatlabType.BuiltinClass;
            end
        end
        return;
    % If the class file contains nothing but HELP comments, it must be a 
    % built-in class constructor.
    else
        cached_w = matlab.depfun.internal.cacheWhich(qName);
        if ~strcmp(cached_w, whichResult) ...
            && ~isempty(strfind(cached_w, requirementsConstants.BuiltInStr)) ...
            && isOnlyComment(whichResult)
            type = MatlabType.BuiltinClass;
            return;
        end
    end
    
    % Single dot-qualified name: mathematical.thing. Use existence tests to
    % determine name's type.
    %
    %       If this exists                    The name is
    % -------------------------------------------------------------
    %   @mathematical/@thing/thing.m     UDD class
    %   @mathematical/thing.m            UDD package-scoped function
    %   +mathematical/@thing/thing.m     MCOS class
    %   +mathematical/thing.m            MCOS package-scoped fcn or class

    dotIdx = strfind(qName, '.');

    if ~isempty(dotIdx)
        nameParts = strsplit(qName,'.');

        
        mcosTest = ['+' nameParts{1} fs '@' nameParts{2} ...
                               fs nameParts{2}];
        uddTest = ['@' nameParts{1} fs '@' nameParts{2} ...
                           fs nameParts{2}];
        
        % also need to escape the '+'
        mcosTestRegexp = [regexptranslate('escape', mcosTest) ...
                          requirementsConstants.executableMatlabFileExtPat];
        uddTestRegexp = [regexptranslate('escape', uddTest) ...
                          requirementsConstants.executableMatlabFileExtPat];
                       
        if length(dotIdx) == 1
            [fileExists,fileLocation]=matlabFileExists(...
                    ['+' nameParts{1} fs nameParts{2}]);
                
            % ssegench
            % g1036086
            
            % first take advantage of the whichresult that has been passed
            % in. This might be a little hacky first pass
            % checking for executable file types is modeled after 
            % matlabFileExists code
            if(~isempty(regexp(whichResult, mcosTestRegexp, 'once')))
                type = MatlabType.MCOSClass;
                        
            elseif(~isempty(regexp(whichResult, uddTestRegexp, 'once')))
                type = MatlabType.UDDClass;
            
                
            % re-orderd the if statements to look for MCOS class first
            % since if both MCOS and UDD exist we want the MCOS class    
            % +mathematical/@thing/thing.m => MCOS class
            elseif matlabFileExists(mcosTest)
                type = MatlabType.MCOSClass;
            % @mathematical/@thing/thing.m => UDD class. Can't use
            % exist, because it always reports non-existence.
            elseif matlabFileExists(uddTest)
                type = MatlabType.UDDClass;
              
            % Class file doesn't exist, but has two @s. Should be UDD.
            % Check for builtin UDD -- call WHICH on class name. (Sometimes
            % the input whichResult is not the result of calling WHICH on
            % the qualified name.) This condition catches built-in UDD
            % classes specified by a help-only method file.
            elseif numel(strfind(whichResult,[fs '@'])) == 2
                clsWhich = matlab.depfun.internal.cacheWhich(qName);
                if ~isempty(strfind(clsWhich, requirementsConstants.BuiltInStr)) && ...
                    (~isempty(strfind(whichResult, requirementsConstants.MethodStr)) || ...
                    existClass(qName))
                        type = MatlabType.UDDClass;
                % Check for a schema file. UDD for sure, then.
                elseif matlabFileExists(['@' nameParts{1} fs '@' ...
                                         nameParts{2} fs 'schema'])
                    type = MatlabType.UDDClass;
                end              

            % +mathematical/thing.m => MCOS class if file has classdef
            elseif fileExists
                if isClassdef(fileLocation)
                    type = MatlabType.MCOSClass;
                else
                    type = MatlabType.OOPSClass;
                end
            end
        else
            % Multiple dots.
            %   +my/+amazing/+mathematical/@thing/thing.m => MCOS class
            %   +my/+amazing/+mathematical/thing.m => MCOS fcn or class

            if length(nameParts) > 2
                delim = [fs '+'];
                if fs == '\'
                    delim = ['\' delim];  % Escape \ for strjoin
                end
                pkgPrefix = ['+' strjoin(nameParts(1:end-1),delim)];
            end
            
            if matlabFileExists(...
                    [pkgPrefix fs '@' nameParts{end} ...
                           fs nameParts{end}])
                type = MatlabType.MCOSClass;
            else
                file = [pkgPrefix fs nameParts{end}];
                if matlabFileExists(file) 
                    if isClassdef(file)
                        type = MatlabType.MCOSClass;
                    else
                        type = MatlabType.OOPSClass;
                    end
                end
            end
        end
    else
        % No dots. An undecorated name.
        %
        % If the parent of @thing exists on the path:
        %   if thing.m is a classdef file, qName is an MCOS class.
        %   otherwise, qName is an OOPS class.
        %
        % If thing.m exists on the path and it contains CLASSDEF, qName is
        % an MCOS class.
        %
        % But! UDD package functions may have the same name as the package
        % that contains them: @collatz/collatz.m, for example, might be a 
        % UDD package function. Don't identify these functions as OOPS class
        % constructors.
        
        if ~isempty(whichResult) && matlabFileExists(whichResult) && ...
                isClassdef(whichResult)
            classDir = fileparts(whichResult);
            if isDirOnPath(classDir)
                type = MatlabType.MCOSClass;
            else
                sepIdx = strfind(classDir,fs);
                if ~isempty(sepIdx)
                    classDir = classDir(1:sepIdx(end)-1);
                    if isDirOnPath(classDir)
                        type = MatlabType.MCOSClass;
                    end
                end
            end
        end
        if type == MatlabType.NotYetKnown
            classDir = findAtDirOnPath(qName);
            [fileExists,fileLocation]=matlabFileExists(qName);
            if ~isempty(classDir)
                if iscell(classDir)
                    k = 1;
                    while (type == MatlabType.NotYetKnown && ...
                           k <= numel(classDir))
                        type = classTypeFromClassDir(classDir{k}, qName);
                        k = k + 1;
                    end
                else
                    type = classTypeFromClassDir(classDir, qName);
                end
            elseif fileExists && isClassdef(fileLocation)
                type = MatlabType.MCOSClass;
            end
        end
    end
end

function type = classTypeFromClassDir(classDir, cName)
    import matlab.depfun.internal.MatlabType;
    
    fs = filesep;
    type = MatlabType.NotYetKnown;
    cdf = [classDir fs cName];
    [fileExists,fileLocation]=matlabFileExists(cdf);
    if fileExists
        if isClassdef(fileLocation)
            type = MatlabType.MCOSClass;
        elseif ~matlabFileExists([classDir fs 'schema'])
            type = MatlabType.OOPSClass;
        end
    end
end

function tf = isOnlyComment(w)
    tf = false;
    if matlabFileExists(w)
        mt = matlab.depfun.internal.cacheMtree(w);
        if ~isempty(mt)
            tf = mt == mt.mtfind('Kind', 'COMMENT');
        end
    end
end
