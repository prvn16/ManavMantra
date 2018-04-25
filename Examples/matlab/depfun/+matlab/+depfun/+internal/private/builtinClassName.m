function [name, clsFile] = builtinClassName(whichResult)
% builtinClassName Return class name and class file assuming whichResult 
% indicates a built-in class. Results unpredictable and likely wrong if
% called with a non-built-in whichResult.
    import matlab.depfun.internal.requirementsConstants;

    fs = filesep;
    space = strfind(whichResult, ' ');
    if isempty(space)
        error(message('MATLAB:depfun:req:InvalidClassInfo', ...
            '<unknown>', whichResult))
    else
        space = space(1);  % You can have too much space.
    end
    
    % Get the first "word" from the whichResult -- everything up to the
    % first space. This is either a function name or the word "built-in".
    nm = whichResult(1:space(1)-1);
    
    [type, clsFile] = classUsingBuiltinCTOR(whichResult);
    if type == matlab.depfun.internal.MatlabType.NotYetKnown
        [name, clsFile] = virtualBuiltinClassCTOR(nm);
        if isempty(clsFile)
            clsFile = whichResult;
            if existClass(nm)
                name = nm;
            end
        end
    else
        name = nm;
    end
    
    % MATLAB intrinsic built-in types (@cell, etc.) are ill-treated by the
    % tests above. Look for them here.
    if isempty(name) || isempty(clsFile)
        % Look for methods of the form:
        %   'built-in (....@class/method)'

        %prefix = [nm ' built-in ('];
        prefix = [requirementsConstants.BuiltInStrAndATrailingSpace '('];
        prefixSize = numel(prefix);
        if strncmp(prefix, whichResult, prefixSize)
            mth = whichResult(prefixSize+1:end-1);
            [name, clsFile] = className_impl(mth);
            if ~isempty(name) && ~isempty(strfind(clsFile,mth))
                % Don't change whichResult for class constructor.
                clsFile = whichResult; 
            else
                % Find the first @ or +, either of which can begin a
                % qualified name.
                plusIdx = strfind(mth, [fs '+']) + 1;
                atIdx = strfind(mth, [fs '@']) + 1;
                qStart = 1;
                if ~isempty(atIdx)
                    atIdx = atIdx(1);
                    qStart = atIdx;
                end
                if ~isempty(plusIdx)
                    plusIdx = plusIdx(1);
                    if plusIdx < atIdx
                        qStart = plusIdx;
                    end
                end
                % Require an @ for this file to have a class name.
                if ~isempty(atIdx)
                    fsIdx = strfind(mth, fs);
                    if ~isempty(fsIdx)
                        fsIdx = fsIdx(end);
                        name = mth(qStart+1:fsIdx-1);
                        clsFile = matlab.depfun.internal.cacheWhich(name);
                    end
                end
            end
        end
    end

end
