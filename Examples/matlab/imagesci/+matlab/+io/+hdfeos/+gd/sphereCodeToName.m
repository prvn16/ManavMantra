function name = sphereCodeToName(code)
%sphereCodeToName  Return name corresponding to GCTP sphere code.
%   NAME = sphereCodeToName(CODE) returns the name for the spheroid
%   corresponding to the spheroid code.  The list of supported GCTP
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
%   See also gd, gd.defProj, gd.sphereNameToCode.

%   Copyright 2010-2013 The MathWorks, Inc.

switch(code)
    case -1
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidUnknown'));
    case 0
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidClarke1866'));
    case 1
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidClarke1880'));
    case 2
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidBessel'));
    case 3
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidInt1967'));
    case 4
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidInt1909'));
    case 5
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidWGS72'));
    case 6
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidEverest'));
    case 7
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidWGS66'));
    case 8
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidGRS1980'));
    case 9
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidAiry'));
    case 10
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidModifiedAiry'));
    case 11
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidModifiedEverest'));
    case 12
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidWGS84'));
    case 13
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidSoutheastAsia'));
    case 14
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidAustralianNational'));
    case 15
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidKrassovsky'));
    case 16
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidHough'));
    case 17
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidMercury1960'));
    case 18
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidModifiedMercury1968'));
    case 19
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidR6370997'));
    case 20
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidR6371228'));
    case 21
        name = getString(message('MATLAB:imagesci:hdfeos:spheroidR6371007'));
    otherwise
        error(message('MATLAB:imagesci:hdfeos:unrecognizedSpheroidCode', code));
end

