function classNames = functionhintsfunc(methodName)
% This undocumented function may be removed in a future release.

% UTGETCLASSESFORMETHOD  Utility function used by Function Hints for
% obtaining the class names for a function/method on the MATLAB path

%   Copyright 1984-2010 The MathWorks, Inc.

pathNames = which('-all',methodName);
classNames = cell(length(pathNames),1);
M = inmem('-completenames');
for k=1:length(pathNames)
    thisPath = pathNames{k};
    fileSeps = strfind(thisPath,filesep);
    
    
    %  Must handle these cases
    %  built-in (C:\Work\R2008b\Acontrol_051508\matlab\toolbox\matlab\datatypes\double)
    %  double is a built-in method
    %  isFocused is a Java method
    
    
    % Matlab OOPS
    %   dir/@ClassName
    %
    % UDD
    %    % dir/@PackageName/@ClassName
    % Note: UDD package scoped functions
    %    % dir/@PackageName/FcnName
    %
    % MCOS Classes can be defined in the following manner
    %   dir/ClassName
    %   dir/@ClassName
    %   dir/+packagename1/ClassName
    %   dir/+packagename1/@ClassName
    %   dir/+packagename1/.../+packagenameN/ClassName
    %   dir/+packagename1/.../+packagenameN/@ClassName
    % Note: package scoped functions are
    %   dir/+packagename1/FcnName
    %   dir/+packagename1/.../+packagenameN/FcnName
    %
    % For MCOS classes WITHOUT an @ symbol in the path the function which
    % -all returns the dir/.../ClassName.m file. In this case when
    % determining the candidate class name from the file path remove ".m" from
    % the file path
    %
    % For MCOS classes WITH an @ symbol in the path the function which
    % -all returns either
    %       dir/.../@ClassName/ClassName.m file if function is
    %           defined in the class definition
    %       dir/.../@ClassName/FncName.m file if function defined as a
    %           separate file
    % In these cases when determining the candidate class name from the file path
    % remove "/*.m" from the file Path
    %
    % Now the candidate class name can be formed by
    %   1. If an @ or + is in the file path, remove the path before the
    %   first occurrence of the character. Replace all filesep with "."
    %   and remove all + or @ chars to create the candidate class name.
    %   2. If NO @ or + is in the file path, the candidate class name is
    %   the last portion of the string after the last filesep.
    
    % Enumerated list of cases
    % 1. dir/FcnName.m
    % 2. dir/@ClassName/FcnName.m (OOPs)
    % 3. dir/@PackageName/@ClassName/FcnName.m (UDD)
    % 4. dir/@PackageName/FcnName.m (UDD)
    % 5. dir/ClassName/ClassName.m (MCOS) FncName.m defined in classdef
    % 6. dir/@ClassName/FncName.m (MCOS)
    % 7. dir/@ClassName/ClassName.m % (MCOS) FncName.m defined in classdef
    % 8. dir/+packagename1/ClassName.m (MCOS) FncName.m defined in classdef
    % 9. dir/+packagename1/@ClassName/FcnName.m (MCOS)
    % 10. dir/+packagename1/@ClassName/ClassName.m  (MCOS) FncName.m defined in classdef
    % 11. dir/+packagename1/.../+packagenameN/ClassName.m (MCOS) FncName.m defined in classdef
    % 12. dir/+packagename1/.../+packagenameN/@ClassName\FcnName.m (MCOS)
    % 13. dir/+packagename1/.../+packagenameN/@ClassName\ClassName.m (MCOS)
    % 14. dir/+packagename1/FcnName.m (MCOS)
    % 15. dir/+packagename1/.../+packagenameN/FcnName.m (MCOS)
    
    try
        % Exclude loaded packages with Documented set to off.
        if strcmp(thisPath(end-1:end),'.m') || strcmp(thisPath(end-1:end),'.p')%&& any(strcmp(thisPath,M))
            
            % Determine ClassName or package
            candidateClassName = thisPath;
            idxplus = strfind(candidateClassName,'+');
            idxat = strfind(candidateClassName,'@');
            % candidateClassName is the fully qualified class name (including
            % path)
            if isempty(idxat)
                % Potentially a MCOS class or func remove ".m" (1,5,8,11)
                candidateClassName = candidateClassName(1:end-2);
            else
                % Truncate path only if class is defined with an @ (i.e. remove
                % method name to leave the class)
                candidateClassName = candidateClassName(1:fileSeps(end)-1);
            end
            % First location of either the "+" or "@" char
            idx = min([idxplus(:);idxat(:)]);
            
            if isempty(idx) % cases 1,5
                candidateClassName = candidateClassName(fileSeps(end)+1:end);
                if strcmp(candidateClassName,methodName) || ~isInMem(M,candidateClassName) % case 1
                    continue;
                end
                classH = meta.class.fromName(candidateClassName);
                if ~isempty(classH) && classH.Hidden % case 5
                    % Class but is hidden
                    continue;
                end
            else
                % Form classname replace fileseps with '.' and remove
                % '+','@'
                candidateClassName = candidateClassName(idx+1:end);
                if ~isInMem(M,candidateClassName)
                    continue;
                end
                candidateClassName = regexprep(candidateClassName,filesep,'.');
                candidateClassName = regexprep(candidateClassName,{'+','@'},'');
                %             candidateClassName = regexprep(candidateClassName,'+','');
                %             candidateClassName = regexprep(candidateClassName,'@','');
                if isempty(idxplus) % cases 2,3,4,6,7 no + but have an @
                    % MCOS class or UDD Package or Matlab oops
                    if length(idxat) == 1 % cases 2,4,6,7
                        % MCOS class or UDD package method or Matlab oops
                        classH = meta.class.fromName(candidateClassName);
                        if isempty(classH) % cases 2,4 not MCOS
                            % Must be a UDD package method or matlab oops
                            packageH = findpackage(regexprep(candidateClassName,'\..*',''));
                            if ~isempty(packageH) % case 4
                                % UDD Package method
                                continue;
                            end
                            
                        elseif classH.Hidden % cases 6,7 hidden
                            % MCOS Class but it is hidden
                            continue;
                        end
                    else % case 3                        
                        packageH = findpackage(regexprep(candidateClassName,'\..*',''));
                        if ~isempty(packageH) && strcmp(packageH.Documented,'off')
                           continue;
                        end
                    end
                    
                else % cases 8-15
                    % MCOS package with a +
                    classH = meta.class.fromName(candidateClassName);
                    
                    if ~isempty(classH) && classH.Hidden
                        continue;
                    end
                end
                
            end
            % Hard coded classes to exclude
            if any(strcmp(candidateClassName,{'uint16','int8','uint8',...
                    'logical','single','double','uint32','int16','int32',...
                    'uint64','int64','char','opaque','handle', 'mtree'}))
                continue;
            elseif any(strcmp(methodName,methods(candidateClassName))) && ...
                    ~strcmpi(methodName,candidateClassName)
                % Make sure that the method name is a case sensitive match
                % see g478089 and not a constructor g513203 
                classNames{k} = candidateClassName;
            end
            
            
        end
    catch me %#ok<NASGU>
        continue
    end
end

% Remove unused entries in the classNames array.
classNames = sort(classNames(~cellfun('isempty',classNames)));


function isInMemOut = isInMem(M,objName)

isInMemOut = false;
for k=1:length(M)
    % do the pre-check, this will preserve the old code performance
    if strfind(M{k}, objName)
        % if objName like 'matlab/+desktop/+editor/@Document', we need replace the '/' and '+' to fit in the Regular expression
        newObjName = regexprep(objName, filesep, strcat('\\',filesep));
        newObjName = regexprep(newObjName, '+', '\\+');

        % construct the match pattern
        % 1. "(.*)([\\/]@.*)?[\\/][+]?objName\.[mp]" matches paths that ending
        % with /objName.m or /objName.p
        % 2. "(.*)[\\/][@+]?objName[\\/](.*)\.[mp]" matches paths that
        % contain /+objName/ or /@objName/ or /objName/
        pattern = strcat('((.*)([\\/]@.*)?[\\/][+]?', newObjName, '\.[mp])|', '((.*)[\\/][@+]?', newObjName, '[\\/](.*)\.[mp])');
        
        matchStr = regexp(M{k},pattern,'match');
        if ~isempty(matchStr)
            isInMemOut = true;
            return;
        end;
    end;
end;
