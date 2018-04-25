function edges = generateBinEdgesFromDuration(dur,xmin,xmax,hardlimits,maxnbins)
if hardlimits
    leftedge = dur*ceil(xmin/dur);
    if leftedge == xmin
        leftedge = leftedge + dur;
    end
    rightedge = dur*floor(xmax/dur);
    if rightedge == xmax
        rightedge = rightedge - dur;
    end    
    if (rightedge - leftedge)/dur + 2 <= maxnbins
        edges = [xmin leftedge:dur:rightedge xmax];
    else
        edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
    end
else
    leftedge = dur*floor(xmin/dur);
    rightedge = max(dur*ceil(xmax/dur),leftedge+dur); % ensure at least one bin    
    if (rightedge - leftedge)/dur <= maxnbins
        edges = leftedge:dur:rightedge;
    else
        edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
    end
end
end

