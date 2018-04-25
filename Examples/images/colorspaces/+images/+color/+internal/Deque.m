% Double-ended queue (deque), implemented as a handle object using a
% cell array acting as a circular buffer.

% Copyright 2014 The MathWorks, Inc.

classdef Deque < handle
    
    properties (Dependent = true)
        Items
    end
    
    properties (Access = private)
        Array = cell(1, 10);
        First = 1;
        GrowthFactor = 2;
        PackFraction = 0.25;
        NumItems = 0
    end
    
    methods
        function value = get.Items(self)
            % Return queue contents as a cell array.
            value = self.Array(self.itemIndices());
        end
    end
    
    methods (Access = private)
        
        function p = arrayIsFull(self)
            p = (self.NumItems == numel(self.Array));
        end
        
        function growArray(self)
            % Grow the underlying cell array containing the queue contents 
            % so that it contain more items. Use a multiplicative growth
            % strategy.
            
            K = numel(self.Array);
            self.Array{ceil(self.GrowthFactor * K)} = [];
            if (self.NumItems > 0)
                num_items_to_move = K - self.First + 1;
                self.Array((end - num_items_to_move + 1):end) = ...
                    self.Array(self.First:K);
            end
            
            self.First = numel(self.Array) - num_items_to_move + 1;
        end
        
        function packArray(self)
            % Rearrange the circular buffer so that it contains no extra
            % space and so that the first item is stored at the beginning
            % of the array. For example, if the array currently looks
            % like this:
            %
            % 4 5 6 x x x 1 2 3
            %
            % then after the call to packArray it will look like this:
            %
            % 1 2 3 4 5 6
            
            if (self.NumItems / numel(self.Array)) <= self.PackFraction
                self.Array = self.Array(self.itemIndices);
                self.First = 1;
            end
        end
        
        function incrementFirst(self)
            if self.First == numel(self.Array)
                self.First = 1;
            else
                self.First = self.First + 1;
            end
        end
        
        function decrementFirst(self)
            if self.First == 1
                self.First = numel(self.Array);
            else
                self.First = self.First - 1;
            end
        end
        
        function idx = last(self)
            idx = mod(self.First + self.NumItems - 2, numel(self.Array)) + 1;
        end
        
        function indices = itemIndices(self)
            % Return a vector of indices that can be used to extract the
            % contents of the circular buffer in their logical order. For
            % example, if the buffer currently looks like this:
            %
            % 4 5 6 x x x 1 2 3
            %
            % Then itemIndices returns the vector:
            %
            % [7 8 9 1 2 3]
            
            indices = mod((1:self.NumItems) + self.First - 2, numel(self.Array)) + 1;
        end
    end
    
    methods
        
        function p = isEmpty(self)
            p = self.NumItems == 0;
        end
        
        function pushBack(self, item)
            % Add an item to the end of the deque.
            
            if self.arrayIsFull()
                self.growArray();
            end
            self.NumItems = self.NumItems + 1;
            self.Array{last(self)} = item;
        end
        
        function pushFront(self, item)
            % Add an item to the beginning of the deque.
            
            if self.arrayIsFull()
                self.growArray();
            end
            
            decrementFirst(self);
            
            self.Array{self.First} = item;
            self.NumItems = self.NumItems + 1;
        end
        
        function val = popBack(self)
            % Remove the item from the end of the deque and return it.
            
            if self.isEmpty()
                error(message('images:color:popBackOnEmptyDeque'));
            end

            val = self.Array{last(self)};
            self.NumItems = self.NumItems - 1;
            
            self.packArray();
        end
        
        function val = popFront(self)
            % Remove the item from the beginning of the deque and return it.
            
            if self.isEmpty()
                error(message('images:color:popFrontOnEmptyDeque'));
            end
            val = self.Array{self.First};
            incrementFirst(self);
            self.NumItems = self.NumItems - 1;
            
            self.packArray();
        end
        
        function val = back(self)
            % Return the item at the end of the deque.
            
            if self.isEmpty()
                error(message('images:color:backOnEmptyDeque'));
            end
            val = self.Array{last(self)};
        end
        
        function val = front(self)
            % Return the item at the beginning of the deque.
            
            if self.isEmpty()
                error(message('images:color:frontOnEmptyDeque'));
            end
            val = self.Array{self.First};
        end
    end
    
end
