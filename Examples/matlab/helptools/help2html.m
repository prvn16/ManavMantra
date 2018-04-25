function [outStr, found] = help2html(topic,pagetitle,helpCommandOption)
%HELP2HTML Convert M-help to an HTML form.
% 
%   This file is a helper function used by the HelpPopup Java component.  
%   It is unsupported and may change at any time without notice.

%   Copyright 2007-2008 The MathWorks, Inc.
if nargin == 0
    topic = '';
end
if nargin < 2
    pagetitle = '';
end
if nargin < 3
    helpCommandOption = '-helpwin';
end
dom = com.mathworks.xml.XMLUtils.createDocument('help-info');
dom.getDomConfig.setParameter('cdata-sections',true);

[helpNode, helpstr, fcnName, found] = help2xml(dom, topic, pagetitle, helpCommandOption);

afterHelp = '';
if found
    % Handle characters that are special to HTML 
    helpstr = fixsymbols(helpstr);

    % Extract the see also and overloaded links from the help text.
    % Since these are already formatted as links, we'll keep them 
    % intact rather than parsing them into XML and transforming
    % them back to HTML.
    helpParts = matlab.internal.language.introspective.helpParts(helpstr, fcnName);
    afterHelp = moveToAfterHelp(afterHelp, helpParts, {'seeAlso', 'note', 'overloaded', 'demo'});
    
    helpstr = deblank(helpParts.getFullHelpText);
    shortName = regexp(fcnName, '(?<=\W)\w*$', 'match', 'once');
    helpstr = helpUtils.highlightHelp(helpstr, fcnName, shortName, '<span class="helptopic">', '</span>');
elseif strcmp(helpCommandOption, '-doc')
    outStr = '';
    return;
end

helpdir = fileparts(mfilename('fullpath'));
helpdir = ['file:///' strrep(helpdir,'\','/')];
addTextNode(dom,dom.getDocumentElement,'helptools-dir',helpdir);

if found
    addAttribute(dom,helpNode,'helpfound','true');
else
    addAttribute(dom,helpNode,'helpfound','false');
    % It's easier to escape the quotes in M than in XSL, so do it here.
    addTextNode(dom,helpNode,'escaped-topic',strrep(fcnName,'''',''''''));
end

% Prepend warning about empty docroot, if we've been called by doc.m
if strcmp(helpCommandOption, '-doc') && ~helpUtils.isDocInstalled
    addAttribute(dom,dom.getDocumentElement,'doc-installed','false');
    warningGif = sprintf('file:///%s',strrep(fullfile(matlabroot,'toolbox','matlab','icons','warning.gif'),'\','/'));
    addTextNode(dom,dom.getDocumentElement,'warning-image',warningGif);
    helperrPage = sprintf('file:///%s',strrep(fullfile(matlabroot,'toolbox','local','helperr.html'),'\','/'));
    addTextNode(dom,dom.getDocumentElement,'error-page',helperrPage);
end

helpCommandOption = char(helpCommandOption);

addTextNode(dom,dom.getDocumentElement,'default-topics-text',getString(message('MATLAB:helpwin:sprintf_DefaultTopics')));
addTextNode(dom,dom.getDocumentElement,'help-command-option',helpCommandOption(2:end));
xslfile = fullfile(fileparts(mfilename('fullpath')),'private','helpwin.xsl');
outStr = xslt(dom,xslfile,'-tostring');

% Use HTML entities for non-ASCII characters
helpstr = regexprep(helpstr,'[^\x0-\x7f]','&#x${dec2hex($0)};');
afterHelp = regexprep(afterHelp,'[^\x0-\x7f]','&#x${dec2hex($0)};');
outStr = regexprep(outStr,'\s*(<!--\s*helptext\s*-->)', sprintf('$1%s',regexptranslate('escape',helpstr)));
outStr = regexprep(outStr,'\s*(<!--\s*after help\s*-->)', sprintf('$1%s',regexptranslate('escape',afterHelp)));

%==========================================================================
function afterHelp = moveToAfterHelp(afterHelp, helpParts, parts)
for i = 1:length(parts)
    part = helpParts.getPart(parts{i});
    if ~isempty(part)
        title = part.getTitle;
        if title(end) == ':'
            title = title(1:end-1);
        end
        afterHelp = sprintf('%s<!--%s-->', afterHelp, parts{i});
        afterHelp = sprintf('%s<div class="footerlinktitle">%s</div>', afterHelp, title);
        afterHelp = sprintf('%s<div class="footerlink">%s</div>', afterHelp, part.getText);
        part.clearPart;
    end
end

%==========================================================================
function addTextNode(dom,parent,name,text)
child = dom.createElement(name);
child.appendChild(dom.createTextNode(text));
parent.appendChild(child);

%==========================================================================
function addAttribute(dom,elt,name,text)
att = dom.createAttribute(name);
att.appendChild(dom.createTextNode(text));
elt.getAttributes.setNamedItem(att);
