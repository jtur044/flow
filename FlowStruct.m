classdef FlowStruct < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Im = []; 
        lastIm;
        Gx;
        Gy;
        Gmag;
        Gdir;        
        Vx;
        Vy;
             
    end
    
    methods 
        
        
        function FlowEstimator ()
        
            
        end
        
        function step (obj, Im)

            %% save data
            obj.lastIm = obj.Im;
            obj.Im = Im;
            
            %% generate gradient information 
            [Gx, Gy]          = imgradientxy(Im);
            [Gmag, Gdir]      = imgradient(Gx, Gy);
            obj.Gx       = Gx;
            obj.Gy       = Gy;
            obj.Gmag     = Gmag;
            obj.Gdir     = Gdir;                 

            %% generate FLow information                
            [Vx, Vy, ~]   = opticalFlowPD( obj.lastIm, obj.Im, 'radius', 8 );                  
                                
            obj.Vx       = Vx; 
            obj.Vy       = Vy;

            
            
        end
        
    end
    
end

