% Copyright 2014 The MathWorks, Inc.

classdef ImageLoaderBW
    
    properties
        warnAboutDeletion
    end

    methods
        
        function self = ImageLoaderBW(warnTF)
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
                    if ~iptui.internal.ImageLoaderBW.isValidBWImage(imgData)
                        hdlg = errordlg(getString(message('images:ImageLoader:errorDialogText')),...
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
        
        function imgData = loadImageFromWorkspace(self,varargin)
            
            if self.warnAboutDeletion
                user_canceled_import = self.showImportingDataWillCauseDataLossDlg();
            else
                user_canceled_import = false;
            end
            
            if ~user_canceled_import
                imgData = iptui.internal.imgetvar([],3); %Binary selections only
            else
                imgData = [];
            end
            
        end
    end
    
    methods (Static)
        
        function TF = isValidBWImage(im)
            
           supportedDataType = isa(im,'logical');
           supportedAttributes = isreal(im) && all(isfinite(im(:))) && ~issparse(im);
           supportedDimensionality = ismatrix(im);
           
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
