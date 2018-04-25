function [name, clsFile] = className_impl(whichResult)
% This file used to be a part of className.m
% It is taken out as a separate file to break the recursive call from
% builtinClassName.m to className.m. Now both of them call this file.

    import matlab.depfun.internal.requirementsConstants;
    
    fs = filesep;  % Expensive when called a bazillion times.
    
    name = '';
    clsFile = '';
    
    [pth,fcnName] = fileparts(whichResult);
    % Find the location of '@'. Note that '@' must follow filesep.
    atIdx = strfind(whichResult, [fs '@']) + 1;

    % Does the whichResult specify a file in an @-directory?
    % Make sure to check for no-constructor cases:
    %    
    %  * UDD class specified by schema.m
    %  * OOPS class with no constructor.
    %  * All-builtin MCOS class.

    if ~isempty(atIdx)
        % Find the first filesep after the last '/@'
        fsIdx = strfind(pth, fs);
        deepFsIdx = fsIdx(find(fsIdx > atIdx(end), 1));            
        if ~isempty(deepFsIdx)
            % Chop off everything after the last '@'
            pth = pth(1:deepFsIdx-1);
        end

        dirName = pth(atIdx(end)+1:end);

        if matlabFileExists([ pth fs dirName]) || ...
           matlabFileExists([ pth fs 'schema' ]) 

            % Find the first (leftmost) + or @ in the path part of the name.
            qStart = atIdx(1);
            % Find the location of '+'. Note that '+' must follow filesep.
            plusIdx = strfind(pth, [fs '+']) + 1;
            if ~isempty(plusIdx)
                qStart = min(qStart, plusIdx(1));
            end
            % Change the path specification into a qualified name
            name = qualifyName( pth(qStart:end) );
            [fileExists,clsFile] = matlabFileExists(fullfile(pth,dirName));

            % G1211213
            % No-constructor cases used to be treated in the same way below.
            % However, UDD package functions and their private
            % functions should not belong here, because they don't
            % belong to a class.
            if ~fileExists
                if numel(atIdx) == 1 && matlabFileExists([ pth fs 'schema' ])
                    name = '';
                    clsFile = '';
                else
                    clsFile = fullfile(pth,[dirName '.m']);
                end
            end

        elseif matlab.depfun.internal.cacheExist(pth,'dir')
            % An @-directory exists, but it does not contain a constructor
            % or schema. This is an extension method directory. Two
            % scenarios, neither pretty.
            %   * The class is built-in, like gpuArray.
            %   * The class has a classdef file somewhere else.

            % Find the first (leftmost) + or @ in the path part of the name.
            qStart = atIdx(1);
            % Find the location of '+'. Note that '+' must follow
            % filesep.
            plusIdx = strfind(pth, [fs '+']) + 1;
            if ~isempty(plusIdx)
                qStart = min(qStart, plusIdx(1));
            end
            % Get the class name from the path.
            qName = qualifyName( pth(qStart:end) );
            qWhich = matlab.depfun.internal.cacheWhich(qName);
            
            % If qName (non MATLAB intrinsic built-in types) is not on the
            % path, stop guessing here.
            if ~isempty(qWhich) || isKey(requirementsConstants.matlabBuiltinClassSet, qName)
                 % Is it a built-in?
                if ~isempty(strfind(qWhich, requirementsConstants.IsABuiltInMethodStr))
                    [name, clsFile] = virtualBuiltinClassCTOR(qName);
                end
                
                if isempty(name)
                    % Class directory must contain an '@'. If qWhich
                    % doesn't, then perhaps we have a shadowed constructor.
                    % Look for class directories using WHAT.
                    if isempty(strfind(qWhich, [fs '@']))
                        w = what(pth(qStart:end));
                        if numel(w) == 1
                            name = qName;
                            clsFile = fullfile(w(1).path, ...
                                               pth(atIdx(end)+1:end));
                            % At this point, if the constructor doesn't
                            % exist, the constructor must be a built-in.
                            if ~matlabFileExists(clsFile)
                                clsFile = [ ...
                                    requirementsConstants.BuiltInStrAndATrailingSpace ...
                                    '(' clsFile ')'];
                            end
                        end
                    end
                end
                if isempty(name)
                    name = qName;
                    clsFile = qWhich;
                end
            end
        end

    % Does the whichResult specify a CLASSDEF file?
    elseif isfullpath(whichResult) && isClassdef(whichResult)
        name = fcnName;
        clsFile = whichResult;
        % Find the location of '+'. Note that '+' must follow filesep.
        plusIdx = strfind(pth, [fs '+']) + 1;
        if ~isempty(plusIdx)
            name = qualifyName([pth(plusIdx(1):end) fs fcnName]);
        end
    end
end