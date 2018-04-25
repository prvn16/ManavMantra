function [ device_table ] = getDefaultDeviceList()
% List of all supported devices used for input validation.
%
%The first column contains the device name
%the second column contains the default filename extension, 
%the third column indicates what type of output device is employed, 
%the fourth indicates Monochrome or Color device, and
%the fifth is what do with output for that driver, P for print or X for export
%the sixth is a brief description of the device
%the seventh indicates whether or not the format supports copy to clipboard
%
%   Copyright 2012 The MathWorks, Inc.
%
device_table = [
    %Postscript device options
    {'ps'           'ps'   'PS'   'M'    'P'  'Postscript', 0}
    {'psc'          'ps'   'PS'   'C'    'P'  'Postscript Color', 0}
    {'ps2'          'ps'   'PS'   'M'    'P'  'Postscript Level 2', 0}
    {'ps2c'         'ps'   'PS'   'C'    'P'  ['Postscript' ...
					' Level 2 Color'], 0}
    {'psc2'         'ps'   'PS'   'C'    'P'  ['Postscript' ...
					' Level 2 Color'], 0}
    {'eps'          'eps'  'EP'   'M'    'X'  'EPS file', 0}
    {'epsc'         'eps'  'EP'   'C'    'X'  'EPS Color file', 0}
    {'eps2'         'eps'  'EP'   'M'    'X'  'EPS Level 2 file', 0}
    {'eps2c'        'eps'  'EP'   'C'    'X'  '', 0}
    {'epsc2'        'eps'  'EP'   'C'    'X'  'EPS Level 2 Color file', 0}
    
    %Other built-in device options
    {'hpgl'              'hgl'  'BI'   'C'    'P'  'HPGL', 0}
    {'ill'               'ai'   'BI'   'C'    'X'  'Adobe Illustrator file', 0}
    {'mfile'             ''     'BI'   'C'    'X'  '', 0}
    {'tiff'              'tif'  'IM'   'C'    'X'  'TIFF image', 0}
    {'tiffnocompression' 'tif'  'IM'   'C'    'X'  'TIFF no compression image', 0}
    {'bmp'               'bmp'  'IM'   'C'    'X'  '', 0}
    {'hdf'               'hdf'  'IM'   'C'    'X'  '', 0}
    {'png'               'png'  'IM'   'C'    'X'  'Portable Network Graphics file', 0}
    {'svg'               'svg'  'QT'   'C'    'X'  'Scalable Vector Graphics file', 0}
 ];
if ~feature('ShowFigureWindows')
device_table = [ device_table ; 
    {'jpeg'              'jpg'  'GS'   'C'    'X'  'JPEG image', 0}
];
else
device_table = [ device_table ; 
    {'jpeg'              'jpg'  'IM'   'C'    'X'  'JPEG image', 0}
];
end

