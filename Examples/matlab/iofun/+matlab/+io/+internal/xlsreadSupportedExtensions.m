function ext = xlsreadSupportedExtensions(List)
    % xlsreadSupportedExtensions Lists extensions supported by xlsread
    %    ext = xlsreadSupportedExtensions() return a cell array of strings,
    %    ext, of all of the file extensions that xlsread supports.  The
    %    extensions include a period as the fist character. xlsread supports
    %    most of the file extensions that Microsoft Excel generates and uses.
    %    This function is a utility to single source the explicit list
    %    supported by xlsread.
    %
    %    ext = xlsreadSupportedExtensions('SupportedOfficeOpenXMLOnly') returns
    %    a list of all the Office Open XML file extensions that xlsread
    %    supports.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.
   
    %   Copyright 2012 The MathWorks, Inc.
    %=============================================================================

    supportedOOXMLExts = {'.xlsx','.xlsm','.xltx','.xltm'};
    classicExt = {'.xls'};
    comSupportedOOXMLonly = {'.xlsb'};
    
    if nargin == 0
        List = 'all';
    end
    switch lower(List)
        case 'all'
            ext = [classicExt supportedOOXMLExts comSupportedOOXMLonly];        
        case lower('SupportedOfficeOpenXMLOnly')
            ext = supportedOOXMLExts;        
        otherwise
            error(message('MATLAB:xlsread:invalidList', List));
    end

end