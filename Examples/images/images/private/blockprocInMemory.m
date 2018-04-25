function b = blockprocInMemory(source,fun,options)
% blockprocInMemory Distinct block processing for image.
%
% This is the separate implementation of BLOCKPROC for in-memory
% operations.  It is optimized for performance.
%
% Constraints:
% - MxNxP data only

%   Copyright 2010-2015 The MathWorks, Inc.

% pull options out into simple variables
a = source;
if size(a,3) > 1
    asize = [size(a,1) size(a,2) size(a,3)];
else
    asize = [size(a,1) size(a,2)];
end
block_size = options.BlockSize;
border_size = options.BorderSize;
pad_partial_blocks = options.PadPartialBlocks;
trim_border = options.TrimBorder;
use_parallel = options.UseParallel;

if strcmp(options.PadMethod,'constant')
    pad_method = options.PadValue;
else
    pad_method = options.PadMethod;
end

% compute size of required padding along image edges for partial blocks
source_height = asize(1);
source_width  = asize(2);
row_padding = rem(source_height,block_size(1));
if pad_partial_blocks && row_padding > 0
    row_padding = block_size(1) - row_padding;
else
    row_padding = 0;
end
col_padding = rem(source_width,block_size(2));
if pad_partial_blocks && col_padding > 0
    col_padding = block_size(2) - col_padding;
else
    col_padding = 0;
end

% Pad the input array.  We handle each case separately for performance
% reasons (to avoid needless calls to padarray).
has_border = ~isequal(border_size,[0 0]);
if ~has_border && ~pad_partial_blocks
    % no-op
    aa = a;
elseif has_border && ~pad_partial_blocks
    % pad both together
    aa = padarray(a,border_size,pad_method,'both');
elseif ~has_border
    % pad_partial_blocks only
    aa = padarray(a,[row_padding col_padding],pad_method,'post');
else
    % both types of padding required
    aa = padarray(a,border_size,pad_method,'pre');
    post_padding = [row_padding col_padding] + border_size;
    aa = padarray(aa,post_padding,pad_method,'post');
end

% number of blocks we'll process
mblocks = ceil(source_height / block_size(1));
nblocks = ceil(source_width  / block_size(2));

% allocate/setup block struct
block_struct.border = border_size;
block_struct.blockSize = block_size;
block_struct.data = [];
block_struct.imageSize = asize;
block_struct.location = [1 1];

% get first block and process it
block_struct = getBlock(aa,asize,block_struct,1,1,[0 0],border_size,...
    block_size,pad_partial_blocks);
[ul_output fun_nargout] = blockprocFunDispatcher(fun,block_struct,...
    trim_border);

% verify user FUN returned something valid
valid_output = isempty(ul_output) || isnumeric(ul_output) || ...
    islogical(ul_output);
if ~valid_output
    error(message('images:blockprocInMemory:invalidOutputClass', class( ul_output )))
end

% probe the remaining corners to compute final output size
ur_processed = false;
ll_processed = false;
lr_processed = false;
if nblocks > 1
    block_struct = getBlock(aa,asize,block_struct,1,nblocks,[0 0],...
        border_size,block_size,pad_partial_blocks);
    ur_output = blockprocFunDispatcher(fun,block_struct,trim_border);
    ur_processed = true;
end
if mblocks > 1
    block_struct = getBlock(aa,asize,block_struct,mblocks,1,[0 0],...
        border_size,block_size,pad_partial_blocks);
    ll_output = blockprocFunDispatcher(fun,block_struct,trim_border);
    ll_processed = true;
end
if nblocks > 1 && mblocks > 1
    block_struct = getBlock(aa,asize,block_struct,mblocks,nblocks,[0 0],...
        border_size,block_size,pad_partial_blocks);
    lr_output = blockprocFunDispatcher(fun,block_struct,trim_border);
    lr_processed = true;
end

% compute final output size
ul_output_size = [size(ul_output,1) size(ul_output,2)];
if ll_processed
    final_rows = ul_output_size(1) * (mblocks - 1) + size(ll_output,1);
else
    final_rows = ul_output_size(1);
end
if ur_processed
    final_cols = ul_output_size(2) * (nblocks - 1) + size(ur_output,2);
else
    final_cols = ul_output_size(2);
end
final_bands = size(ul_output,3);
final_size = [final_rows final_cols final_bands];

% allocate output matrix
if islogical(ul_output)
    b = false(final_size);
else
    b = zeros(final_size,class(ul_output));
end

