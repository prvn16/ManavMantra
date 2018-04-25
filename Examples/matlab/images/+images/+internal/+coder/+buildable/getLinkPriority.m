function out = getLinkPriority(libName)
%  GETLINKPRIORITY(LIBNAME) returns the linkPriority for the specified 
% library. Use this function to set the linkPriority of 3P libraries such 
% as TBB and IPP in buildInfo.addLinkObjects(). When linkPriority is
% unspecified, it defaults to 1000.

% Copyright 2014 The MathWorks, Inc.

% Make the priority of TBB higher than that of IPP, see g1052652
switch lower(libName)
    case 'tbb'
        out = 800;
    case 'ipp'
        out = 2000;
    otherwise
        error('%s is an unknown library name',libName);
end
