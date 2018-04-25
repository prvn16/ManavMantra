function edges = generateBinEdgesFromCalendarDuration(dur,xmin,xmax,hardlimits,maxnbins)
[dury,durm,durd,durt] = split(dur,{'year','month','day','time'});
% shortest DUR in absolute time
shortestwidth = hours((dury*365 + durm*28 + durd)*24 ...
    + hours(durt) - 1); % the -1 at the end is for possible daylight saving time
if dury > 0   % year
    xminy = year(xmin);
    if dury < 10 
        % set origin at start of decade
        decade = floor(xminy/10)*10;
        if hardlimits
            leftedge = datetime(decade,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(ceil((xminy-decade)/dury)*dury);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(decade,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(floor((xminy-decade)/dury)*dury);
        end
    elseif dury < 100
        % set origin at start of century
        century = floor(xminy/100)*100;
        if hardlimits
            leftedge = datetime(century,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(ceil((xminy-century)/dury)*dury);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(century,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(floor((xminy-century)/dury)*dury);
        end
    else
        % use the year 0 as the origin
        if hardlimits
            leftedge = datetime(0,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(ceil(xminy/dury)*dury);
            if leftedge == xmin
                leftedge = leftedge + dur;
            end
        else
            leftedge = datetime(0,1,1,0,0,0,'TimeZone',xmin.tz) + ...
                calyears(floor(xminy/dury)*dury);
        end
    end
else
    if durm > 0 % month
        unit = 'year';
    elseif durd > 0 % day
        unit = 'month';
    else % time only
        edges = generateBinEdgesFromDuration(durt,xmin,xmax,hardlimits,maxnbins);
        return;
    end
    origin = dateshift(xmin,'start',unit);
    maxndur = ceil((xmin - origin)/shortestwidth);
    if hardlimits
        index = find(origin + (0:maxndur)*dur > xmin,1);
        if isempty(index)
            % TODO: is this branch reachable?
            leftedge = origin + maxndur*dur;
        else
            leftedge = origin + (index-1)*dur;
        end
    else
        % find the location of left edge, which should be the multiple of DUR
        % just to the left of xmin
        index = find(origin + (0:maxndur)*dur <= xmin,1,'last');
        leftedge = origin + (index-1)*dur;
    end
end
% find the location of the right edge, which should be the multiple of DUR
% just to the right of xmax
nbinsupperbounds = ceil((xmax - leftedge)/shortestwidth);
if nbinsupperbounds <= maxnbins
    if hardlimits
        edges = [xmin leftedge+(0:nbinsupperbounds)*dur];
        index = find(edges >= xmax, 1);
        edges.data(index:end) = [];
        edges = [edges xmax];
    else
        edges = [leftedge leftedge+(1:nbinsupperbounds)*dur];
        index = find(edges >= xmax, 1);
        edges.data(index+1:end) = [];
    end
else
    edges = generateBinEdgesFromNumBins(maxnbins,xmin,xmax,hardlimits);
end
end