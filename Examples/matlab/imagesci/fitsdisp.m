function fitsdisp(filename,varargin)
%FITSDISP Display FITS metadata.
%   FITSDISP(FILE) displays metadata for all HDUs found in the FITS file.
%   
%   FITSDISP(...,'PARAM','VALUE') displays metadata according to parameter 
%   value pairs.
%
%       Parameter name   Value
%       --------------   -----
%       'Index'          A positive scalar value or vector specifying the
%                        HDUs.
%
%       'Mode'           'standard' - display standard keywords (default)
%                        'min'      - display only HDU types and sizes
%                        'full'     - display all HDU keywords
%
%   Please read the file cfitsiocopyright.txt for more information.
%
%   Example:  Display metadata in the 2nd HDU in tst0012.fits.
%        fitsdisp('tst0012.fits','Index',2);
%
%   Example:  Display the metadata in the 1st, 3rd, and 5th HDUs in a file.
%        fitsdisp('tst0012.fits','Index',[1 3 5]);
%
%   Example:  Display all metadata in the 5th HDU in a file
%        fitsdisp('tst0012.fits','Index',5,'Mode','full');
%
%   See also:  matlab.io.fits

%   Copyright 2011-2017 The MathWorks, Inc.

p = inputParser;

p.addRequired('filename', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));
p.addParamValue('Mode','standard', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','MODE'));
p.addParamValue('Index',[], ...
    @(x) validateattributes(x,{'double'},{'positive','row','integer'},'','Index'));


p.parse(filename,varargin{:});
mode = validatestring(p.Results.Mode,{'standard','min','full'});
hdus = p.Results.Index;

import matlab.io.*

try
    fptr = fits.openDiskFile(filename);
catch ME
    try
        [~, ~, hasExtSyntax] = matlab.io.fits.internal.resolveExtendedFileName(filename);
    catch
        throw(ME);
    end
    
    if hasExtSyntax
        error(message('MATLAB:imagesci:fitsdisp:fileOpenExtSyntax'));
    end
end

try
    display_hdus(fptr,mode,hdus);
catch me
    fits.closeFile(fptr);
    rethrow(me);
end

fits.closeFile(fptr);

%--------------------------------------------------------------------------
function display_hdus(fptr,mode,hdus)

import matlab.io.*

if isempty(hdus)
    n = fits.getNumHDUs(fptr);
    hdus = 1:n;
end

switch(mode)
    case 'standard'
        display_hdu_standard(fptr,hdus);
    case 'min'
        display_hdu_min(fptr,hdus);
    case 'full'
        display_hdu_full(fptr,hdus);
end


%--------------------------------------------------------------------------
function display_hdu_full(fptr,hdus)

import matlab.io.*

for j = hdus
    
    fits.movAbsHDU(fptr,j);
        
    fprintf('\n');
    fprintf('%s:  %d ', getString(message('MATLAB:imagesci:fits:HDU')),j);
    if ( j == 1)
        fprintf('(%s)', getString(message('MATLAB:imagesci:fits:primaryHDU')));
    end
    fprintf('\n');
    
    numrecs = fits.getHdrSpace(fptr);   
    for k = 1:numrecs
        card = fits.readRecord(fptr,k);
        fprintf('\t%s\n', card);
    end
    
end



%--------------------------------------------------------------------------
function display_hdu_standard(fptr,hdus)

import matlab.io.*

for j = hdus
    
    fits.movAbsHDU(fptr,j);
        
    fprintf('\n');
    fprintf('%s:  %d ', getString(message('MATLAB:imagesci:fits:HDU')),j);
    if ( j == 1)
        fprintf('(%s)', getString(message('MATLAB:imagesci:fits:primaryHDU')));
    end
    fprintf('\n');
    
    numrecs = fits.getHdrSpace(fptr);
    for k = 1:numrecs
        
        card = fits.readRecord(fptr,k);
        if strncmp(card,'COMMENT',6)
            fprintf('\t%s\n', card);
            continue
        end
        
        tokens = regexp(card,'=','split');
        name = deblank(tokens{1});
        
        switch(name)
            case { 'AUTHOR','BITPIX', ...
                    'NMATRIX','BLANK', ...
                    'BSCALE','BZERO','BUNIT','COMMENT', ...
                    'DATAMAX','DATAMIN', ...
                    'DATE','DATE-OBS','END','EPOCH', ...
                    'EQUINOX','EXTEND','EXTLEVEL','EXTNAME','EXTVER', ...
                    'GCOUNT','GROUPS','HISTORY','INSTRUME','NAXIS',...
                    'OBJECT','OBSERVER','ORIGIN','PCOUNT','REFERENCE', ...
                    'SIMPLE','TELESCOP','TFIELDS','THEAP','XTENSION'}
                fprintf('\t%s\n', card);
                
            otherwise
                keys4 = {'TDIM','TDISP'};
                keys5 = {'NAXIS','CTYPE','CRVAL','CDELT','CRPIX', ...
                    'CROTA','PSCAL','PTYPE','PZERO','TBCOL', ...
                    'TFORM','TNULL','TSCAL','TTYPE','TUNIT', ...
                    'TZERO'};
                if any(strncmp(name,keys4,4)) || any(strncmp(name,keys5,5))
                    fprintf('\t%s\n', card);
                end
                              
        end
        
    end
end



%--------------------------------------------------------------------------
function display_hdu_min(fptr,hdus)

import matlab.io.*

fprintf('\n');
for j = hdus
    
    hdu_type = fits.movAbsHDU(fptr,j);
    
    switch(hdu_type)
        case 'IMAGE_HDU'
            img_size = fits.getImgSize(fptr);
            img_type = fits.getImgType(fptr);
            size_str = sprintf('%d ', img_size);
            fprintf('%s %d:  %s %s [ %s]\n',getString(message('MATLAB:imagesci:fits:HDU')),  j, img_type, hdu_type, size_str);
            
        case {'ASCII_TBL','BINARY_TBL'}
            numrows = fits.getNumRows(fptr);
            numcols = fits.getNumCols(fptr);
            fprintf('%s %d:  %s [ %d %d ]\n', getString(message('MATLAB:imagesci:fits:HDU')), j, hdu_type, numrows, numcols);
            
    end
    
end
        
fprintf('\n');
