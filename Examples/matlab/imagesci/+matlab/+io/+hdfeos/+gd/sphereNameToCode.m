function code = sphereNameToCode(name)
%sphereNameToCode  Return numeric GCTP code corresponding to sphere name.
%   CODE = sphereCodeToName(NAME) returns the numeric GCTP code 
%   corresponding to the named spheroid.  The list of supported GCTP
%   spheroids is as follows:
%
%         0 - Clarke 1866                11 - Modified Everest
%         1 - Clarke 1880                12 - WGS 84
%         2 - Bessel                     13 - Southeast Asia
%         3 - International 1967         14 - Australian National
%         4 - International 1909         15 - Krassovsky
%         5 - WGS 72                     16 - Hough
%         6 - Everest                    17 - Mercury 1960
%         7 - WGS 66                     18 - Modified Mercury 1968
%         8 - GRS 1980                   19 - Sphere of radius 6370997m
%         9 - Airy                       20 - Sphere of radius 6371228m
%        10 - Modified Airy              21 - Sphere of radius 6371007.181m
%        
%   See also gd, gd.defProj, gd.sphereCodeToName.

%   Copyright 2010-2013 The MathWorks, Inc.

switch(lower(name))
    case 'unknown'
        code = -1;
    case 'clarke 1866'
        code = 0;
    case 'clarke 1880'
        code = 1;
    case 'bessel'
        code = 2;
    case 'international 1967'
        code = 3;
    case 'international 1909'
        code = 4;
    case 'wgs 72'
        code = 5;
    case 'everest'
        code = 6;
    case 'wgs 66'
        code = 7;
    case 'grs 1980'
        code = 8;
    case 'airy'
        code = 9;
    case 'modified airy'
        code = 10;
    case 'modified everest'
        code = 11;
    case 'wgs 84'
        code = 12;
    case 'southeast asia'
        code = 13;
    case 'australian national'
        code = 14;
    case 'krassovsky'
        code = 15;
    case 'hough'
        code = 16;
    case 'mercury 1960'
        code = 17;
    case 'modified mercury 1968'
        code = 18;
    case 'sphere of radius 6370997m'
        code = 19;
    case 'sphere of radius 6371228m'
        code = 20;
    case 'sphere of radius 6371007.181m'
        code = 21;
    otherwise
        error(message('MATLAB:imagesci:hdfeos:unrecognizedSpheroidName', name));
end

