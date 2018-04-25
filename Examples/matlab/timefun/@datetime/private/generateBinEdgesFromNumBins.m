function edges = generateBinEdgesFromNumBins(numbins,xmin,xmax,hardlimits)
numbins = double(numbins);

if hardlimits
    edges = linspace(xmin,xmax,numbins+1);
else
    % try from coarsest to finest levels
    levels = {'year', 'month', 'day', 'hour', 'minute', 'second'};
    funcs = {@calyears, @calmonths, @caldays, @hours, @minutes, @seconds};
    edges = [];
    for ind = 1:length(levels)
        unit = levels{ind};
        func = funcs{ind};
        xminstart = dateshift(xmin,'start',unit);
        xmaxnext = dateshift(xmax,'start',unit,'next');
        if any(strcmp(unit, {'year', 'month', 'day'}))
            span = func(between(xminstart,xmaxnext,unit));
        else
            span = func(xmaxnext - xminstart);
        end
        if span > numbins
            if numbins == 1
                edges = [xminstart xmaxnext];
            elseif numbins == 2
                bw = ceil(span / 2);
                midpoint = xminstart + func(floor(span/2));
                edges = midpoint + func((-1:1)*bw);
            else % numbins >= 3
                % determine shortest and longest binwidth possible, and determine if
                % there is an integer between them
                bwshortest = span / numbins;
                bwlongest = (span-2)/(numbins-2);
                bw = ceil(bwshortest); % integer
                if bw < bwlongest
                    midpoint = xminstart + func(floor(span/2));
                    if rem(numbins,2) == 1 % odd number of bins
                        if rem(span,2) == 1  % odd span
                            if rem(bw,2) == 1 % odd bin width
                                rawhalflength = bw*(ceil(...
                                    span/2/bw-0.5)+0.5);
                                lefthalflength = func(floor(rawhalflength));
                                righthalflength = func(ceil(rawhalflength));
                            else   % even bin width
                                lefthalflength = func(bw*(ceil(...
                                    span/2/bw-0.5)+0.5));
                                righthalflength = lefthalflength;
                            end
                        else  % even span
                            if rem(bw,2) == 1 % odd bin width
                                rawhalflength = bw*(...
                                    ceil(span/2/bw-0.5)+0.5);
                                lefthalflength = func(ceil(rawhalflength));
                                righthalflength = func(floor(rawhalflength));
                            else  % even bin width
                                lefthalflength = func(bw*(ceil(span/2/bw-0.5)+0.5));
                                righthalflength = lefthalflength;
                            end
                        end
                    else  % even number of bins
                        lefthalflength = func(bw*ceil(ceil(span/2)/bw));
                        righthalflength = lefthalflength;
                    end
                    leftedge = midpoint - lefthalflength;
                    rightedge = midpoint + righthalflength;
                    bw = func(bw);
                    edges = leftedge:bw:rightedge;
                end
            end
            if ~isempty(edges)
                break; %break out of the loop
            end
        end
    end
    if isempty(edges)
        % if still empty, simply use binpicker on numeric time
        % TODO: think about using second boundary as origin?
        edges = datetime(matlab.internal.math.binpicker(...
            posixtime(xmin),posixtime(xmax),numbins,...
            (posixtime(xmax)-posixtime(xmin))/numbins),...
            'convertFrom', 'posixtime', 'TimeZone', xmin.tz);
    end
end
end