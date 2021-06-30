classdef ResultManager < handle
    
    %
    % RESULTMANAGER A class with abstract methods for displaying video overlay
    %
    % 
    
    properties (Constant)
       
        TIME   = 'TIME';
        PUPILX = 'PUPILX';
        PUPILY = 'PUPILY';
        
    end
    
    properties
        
        inputTable = [];
        inputFields = {};
        Time = nan;
        
        pointerIndex = nan;             
        pointerTime  = nan;
        timeList     = [];
        
        CurrentTime  = 0;
        
    end
    
    properties
        
        frameRate = 30; % FPS  
        
    end
    
    
    methods
        
        function obj = ResultManager(strInputFile, strTimeField) 
                        
            % create a list
            readFrom(obj, strInputFile);             
            obj.inputFields = containers.Map();  
            addField(obj, ResultManager.TIME, strTimeField);            
            obj.timeList = getField(obj, ResultManager.TIME);
            
            % initialize the list 
            minTime = min(obj.timeList);
            setCurrentTime(obj, minTime);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %
        % FIELD ADDER/GETTERS 
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function addField(obj, strRole, strName)
            obj.inputFields(strRole) = strName; 
        end
        
        function ret = getField(obj, strRole)
            myField    = obj.inputFields(strRole);
            ret = obj.inputTable.(myField);
        end
        
        function ret = get(obj, strName)
            %myField    = obj.inputFields(strRole);
            ret = obj.inputTable.(strName);
        end
        
        
        function addColumn(obj, strNewColumn, value)
           obj.inputTable.(strNewColumn) = value; 
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %
        % STEP  
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function ret = readData(obj)            
            pIndex = obj.pointerIndex;
            ret = obj.inputTable(pIndex, :);            
            M = size(obj.inputTable,1);
            if (pIndex >= M)
               return 
            end
            obj.pointerIndex = obj.pointerIndex + 1;
            strFieldTime  = obj.inputFields(ResultManager.TIME);
            obj.CurrentTime = ret.(strFieldTime);
        end    
        
        function ret = step(obj)
            
            % ... lets just get the next row 
            obj.pointerIndex = obj.pointerIndex + 1;
            ret = obj.inputTable(obj.pointerIndex, :);

            %myField = obj.inputFields(strRole) 
            %strTimeField = obj.inputFields(ResultManager.TIME);            
            %ret.(strTimeField)            
            %obj.CurrentTime = ret.(strTimeField);
            %setCurrentTime(obj, ret.(strTimeField));            
        end
        
        function ret = hasData(obj)
            if (obj.pointerIndex == size(obj.inputTable, 1))
                ret = false;
            else
                ret = true;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % READER  
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function readFrom(obj, dataSource)            
            if (ischar(dataSource))
                obj.inputTable = readtable(dataSource);
            elseif (istable(dataSource))
                obj.inputTable = dataSource;                
            end
             
        end
        
        function [flag, nIndex] = hasTime(obj, myTime, varargin)               
            nValue = abs(myTime - obj.timeList);            
            [~, nIndex] = min(nValue);
            if (~isempty(nIndex))            
                flag = true;
                return            
            else
                flag = false;
                nIndex = nan;
            end            
        end
        
        
        function found = setCurrentTime(obj, myTime)
           [found, nIndex] = hasTime(obj, myTime);
           if (found)                               
               obj.CurrentTime  = myTime;
               obj.pointerIndex = nIndex;    
           end    
        end

       function X = getColumn(obj, strField)
             X = obj.inputTable.(strField);             
       end       
        
       function [result, nIndex] = getCurrentData(obj)            
            if (~isnan(obj.pointerIndex))
                nIndex = obj.pointerIndex;
                result = obj.inputTable(nIndex, :);           
            end            
        end

    
    end
end
    

