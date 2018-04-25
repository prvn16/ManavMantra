function schema
%SCHEMA Define the HDFPANEL class.

%   Copyright 2004-2013 The MathWorks, Inc.

    ppkg = findpackage('hdftool');
    pcls = ppkg.findclass('filepanel');

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'hdfpanel',pcls);

    prop(1) = schema.prop(cls,'subsetPanelContainer','MATLAB array');
    prop(2) = schema.prop(cls,'subsetPanel','MATLAB array');
    prop(3) = schema.prop(cls,'currentNode','MATLAB array');
    prop(4) = schema.prop(cls,'mainLayout','MATLAB array');
    prop(5) = schema.prop(cls,'title','MATLAB array');
    prop(6) = schema.prop(cls,'hImportMetadata','MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');
    
end
