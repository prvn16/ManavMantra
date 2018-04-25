function handleForm(inStr)
%handleForm  Manage the preferences for reports with checkboxes.
%   VISDIRFORMHANDLER is invoked by a POST method inside a <FORM> tag in
%   the various directory reports. 

% Copyright 2009-2016 The MathWorks, Inc.

strc = parsehtmlpostmethod(inStr);

% Unfortunately this file needs to know specific information about the
% prefs for each of the report types. This is because only boxes that are
% checked are reported, but we need to report the unchecked boxes too.

% The hidden "reporttype" input is named for the page from which the report
% was requested.
switch strc.reporttype
    case 'dofixrpt'
        interpretCheckbox(strc, 'planDisplayMode')
        interpretCheckbox(strc, 'todoDisplayMode')
        interpretCheckbox(strc, 'fixmeDisplayMode')
        interpretCheckbox(strc, 'regexpDisplayMode')

    case 'helprpt'
        interpretCheckbox(strc,'helpDisplayMode')
        interpretCheckbox(strc,'h1DisplayMode')
        interpretCheckbox(strc,'copyrightDisplayMode')
        interpretCheckbox(strc,'helpSubfunsDisplayMode')
        interpretCheckbox(strc,'seeAlsoDisplayMode')
        interpretCheckbox(strc,'exampleDisplayMode')

    case 'deprpt'
        interpretCheckbox(strc,'depSubfunDisplayMode')
        interpretCheckbox(strc,'localParentDisplayMode')
        interpretCheckbox(strc,'allChildDisplayMode')

end


function interpretCheckbox(strc,modeStr)
% Interpret the setting of the checkbox as needed

thePref = 0;
if isfield(strc,modeStr)
    if strcmpi(strc.(modeStr),'on')
        thePref = 1;
    end
else
    % The field doesn't exist. Turn the preference off.
    thePref = 0;
end

setpref('dirtools',modeStr,thePref)

function strc = parsehtmlpostmethod(inStr)
%PARSEHTMLPOSTMETHOD  Returns HTML <form> post data in structure form
%   strc = PARSEHTMLPOSTMETHOD(inStr)

% Replace the first "?" with an "&" to simplify the parsing logic below
% "&" will be used as the delimiter between prop-value pairs.
if inStr(1)=='?'
    inStr(1) = '&';
end

strc = [];
match1 = regexp(inStr,'&([^&]*)','tokens');
for n = 1:length(match1)
    match2 = regexp(match1{n}{1},'([^=]*)=([^=]*)','tokens');
    for m = 1:length(match2)
        prop = char(com.mathworks.mlwidgets.html.HTMLUtils.decodeUrl(match2{m}{1}));
        val  = char(com.mathworks.mlwidgets.html.HTMLUtils.decodeUrl(match2{m}{2}));
        strc.(prop) = val;
    end
end

