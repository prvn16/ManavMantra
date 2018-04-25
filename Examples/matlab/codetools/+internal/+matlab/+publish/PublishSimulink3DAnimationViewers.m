classdef PublishSimulink3DAnimationViewers < internal.matlab.publish.PublishFigures
% Copyright 1984-2017 The MathWorks, Inc.

    methods
        function obj = PublishSimulink3DAnimationViewers(options)
            obj = obj@internal.matlab.publish.PublishFigures(options);
        end
    end
    
    methods(Static)
        function imgFilename = snapFigure(f,imgNoExt,opts)                        
            % Nail down the image format.
            if isempty(opts.imageFormat)
                imageFormat = internal.matlab.publish.getDefaultImageFormat(opts.format,'imwrite');
            else
                imageFormat = opts.imageFormat;
            end
            
            % Nail down the image filename.
            imgFilename = internal.matlab.publish.getPrintOutputFilename(imgNoExt,imageFormat);

            % Call vr.figure.snap to get the image data.
            myFrame.cdata = snap(vr.figure.fromHGFigure(f));
            myFrame.colormap = [];

            % Finally, write out the image file.
            internal.matlab.publish.resizeIfNecessary(imgFilename,imageFormat,opts.maxWidth,opts.maxHeight,myFrame);
           
        end
    end
end
