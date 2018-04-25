%FROMNAME    Obtain META.PACKAGE for specified package name
%    METAPACK = META.PACKAGE.FROMNAME(PACKAGENAME) returns the META.PACKAGE
%    object associated with the named package.  PACKAGENAME can be a
%    string scalar or character vector.  If PACKAGENAME is a nested 
%    package, you must provide the fully qualified name.
%
%    %Example: Obtain the META.PACKAGE instance for package META using
%    %the package name.
%    mp = meta.package.fromName('meta');
%    
%    See also META.PACKAGE, META.PACKAGE.GETALLPACKAGES

%   Copyright 2008-2017 The MathWorks, Inc. 
%   Built-in method.