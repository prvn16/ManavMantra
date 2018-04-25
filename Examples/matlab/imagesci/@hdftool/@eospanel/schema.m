function schema
%SCHEMA Define the eospanel class.

%   Copyright 2005-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('hdfpanel');
    cls = schema.class(pkg,'eospanel',superCls);

    prop(1) = schema.prop(cls, 'subsetFrame', 'MATLAB array');
    prop(2) = schema.prop(cls, 'subsetFrameContainer','MATLAB array');
    prop(3) = schema.prop(cls, 'subsetApi', 'MATLAB array');
    prop(4) = schema.prop(cls, 'subsetSelectionApi', 'MATLAB array');
    
    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');

end
