classdef FlowData < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = 'private' )
        
        flow;
    end
    
    
    methods
    
        function r = isempty (obj)        
            if (isempty(obj.flow.Vx) || isempty(obj.flow.Vy))            
                r = true;
                return
            end            
            r = false;
        end
        
        function set (obj, flow)            
            obj.flow = flow;
        end
        
        
        function r = get (obj)
            r = obj.flow;
        end
        
        function obj = FlowData (varargin)               
            
            if (nargin == 0)
                obj.flow = opticalFlow ();
            elseif (nargin == 1)
                obj.flow = varargin{1}; %% opticalFlow 
            elseif (nargin == 2)   
                obj.flow = opticalFlow(varargin{1}, varargin{2}); %% opticalFlow             
            else
                error ('FlowData number of arguments');
            end
            
        end
        
    end
    
end

