function edges = generateBinEdgesFromNumBins(numbins,xmin,xmax,hardlimits)
numbins = double(numbins);
if hardlimits
    edges = linspace(xmin,xmax,numbins+1);
else
    % try from coarsest to finest levels
    levels = {'year', 'day', 'hour', 'minute', 'second'};
    funcs = {@years, @days, @hours, @minutes, @seconds};
    edges = [];
    for ind = 1:length(levels)
        unit = levels{ind};
        func = funcs{ind};
        xminstart = floor(xmin,unit);
        xmaxnext = ceil(xmax,unit);
        span = func(xmaxnext - xminstart);
        if span > numbins
            if numbins == 1
                edges = [xminstart xmaxnext];
            elseif numbins == 2
                bw = ceil(span / 2);
                midpoint = xminstart + func(floor(span/2));
                edges = midpoint + func((-1:1)*bw);
            else
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
                break;  %break out of the loop
            end
        end
    end
    if isempty(edges)
        % if still empty, simply use binpicker on numeric time
        edges = milliseconds(matlab.internal.math.binpicker(...
            milliseconds(xmin),milliseconds(xmax),numbins,...
            (milliseconds(xmax)-milliseconds(xmin))/numbins));
    end
end
end
