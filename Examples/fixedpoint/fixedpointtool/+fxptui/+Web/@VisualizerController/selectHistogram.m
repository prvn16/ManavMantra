function selectHistogram(this, rowId)
%% SELECTHISTOGRAM function publishes data to select histogram in 
% visualization section of FPT GUI

%   Copyright 2016-2017 The MathWorks, Inc.

     if ~isempty(this.VisualizerEngine.TableData)
       matchingIndex  = this.VisualizerEngine.getRowIndexForScopingId(rowId); %@ok

       if ~isempty(matchingIndex) && matchingIndex > 0
           % If index to select is outside of StartIndex:EndIndex,
           % histogram widget should be re-rendered using new data. Move
           % canvas if required.
           if (matchingIndex < this.VisualizerEngine.StartIndex) || (matchingIndex > this.VisualizerEngine.EndIndex) 
               % If index to select is one less than startindex, instead of
               % moving canvas to just start index - 1 position, move it to
               % startIndex - DataThreshold position
               if (abs(matchingIndex - this.VisualizerEngine.StartIndex) == 1)
                   newStartPosition = this.VisualizerEngine.StartIndex - this.VisualizerEngine.DataThreshold;
               else
                   newStartPosition  = matchingIndex;
               end
               this.sendDataForCanvasMove(struct('NewCanvasPosition', newStartPosition));
           end

           % Histogram to be selected is within StartIndex:EndIndex
           publishedIndex = matchingIndex - this.VisualizerEngine.StartIndex + 1;
           message.publish(this.PublishSelectHistogramChannel, struct('SignalIdx', publishedIndex, 'Run', this.VisualizerEngine.RunName));
           this.LastUsedChannel = this.PublishSelectHistogramChannel;
       else
           % Index is not found
           publishedIndex = -1;
           message.publish(this.PublishSelectHistogramChannel, struct('SignalIdx', publishedIndex, 'Run', this.VisualizerEngine.RunName));
           this.LastUsedChannel = this.PublishSelectHistogramChannel;
       end
      this.LastUsedData = publishedIndex;
    end
end