%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = bwmorph3Algorithm(inp,op,orgsize)

out = false(orgsize);
if isempty(out)
    return
end
sR = 1; sC = 1;sP = 1;
temp = num2cell(orgsize);
[Ma,Na,~] = deal(temp{:});
[Mb,Nb,~] = size(inp);
pl_offset = [ -Mb*Nb 0 Mb*Nb ];
rc_offset = [ -Mb-1 -Mb -Mb+1 -1 0 1 Mb-1 Mb Mb+1]';
all_offset = repmat(rc_offset,1,3) + pl_offset;
offset = all_offset(:);

for id=1:prod(orgsize)
    loc = Mb*Nb*(sP + floor((id-1)/(Ma*Na))) + sR ;
    
    %adding column
    if mod(id,Ma*Na) == 0
        loc = loc +  Mb*(sC + floor((Ma*Na-1)/Ma));
    else
        loc = loc +  Mb*(sC + floor((mod(id,Ma*Na)-1)/Ma));
    
    end
    
    % adding row 
    if mod(mod(id,Ma*Na),Ma) == 0
        loc = loc + Ma;
    else
        loc = loc + mod(mod(id,Ma*Na),Ma);
    end
    
    nhood = inp(loc+offset);
    switch op
        case 'branchpoints'
            if nhood(14)
                out(id) = sum(nhood(:)) > 3;
            else
                out(id) = 0;
            end
        case 'clean'
            if nhood(14)
                if sum(nhood(:)) ==1
                    out(id)=0;
                else
                    out(id)=1;
                end
            else
                out(id)=0;
            end
        case 'endpoints'
            if nhood(14)
                out(id) = sum(nhood(:)) ==2;
            else
                out(id) = 0;
            end
        case 'fill'
            if ~nhood(14)
                interim_sum=sum(nhood([5 11 13 15 17 23]));
                if interim_sum == 6
                    out(id) = 1;
                else
                    out(id) = 0;
                end
            else
                out(id) = 1;
            end
        case 'majority'
            if sum(nhood(:))> 13
                out(id)=1;
            else
                out(id)=0;
            end
        case 'remove'
            if nhood(14)
                interim_sum=sum(nhood([5 11 13 15 17 23]));
                if interim_sum == 6
                    out(id) = 0;
                else
                    out(id) = 1;
                end
            else
                out(id) = 0;
            end           
    end       
end

