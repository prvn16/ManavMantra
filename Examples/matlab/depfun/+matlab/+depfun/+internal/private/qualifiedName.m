function fcnName = qualifiedName(file)
% qualifiedName Determine full function name from full path to file.
%
% Include package and class prefix as necessary.
    import matlab.depfun.internal.requirementsConstants;
    
    fs = filesep;
    
    [pth,fcnName,~] = fileparts(file);
    % Built-ins of the form 'built-in (/path/to/fcn)' end up with a 
    % trailing ) after fileparts is done with them.
    %
    % Built-ins of the form '<qualified name> is a built-in method'
    % end up with an empty pth.
    if ~isempty(strfind(file,requirementsConstants.BuiltInStr))
        if fcnName(end) == ')' 
            fcnName(end) = '';
        else
            k = strfind(file, requirementsConstants.IsABuiltInMethodStr);
            if ~isempty(k)
                fcnName = file(1:k-2);
            end
        end
    end
        
    % Chop off everything before the first @ or + (beginning of class or
    % package specification). at1 and plus1 must be scalars, or the min()
    % will fail. (They must be the same size, and since we're looking for
    % the first @ or +, they should be scalars, since there's only one
    % first.)
    at1 = strfind(pth, [fs '@']) + 1;
    if ~isempty(at1), at1 = at1(1); end
    plus1 = strfind(pth, [fs '+']) + 1;
    
    if ~isempty(plus1)
        plus1 = plus1(1);
    else
        plus1 = at1;
    end
    
    if isempty(at1)
        at1 = plus1;   % min returns empty if any input is empty
    end
    chop = min(at1,plus1);
    if ~isempty(chop)
        prefix = pth(chop+1:end);
        % Turn /@ and /+ into . (taking into account the flip-flopping
        % file separators).
        prefix = regexprep(prefix,'[/\\][@+]','.');
        fcnName = [prefix '.' fcnName];
    end
end
