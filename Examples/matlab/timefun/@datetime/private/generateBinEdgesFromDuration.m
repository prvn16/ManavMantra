function edges = generateBinEdgesFromDuration(dur,xmin,xmax,hardlimits,maxnbins)
bws = seconds(dur);
if bws >= 31556952 % years (365.2425*3600*24)
    bwy = years(dur);
    xminy = year(xmin);
    if bwy < 10
        decade = floor(xminy/10)*10;
        if hardlimits
            % with hard limits, the variable leftedge is the second leftmost 
            % bin edge
            leftedge = datetime(decade,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(ceil((xminy-decade)/bwy)*bwy);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(decade,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(floor((xminy-decade)/bwy)*bwy);
        end
    elseif bwy < 100
        century = floor(xminy/100)*100;
        if hardlimits
            leftedge = datetime(century,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(ceil((xminy-century)/bwy)*bwy);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(century,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(floor((xminy-century)/bwy)*bwy);
        end
    else
        if hardlimits
            leftedge = datetime(0,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(ceil(xminy/bwy)*bwy);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(0,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                years(floor(xminy/bwy)*bwy);
        end
    end
else
    if bws < 1   % milliseconds
        xmins = rem(second(xmin),1);
        unit = 'second';
    elseif bws < 60  % seconds
        xmins = second(xmin);
        unit = 'minute';
    elseif bws < 3600  % minutes
        xmins = minute(xmin)*60+second(xmin);
        unit = 'hour';
    elseif bws < 86400  % hours (3600*24)
        xmins = hour(xmin)*3600 + minute(xmin)*60 + second(xmin);
        unit = 'day';
    else  % days
        xmins = (day(xmin)-1)*86400 + hour(xmin)*3600 + minute(xmin)*60 + second(xmin);
        unit = 'month';
    end
    if hardlimits
        % with hard limits, the variable leftedge is the second leftmost bin edge
        leftedge = dateshift(xmin,'start',unit) + ...
            seconds(ceil(xmins/bws)*bws);
        if leftedge == xmin
            leftedge = leftedge + dur;
        end
    else
        % round to closest multiple of dur on the left
        leftedge = dateshift(xmin,'start',unit) + ...
            seconds(floor(xmins/bws)*bws);
    end
end
nbins = (xmax - leftedge)/dur;
if nbins <= maxnbins
    if hardlimits
        edges = [xmin leftedge+(0:floor(nbins))*dur];
        lastedge = edges;
        lastedge.data = lastedge.data(end);
        if lastedge < xmax
            edges = [edges xmax];
        end
    else
        edges = [leftedge leftedge+(1:ceil(nbins))*dur];
    end
else
    edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
end
end
