classdef SplitReader < matlab.mixin.Copyable
%SplitReader   Abstract class that can iterate over data in a split.
% This class inherits copyability to allow cloning a split reader and
% resetting it rather than modifying the state of an existing instance

%   Copyright 2015 The MathWorks, Inc.

     methods (Access = 'public', Abstract = true)
        
        % Return logical scalar indicating availability of data
        % This method should return the same value on repeated calls if
        % the getNext() method has not been called.
        tf = hasNext(rdr);

        % Return data and info as appropriate for the datastore
        [data, info] = getNext(rdr);
        
        % Reset the reader to the beginning of the split.
        % This method is called after creating a reader and if a reader is
        % required to re-read the data.
        reset(rdr);
        
        %progress   Percentage of data read as a value between [0.0, 1.0].
        %   Returns all the data in the datastore and resets it.
        pctg = progress(rdr);
        
        %
        % Subclasses must also write a copyElement() method to be truly
        % copyable. Authors must ensure that a copied reader starts reading
        % exactly where the original reader stopped. Essentially,
        %
        % rdrcopy = copy(rdr);
        % while hasNext(rdr)
        %    isequal(hasNext(rdr), hasNext(rdrcopy)); % must equals 1
        %    isequal(getNext(rdr), getNext(rdrcopy)); % must equals 1
        % end
        % isequal(hasNext(rdr), hasNext(rdrcopy)); % must equals 1
        %
    end
    
end