% write 4 corner blocks
b(1:ul_output_size(1),1:ul_output_size(2),:) = ul_output;
if ll_processed
    last_row_start = final_rows - size(ll_output,1) + 1;
    last_row_width = size(ll_output,2);
    b(last_row_start:end,1:last_row_width,:) = ll_output;
end
if ur_processed
    last_col_start = final_cols - size(ur_output,2) + 1;
    last_col_height = size(ur_output,1);
    b(1:last_col_height,last_col_start:end,:) = ur_output;
end
if lr_processed
    last_row_start = final_rows - size(ll_output,1) + 1;
    last_col_start = final_cols - size(ur_output,2) + 1;
    b(last_row_start:end,last_col_start:end,:) = lr_output;
end

% setup remaining index lists for unprocessed blocks.  make sure to process
% blocks we know to be of the same size in sequence to avoid reallocation
% in the block struct.
[r1 c1] = meshgrid(1,2:nblocks-1);             % top row
[r2 c2] = meshgrid(2:mblocks-1,1:nblocks-1);   % interior rows
[r3 c3] = meshgrid(mblocks,2:nblocks-1);       % bottom row
[r4 c4] = meshgrid(2:mblocks-1,nblocks);       % right column

% get number of remaining blocks
num_blocks = numel(r1) + numel(r2) + numel(r3) + numel(r4);
previously_processed = mblocks * nblocks - num_blocks;

% setup wait bar mechanics (must be declared at function scope)
wait_bar = [];
cleanup_waitbar = [];

% update wait bar for first 100 blocks and then per percentage increment
update_increments = unique([1:100 round((0.01:0.01:1) .* num_blocks)]);
update_counter = 1;

% inner loop starts
start_tic = tic;

if use_parallel
    % track progress of work for waitbar
    completed_blocks = false(1,numel(num_blocks));
    parallelLoop();
else
    serialLoop();
end

% clean up wait bar if we made one
if ~isempty(wait_bar)
    clear cleanup_waitbar;
end


