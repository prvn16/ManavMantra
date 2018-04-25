function writeKey(fptr,keyname,value,comment,decimals)
%writeKey update or add new keyword into current HDU
%   writeKey(FPTR,KEYNAME,VALUE,COMMENT) adds a new record in the current
%   HDU, or updates it if it already exists.  COMMENT is optional.
%
%   writeKey(FPTR,KEYNAME,VALUE,COMMENT,DECIMALS) adds a new floating 
%   point keyword in the current HDU, or updates it if it already exists.  
%   You must use this syntax to write a keyword with imaginary components.
%   DECIMALS is ignored otherwise.
%
%   If a character VALUE exceeds 68 characters in length, the LONGWARN
%   convention is automatically employed.
%
%   This function corresponds to the "fits_write_key" (ffpky) and 
%   "fits_update_key" (ffuky) family of functions in the CFITSIO library C 
%   API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.writeKey(fptr,'mykey1','a char value','with a comment');
%       fits.writeKey(fptr,'mykey2',int32(1));
%       fits.writeKey(fptr,'mykey3',5+7*j,'with another comment');
%       fits.writeKey(fptr,'mykey4',4/3,'with yet another comment',2);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, readKey, deleteKey, readRecord.

%   Copyright 2011-2016 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'row'},'','KEYNAME');
if ~isHierarchKey(keyname)
    keyname = lower(keyname);
end
dtypes = {'char','logical','uint8','int16','int32','int64','single','double'};
validateattributes(value,dtypes,{'nonempty'},'','VALUE');

% Validate primary array restrictions.
switch(keyname)
    case {'extlevel','extname','extver','xtension'}
        n = matlab.io.fits.getHDUnum(fptr);
        if (n == 1)
            error(message('MATLAB:imagesci:fits:standardKeywordsPrimaryArrayViolation',upper(keyname)));
        end
end


% Validate string value restrictions.
pat = {'ptype\d','tdim\d*', 'tdisp\d*', 'tform\d*', 'ttype\d*','tunit\d*'};
for j = 1:numel(pat)
    if ~isempty(regexp(keyname,pat{j},'match'))
        error(message('MATLAB:imagesci:fits:standardKeywordsStringDatatypeViolation',upper(keyname)));
    end
end
switch(keyname)
    case {'author', 'bunit', 'date', 'date-obs', 'extname', 'instrume', ...
            'object','observer','origin','referenc','telescop','xtension'}
        if ~ischar(value)
            error(message('MATLAB:imagesci:fits:standardKeywordsStringDatatypeViolation',upper(keyname)));
        end
end

% Validate floating point restrictions.
pat = {'cdelt\d','crota\d*', 'crpix\d*', 'crval\d*', 'pscal\d*', ...
    'pzero\d*','tscal\d*','tzero\d*'};
for j = 1:numel(pat)
    if ~isempty(regexp(keyname,pat{j},'match'))
        if ~(isa(value,'single') || isa(value,'double'))
            error(message('MATLAB:imagesci:fits:standardKeywordsRealDatatypeViolation',upper(keyname)));
        end
    end
end
switch(keyname)
    case {'bscale', 'bzero', 'datamax', 'datamin', 'epoch', 'equinox'}
        if ~(isa(value,'double') || isa(value,'single'))
            error(message('MATLAB:imagesci:fits:standardKeywordsRealDatatypeViolation',upper(keyname)));
        end
end



% TNULLn keywords should NOT be floating point.
if (numel(keyname) > 5) && strncmpi(keyname,'tnull',5) && (isa(value,'double') || isa(value,'single'))
    value = int64(value);
end

switch nargin
    case 3
        comment = '';
        decimals = 0;
        
    case 4
        validateattributes(comment,{'char'},{'nonempty'},'','COMMENT');
        decimals = 0;
    case 5
        validateattributes(comment,{'char'},{'nonempty'},'','COMMENT');
        validateattributes(decimals,{'double'},{'integer'},'','DECIMALS');
end

fitsiolib('update_key',fptr,keyname,value,comment,decimals);

%--------------------------------------------------------------------------
function out = isHierarchKey(keyname)

% Any key greater than 8 characters is a HIERARCH key
out = length(keyname) > 8;
