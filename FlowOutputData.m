classdef FlowOutputData < handle
    %FLOWOUTPUTDATA Flow OutputData 
    %   Detailed explanation goes here
    
    properties

        X  = 0;
        Y  = 0;
        Vx = 0;
        Vy = 0;
             
    end
    
    properties (Access = 'private' )
        
    end
    
    
    methods
            
        function obj = FlowOutputData (X, Y, Vx, Vy, dT)               
            reset (obj);
            
            if (nargin == 5)
                update(obj, X, Y, Vx, Vy, dT);
            end
        end
        
        
        function reset (obj, varargin)
        
           if (nargin == 3)
                obj.X  = varargin{1};
                obj.Y  = varargin{2};           
           elseif (nargin == 1)               
                obj.X  = 0;
                obj.Y  = 0;
           else 
                error ('Bad arguments.');
           end
            
           obj.Vx = 0;
           obj.Vy = 0;
            
        end
        
        function r = isempty (obj)        
            if (isempty(obj.Vx) || isempty(obj.Vy))            
                r = true;
                return
            end            
            r = false;
        end
        
        function update (obj, Vx, Vy, dT)
            obj.Vx = Vx;
            obj.Vy = Vy;            
            obj.X  = obj.X + Vx*dT;
            obj.Y  = obj.Y + Vy*dT;            
        end
                
        function [Vx, Vy] = get (obj)
            Vx = obj.Vx;
            Vy = obj.Vy;            
        end
        
    end
    
end

