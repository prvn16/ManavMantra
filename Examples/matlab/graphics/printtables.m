function [ options, devices, extensions, classes, colorDevs, destinations, descriptions, clipsupport] = printtables( pj ) 
%PRINTTABLES Method to create cell arrays of data on drivers and options available.
%   Tables are for use in input validation of arguments to PRINT command.
%
%   See also PRINT

%   Copyright 1984-2015 The MathWorks, Inc.

if ~nargin
    pj = printjob();
end

options = localBuildOptions;
if nargout == 1
    % passing in an empty device table since we're not going to use it in
    % this context.
    options = postProcessPrinttables(pj, [], options);
    return; %shortcircuit - no need to do the rest 
end

device_table = getDefaultDeviceList();

%Set them in table as cell arrays of cell arrays for convenience of entry,
%now break them up into individual cell arrays for ease of use.
%devices = device_table(:, 1 );
%extensions = device_table(:, 2 );
%classes = device_table(:, 3 );
%colorDevs = device_table(:, 4 );
%destinations = device_table(:, 5 );
%descriptions = device_table(:, 6 );
%clipsupport = device_table(:, 7);
[options, devices, extensions, classes, colorDevs, destinations, descriptions, clipsupport] = ...
    postProcessPrinttables(pj, device_table, options);
end

function options = localBuildOptions 
%
% Set up print options table
%
options = { 
    'loose'
    'tiff'
    'append'
    'adobecset'
    'cmyk'
    'r'
    'noui'
    'opengl'
    'painters'
    'zbuffer'
    'tileall'
    'printframes'
    'pages'
    'fillpage' % only for figures
    'bestfit'  % only for figures
    'numcopies' %Undocumented, and only for simulink
    'DEBUG'    %Undocumented, prints out diagnostic information
};

if ispc
    platform_options = { 'v' };
    
else %must be unix
    platform_options = {};
end

options = [ options ; platform_options ];
end

% LocalWords:  shortcircuit ps psc EP epsc hpgl hgl ai mfile tif IM
% LocalWords:  tiffnocompression svg jpeg laserjet ljetplus ljet IId IIp
% LocalWords:  pxlmono cdjcolor cdjmono deskjet cdj Cse djet paintjet pjetxl
% LocalWords:  pjxl dnj bjc epson ep epsonc LQ ibmpro ibm Proprinter pcxmono
% LocalWords:  pcx pcxgray bmpmono pngmono pnggray pbm pbmraw pgm Graymap
% LocalWords:  pgmraw Pixmap ppmraw pkm Kmap pkmraw tifflzw tiffpack nc
% LocalWords:  pdfwrite winc metafile Devs
