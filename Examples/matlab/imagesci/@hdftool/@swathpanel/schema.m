function schema
%SCHEMA Define the SWATHPANEL Class.

%   Copyright 2004-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('eospanel');
    cls = schema.class(pkg,'swathpanel',superCls);

end
