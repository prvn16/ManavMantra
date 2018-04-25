function schema
%SCHEMA Define the FILEPANEL class.

%   Copyright 2005-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'filepanel');

    prop(1) = schema.prop(cls,'mainPanel','MATLAB array');
    prop(2) = schema.prop(cls,'fileTree','MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
             'AccessFlags.PrivateSet','on',...
             'AccessFlags.PublicGet','on',...
             'AccessFlags.PublicSet','on');

end