%GhostScript device options
device_table = [ device_table ; 
    {'laserjet'     'jet'  'GS'   'M'    'P'  'HP LaserJet', 0}
    {'ljetplus'     'jet'  'GS'   'M'    'P'  'HP LaserJet Plus', 0}
    {'ljet2p'       'jet'  'GS'   'M'    'P'  'HP LaserJet IId/IIp', 0}
    {'ljet3'        'jet'  'GS'   'M'    'P'  'HP LaserJet III', 0}
    {'ljet4'        'jet'  'GS'   'M'    'P'  'HP LaserJet 4/5L/5P', 0}
    {'pxlmono'      'jet'  'GS'   'M'    'P'  'HP LaserJet 5/6', 0}
    {'cdjcolor'     'jet'  'GS'   'C'    'P'  ['HP DeskJet 500C 24bit' ...
	 'color'], 0}
    {'cdjmono'      'jet'  'GS'   'M'    'P'  'HP DeskJet 500C b+w', 0}
    {'deskjet'      'jet'  'GS'   'M'    'P'  'HP DeskJet/DeskJet Plus', 0}
    {'cdj550'       'jet'  'GS'   'C'    'P'  ['HP DeskJet 550C/' ...
					'560C/660C/660Cse'], 0}
    {'djet500'      'jet'  'GS'   'M'    'P'  'HP DeskJet 500C/540C', 0}
    {'cdj500'       'jet'  'GS'   'C'    'P'  'HP DeskJet 500C', 0}
    {'paintjet'     'jet'  'GS'   'C'    'P'  'HP PaintJet', 0}
    {'pjetxl'       'jet'  'GS'   'C'    'P'  'HP PaintJet XL', 0}
    {'pjxl'         'jet'  'GS'   'C'    'P'  'HP PaintJet XL (alternate)', 0}
    {'pjxl300'      'jet'  'GS'   'C'    'P'  'HP PaintJet XL300', 0}
    {'dnj650c'      'jet'  'GS'   'C'    'P'  'HP DesignJet 650C', 0}
    {'bj10e'        'jet'  'GS'   'M'    'P'  'Canon BubbleJet 10e', 0}
    {'bj200'        'jet'  'GS'   'C'    'P'  'Canon BubbleJet 200', 0}
    {'bjc600'       'jet'  'GS'   'C'    'P'  'Canon Color BubbleJet 600/4000/70', 0}
    {'bjc800'       'jet'  'GS'   'C'    'P'  'Canon Color BubbleJet 800', 0}
    {'epson'        'ep'   'GS'   'M'    'P'  'Epson', 0}
    {'epsonc'       'ep'   'GS'   'C'    'P'  'Epson LQ-2550', 0}
    {'eps9high'     'ep'   'GS'   'M'    'P'  'Epson 9-pin', 0}
    {'ibmpro'       'ibm'  'GS'   'M'    'P'  'IBM Proprinter', 0}
    {'pcxmono'      'pcx'  'GS'   'M'    'X'  '', 0}
    {'pcxgray'      'pcx'  'GS'   'C'    'X'  '', 0}
    {'pcx16'        'pcx'  'GS'   'C'    'X'  '', 0}
    {'pcx256'       'pcx'  'GS'   'C'    'X'  '', 0}
    {'pcx24b'       'pcx'  'GS'   'C'    'X'  'Paintbrush 24-bit file', 0}
    {'bmpmono'      'bmp'  'GS'   'M'    'X'  '', 0}
    {'bmp16m'       'bmp'  'GS'   'C'    'X'  '', 0}
    {'bmp256'       'bmp'  'GS'   'C'    'X'  '', 0}
    {'pngmono'      'png'  'GS'   'M'    'X'  '', 0}
    {'pnggray'      'png'  'GS'   'C'    'X'  '', 0}
    {'png16m'       'png'  'GS'   'C'    'X'  '', 0}
    {'png256'       'png'  'GS'   'C'    'X'  '', 0}
    {'pbm'          'pbm'  'GS'   'C'    'X'  'Portable Bitmap file', 0}
    {'pbmraw'       'pbm'  'GS'   'C'    'X'  '', 0}
    {'pgm'          'pgm'  'GS'   'C'    'X'  'Portable Graymap file', 0}
    {'pgmraw'       'pgm'  'GS'   'C'    'X'  '', 0}
    {'ppm'          'ppm'  'GS'   'C'    'X'  'Portable Pixmap file', 0}
    {'ppmraw'       'ppm'  'GS'   'C'    'X'  '', 0}
    {'pkm'          'pkm'  'GS'   'C'    'X'  'Portable inKmap file', 0}
    {'pkmraw'       'pkm'  'GS'   'C'    'X'  '', 0}
    {'tifflzw'      'tif'  'GS'   'C'    'X'  '', 0}
    {'tiffpack'     'tif'  'GS'   'C'    'X'  '', 0} 
    {'tiff24nc'     'tif'  'GS'   'C'    'X'  '', 0}
    {'pdfwrite'     'pdf'  'GS'   'C'    'X'  'Portable Document Format', 0} 
];

if ispc
    platform_device_table = [
        {'win'      ''      'MW'    'M'    'P'  'Windows', 0}
        {'winc'     ''      'MW'    'C'    'P'  'Color Windows', 0}
        {'meta'     'emf'   'MW'    'C'    'X'  'Enhanced metafile', 1}
        {'bitmap'   'bmp'   'MW'    'C'    'X'  'Bitmap file', 1}
        {'setup'    ''      'MW'    'M'    ''   '', 0}
    ];
    
else %Unix
    platform_device_table = ...
        {'bitmap' 	'bmp'   'QT'    'C'    'X'  'Bitmap file', 0};
end

device_table = [ platform_device_table ; device_table ];
end

