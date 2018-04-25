classdef FifoPriorityQueue < handle %#codegen
    %Min FIFO PQ - Lowest Priority at the top
    
    %Copyright 2014 The MathWorks, Inc.

    properties (Access=private)
        queueElements;  %Elements in the queue
        queueIndex;     %The current element of interest in the queue
        queueMaxSize;   %Maxixum size of the queue
        queueOrder;     %Time-stamp 
    end
    
    methods
        function obj = FifoPriorityQueue(n)
            obj.queueMaxSize = n;
            obj.queueIndex = 0;
            obj.queueOrder = 0;
            
            mystruct = struct('priority',0,'value',0,'order',0);
            obj.queueElements = repmat(mystruct,[n 1]);
        end
        
        function state = isempty(obj)
            if(obj.queueIndex == 0)
                state=true;
            else
                state=false;
            end
        end
        
        function push(obj, elemValue, elemPriority)
            obj.queueIndex = obj.queueIndex + 1;
            obj.queueOrder = obj.queueOrder + 1;
            obj.queueElements(obj.queueIndex).value = double(elemValue);
            obj.queueElements(obj.queueIndex).priority = double(elemPriority);
            obj.queueElements(obj.queueIndex).order = obj.queueOrder;
            
            %Ensure the priority of parent is always less than its children
            currentIndex = obj.queueIndex;
            while (currentIndex > 1 && ((obj.queueElements(currentIndex).priority < obj.queueElements(floor(currentIndex/2)).priority))) 
                    obj.queueElements([currentIndex floor(currentIndex/2)]) = obj.queueElements([floor(currentIndex/2) currentIndex]);
                    currentIndex = floor(currentIndex/2);
            end
        end
        
        function [elemValue, elemPriority] = pop(obj)
            if(obj.queueIndex == 0)
                error('No elements in the priority queue to pop!');
            end

            elemValue = obj.queueElements(1).value;
            elemPriority = obj.queueElements(1).priority;           
            
            %Exchange with the last element
            obj.queueElements(1) = obj.queueElements(obj.queueIndex);
            
            parentIndex = 1;              %Parent
            leftChildIndex = 2;           %Left
            rightChildIndex = 3;          %Right
            incompleteFlag = true;
            
            while(incompleteFlag)
                if((leftChildIndex < obj.queueIndex) && (rightChildIndex < obj.queueIndex)) %Both elements exist
                    if((obj.queueElements(parentIndex).priority > obj.queueElements(leftChildIndex).priority) || ...
                            (obj.queueElements(parentIndex).priority > obj.queueElements(rightChildIndex).priority))  % P>L || P>R
                        if(obj.queueElements(rightChildIndex).priority==obj.queueElements(leftChildIndex).priority)  % L==R
                            [~,minIndex] = min([obj.queueElements(leftChildIndex).order; obj.queueElements(rightChildIndex).order]);
                            if(minIndex==1)  %left child priority is lowest
                                obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                                parentIndex = leftChildIndex;
                                leftChildIndex = parentIndex*2;
                                rightChildIndex = parentIndex*2 + 1;
                            else             %right child priority is lowest
                                obj.queueElements([parentIndex rightChildIndex]) = obj.queueElements([rightChildIndex parentIndex]);
                                parentIndex = rightChildIndex;
                                leftChildIndex = parentIndex*2;
                                rightChildIndex = parentIndex*2 + 1;
                            end
                        else      % P<L & P<R
                            [~,minIndex] = min([obj.queueElements(leftChildIndex).priority; obj.queueElements(rightChildIndex).priority]);
                            if(minIndex==1)  %left child priority is lowest
                                obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                                parentIndex = leftChildIndex;
                                leftChildIndex = parentIndex*2;
                                rightChildIndex = parentIndex*2 + 1;
                            else             %right child priority is lowest
                                obj.queueElements([parentIndex rightChildIndex]) = obj.queueElements([rightChildIndex parentIndex]);
                                parentIndex = rightChildIndex;
                                leftChildIndex = parentIndex*2;
                                rightChildIndex = parentIndex*2 + 1;
                            end
                        end
                    else
                        if((obj.queueElements(parentIndex).priority == obj.queueElements(leftChildIndex).priority) || ...
                                (obj.queueElements(parentIndex).priority == obj.queueElements(rightChildIndex).priority))  % ~(P>L||P>R) && (P==L || P==R) 
                            if(obj.queueElements(rightChildIndex).priority==obj.queueElements(leftChildIndex).priority)   % R==L
                                if(((obj.queueElements(parentIndex).order > obj.queueElements(leftChildIndex).order) || ...
                                        (obj.queueElements(parentIndex).order > obj.queueElements(rightChildIndex).order))) %Porder>Lorder || Porder>Rorder
                                    [~,minIndex] = min([obj.queueElements(leftChildIndex).order; obj.queueElements(rightChildIndex).order]);
                                    if(minIndex==1) %left child priority is lowest
                                        obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                                        parentIndex = leftChildIndex;
                                        leftChildIndex = parentIndex*2;
                                        rightChildIndex = parentIndex*2 + 1;
                                    else            %right child priority is lowest
                                        obj.queueElements([parentIndex rightChildIndex]) = obj.queueElements([rightChildIndex parentIndex]);
                                        parentIndex = rightChildIndex;
                                        leftChildIndex = parentIndex*2;
                                        rightChildIndex = parentIndex*2 + 1;
                                    end
                                else  %completely balanced heap
                                     incompleteFlag = false;
                                end
                            else  %one of the left/right priorities including the order maybe lower
                                [~,minIndex] = min([obj.queueElements(leftChildIndex).priority; obj.queueElements(rightChildIndex).priority]);
                                if(minIndex==1 && obj.queueElements(parentIndex).order > obj.queueElements(leftChildIndex).order)
                                        obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                                        parentIndex = leftChildIndex;
                                        leftChildIndex = parentIndex*2;
                                        rightChildIndex = parentIndex*2 + 1;
                                elseif(minIndex==2 && obj.queueElements(parentIndex).order > obj.queueElements(rightChildIndex).order)
                                    obj.queueElements([parentIndex rightChildIndex]) = obj.queueElements([rightChildIndex parentIndex]);
                                    parentIndex = rightChildIndex;
                                    leftChildIndex = parentIndex*2;
                                    rightChildIndex = parentIndex*2 + 1;
                                else
                                    incompleteFlag = false;
                                end
                            end
                        else %completely balanced
                            incompleteFlag = false;
                        end
                    end
                else 
                    if(leftChildIndex < obj.queueIndex && obj.queueElements(parentIndex).priority > obj.queueElements(leftChildIndex).priority)  %one element on the left
                        obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                    elseif(leftChildIndex < obj.queueIndex && obj.queueElements(parentIndex).priority == obj.queueElements(leftChildIndex).priority && ...
                            obj.queueElements(parentIndex).order > obj.queueElements(leftChildIndex).order)
                        obj.queueElements([parentIndex leftChildIndex]) = obj.queueElements([leftChildIndex parentIndex]);
                    end %a perfect binary tree
                    incompleteFlag = false;
                end
            end       
            obj.queueIndex = obj.queueIndex-1;
        end
    end
end