% Nested Functions
% ------------------------------------------------------------------------


    function parallelLoop()
        % The parallel loop is split into 3 different calls to
        % parallel_function.  This ensures that each call will only process
        % a set of contiguous blocks.  This is important to avoid our
        % @supplyFcn from having to send the entire image (just about) to a
        % worker.  This could happen if a worker was assigned to process
        % the last row in the "full blocks" section, as well as the
        % beginning of the last column of blocks (ie, "r3/c3" and "r4/c4"
        % below).  The resulting bounding box would be very large, and the
        % entire image would be sent to the worker.
        
        try
            
            % process all full blocks
            rr = [r1(:); r2(:)];
            cc = [c1(:); c2(:)];
            
            parallel_function(...
                [1 numel(rr)],...
                getProcessFcn(fun, fun_nargout, trim_border,asize,...
                border_size,block_size,pad_partial_blocks,rr,cc),...
                @stitchFcn,...
                @supplyFcn,...
                [],[],[],[],...
                Inf,@divideHarmonic);
            
            % process bottom row
            rr = r3(:);
            cc = c3(:);
            
            parallel_function(...
                [1 numel(rr)],...
                getProcessFcn(fun, fun_nargout, trim_border,asize,...
                border_size,block_size,pad_partial_blocks,rr,cc),...
                @stitchFcn,...
                @supplyFcn,...
                [],[],[],[],...
                Inf,@divideHarmonic);
            
            % process right column
            rr = r4(:);
            cc = c4(:);
            
            parallel_function(...
                [1 numel(rr)],...
                getProcessFcn(fun, fun_nargout, trim_border,asize,...
                border_size,block_size,pad_partial_blocks,rr,cc),...
                @stitchFcn,...
                @supplyFcn,...
                [],[],[],[],...
                Inf,@divideHarmonic);
            
        catch ME
            % the cancel button generates this error as a signal
            if strcmp(ME.identifier,'images:blockprocInMemory:cancelParallelWaitbar')
                return
            else
                rethrow(ME);
            end
        end
        
        
        function sub_image = supplyFcn(base, limit)
            % Returns the chunk of data holding all the requested blocks

            % Find min/max row/col in block indices
            block_inds = base+1:limit;
            block_rows = rr(block_inds);
            min_block_row = min(block_rows);
            max_block_row = max(block_rows);
            block_cols = cc(block_inds);
            min_block_col = min(block_cols);
            max_block_col = max(block_cols);
            
            % Find min/max row/col in pixel indices
            source_min_row = 1 + block_size(1) * (min_block_row - 1);
            source_min_col = 1 + block_size(2) * (min_block_col - 1);
            
            source_max_row = block_size(1) * max_block_row;
            source_max_col = block_size(2) * max_block_col;
            
            source_height = asize(1);
            source_width  = asize(2);
            if ~pad_partial_blocks
                source_max_row = min(source_max_row,source_height);
                source_max_col = min(source_max_col,source_width);
            end
            
            % compute indices in offset (border/padding-added) input, aa
            row_ind = source_min_row : source_max_row + 2 * border_size(1);
            col_ind = source_min_col : source_max_col + 2 * border_size(2);
            
            % set remaining block_struct fields
            sub_image{1} = aa(row_ind,col_ind,:);
            sub_image{2} = [source_min_row - 1 source_min_col - 1];

        end
        
        
        function stitchFcn(base,limit, outputBlocks)
            % Takes results from worker and writes to our output matrix

            for blockInd = 1:(limit-base)
                
                % compute row/col of block
                k = base + blockInd;
                row = rr(k);
                col = cc(k);
                completed_blocks(k) = true;
                
                % write to output
                row_idx = 1 + ul_output_size(1) * (row-1) : min(ul_output_size(1) * row,final_rows);
                col_idx = 1 + ul_output_size(2) * (col-1) : min(ul_output_size(2) * col,final_cols);
                b(row_idx,col_idx,:) = outputBlocks{blockInd};
                
            end
            
            total_done = sum(completed_blocks);
            updateWaitbar(total_done);
            
        end
        
    end


    function serialLoop
        
        
        % process all blocks
        rr = [r1(:); r2(:); r3(:); r4(:)];
        cc = [c1(:); c2(:); c3(:); c4(:)];
        
        for k = 1:num_blocks
            
            row = rr(k);
            col = cc(k);
            
            %%% INLINED: getBlock(aa,asize,block_struct,row,col,...) %%%
            % For performance we have inlined getBlock in the inner loop.  Changes
            % made here should also be made in the original sub-function.
            
            % compute row/col indices in (non-padded) source image of block of data
            source_min_row = 1 + block_size(1) * (row - 1);
            source_min_col = 1 + block_size(2) * (col - 1);
            source_max_row = source_min_row + block_size(1) - 1;
            source_max_col = source_min_col + block_size(2) - 1;
            if ~pad_partial_blocks
                source_max_row = min(source_max_row,source_height);
                source_max_col = min(source_max_col,source_width);
            end
            
            % set block location
            block_struct.location = [source_min_row source_min_col];
            
            % compute indices in offset (border/padding-added) input, aa
            row_ind = source_min_row : source_max_row + 2 * border_size(1);
            col_ind = source_min_col : source_max_col + 2 * border_size(2);
            
            % set remaining block_struct fields
            % NOTE: resizes to the data field cause a re-allocation.  All
            % similarly sized blocks should be processed in sequence
            block_data = aa(row_ind,col_ind,:);
            block_struct.data = block_data;            
            data_size = [size(block_struct.data,1) size(block_struct.data,2)];
            block_struct.blockSize = data_size - 2 * block_struct.border;
            
            %%% INLINE ENDING: getBlock(aa,row,col,...) %%%
            
            
            %%% INLINED: blockprocFunDispatcher(fun,...) %%%
            % For performance we have inlined some code from blockprocFunDispatcher
            % in the inner loop.  Applicable changes made here should also be made
            % in the original sub-function.
            
            % process the block
            if fun_nargout > 0
                output_block = fun(block_struct);
            else
                fun(block_struct);
                output_block = [];
            end
            
            % trim output if necessary
            if trim_border
                % get border size from struct
                bdr = block_struct.border;
                % trim the border
                output_block = output_block(bdr(1)+1:end-bdr(1),bdr(2)+1:end-bdr(2),:);
            end
            
            %%% INLINE ENDING: blockprocFunDispatcher(fun,...) %%%
            
            
            % write to output
            row_idx = 1 + ul_output_size(1) * (row-1) : min(ul_output_size(1) * row,final_rows);
            col_idx = 1 + ul_output_size(2) * (col-1) : min(ul_output_size(2) * col,final_cols);
            b(row_idx,col_idx,:) = output_block;
            
            if updateWaitbar(k)
                break;
            end
            
        end % inner loop
        
    end % serialLoop


    function abort = updateWaitbar(k)
        
        abort = false;
        
        if(options.DisplayWaitbar == false)
            return;
        end
        
        % only update for specific values of k, updates are expensive
        if k >= update_increments(update_counter)
            
            update_counter = update_counter + 1;
            
            % keep a running total of how long we've taken
            elapsed_time = toc(start_tic);
            
            % display a wait bar if necessary
            if isempty(wait_bar)
                
                % decide if we need a wait bar or not
                remaining_time = elapsed_time / k * (num_blocks - k);
                if elapsed_time > 10 && remaining_time > 25
                    total_blocks = num_blocks + previously_processed;
                    if images.internal.isFigureAvailable()
                        
                        wait_bar = iptui.cancellableWaitbar('Block Processing:',...
                            'Processing %d blocks',total_blocks,previously_processed + k);
                    else
                        
                        wait_bar = iptui.textWaitUpdater('Block Processing %d blocks.',...
                            'Completed %d of %d blocks.',total_blocks);
                    end
                    cleanup_waitbar = onCleanup(@() destroy(wait_bar)); %#ok<SETNU>
                end
                
            elseif wait_bar.isCancelled()
                % we had a waitbar, but the user hit the cancel button
                
                % return empty on cancels
                b = [];
                abort = true;
                if use_parallel
                    error(message('images:blockprocInMemory:cancelParallelWaitbar'));
                end
                
            else
                % we have a waitbar and it has not been canceled
                wait_bar.update(previously_processed + k);
                drawnow;
                
            end
        end
        
    end % updateWaitbar

