function edges = binpicker(xmin,xmax,nbins,rawBinWidth)
% BINPICKER Choose histogram bins.

%   Copyright 1984-2016 The MathWorks, Inc.

if ~isempty(xmin)
    xscale = max(abs([xmin,xmax]));
    xrange = xmax - xmin;
    
    % Make sure the bin width is not effectively zero.  Otherwise it will never
    % amount to anything, which is what we knew all along.
    rawBinWidth = max(rawBinWidth, eps(xscale));
    
    % If the data are not constant, place the bins at "nice" locations
    if xrange > max(sqrt(eps(xscale)), realmin(class(xscale)))
        % Choose the bin width as a "nice" value.
        powOfTen = 10.^floor(log10(rawBinWidth)); % next lower power of 10
        relSize = rawBinWidth / powOfTen; % guaranteed in [1, 10)
        
        % Automatic rule specified
        if isempty(nbins)
            if  relSize < 1.5
                binWidth = 1*powOfTen;
            elseif relSize < 2.5
                binWidth = 2*powOfTen;
            elseif relSize < 4
                binWidth = 3*powOfTen;
            elseif relSize < 7.5
                binWidth = 5*powOfTen;
            else
                binWidth = 10*powOfTen;
            end
            
            % Put the bin edges at multiples of the bin width, covering x.  The
            % actual number of bins used may not be exactly equal to the requested
            % rule.
            leftEdge = max(min(binWidth*floor(xmin ./ binWidth), xmin),-realmax(class(xmax)));
            nbinsActual = max(1, ceil((xmax-leftEdge) ./ binWidth));
            rightEdge = min(max(leftEdge + nbinsActual.*binWidth, xmax),realmax(class(xmax)));
            
            % Number of bins specified
        else
            % temporarily set a raw binWidth to a nice power of 10.
            % binWidth will be set again to a different value if more than
            % 1 bin.
            binWidth = powOfTen*floor(relSize);
            % Set the left edge at multiples of the raw bin width.
            % Then adjust bin width such that all bins are of the same
            % size and xmax fall into the rightmost bin.
            leftEdge = max(min(binWidth*floor(xmin ./ binWidth), xmin),-realmax(class(xmin)));
            if nbins > 1
                ll = (xmax-leftEdge)/nbins;  % binWidth lower bound, xmax
                % on right edge of last bin
                ul = (xmax-leftEdge)/(nbins-1);  % binWidth upper bound,
                % xmax on left edge of last bin
                p10 = 10^floor(log10(ul-ll));
                binWidth = p10*ceil(ll./p10);  % binWidth-ll < p10 <= ul-ll
                % Thus, binWidth < ul
            end
            
            nbinsActual = nbins;
            rightEdge = min(max(leftEdge + nbinsActual.*binWidth, xmax),realmax(class(xmax)));
        end
        
    else % the data are nearly constant
        % For automatic rules, use a single bin.
        if isempty(nbins)
            nbins = 1;
        end
        
        % There's no way to know what scale the caller has in mind, just create
        % something simple that covers the data.
        
        % Make the bins cover a unit width, or as small an integer width as
        % possible without the individual bin width being zero relative to
        % xscale.  Put the left edge on an integer or half integer below
        % xmin, with the data in the middle 50% of the bin.  Put the right
        % edge similarly above xmax.
        binRange = max(1, ceil(nbins*eps(xscale)));
        leftEdge = floor(2*(xmin-binRange./4))/2;
        rightEdge = ceil(2*(xmax+binRange./4))/2;
        
        binWidth = (rightEdge - leftEdge) ./ nbins;
        nbinsActual = nbins;
    end
    
    if ~isfinite(binWidth)
        % if binWidth overflows, don't worry about nice bin edges anymore
        edges = linspace(leftEdge, rightEdge, nbinsActual+1);
    else
        edges = [leftEdge leftEdge+(1:nbinsActual-1).*binWidth rightEdge];
    end
else
    % empty input
    if ~isempty(nbins)
        edges = cast(0:nbins, 'like', xmin);
    else
        edges = cast([0 1], 'like', xmin);
    end
end

end