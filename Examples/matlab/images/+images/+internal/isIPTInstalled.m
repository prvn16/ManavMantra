function tf = isIPTInstalled()

%   Copyright 2014 The MathWorks, Inc.

persistent IPT_INSTALLED

if isempty(IPT_INSTALLED)
    % check using dicomread
    dicomReadLocation = which('dicomread');
    if(strfind(dicomReadLocation,'iptformats'))
        IPT_INSTALLED =  true;
    else
        IPT_INSTALLED = false;
    end
end

tf = IPT_INSTALLED;

