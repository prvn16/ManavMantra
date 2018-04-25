classdef DICOMThumbnails < iptui.internal.imageBrowser.BrowserThumbnails
    
    % Copyright 2016-2017 The MathWorks, Inc.

    properties
        Files;
    end
    
    properties (SetAccess = protected)
        NumberOfThumbnails = 0;
        EmptyImagePlaceholder
    end
    
    properties (Access = private)
        FullVolume = [];
        Colormap = [];
        NumberOfThumbnailsLoaded = 0;
    end
    
    events
        CountChanged
        EmptyFileRead
        FailedFileRead
        FullVolumeLoad
        SuccessfulFileRead
    end
    
    methods
        function thumbs = DICOMThumbnails(hParent)
            thumbNailSize = images.internal.app.dicom.thumbnailSize();
            thumbs@iptui.internal.imageBrowser.BrowserThumbnails(hParent, thumbNailSize);
            thumbs.CoalescePeriod = 0.1;
            
            thumbs.EmptyImagePlaceholder = imresize(imread(fullfile(matlabroot, 'toolbox/images/icons/', 'EmptyPlaceHolderImage_72.png')), thumbNailSize, 'nearest');
        end
        
        function set.Files(thumbs, files_)
            assert(isstring(files_) || ischar(files_) || iscellstr(files_))
            
            thumbs.clearOldState()
            thumbs.Files = convertToString(files_);
            thumbs.countThumbnails();
            thumbs.refreshThumbnails();
        end
        
        function [thumbnail, userdata] = createThumbnail(thumbs, imageNum)
            % Additional metadata could be embedded in the thumbnail's
            % userdata, but this isn't needed.
            userdata = [];
            fullImage = thumbs.readFullImage(imageNum);
            
            if size(fullImage,3)~=1 && size(fullImage,3)~=3
                % Hyperspectral or CMYK imagery...
                fullImage = fullImage(:,:,1);
            end
            
            if ~isempty(thumbs.Colormap) && size(fullImage, 3) == 1
                fullImage = ind2rgb(fullImage, thumbs.Colormap);
            end
            
            thumbnail = thumbs.resizeToThumbnail(fullImage);
        end
        
        function desc = getOneLineDescription(thumbs, imageNum)
            desc = thumbs.Files(imageNum);
        end
        
        function im = readFullImage(thumbs, imageNum)
            origWarnState = warning();
            oc = onCleanup(@() warning(origWarnState));
            images.internal.app.dicom.disableDICOMWarnings()
            
            if (imageNum > 1) && (size(thumbs.FullVolume,4) > 1)
                im = thumbs.loadImageFromCachedVolume(imageNum);
            else
                if ~isempty(thumbs.FullVolume)
                    % Used when exporting from browser.
                    im = thumbs.loadImageFromCachedVolume(imageNum);
                else
                    % Used when building first thumbnail.
                    im = thumbs.loadImageFromFile(imageNum);
                end
            end
        end
        
        function exportToWorkSpace(thumbs, varargin)
            % Overload BrowserThumbnail method to enable colormap output.
            im = thumbs.readFullImage(thumbs.CurrentSelection(1));
            
            if ~isempty(thumbs.Colormap)
                h = export2wsdlg({getString(message('images:DICOMBrowser:exportFrameLabel')), ...
                    getString(message('images:DICOMBrowser:exportColormapLabel'))}, ...
                    {'im', 'map'}, {im, thumbs.Colormap});
            else
                h = export2wsdlg({[getString(message('images:commonUIString:saveAs')) ':']},{'im'}, {im});
            end
            movegui(h,'center');
        end
    end
    
    methods (Access = private)

        function clearOldState(thumbs)
            thumbs.FullVolume = [];
            thumbs.Colormap = [];
            thumbs.NumberOfThumbnailsLoaded = 0;
        end
        
        function countThumbnails(thumbs)
            % NOTE: This function assumes that only volume/series is stored
            % in thumbs.Files.
            
            origWarnState = warning();
            oc = onCleanup(@() warning(origWarnState));
            images.internal.app.dicom.disableDICOMWarnings()
            
            if isempty(thumbs.Files)
                thumbs.NumberOfThumbnails = 0; 
            elseif numel(thumbs.Files) > 1
                % Volume spread across files...
                thumbs.NumberOfThumbnails = numel(thumbs.Files);  
            else
                % Single image or full volume in one file...
                try
                    file = images.internal.dicom.DICOMFile(thumbs.Files);
                    numFrames = file.getAttribute(40,8);  % (0028,0008) NumberOfFrames
                    if ~isempty(numFrames)
                        thumbs.NumberOfThumbnails = numFrames;
                    else
                        thumbs.NumberOfThumbnails = 1; 
                    end
                catch
                    thumbs.NumberOfThumbnails = 1; 
                end
            end
        end
        
        function im = loadImageFromFile(thumbs, imageNum)
            try
                filename = thumbs.Files(imageNum);
                [im, map] = dicomread(filename);
                thumbs.Colormap = map;
                
                if isempty(thumbs.FullVolume)
                    if (size(im,4) > 1)
                        thumbs.FullVolume = im;
                        im = squeeze(thumbs.FullVolume(:, :, :, imageNum));
                        
                        file = images.internal.dicom.DICOMFile(filename);
                        spatialDetails = images.internal.dicom.getSpatialDetailsForMultiframe(file);
                        sliceDim = images.internal.dicom.findSortDimension(spatialDetails.PatientPositions);
                        
                        evtData = images.internal.app.dicom.LoadVolumeEventData(thumbs.FullVolume, ...
                            spatialDetails, sliceDim, thumbs.Colormap);
                        notify(thumbs, 'FullVolumeLoad', evtData)
                    end
                end
                
                if isempty(im)
                    im = thumbs.EmptyImagePlaceholder;
                    notify(thumbs, 'EmptyFileRead')
                else 
                    notify(thumbs, 'SuccessfulFileRead')
                end
            catch
                im = thumbs.CorruptedImagePlaceHolder;
                thumbs.Colormap = [];
                notify(thumbs, 'FailedFileRead')
            end
        end
        
        function im = loadImageFromCachedVolume(thumbs, imageNum)
            try
                im = squeeze(thumbs.FullVolume(:, :, :, imageNum));
            catch
                im = thumbs.CorruptedImagePlaceHolder;
                return
            end
        end
    end
end


function out = convertToString(in)

if isstring(in)
    out = in;
else
    out = string(in);
end
end
