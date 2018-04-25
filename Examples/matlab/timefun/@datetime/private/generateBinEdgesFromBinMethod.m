function [edges,twoedgesformat,fmt] = generateBinEdgesFromBinMethod(...
    binmethod, xmin, xmax, hardlimits, maxnbins)
switch binmethod
    case 'century'
        if hardlimits
            leftedge = datetime(100*ceil(year(...
                dateshift(xmin,'start','year','next'))/100),1,1,'TimeZone',xmin.tz);
            rightedge = datetime(100*floor(year(xmax)/100),1,1,'TimeZone',xmin.tz);
            if rightedge == xmax
                rightedge = rightedge - calyears(100);
            end
        else
            leftedge = datetime(100*floor(year(xmin)/100),1,1,'TimeZone',xmin.tz);
            rightedge = datetime(100*ceil(year(...
                dateshift(xmax,'start','year','next'))/100),1,1,'TimeZone',xmin.tz);
        end
        binwidth = calyears(100);
        twoedgesformat = true;
        fmt = 'uuuu';
    case 'decade'
        if hardlimits
            leftedge = datetime(10*ceil(year(...
                dateshift(xmin,'start','year','next'))/10),1,1,'TimeZone',xmin.tz);
            rightedge = datetime(10*floor(year(xmax)/10),1,1,'TimeZone',xmin.tz);
            if rightedge == xmax
                rightedge = rightedge - calyears(10);
            end
        else
            leftedge = datetime(10*floor(year(xmin)/10),1,1,'TimeZone',xmin.tz);
            rightedge = datetime(10*ceil(year(...
                dateshift(xmax,'start','year','next'))/10),1,1,'TimeZone',xmin.tz);
        end
        binwidth = calyears(10);
        twoedgesformat = true;
        fmt = 'uuuu';
    case 'year'
        if hardlimits
            leftedge = dateshift(xmin,'start','year','next');
            rightedge = dateshift(xmax,'start','year');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'year', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','year');
            rightedge = dateshift(xmax,'start','year','next');
        end
        binwidth = calyears(1);
        twoedgesformat = false;
        fmt = 'uuuu';
    case 'quarter'
        if hardlimits
            leftedge = dateshift(xmin,'start','quarter','next');
            rightedge = dateshift(xmax,'start','quarter');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'quarter', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','quarter');
            rightedge = dateshift(xmax,'start','quarter','next');
        end
        binwidth = calmonths(3);
        twoedgesformat = false;
        fmt = 'QQQ uuuu';
    case 'month'
        if hardlimits
            leftedge = dateshift(xmin,'start','month','next');
            rightedge = dateshift(xmax,'start','month');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'month', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','month');
            rightedge = dateshift(xmax,'start','month','next');
        end
        binwidth = calmonths(1);
        twoedgesformat = false;
        fmt = 'MMM-uuuu';
    case 'week'
        if hardlimits
            leftedge = dateshift(xmin,'start','week','next');
            rightedge = dateshift(xmax,'start','week');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'week', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','week');
            rightedge = dateshift(xmax,'start','week','next');
        end
        binwidth = caldays(7);
        twoedgesformat = true;
        fmt = getDatetimeSettings('defaultdateformat');
    case 'day'
        if hardlimits
            leftedge = dateshift(xmin,'start','day','next');
            rightedge = dateshift(xmax,'start','day');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'day', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','day');
            rightedge = dateshift(xmax,'start','day','next');
        end
        binwidth = caldays(1);
        twoedgesformat = false;
        fmt = getDatetimeSettings('defaultdateformat');
    case 'hour'
        if hardlimits
            leftedge = dateshift(xmin,'start','hour','next');
            rightedge = dateshift(xmax,'start','hour');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'hour', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','hour');
            rightedge = dateshift(xmax,'start','hour','next');
        end
        binwidth = hours(1);
        twoedgesformat = false;
        fmt = getDatetimeSettings('defaultformat');
    case 'minute'
        if hardlimits
            leftedge = dateshift(xmin,'start','minute','next');
            rightedge = dateshift(xmax,'start','minute');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'minute', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','minute');
            rightedge = dateshift(xmax,'start','minute','next');
        end
        binwidth = minutes(1);
        twoedgesformat = false;
        fmt = getDatetimeSettings('defaultformat');
    case 'second'
        if hardlimits
            leftedge = dateshift(xmin,'start','second','next');
            rightedge = dateshift(xmax,'start','second');
            if rightedge == xmax
                rightedge = dateshift(rightedge, 'start', 'second', 'previous');
            end
        else
            leftedge = dateshift(xmin,'start','second');
            rightedge = dateshift(xmax,'start','second','next');
        end
        binwidth = seconds(1);
        twoedgesformat = false;
        fmt = getDatetimeSettings('defaultformat');
end
toomanybins = false;
try 
    % the following may generate "Datetime value exceeds calendar limits"
    % error
    toomanybins = leftedge+maxnbins*binwidth < rightedge;
catch
end
if ~toomanybins
    if hardlimits
        edges = [xmin leftedge:binwidth:rightedge xmax];
    else
        edges = leftedge:binwidth:rightedge;
    end
else
    edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
end
end