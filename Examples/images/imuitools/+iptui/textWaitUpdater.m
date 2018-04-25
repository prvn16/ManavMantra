% This undocumented class may be removed in a future release.

%   obj = textWaitUpdater(introFormatter,statusFormatter,totalImages,processedImages)
%
%   We first print out the INTROFORMATTER, which should contain a %d
%   symbol to receive the total number of elements to process.  So a typical
%   value for introFormatter might be:
%
%       'Block Processing %d blocks.'
%
%   Next we print one "dot" per second for 10 seconds before each time
%   update.  The STATUSFORMATTER should contain 2 %d symbols which receive
%   the completed and total elements respectively.  So a typical value for
%   statusFormatter might be:
%
%       'Completed %d of %d blocks.'
%
%   The UPDATE(PROCESSED_IMAGES) method will update the wait updater.
%   PROCESSED_IMAGES should be the total number of images that are
%   completed, including any that may have been processed before the
%   waitbar was created (the PROCESSEDIMAGES from the constructor).  If the
%   argument is omitted, the updater just increments by 1.

%   Copyright 2008-2015 The MathWorks, Inc.

classdef textWaitUpdater < handle
    
    properties (SetAccess = 'private',GetAccess = 'public')
        
        % image counts
        totalImages
        processedImages
        
        % times
        startTime
        lastUpdate
        lastDot
        
        % for computing velocity
        timeAtFirstUpdate
        imagesAtFirstUpdate
        
        % strings and formatters
        elapsedTimeStr
        estimatedTimeStr
        introFormatter
        statusFormatter
        
    end % properties
    
    
    methods (Access = 'public')
        
        
        function obj = resetWaitbarState(obj, introFormatter, statusFormatter, numImages, processed_images)
            
            obj.introFormatter = introFormatter;
            obj.statusFormatter = statusFormatter;
            obj.totalImages = numImages;
            if nargin > 4
                obj.processedImages = processed_images;
            else
                obj.processedImages = 0;
            end
            
            % Display intro formatter with total images
	    fprintf('\n');
            fprintf(obj.introFormatter, obj.totalImages);
            fprintf('\n');
            
            obj.elapsedTimeStr = '';
            obj.estimatedTimeStr = '';
            
            obj.timeAtFirstUpdate = [];
            obj.imagesAtFirstUpdate = [];
            
            obj.startTime = tic;
            obj.lastUpdate = obj.startTime;
            obj.lastDot    = obj.startTime;
   
        end
            
            
        function obj = textWaitUpdater(introFormatter, statusFormatter, numImages, processed_images)
            
            if nargin < 4
                processed_images = 0;
            end
            obj.resetWaitbarState(introFormatter, statusFormatter, numImages, processed_images);
            
        end
        
        
        function update(obj,processed_images)
            
            % increment our current step counter
            if nargin > 1
                obj.processedImages = processed_images;
            else
                obj.processedImages = obj.processedImages + 1;
            end
            
            % update at most once per second (updates are expensive)
            current_time = toc(obj.lastDot);
            if current_time < 1
                return
            end
            
            % see if it is time to update (every 10 seconds)
            current_time = toc(obj.lastUpdate);
            if current_time < 10
                
                % only do a "dot" update
                fprintf('.');
                
            else
                
                if isempty(obj.timeAtFirstUpdate)
                    obj.timeAtFirstUpdate = tic;
                    obj.imagesAtFirstUpdate = obj.processedImages;
                    
                    fprintf('\n');
                    str = getString(message('images:textWaitUpdater:timeCalculating'));
                    fprintf([obj.statusFormatter '  ' str '\n'], ...
                        obj.processedImages, obj.totalImages);
                else
                    % do a full update
                    obj.updateTimeEstimates();
                    
                    fprintf('\n')
                    str = getString(message('images:textWaitUpdater:timeXofY', ...
                        obj.elapsedTimeStr, obj.estimatedTimeStr));
                    fprintf([obj.statusFormatter '  ' str '\n'], ...
                        obj.processedImages, obj.totalImages)
                end
                obj.lastUpdate = tic;
                
            end
            obj.lastDot = tic;
            
        end % update
        
        
        function destroy(obj) %#ok<*MANU>
            
            str = getString(message('images:textWaitUpdater:done'));
            fprintf('\n%s\n',str);
            
        end % destroy
        
        
        function cancel(~, varargin)
            
        end % cancel
        
        
        function tf = isCancelled(obj)
            
            tf = false;
            
        end % isCancelled
        
    end % public methods
    
    
    methods (Access = 'private')
        
        function updateTimeEstimates(obj)

            % get elapsed time string
            elapsedTime = toc(obj.startTime);
            obj.elapsedTimeStr = getTimeStr(elapsedTime);
            
            % compute velocity
            timeSinceFirstUpdate = toc(obj.timeAtFirstUpdate);
            imagesSinceFirstUpdate = obj.processedImages - obj.imagesAtFirstUpdate;
            timePerImage = timeSinceFirstUpdate / imagesSinceFirstUpdate;
                
            % get estimated time remaining string
            timeRemaining = (obj.totalImages - obj.processedImages) * timePerImage;
            estTotalTime = elapsedTime + timeRemaining;
            obj.estimatedTimeStr = getTimeStr(estTotalTime);
            
        end
        
    end % private methods
    
end % classdef


function str = getTimeStr(time)

% convert to serial date number (units == days)
seconds_per_day = 60 * 60 * 24;
time = time / seconds_per_day;

hour = 1/24;
if time > hour
    str = datestr(time, 'HH:MM:SS');
    if str(1) == '0'
        str(1) = '';
    end
else
    str = datestr(time, 'MM:SS');
end

end

