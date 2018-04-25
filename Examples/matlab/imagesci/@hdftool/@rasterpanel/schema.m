function schema
%SCHEMA Define the RASTERPANEL Class.
  
%   Copyright 2004-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('hdfpanel');
    cls = schema.class(pkg,'rasterpanel',superCls);

    prop(1) = schema.prop(cls,'editHandle','MATLAB array');
    prop(2) = schema.prop(cls,'textHandle','MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
             'AccessFlags.PrivateSet','on',...
             'AccessFlags.PublicGet','on',...
             'AccessFlags.PublicSet','on');

end
