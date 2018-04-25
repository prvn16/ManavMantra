function [name, clsFile] = virtualBuiltinClassCTOR(nm)
% create a virtual built-in class constructor if WHAT knows about the given
% class name.
%
% Try hard to do better than <X is a built-in method>. But if the
% WHAT result directory has no @-sign in it, it isn't a class
% directory.

import matlab.depfun.internal.requirementsConstants;

name = '';
clsFile = '';

fs = filesep;

partialClassDir = strrep(nm,'.','/');
w = what(partialClassDir);
if ~isempty(w)
    keep = ~cellfun('isempty',strfind({w.path}, [fs '@']));
    w = w(keep);
    if ~isempty(w)
        % It is not uncommon for built-in classes to have a
        % m-file to contain HELP comments.
        % Using that constructor-like m-file as proxy is much better 
        % than creating a virtual proxy. Otherwise, more than one proxy 
        % may be created for extension methods of the same built-in class.
        existIdx = cell2mat(cellfun(@(f)matlab.depfun.internal.cacheExist(f, 'file'), ...
                           strcat({w.path}, [fs nm '.m']), 'UniformOutput', false)) == 2;
        
        if any(existIdx)
            w = w(existIdx);
            name = nm;
            clsFile = [w(1).path fs nm '.m'];
        else
            % TODO: Decide between the first directory on the path or
            % the directory returned by which.
            if numel(w) > 1
                w = w(1);
            end

            dotIdx = strfind(nm,'.');
            cls = nm;
            if ~isempty(dotIdx)
                dotIdx = dotIdx(end);
                cls = nm(dotIdx+1:end);
            end
            % Need path information in the file-spec so that exclude
            % and expect rules can operate on built-in class
            % constructors.
            clsFile = [requirementsConstants.BuiltInStrAndATrailingSpace ...
                       '(' w.path fs cls ')'];
            %clsFile = matlab.depfun.internal.cacheWhich(cls);
            name = nm;
        end
    end
end

end