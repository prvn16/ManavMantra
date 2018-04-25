function schema
%SCHEMA Define the POINTPANEL Class.

%   Copyright 2005-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('eospanel');
    cls = schema.class(pkg,'pointpanel',superCls);

    prop(1) = schema.prop(cls,'datafieldApi','MATLAB array');
    prop(2) = schema.prop(cls,'levelApi','MATLAB array');
    prop(3) = schema.prop(cls,'boxApi','MATLAB array');
    prop(4) = schema.prop(cls,'recordApi','MATLAB array');
    prop(5) = schema.prop(cls,'timeApi','MATLAB array');

    set(prop,'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on',...
        'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on');

end
