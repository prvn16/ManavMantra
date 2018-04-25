classdef (Sealed, Abstract) ImageUtils < handle
    % IMAGEUTILS - Collection of functions for converting image between
    %   different data types.
    %
    % Copyright 2017 The MathWorks, Inc.

    methods(Static)
        function imageString = getImageDataURIFromBytes(bytes, imageFormat)
            bais = java.io.ByteArrayInputStream(bytes);
            bufferedImage = javax.imageio.ImageIO.read(bais);
            imageString = appdesigner.internal.application.ImageUtils.getImageDataURIFromBufferedImage(bufferedImage, imageFormat);
        end

        function imageString = getImageDataURIFromCDataRGB(cdata, imageFormat)
            bImage = appdesigner.internal.application.ImageUtils.getBufferedImageFromCDataRGB(cdata);
            imageString = appdesigner.internal.application.ImageUtils.getImageDataURIFromBufferedImage(bImage, imageFormat);
        end
     
        function imageString = getImageDataURIFromFile(imagePath)
            [bytes, imageFormat] = appdesigner.internal.application.ImageUtils.getBytesFromImageFile(imagePath);
            imageString = appdesigner.internal.application.ImageUtils.getImageDataURIFromBytes(bytes, imageFormat);
        end

        function [bytes, imageFormat] = getBytesFromImageFile(imagePath)
            [~,~,imageFormat] = fileparts(imagePath);
            imageFormat = strrep(imageFormat,'.','');
            
            % Using fread instead of java ImageIO to support reading all
            % of the images of a gif file and not just the first one.
            fid = fopen(imagePath, 'r');
            bytes = fread(fid, 'uint8=>uint8');
            fclose(fid);
        end

        function bytes = getBytesFromCDataRGB(cdata, imageFormat)
            bImage = appdesigner.internal.application.ImageUtils.getBufferedImageFromCDataRGB(cdata);
            bytes = appdesigner.internal.application.ImageUtils.getBytesFromBufferedImage(bImage, imageFormat);
        end

        function createImageFileFromBytes(imagePath, bytes)
            
            % Using fwrite instead of java ImageIO to support writting all
            % of the images of a gif file and not just the first one.
            fid = fopen(imagePath, 'w+');
            fwrite(fid, bytes);
            fclose(fid);
        end
    end

    methods (Static, Access = private)
        function iconString = getImageDataURIFromBufferedImage(bImage, imageFormat)
            baos = java.io.ByteArrayOutputStream;
            javax.imageio.ImageIO.write(bImage, imageFormat, baos);
            byteArray = baos.toByteArray();
            baos.flush();
            baos.close()
            encoder = org.apache.commons.codec.binary.Base64;
            iconString = sprintf('data:image/%s;base64,%s',imageFormat, (char(encoder.encode(byteArray)))');
        end

        function bImage = getBufferedImageFromCDataRGB(cdata)
            img = im2java(cdata);
            bImage = java.awt.image.BufferedImage(img.getWidth(), img.getHeight(), java.awt.image.BufferedImage.TYPE_INT_ARGB);
            bGr = bImage.createGraphics();
            bGr.drawImage(img, 0, 0, []);
            bGr.dispose();
        end
        
        function bytes = getBytesFromBufferedImage(bImage, imageFormat)
            baos = java.io.ByteArrayOutputStream;
            javax.imageio.ImageIO.write(bImage, imageFormat, baos);
            byteArray = baos.toByteArray();
            baos.flush();
            baos.close()
            bytes = (typecast(byteArray, 'uint8'))';
        end
    end
end