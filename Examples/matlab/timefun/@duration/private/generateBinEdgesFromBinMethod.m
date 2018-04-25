function edges = generateBinEdgesFromBinMethod(binmethod,xmin,xmax,hardlimits,maxnbins)
switch binmethod
    case 'year'
        binwidth = years(1);
    case 'day'
        binwidth = days(1);        
    case 'hour'
        binwidth = hours(1);        
    case 'minute'
        binwidth = minutes(1);        
    case 'second'
        binwidth = seconds(1);
end
if hardlimits
    leftedge = ceil(xmin,binmethod);
    if leftedge == xmin
        leftedge = leftedge + binwidth;
    end
    rightedge = floor(xmax,binmethod);
    if rightedge == xmax
        rightedge = rightedge - binwidth;
    end
    if (rightedge - leftedge)/binwidth + 2 <= maxnbins
        edges = [xmin leftedge:binwidth:rightedge xmax];
    else
        edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
    end
else
    leftedge = floor(xmin,binmethod);
    rightedge = max(ceil(xmax,binmethod),leftedge+binwidth);
    if (rightedge - leftedge)/binwidth <= maxnbins
        edges = leftedge:binwidth:rightedge;
    else
        edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
    end
end
end

