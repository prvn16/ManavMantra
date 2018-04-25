classdef (Sealed, Abstract) IconUtils < handle
    %ICONUTILS utility function can be used to convert images to a DataURI
    
    methods(Static)
        
        function iconString = getImageDataURIFromRasterFile(file, fileType)
            bImage = javax.imageio.ImageIO.read(java.io.File(file));
            iconString = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromBufferedImage(bImage, fileType);
        end
        
        function iconString = getImageDataURIFromCDataRGB(cdata)
            img = im2java(cdata);
            bImage = java.awt.image.BufferedImage(img.getWidth(), img.getHeight(), java.awt.image.BufferedImage.TYPE_INT_ARGB);
            bGr = bImage.createGraphics();
            bGr.drawImage(img, 0, 0, []);
            bGr.dispose();
            iconString = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromBufferedImage(bImage, 'png');
        end
        
        function iconString = getImageDataURIFromSVGFile(file)
            jFile = java.io.File(file);
            byteArray = java.nio.file.Files.readAllBytes(jFile.toPath());
            encoder = org.apache.commons.codec.binary.Base64;
            iconString = sprintf('data:image/svg+xml;base64,%s', (char(encoder.encode(byteArray)))');
        end
        
        function iconString = getImageDataURIFromGIFFile(file)
            jFile = java.io.File(file);
            byteArray = java.nio.file.Files.readAllBytes(jFile.toPath());
            encoder = org.apache.commons.codec.binary.Base64;
            iconString = sprintf('data:image/gif;base64,%s', (char(encoder.encode(byteArray)))');
        end
        
        function iconString = getImageDataURIFromBufferedImage(bImage, fileType)
            baos = java.io.ByteArrayOutputStream;
            javax.imageio.ImageIO.write(bImage, fileType, baos);
            byteArray = baos.toByteArray();
            baos.flush();
            baos.close()
            encoder = org.apache.commons.codec.binary.Base64;
            iconString = sprintf('data:image/%s;base64,%s',fileType, (char(encoder.encode(byteArray)))');
        end
        
        function out = getIconForView(icon,iconType)
            out = 'error';
            try
                switch (iconType)
                    case 'preset'
                        out = icon;
                        if isempty(out)
                            out = 'none';
                        end                        
                    case 'file'
                        [~, ~, ext] = fileparts(icon);
                        fileType = lower(ext(2:end));
                        switch(fileType)
                            case {'png','jpg'}
                                out = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromRasterFile(icon, fileType);
                            case 'svg'
                                out = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromSVGFile(icon);
                            case 'gif'
                                out = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromGIFFile(icon);
                        end
                    case 'cdata'
                        out = matlab.ui.internal.dialog.IconUtils.getImageDataURIFromCDataRGB(icon);
                    otherwise
                        out = 'error';
                end
            catch E
                warning ('MATLAB:DialogController:UnexpectedErrorInIcon', 'Error occured when parsing the icon file:\n%s', E.getReport());
            end
        end
    end
    
end

