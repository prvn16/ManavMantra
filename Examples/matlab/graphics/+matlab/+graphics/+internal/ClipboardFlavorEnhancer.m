classdef ClipboardFlavorEnhancer < handle
    % This is an undocumented class and may be removed in a future release.
    
    % Copyright 2013 The MathWorks, Inc.
    
    % workaround for g899473
    % In Java 7, on mac, posting images to clipboard does not work 
    % without this fix. Any MATLAB code wishing to support copying 
    % images to clipboard through Java needs to instantiate this class.
    %   
    % Creating an object of this class sets the correct native formats
    % for imageFlavor.
    % The destructor resets the native formats back to original.
    %   
    % This class should be removed when Oracle fixes the bug in Java.

    
    properties
        prevImageFormats = [];
        sfm = [];
    end
    
    methods
        function obj=ClipboardFlavorEnhancer()
            if (ismac && (usejava('awt') == 1))
                obj.sfm = java.awt.datatransfer.SystemFlavorMap.getDefaultFlavorMap();
                obj.prevImageFormats = obj.sfm.getNativesForFlavor(java.awt.datatransfer.DataFlavor.imageFlavor);
                if(com.mathworks.util.PlatformInfo.getVersion() > com.mathworks.util.PlatformInfo.VERSION_16)   
                    obj.sfm.setNativesForFlavor(java.awt.datatransfer.DataFlavor.imageFlavor, ('TIFF'));
                end
            end
        end
        function delete(obj)
            if(~isempty(obj.sfm) && ~isempty(obj.prevImageFormats))
                obj.sfm.setNativesForFlavor(java.awt.datatransfer.DataFlavor.imageFlavor, cell(obj.prevImageFormats.toArray()));
            end
        end
    end
    
end

