function [t,fmt] = guessFormat(dateStrs,tryFmts,errMode,tz,locale,pivot)

%   Copyright 2014 The MathWorks, Inc.
import matlab.internal.datetime.createFromString

tryStr = {};
for k = 1:numel(dateStrs)
    % Need to check for missing string, because curly brace indexing on missing
    % string will error
    if ismissing(dateStrs(k)) 
        str = char.empty;
    else
        str = dateStrs{k};
    end
    if ~isempty(str) && ~any(strcmpi(str,{'NaT' 'Inf' '+Inf' '-Inf'}))
        tryStr = {str}; % try just the first non-empty, non-NaT/Inf one
        break
    end
end

if isempty(tryStr)
    % If the cellstr is empty, or if all strings are empty or nonfinites, assume the default format.
    fmt = getDatetimeSettings('defaultformat');
    t = createFromString(dateStrs,fmt,errMode,tz,locale,pivot);
else
    % First try the suggested formats.
    for i = 1:length(tryFmts)
        fmt = tryFmts{i};
        if tryOneFmt(fmt), return, end % quit if this format works
    end
    
    if isempty(locale)
        [guessformats,numNonAmbiguous] = matlab.internal.datetime.getFormatsForGuessing(matlab.internal.datetime.getDefaults('locale'));
    else
        [guessformats,numNonAmbiguous] = matlab.internal.datetime.getFormatsForGuessing(locale);
    end
    % Next try some standard formats. Try short month names (MMM) formats before
    % trying the month number (MM) formats below; the latter would accept month
    % names but turn them into numbers.
    for i = 1:numNonAmbiguous
        fmt = guessformats{i};
        if tryOneFmt(fmt), return, end % quit if this format works
    end
    % None of the non-ambiguous formats worked. Remove them and try the
    % others.
    guessformats(1:numNonAmbiguous) = [];
    if ~isempty(guessformats)
        % If the locale's preferred MM format is month-first or day-first, try the
        % preferred format first.
        numAmbiguous = numel(guessformats); % This will always be even.
        for j = 1:2:numAmbiguous
            % Get the locale's preferred month number (MM) format. If the preferred
            % format is "month-first" or "day-first", get its opposite too.
            fmt1 = guessformats{j};  
            fmt2 = guessformats{j+1};
            
            if tryOneFmt(fmt1);
                % The first format worked on at least the first string.
                numNaTs = sum(isnan(t(:)));
                if numNaTs == 0
                    % The first format worked perfectly. Warn if the second one would
                    % have too.
                    ucal = datetime.dateFields;
                    day = matlab.internal.datetime.getDateFields(t,ucal.DAY_OF_MONTH,tz);
                    if all(day <= 12)
                        warning(message('MATLAB:datetime:AmbiguousDateString',fmt1,fmt2));
                    end
                    fmt = fmt1;
                    return % quit, the first format works
                else % numNaTs > 0
                    % The first one had some failures. Try the second format.
                    t2 = createFromString(dateStrs,fmt2,0,tz,locale,pivot);
                    firstNotSecond = any(~isnan(t(:)) & isnan(t2(:)));
                    secondNotFirst = any(isnan(t(:)) & ~isnan(t2(:)));
                    if firstNotSecond && secondNotFirst
                        % If the second format failed somewhere the first one succeeded,
                        % and vice-versa, we definitely have mixed month-first/day-first.
                        % Don't accept either.
                        break
                    elseif firstNotSecond
                        % If the second format failed somewhere the first one succeeded,
                        % but didn't succeed anywhere the first one failed, the first
                        % is unambiguously the right one.
                        fmt = fmt1;
                        return % quit, the first format works well enough
                    elseif secondNotFirst
                        % If the second format succeeded somewhere the first one failed,
                        % but didn't fail anywhere the first one succeeded, the second
                        % is unambiguously the right one.
                        t = t2;
                        fmt = fmt2;
                        return % quit, the second format works well enough
                    else
                        % Otherwise, the two formats worked equally well. Warn about that.
                        warning(message('MATLAB:datetime:AmbiguousDateString',fmt1,fmt2));
                        fmt = fmt1;
                        return % quit, the first format works well enough
                    end
                end
            else
                % The first format didn't work on the first string, try the second format.
                if tryOneFmt(fmt2)
                    % The second format worked on at least the first string.
                    numNaTs = sum(isnan(t(:))); % always < numel(t)
                    if numNaTs == 0
                        % The second format worked perfectly. Already know the first one
                        % didn't work perfectly.
                        fmt = fmt2;
                        return % quit, the second format works
                    else % numNaTs > 0
                        t1 = createFromString(dateStrs,fmt1,0,tz,locale,pivot);
                        % Already know the first format failed somewhere the second one succeeded.
                        firstNotSecond = any(isnan(t(:)) & ~isnan(t1(:)));
                        if firstNotSecond
                            % If the first format succeeded somewhere the second one failed, we
                            % definitely have mixed month-first/day-first. Don't accept either.
                            break
                        else
                            % If the first format didn't succeed anywhere the second one failed,
                            % the second is unambiguously the right one.
                            fmt = fmt2;
                            return % quit, the second format works well enough
                        end
                    end
                end
            end
        end
    end
    
    % Try the datetime preference settings and the spreadsheet formats as a
    % last resort
    %
    % NOTE: The preference setting should not be in guessing formats as it
    % is not yet known if they are ambiguous or unambiguous.
    dtFmt = getDatetimeSettings('defaultdateformat');
    dtTmFmt = getDatetimeSettings('defaultformat');
    spFmts = matlab.io.spreadsheet.internal.dateFormats('all');
    extraFmts = unique([spFmts(:); {dtFmt}; {dtTmFmt}], 'stable');
    for i = 1:numel(extraFmts)
        fmt = extraFmts{i};
        if tryOneFmt(fmt), return, end % quit if this format works
    end
    
    % None of the formats worked
    error(message('MATLAB:datetime:ParseErrs','')); % caught by constructor and elaborated on
end%if isempty(tryStr)

% ----------------------------------------------------------------------- %

    function tf = tryOneFmt(fmt)
        import matlab.internal.datetime.createFromString
        try
            t = createFromString(tryStr,fmt,2,tz,locale,pivot); % error, don't return NaT
            % The test string succeeded
            tf = true;
            if ~isscalar(dateStrs)
                % This may return NaTs, or may error, as requested
                t = createFromString(dateStrs,fmt,errMode,tz,locale,pivot);
            end
        catch ME
            if strcmp(ME.identifier,'MATLAB:datetime:ParseErr') ...
                   || strcmp(ME.identifier,'MATLAB:datetime:ParseErrs')
                % The test string failed, give up on this format
                tf = false;
            else
                throwAsCaller(ME);
            end
        end
    end

end
