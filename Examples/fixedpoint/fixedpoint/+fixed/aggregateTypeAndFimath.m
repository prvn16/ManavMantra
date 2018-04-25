function [a_agg,b_agg] = aggregateTypeAndFimath(a,b) %#codegen
%aggregateTypeAndFimath  Aggregate numerictype and fimath
%
%   [a_agg,b_agg] = aggregateTypeAndFimath(a,b)  returns fi objects
%   that contain the same values as the inputs, respectively, with
%   the same numerictype that is the aggregate of both input
%   numerictypes, ensuring no quantization or overflow.  The fimath
%   of the aggregates will be local if it was local on either
%   input (preferring the fimath of the first input if they are
%   different).  If neither input had local fimath, then the
%   aggregates will not have local fimath.

%   Copyright 2014 The MathWorks, Inc.
    
    aggNT = fixed.aggregateType(a, b);
    
    % numerictype
    a_agg = fi(a, aggNT);
    b_agg = fi(b, aggNT);
    
    % fimath
    if isfi(a) && isfimathlocal(a)
        % If a has a local fimath, then use it
        a_agg = setfimath(a_agg,a.fimath);
        b_agg = setfimath(b_agg,a.fimath);
    elseif isfi(b) && isfimathlocal(b)
        % a is not a fi or does not have a local fimath
        a_agg = setfimath(a_agg,b.fimath);
        b_agg = setfimath(b_agg,b.fimath);
    else
        % Neither have a local fimath, so remove fimath from
        % aggregate
        a_agg = removefimath(a_agg);
        b_agg = removefimath(b_agg);
    end
    
end
