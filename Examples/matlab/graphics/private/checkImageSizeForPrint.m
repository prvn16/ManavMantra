function tooBig = checkImageSizeForPrint(dpi, ~, width, height)
    % CHECKIMAGESIZEFORPRINT Checks to see if the image that will be
    % produced in the print path is within certain bounds. This
    % undocumented helper function is for internal use.

    % This function is called during the print path.  See usage in
    % alternatePrintPath.m
    
    % Predict how big the image data will be based on the requested
    % resolution and image size.  Returns true if the image size is greater
    % than the limit in imwrite.
    
    % Copyright 2013-2017 The MathWorks, Inc.

    tooBig = false;
        
    expectedWidth = width*dpi;
    expectedHeight = height*dpi;

    maxInt32 = double(intmax('int32'));
    
    % If one of the dimensions is larger than maxInt32, or if the number of
    % elements in the data (width*height*4 for RGBA data) is larger than
    % maxInt32, then we won't be able to write outvfput through
    % HGRasterOutputHelper->generateOutput (NIO buffer size limitation)
    % It's better to exit early g1363602
    %
    % This case also cover imwrite() limitation as it allowed maximum
    % buffer size of unsigned int 32-bit RGB data.
    
    if expectedWidth > maxInt32 || expectedHeight > maxInt32
         tooBig = true;
    elseif ((expectedWidth * expectedHeight * 4) > maxInt32)
         tooBig = true;
    end
end
