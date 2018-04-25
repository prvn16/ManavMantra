classdef ClassMemberIterator < handle
    % CLASSMEMBERITERATOR - iterator class that allows user to iterate over
    % a collection of ClassMemberHelpContainer objects.
    
    % Copyright 2009 The MathWorks, Inc.
    properties(Access = private)
        % index - stores index in collection that iterator is currently
        % pointing to.
        index = 1;
        
        NumMembers = 0; % stores total number of elements in the collection.
        
        classMemberHelpContainers = {}; % array of ClassMemberHelpContainers
    end
    
    methods
        function this = ClassMemberIterator(varargin)
            % constructor takes in a collection of
            % ClassMemberHelpContainers and returns an iterator that
            % iterates over this collection.
            for i = 1:nargin
                this.classMemberHelpContainers = [this.classMemberHelpContainers; struct2cell(varargin{i})];
            end
            this.NumMembers = length(this.classMemberHelpContainers);
        end
        
        function result = hasNext(this)
            % HASNEXT - returns a boolean indicating whether the collection
            % stores any more unvisited objects in the collection.
            result = this.index <= this.NumMembers;
        end
        
        function memberHelpInfo = next(this)
            % NEXT - returns the ClassMemberHelpContainer currently being
            % pointed to and moves the iterator down the collection
            if ~this.hasNext
                error(message('MATLAB:introspective:classMemberIterator:NoSuchElement'));
            end
            
            memberHelpInfo = this.classMemberHelpContainers{this.index};
            
            this.index = this.index + 1;
        end
    end
end