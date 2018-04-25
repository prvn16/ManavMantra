function dt = text2timetype(text,msgID,template)
%TEXT2TIMETYPE
%   DT = TEXT2TIMETYPE(TEXT,MSGID) is a wrapper for the duration and datetime
%   constructors that converts the char row, cellstr, or string array TEXT to
%   either a duration array or a datetime array. If TEXT cannot be converted,
%   TEXT2TIMETYPE throws the error specified by MSGID. MSGID must refer to a
%   message with exactly one hole for the unrecognizable text, e.g.
%   MATLAB:datetime:InvalidTextInput.
%
%   duration is tried first, so text such as '00:00:00' that might be either
%   datetime or duration is converted to duration.
%
%   The datetime and duration constructors error if the format of the first
%   non-empty element of TEXT is not automatically recognizable. If that first
%   element can be converted, any subsequent elements that cannot be converted
%   using that format are set to NaT or NaN.

%   Copyright 2017 The MathWorks, Inc.

if ischar(text), text = string(text); end
if nargin == 3 && ~isdatetime(template) && ~isduration(template) % assume text
    try
        % convert the template, prefering duration, if the template is an error ignore it.
        template = matlab.internal.datetime.text2timetype(template,'',duration());
    catch 
        template = duration();
    end
end
% return an empty of the same type & size as template if it's passed in   
if nargin == 3 && isempty(text) 
    if isduration(template)
        dt = duration.empty(size(text));
    else
        dt = datetime.empty(size(text));
    end
    return;
end

% If everything is inf or zero-length, and a template is passed in, convert to
% the type of the template
isinf = strcmpi(text(:),'inf')|strcmpi(text(:),'+inf')|strcmpi(text(:),'-inf');
if nargin == 3 && all(isinf | strlength(text(:))==0)
    if isduration(template)
        dt = duration(text);
    else
        dt = datetime(text);
    end
    return
end

if ~(isempty(text) || all(strlength(text(:))==0))
    try
        % hh:mm:ss or dd:hh:mm:ss should be duration type first and
        % treat that as duration.
        if nargin == 3 && isduration(template)
            dt(~isinf) = duration(text(~isinf),'Format',template.Format);
        else
            dt(~isinf) = duration(text(~isinf));
        end
        dt(isinf) = duration(text(isinf));
        return
    catch
        % next try a datetime
    end
end 

try
    % Any datetime format should work here
    if nargin == 3 && isdatetime(template)
        dt(~isinf) = datetime(text(~isinf),'Format',template.Format,'Timezone',template.TimeZone);
    else
        dt(~isinf) = datetime(text(~isinf));
    end
    dt(isinf) = datetime(text(isinf));
    return
catch
    % otherwise, give up and error
end

if iscell(text) || isstring(text)
    % The inputs are assumed not to be empty here.
    text = text{find(strlength(text) > 0,1)};
end
error(message(msgID, text));
