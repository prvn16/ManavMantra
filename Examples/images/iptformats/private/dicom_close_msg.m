function file = dicom_close_msg(file)
%DICOM_CLOSE_MSG  Close a DICOM message.
%   FILE = DICOM_CLOSE_MSG(FILE) closes the DICOM message pointed to in
%   FILE.FID.  The returned value, FILE, is the updated file structure.

%   Copyright 1993-2010 The MathWorks, Inc.

if (file.FID > 0)
    
    result = fclose(file.FID);
    
    if (result == -1)

      error(message('images:dicom_close_msg:unableToClose', file.Filename, ferror( file.FID )))
        
    end
    
else

    error(message('images:dicom_close_msg:invalidFID'))
    
end
