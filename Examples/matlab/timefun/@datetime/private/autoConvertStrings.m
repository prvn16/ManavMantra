function t = autoConvertStrings(s,template)

%   Copyright 2014-2017 The MathWorks, Inc.

if ischar(s), s = {s}; end
% infinities should be treated as datetime.
isinf = strcmpi(s,'inf') | strcmpi(s,'+inf') | strcmpi(s,'-inf');
isnanLiteral = strcmpi(s,'nan') | strcmpi(s,'+nan') | strcmpi(s,'-nan');
isblank = ismissing(s) | strlength(s)==0;

if any(~isinf(:) & ~isblank(:))
    try
        % if the text is a duration, then use it as duration and not as a
        % datetime. This is for 'hh:mm:ss' and 'dd:hh:mm:ss'.
        % 'hh:mm:ss' would otherwise be treated as time-of-day leading to
        % unexpected results.
        t(~isinf) = duration(s(~isinf));
        % If the only data that would convert is the INF data, then we
        % won't want to convert to duration, separating these comparison
        % makes sure duration will error, but then we want to get the signs
        % correct for the infinities, so convert the inf(s) only if the
        % non-inf(s) succeed.
        t(isinf) = duration(s(isinf)); % this should always pass
    catch
        % if we get here, try to convert to datetime instead
        t = [];
    end

    if isduration(t) % will be double if duration errored.
        % If we had duration text with infinity, and the infinity was the
        % first no-blank element, then we should ignore that, and treat the
        % whole things as datetime.
        firstConverted = max([find(isfinite(t) | isnanLiteral,1) 0]);
        firstInf = max([find(isinf,1) 0]);
        firstNonBlank = max([find(~isblank,1) 0]);
        
        if firstConverted == firstNonBlank
            % First non-blank is also non-finite, use duration 
            return
        end
        if firstInf > firstConverted 
            % if the first inf text appears after the first finite value
            % and there were other non-blank elements then we have a case
            % where there is other text before the duration text that
            % should be converted to datetime first.
            throwAsCaller(MException(message('MATLAB:datetime:CompareTimeOfDay')));
        end
        % if we get here, redo with datetime. replace timer formatted data
        % with NaT.
        s(isfinite(t)) = {'NaT'};
    end
end

try
    t = template;
    format = getDisplayFormat(template);
    % Format and TimeZone taken from the template. The locale and
    % pivot year are the default. Error if parse fails -- these
    % are strings converted on-the-fly, no point in creating NaT
    t.data = matlab.internal.datetime.createFromString(s,format,2,t.tz);
    return;
catch
end

try
    t = datetime(s,'TimeZone',template.tz); % try once more, see if we can guess the format
catch ME
    % Look for UnrecognizedDateString[s], UnrecognizedDateString[s]WithLocale,
    % or UnrecognizedDateString[s]SuggestLocale, or ParseErrs when the datetime is
    % UTCLeapSeconds.
    if ~isempty(strfind(ME.identifier,'MATLAB:datetime:UnrecognizedDateString')) ...
            || strcmp(ME.identifier,'MATLAB:datetime:ParseErrs')
        ME = getAutoConvertError(s);
    end
    throwAsCaller(ME);
end

end
function ME = getAutoConvertError(s)
if isscalar(s)
    ME = MException(message('MATLAB:datetime:AutoConvertString',s{1}));
else
    ME = MException(message('MATLAB:datetime:AutoConvertStrings'));
end
end