end % blockprocInMemory


%-------------------------------------------------------------------------
function processFcn = getProcessFcn(fun,fun_nargout,trim_border,asize,...
    border_size,block_size,pad_partial_blocks,rr,cc)

processFcn = @processBlocks;

    function outputBlocks = processBlocks(base,limit,sub_image)
        
        % unpack our sub_image
        local_image = sub_image{1};
        offset      = sub_image{2};
        
        % allocate/setup block struct
        block_struct.border = border_size;
        block_struct.blockSize = block_size;
        block_struct.data = [];
        block_struct.imageSize = asize;
        block_struct.location = [1 1];

        % the results could be different size based on their location in
        % the input image, so we return them as a cell array.
        outputBlocks = cell(1,limit-base);
        
        for blockInd = 1:(limit-base)
            
            % NOTE: resizes to the data field cause a re-allocation.  All
            % similarly sized blocks should be processed in sequence
            
            k = base + blockInd;
            row = rr(k);
            col = cc(k);
            block_struct = getBlock(local_image,asize,block_struct,row,col,...
                offset,border_size,block_size,pad_partial_blocks);
            
            %%% INLINED: blockprocFunDispatcher(fun,...) %%%
            % For performance we have inlined some code from blockprocFunDispatcher
            % in the inner loop.  Applicable changes made here should also be made
            % in the original sub-function.
            
            % process the block
            if fun_nargout > 0
                outputBlocks{blockInd} = fun(block_struct);
            else
                fun(block_struct);
                outputBlocks{blockInd} = [];
            end
            
            % trim output if necessary
            if trim_border
                % get border size from struct
                bdr = block_struct.border;
                % trim the border
                outputBlocks{blockInd} =...
                    outputBlocks{blockInd}...
                    (bdr(1)+1:end-bdr(1),bdr(2)+1:end-bdr(2),:);
            end
            
            %%% INLINE ENDING: blockprocFunDispatcher(fun,...) %%%
        end
    end
end


%-------------------------------------------------------------------------
function block_struct = getBlock(aa,asize,block_struct,row,col,offset,...
    border_size,block_size,pad_partial_blocks)
% Gets a block struct containing the requested block.  This function is
% reproduced (inlined) in the inner loop of blockprocInMemory for
% performance reasons.  Changes to this function should be reflected there
% as well.

% compute row/col indices in (non-padded) source image of block of data
source_min_row = 1 + block_size(1) * (row - 1);
source_min_col = 1 + block_size(2) * (col - 1);
source_max_row = source_min_row + block_size(1) - 1;
source_max_col = source_min_col + block_size(2) - 1;
source_height = asize(1);
source_width  = asize(2);
if ~pad_partial_blocks
    source_max_row = min(source_max_row,source_height);
    source_max_col = min(source_max_col,source_width);
end

% set block location
block_struct.location = [source_min_row source_min_col];

% compute indices in offset (border/padding-added) input, aa
row_ind = source_min_row : source_max_row + 2 * border_size(1);
col_ind = source_min_col : source_max_col + 2 * border_size(2);

% account for offset
row_ind = row_ind - offset(1);
col_ind = col_ind - offset(2);

% set remaining block_struct fields
block_data = aa(row_ind,col_ind,:);
block_struct.data = block_data;

data_size = [size(block_struct.data,1) size(block_struct.data,2)];
block_struct.blockSize = data_size - 2 * block_struct.border;
end

