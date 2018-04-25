function underDocroot = isUnderDocroot(file)
% HELPUTILS.ISUNDERDOCROOT - checks whether a file is under the current
% docroot.

% Copyright 2010-2014 The MathWorks, Inc.
if isempty(file) || (isStringScalar(file) && strlength(file) == 0)
    underDocroot = false;
elseif usejava('mwt')
    file = strrep(file,'\','/');
    fileUrl = com.mathworks.html.Url.parseSilently(file);
    if ~isempty(fileUrl)
        docConfig = com.mathworks.mlwidgets.help.DocCenterDocConfig.getLocalConfig;
        docUrlParser = docConfig.getDocUrlParser;
        docPage = docUrlParser.resolve(fileUrl);
        underDocroot = ~isempty(docPage);
    else
        underDocroot = false;
    end
else
    docrootParts = regexp(docroot, '[\\/]', 'split');
    docrootParts = regexptranslate('escape', docrootParts);
    docrootCheck = sprintf('%s[\\\\/]', docrootParts{:});
    docrootRegexp = ['^(?:(\w{2,}:)+///?)?' docrootCheck '?'];
    underDocroot = ~isempty(regexp(file,docrootRegexp,getCaseArg,'once'));
end
end

function caseArg = getCaseArg
    if ispc
        caseArg = 'ignorecase';
    else
        caseArg = 'matchcase';
    end
end
