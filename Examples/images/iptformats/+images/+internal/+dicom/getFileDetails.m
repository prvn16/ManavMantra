function details = getFileDetails(filename, verifyIsDICOM)

% Copyright 2006-2017 The MathWorks, Inc.

% Get the fully qualified path to the file.
fid = fopen(filename);
if fid < 0
    augmentedFilename = findActualFilename(filename);
    
    if (~isempty(augmentedFilename))
        fid = fopen(augmentedFilename);
    else
        error(message('images:dicomread:fileNotFound', filename))
    end
end

details.name = fopen(fid);
if (verifyIsDICOM)
    details.isdicom = images.internal.dicom.isdicomFromFID(fid);
end
fseek(fid, 0, 'eof');
details.bytes = ftell(fid);
fclose(fid);

end


function fullFilename = findActualFilename(originalFilename)

if (exist(originalFilename, 'file'))
    
    fullFilename = originalFilename;
    
elseif (exist([originalFilename '.dcm'], 'file'))
    
    fullFilename = [originalFilename '.dcm'];
    
elseif (exist([originalFilename '.dic'], 'file'))
    
    fullFilename = [originalFilename '.dic'];
    
elseif (exist([originalFilename '.dicom'], 'file'))
    
    fullFilename = [originalFilename '.dicom'];
    
elseif (exist([originalFilename '.img'], 'file'))
    
    fullFilename = [originalFilename '.img'];
    
else
    
    fullFilename = '';
    return
    
end
end
