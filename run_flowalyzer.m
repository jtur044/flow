function varargout = run_flowalyzer(inputVideo, outputVideo, outputDataFile, config, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% RUN_FLOWALYZER Perform flow analysis on ROI 
%
% run_flowalyzer (inputVideo, config)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser();
p.addOptional('UseProfile', 'default');
p.addOptional('StartTime', 0);
p.addOptional('EndTime', inf);
p.addOptional('Display', true);
p.KeepUnmatched = true;
p.parse(varargin{:});
res = p.Results;

varargout{1} = [];


vidObj = VideoReader(inputVideo);

flowalyzer_config = getfield(config.OpticalFlow, res.UseProfile);

% flowalyzer_config

myFlowAlyzer = FlowAlyzer(flowalyzer_config); 

%% register individual REGIONS for "flowalyzer"
M = length(config.ROI);
for k = 1:M
    each_ROI = config.ROI{k};
    myFlowAlyzer.registerROI(each_ROI); 
end

%% register an individual OUTPUT (signal) for "flowalyzer"
M = length(config.OUTPUT);
for k = 1:M
    each_Output = config.OUTPUT{k};
    myFlowAlyzer.registerOutput(each_Output); 
end


%% show output 
if (config.Display.show)
    myPlayer = vision.VideoPlayer;    
end

LastTime = 0;


videoFWriter = vision.VideoFileWriter(outputVideo,'FileFormat','MPEG4');

%fid = fopen(outputDataFile, 'w');
 
%% filter radius
se = fspecial('disk', config.Parameters.SmoothingDiskRadius);

%% Open : output data file  
open (myFlowAlyzer, outputDataFile);
   

vidObj.CurrentTime = res.StartTime;

%% looping 
while(hasFrame(vidObj) & (vidObj.CurrentTime < res.EndTime))   
    
    %% read input image 
    CurrentTime = vidObj.CurrentTime;
    Im = readFrame(vidObj);      
    Im = rgb2gray(Im);            
    annotatedImage = Im;
    
    %% smoothing 
    if (config.Parameters.SmoothingEnabled)
        Im = imfilter(Im, se);
    end    
    
    %% perform flow computation on whole image + generate 
    %setTime(myFlowAlyzer, CurrentTime);    
    step(myFlowAlyzer, Im, CurrentTime); 
       
    %% write result  total Vx & Vy for each OUTPUT    
    write (myFlowAlyzer);
    
    %% show the output
    if ((config.Display.show) & (res.Display))        
        
        annotatedIm = draw(myFlowAlyzer, Im);
        reducedFrame = imresize(annotatedIm, config.Display.scale_factor);
        step(myPlayer, reducedFrame);
    end
        
    
    LastTime = CurrentTime; % = vidObj.CurrentTime;
end

%close (myFlowAlyzer);

end


function p = getfield (config, fieldstr)

    fn = fieldnames(config);    
    m  = ismember (fn, fieldstr);
    if (~any(m)) 
       error ('profile was not found.'); 
    end
    
    p = config.(fieldstr);
end

