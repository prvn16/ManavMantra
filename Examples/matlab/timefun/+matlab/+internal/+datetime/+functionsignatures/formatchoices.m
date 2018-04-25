function choices = formatchoices(d)
% FORMATCHOICES List some common formats for use in DATETIME function signatures

%   Copyright 2017 The MathWorks, Inc.

if ~ischar(d), d = class(d); end

switch d
case 'datetime'
    choices = {'uuuu-MM-dd' 'QQQ-uuuu' 'MMM-uuuu' 'dd-MMM-uuuu' ...
               'dd-MMM-uuuu HH:mm:ss' 'dd-MMM-uuuu HH:mm:ss.SSS' ...
               'dd/MM/uuuu' 'dd/MM/uuuu HH:mm:ss' 'dd/MM/uuuu hh:mm:ss aa' ...
               'MM/dd/uuuu' 'MM/dd/uuuu HH:mm:ss' 'MM/dd/uuuu hh:mm:ss aa'...
               'dd-MMM-uuuu HH:mm:ss z' 'dd-MMM-uuuu HH:mm:ss.SSS z' ...
               'MMM d, uuuu' 'MMM d, uuuu HH:mm' 'MMM d, uuuu hh:mm aa' ...
               'uuuuMMdd''T''HHmmss' 'uuuu-MM-dd''T''HH:mm:ss.SSS'};
    locale = matlab.internal.datetime.verifyLocale('system');
    if ~startsWith(locale,'en_US')
        % Get the locale's preferred YMD format, and add it and a version with HMS to
        % the hard-coded choices if it's not already there.
        base = matlab.internal.datetime.getDefaults('LocaleFormat',locale,'uuuuMMMd'); % locale's MMM default
        if ~any(strcmp(base,choices))
            choices = [choices {base [base ' HH:mm:ss']}];
        end
    end
case 'duration'
    choices = {'y' 'd' 'h' 'm' 's' 'dd:hh:mm:ss' 'dd:hh:mm:ss.SSS' 'hh:mm' 'hh:mm:ss' 'hh:mm:ss.SSS' 'mm:ss' 'mm:ss.SSS'};
case 'duration-input'
    choices = {'dd:hh:mm:ss' 'dd:hh:mm:ss.SSS' 'hh:mm' 'hh:mm:ss' 'hh:mm:ss.SSS' 'mm:ss' 'mm:ss.SSS'};
case 'calendarDuration'
    choices = {'yqmwdt' 'ymdt' 'mdt'};
end
