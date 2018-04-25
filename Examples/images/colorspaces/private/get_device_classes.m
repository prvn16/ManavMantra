function device_classes = get_device_classes(version)
%GET_DEVICE_CLASSES Create table of device-class names
%   DEVICE_CLASSES = GET_DEVICE_CLASSES(VERSION) returns an
%   (n x 2) matrix of strings constituting a translation
%   table for ICC profile classes (a.k.a. device classes).
%   The first column contains all the valid 4-character
%   signatures for the device classes, while the second
%   column contains the corresponding field names used for
%   the "Header" field in the MIPS (in-Matlab ICC Profile
%   Structure).  VERSION is the major-version number of
%   the relevant ICC profile spec, which defaults to 2.
%   (Currently there is no dependence on VERSION.)
%
%   See ICCREAD, ICCWRITE, ISICC

%   Copyright 1993-2004 The MathWorks, Inc.
%      Poe
%   Original authors: Scott Gregory, Toshia McCabe, Robert Poe 01/28/04

if nargin < 1
    version = 2;
end

% Return list of device classes
device_classes = {  ...
        'scnr', 'input'; ...
        'mntr', 'display'; ...
        'prtr', 'output'; ...
        'link', 'device link'; ...
        'spac', 'colorspace conversion'; ...
        'abst', 'abstract'; ...
        'nmcl', 'named color'};

    

