% Copyright 2014 The MathWorks, Inc.

classdef ImageLoaderRGB
    
    properties
        warnAboutDeletion
    end

    methods
        
        function self = ImageLoaderRGB(warnTF)
            self.warnAboutDeletion = warnTF;
        end
        
        function imgData = loadImageFromFile(self,varargin)
            
            % If the class is set to warn about deleting data, show the
            % warning dialog.
            if self.warnAboutDeletion
                user_canceled_import = self.showImportingDataWillCauseDataLossDlg();
            else
                user_canceled_import = false;
            end
            
            if ~user_canceled_import
                filename = imgetfile();
                if ~isempty(filename)
                    imgData = imread(filename);
                    if ~iptui.internal.ImageLoaderRGB.isValidRGBImage(imgData)
                        hdlg = errordlg(getString(message('images:colorSegmentor:nonTruecolorErrorDlgText')),...
                            getString(message('images:colorSegmentor:nonTruecolorErrorDlgTitle')),'modal');
                        % We need error dlg to be blocking, otherwise
                        % loadImageFromFile() is invoked before dlg
                        % finishes setting itself up and becomes modal.
                        uiwait(hdlg);
                        % Drawnow is necessary so that imgetfile dialog will
                        % enforce modality in next call to imgetfile that
                        % arrises from recursion.
                        drawnow
                        imgData = self.loadImageFromFile();
                        return;
                    end
                else
                    imgData = [];
                end
            else
                imgData = [];
            end
        end
    end
    
    methods (Static)
        
        function TF = isValidRGBImage(im)
            
           supportedDataType = isa(im,'uint8') || isa(im,'uint16') || isa(im,'double');
           supportedAttributes = isreal(im) && all(isfinite(im(:))) && ~issparse(im);
           supportedDimensionality = (ndims(im) == 3) && size(im,3) == 3;
           
           TF = supportedDataType && supportedAttributes && supportedDimensionality;
            
        end
        
        % Method is used by both import from file and import from workspace
        % callbacks.
        function user_canceled = showImportingDataWillCauseDataLossDlg
            
            user_canceled = false;

            buttonName = questdlg(getString(message('images:colorSegmentor:loadingNewImageMessage')),...
                getString(message('images:colorSegmentor:loadingNewImageTitle')),...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

            if ~strcmp(buttonName,getString(message('images:commonUIString:yes')))
                user_canceled = true;
            end
                
        end
                
    end
    
end
