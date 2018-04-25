function B = morphopAlgo(A,se,padfull,unpad,op_type)
%MORPHOPALGO Algorithmic core for gpuArray image dilation/erosion. Intended
%for use with morphopInputParser in functions like IMDILATE, IMERODE,
%IMOPEN, IMCLOSE, IMTOPHAT and IMBOTHAT.

% Copyright 2013-2016 The MathWorks, Inc.

num_strels = length(se);
ndims_A    = ndims(A);
size_A     = size(A);

centers           = zeros(num_strels,2);
pad_size          = zeros(num_strels,2);
dst_size          = zeros(num_strels,2);
additional_offset = zeros(num_strels,2);    % additional offset to account 
                                            % for effective mask size being
                                            % smaller.
                                            
% Get the center location and neighborhood sizes.                                            
for k = 1 : num_strels
    [centers(k,:),pad_size(k,:)] = getcenterandsize(se(k));
end

% Cast pad_val to the input image class
pad_val = cast(getPadValue(A,op_type),classUnderlying(A));

if padfull
    % Pad the input for 'full' option.
    
    % Find the array offsets and centers for each structuring element in
    % the sequence. Use these values to update the extent of the effective 
    % mask and the additional offsets needed.
    min_extent        = zeros(num_strels,2);
    max_extent        = zeros(num_strels,2);
    for k = 1 : num_strels
        % Get the array offsets
        offset_k = getneighbors(se(k));
        
        % This is the upper-left corner of the effective mask.
        min_offset = min([offset_k;[0 0]]);     %include the center
        % This is the lower-right corner of the effective mask.
        max_offset = max([offset_k;[0 0]]);     %include the center
        
        % Find the new extent of the effective mask.
        min_extent(k,:) = centers(k,:) + min_offset;
        max_extent(k,:) = centers(k,:) + max_offset;

        additional_offset(k,:) = pad_size(k,:)-max_extent(k,:);
    end
    
    % Pad the input by the sum of padding needed for each structuring
    % element.
    max_pad_size = sum((pad_size-1),1);
    if numel(max_pad_size) < ndims_A
        max_pad_size(ndims_A) = 0;
    end
    A = images.internal.gpu.constantpaduint8(A,max_pad_size,pad_val,'both');
    
    % Compute the destination size for each dilation/erosion output.
    % Corresponding to each successive structuring element, the destination
    % size is the previous destination size minus the padding for that
    % structuring element. The padding needs to be reduced according to the
    % effective size of the mask.
    if num_strels>0
        dst_size(1,:) = [size(A,1) size(A,2)]-2*(pad_size(1,:)-1)+(max_extent(1,:)-min_extent(1,:));
    end
    for k = 2 : num_strels
        dst_size(k,:) = dst_size(k-1,:) - 2*(pad_size(k,:)-1) + (max_extent(k,:)-min_extent(k,:));
    end
    
else
    % Pad the input for 'same' option.
    [max_pad_size, k] = max(pad_size,[],1);
   
    prepad_size  = centers(k(1),:) - 1;
    postpad_size = max_pad_size - centers(k(1),:);
    
    if numel(prepad_size) < ndims_A
        prepad_size(ndims_A)  = 0;
        postpad_size(ndims_A) = 0;
    end
    A = images.internal.gpu.constantpaduint8(A,[prepad_size;postpad_size],pad_val,'both');
    
    dst_size = repmat([size_A(1) size_A(2)],[num_strels,1]); 
end

% Zero-based offset from starting pixel.
centers_offset = centers - 1;

% Create gpuArray's from the STREL objects
mask = cell(1,num_strels);
for k = 1 : num_strels
        mask{k} = gpuArray(cast(getnhood(se(k)),classUnderlying(A))); 
end

% Apply the operation (dilation/erosion) on the image with the sequence of
% structuring elements.
B = A;
if strcmp(op_type,'dilate')
    for k = 1 : num_strels
        B = images.internal.gpu.morph(B,mask{k},centers_offset(k,:),...
                           additional_offset(k,:),dst_size(k,:),'dilate');
    end
else
    for k = 1 : num_strels
        B = images.internal.gpu.morph(B,mask{k},centers_offset(k,:),...
                          additional_offset(k,:),dst_size(k,:),'erode');
    end
    % Special case: If input is logical and at least one mask has an empty
    % neighborhood, handle it.
    if strcmp(classUnderlying(B),'logical') && ...
            any(arrayfun(@(x) all(~any(getnhood(x))), se))
        B = (B~=0);
    end 
end

% Unpad the image if needed.    
if unpad
    % Note:
    % * This went through the padfull codepath. We crop accordingly.
    % * Call to SUBSREF needs to be explicit from within @gpuArray
    % directory.

    idx = cell(1,ndims_A);
    sum_centers = zeros(1,2);
    for k = 1 : num_strels
        sum_centers = sum_centers + (size(mask{k}) - centers(k,:));
    end
    sum_addoffs = sum(additional_offset,1);
    for k = 1:2
        first = 1 + sum_centers(k) - sum_addoffs(k);
        last = first + size_A(k) - 1;
        idx{k} = first:last;
    end
    for k = 3:ndims_A
        idx{k} = ':';
    end
    
    subscripts.type = '()';
    subscripts.subs = idx;
    B = subsref(B,subscripts); 
end
%--------------------------------------------------------------------------

%==========================================================================
function pad_value = getPadValue(A, op_type)
% Returns the appropriate pad value, depending on whether we are performing
% erosion or dilation, and whether or not A is logical (binary).

if strcmp(op_type, 'dilate')
   pad_value = -Inf;
else
   pad_value = Inf;
end

if islogical(A)
   % Use 0s and 1s instead of plus/minus Inf.
   pad_value = max(min(pad_value, 1), 0);
end
%--------------------------------------------------------------------------

%==========================================================================
function [center,sz] = getcenterandsize(se)
% Compute center of the structuring element.

sz = size(se.getnhood());
center = floor((sz+1)/2);
%--------------------------------------------------------------------------
