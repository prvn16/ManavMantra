%GETALLPACKAGES    List of all top-level packages
%    ALL = META.PACKAGE.GETALLPACKAGES returns a cell array of META.PACKAGE 
%    instances representing all of the top-level packages that are visible 
%    on the MATLAB path or defined as top-level built-in packages.
%
%    Note that this method requires searching the MATLAB path to find all 
%    packages.  It is therefore intended primarily for interactive use and
%    should not be utilized in performance-critical applications.
%
%    %Example: Display the names of all visible packages
%    allpck = meta.package.getAllPackages;
%    for i=1:numel(allpck)
%        disp(allpck{i}.Name);
%    end
%    
%    See also META.PACKAGE, META.PACKAGE.FROMNAME

%   Copyright 2008 The MathWorks, Inc. 
%   Built-in method.