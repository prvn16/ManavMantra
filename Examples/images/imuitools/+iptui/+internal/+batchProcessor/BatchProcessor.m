classdef BatchProcessor < handle
    
    %   Copyright 2014-2015 The MathWorks, Inc.
    
    properties (Hidden = true)
        % State of each image. Each element has these fields:
        %   visited       = true | false
        %      true -> ProcessFunction has been called on this file. (Could
        %      still have errored though)
        %
        %   The remaining flags have a valid state only if visited == true.
        %
        %   errored       = true | false
        %      true -> One of read/proc/write failed. exception field has
        %      the relevent exception.
        %   exception     = []   | MException
        %      non-empty-> hasErrored is true. Contains corresponding
        %      exception.
        %
        ImageStates;
    end
    
    
    properties (Hidden = true)
        imageStore;
        batchFcn;
        
        UseParallel = false;
    end
    
    %% API
    properties
        beginning            = @(ind)[];
        done                 = @(ind)[];

        cleanup              = @(inds)[];
        
        checkIfStopRequested = @()false;
    end
    
    methods
        %
        function this = BatchProcessor(imageStore_, batchFcn_)
            this.imageStore = imageStore_;
            
            % batchFcn is expected to be on path
            assert(isa(batchFcn_,'function_handle'));
            this.batchFcn = batchFcn_;
            
            this.resetState();
        end
        
        %
        function resetState(this)
            % (Re)Initialize image states
            this.ImageStates = struct(...
                'visited', num2cell(false(1,this.imageStore.NumberOfImages)),...
                'errored', false,...
                'exception', []);
        end
                
        %
        function process(this)
            selectedInds = 1:this.imageStore.NumberOfImages;
            this.processSelected(selectedInds);
        end

        %
        function processSelected(this, selectedInds)
            assert(~isempty(this.imageStore.WriteLocation),...
                'Image store does not have a write location set');

            if(this.UseParallel)
                this.processSelectedInParallel(selectedInds);
            else
                this.processSelectedInSerial(selectedInds);
            end
        end
        
        %
        function wasVisited = visited(this, ind)
            wasVisited = this.ImageStates(ind).visited;
        end
                
        %
        function hasErrored   = errored(this, ind)
            hasErrored = this.ImageStates(ind).errored;
        end
        
        %
        function exception = getException(this, ind)
            exception = this.ImageStates(ind).exception;
        end
        
    end
    
    
    %% Helpers
    methods (Hidden = true)
        
        function processSelectedInSerial(this, selectedInds)
            for ind = selectedInds
                
                if(this.checkIfStopRequested())
                    break;
                end                
                
                try
                    cleanUpObj = onCleanup(@()this.done(ind));
                    this.beginning(ind);
                    
                    [   this.ImageStates(ind).errored,...
                        this.ImageStates(ind).exception] = ...
                        this.readProcessAndWrite(...
                        ind,...
                        this.imageStore,...
                        this.batchFcn);

                catch ALL %#ok<NASGU>
                    % Using TRY-CATCH only to ensure clean up. All
                    % exceptions will be caught internally by
                    % readProcessAndWrite above.
                end
                
                this.ImageStates(ind).visited = true;                
            end
            
        end
        
        function processSelectedInParallel(this, selectedInds)
            
            % Enqueue (in reverse order to enable auto pre allocation of
            % ffuture)
            selectedInds = fliplr(selectedInds);
            for ind = numel(selectedInds):-1:1 
                imgInd = selectedInds(ind);             
                
                ffuture(ind) = parfeval(...
                    @iptui.internal.batchProcessor.BatchProcessor.readProcessAndWrite,...
                    2,...
                    imgInd,...
                    this.imageStore,...
                    this.batchFcn);
                this.beginning(imgInd);
                
                if(this.checkIfStopRequested())
                    % User cancelled during queuing operation
                    cancel(ffuture);
                    % Remove unqueued futures and image indices
                    ffuture = ffuture(ind:end);
                    selectedInds = selectedInds(ind:end);
                    break;
                end
            end                                    
            
            % Farm completed jobs
            for ind = 1:numel(ffuture)                
                if(this.checkIfStopRequested())
                    cancel(ffuture);
                end
                
                try
                    [completedInd, errored, exception] = ...
                        fetchNext(ffuture);
                catch PEXP   
                    cause = PEXP.cause{1};
                    if(strcmp(cause.identifier,'parallel:fevalqueue:ExecutionCancelled'))
                        % Interrupted
                        continue;
                    else
                        completedInd = ind;
                        errored = true;
                        exception = cause;
                    end
                end
                
                imgInd = selectedInds(completedInd);
                this.ImageStates(imgInd).visited       = true;
                this.ImageStates(imgInd).errored       = errored;
                this.ImageStates(imgInd).exception     = exception;                
                this.done(imgInd);                
            end
            
            % Always clean up unfinished work
            unFinished = ~arrayfun(@(x)strcmp(x.State,'finished'), ffuture);
            errored    = ~arrayfun(@(x)isempty(x.Error), ffuture);
            cleanUp    = unFinished | errored;
            % Dont clean up errorred images
            cleanUp    = cleanUp &~ errored;
            cleanUpInds = selectedInds(cleanUp);
            this.cleanup(cleanUpInds);
            
        end
    end
    
    
    methods (Hidden = true, Static = true)
        
        function [hasErrored, exception] = readProcessAndWrite(ind, imageStore, batchFcn)
            hasErrored    = false;
            exception     = [];
            
            try % to process file
                im = imageStore.read(ind);
                results = batchFcn(im);                
                if~( (isstruct(results)&&numel(results)==1)...
                        || islogical(results) || isnumeric(results))                    
                    % Ensure scalar structure or numeric array
                    error(getString(message('images:imageBatchProcessor:expectedScalarStruct')));                    
                end
                imageStore.write(ind, results);
            catch ALL
                hasErrored = true;
                exception  = ALL;
                imageStore.clearPreviousResults(ind);
            end
            
        end
        
    end
    
end
