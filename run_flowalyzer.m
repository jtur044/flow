function varargout = run_flowalyzer(inputVideo, outputVideo, outputDataFile, config, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% RUN_FLOWALYZER Perform flow analysis on ROI 
%
% run_flowalyzer(inputVideo, outputVideo, outputDataFile, config, varargin)
%
% where 
%       inputVideo     is the input video 
%       outputVideo    is the input video 
%       outputDataFile is the output datafile
%       config         is the configuration file 
%       
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser();
p.addOptional('UseProfile', 'default');
p.addOptional('StartTime', 0);
p.addOptional('EndTime', inf);
p.addOptional('Display', true);
p.addOptional('OpenFaceInfo', []);

p.KeepUnmatched = true;
p.parse(varargin{:});
res = p.Results;

varargout{1} = [];


if (ischar(config))
    config = load_commented_json (config);
end


%% Information 

vidObj = VideoReader(inputVideo);
flowalyzer_config = getfield(config.OpticalFlow, res.UseProfile);
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
   

%% Initialize OpenFace if needed 
isUsingOpenFaceInfo = false;
if (~isempty(res.OpenFaceInfo))
    if (res.OpenFaceInfo.Enable)

        %% Allow processing of OpenFace             
        isUsingOpenFaceInfo = true;        
        inputOpenFaceFile = res.OpenFaceInfo.Filename;

        %% high-level names for face features to include 
        filteredFaceInfoHeaders = {   'irisPointsR',            'irisPointsL', ... 
                                      'pupilPointsR',           'pupilPointsL', ...
                                      'eyeorderedR',            'eyeorderedL', ...
                                      'rightEyeInnerCorner',    'rightEyeOuterCorner', ... 
                                      'leftEyeInnerCorner',     'leftEyeOuterCorner' };                        

        %% specific column format for features OPENFACE 
        columnFormat.x = 'eye_lmk_x_%d';                        
        columnFormat.y = 'eye_lmk_y_%d';                 
        FaceId         = 0;

        %% Initialize FaceInfo
        FaceInfo = OpenFaceInfoController ();    
        FaceInfo.load (inputOpenFaceFile, FaceId);  %% ... a face was specified
        FaceInfo.addHeader({ 'timestamp', 'success' });
        FaceInfo.addHeader(filteredFaceInfoHeaders, columnFormat);  %% default fields 
        FaceInfo.find (0.0);                                        %% only add these  
    
        
        myFlowAlyzer.postFn = @(x) determine_activity (x, res.OpenFaceInfo, FaceInfo);
        
        
    end    
end
    



clear textprogressbar;
textprogressbar('outputs: ');

vidObj.CurrentTime = res.StartTime;

%% looping 
while(hasFrame(vidObj) & (vidObj.CurrentTime < res.EndTime))   
    
        
    
    %% read input image 
    CurrentTime = vidObj.CurrentTime;
    Im = readFrame(vidObj);      
    Im = rgb2gray(Im);            
    annotatedImage = Im;
    
    %% Update information 
    if (isUsingOpenFaceInfo)
        FaceInfo.find(CurrentTime); 
    end
    
    
    %% smoothing 
    if (config.Parameters.SmoothingEnabled)
        Im = imfilter(Im, se);
    end    
    
    %% perform flow computation on whole image + generate 
    %setTime(myFlowAlyzer, CurrentTime);    
    
    step(myFlowAlyzer, Im, CurrentTime); 
    
    %% Set activity information 
        
        
    
    %% Unset regions if using OpenFace 
    %
    % Unset any tiles that don't contain the region     
    %
    
    %if (isUsingOpenFaceInfo)    
    %    %% get a registered region 
    %    %% check against all registered regions 
    %    %% loop
    %    
    %end
    
    
    %% write result  total Vx & Vy for each OUTPUT    
    write (myFlowAlyzer);
    
    %% show the output
    if ((config.Display.show) & (res.Display))        
        
        annotatedIm = draw(myFlowAlyzer, Im);
        reducedFrame = imresize(annotatedIm, config.Display.scale_factor);
        step(myPlayer, reducedFrame);
    end
    
    LastTime = CurrentTime; % = vidObj.CurrentTime;
    
    progress = round((vidObj.CurrentTime)/(res.EndTime - res.StartTime)*100);
    textprogressbar(progress);
    
end

textprogressbar(100);
textprogressbar('done');

end


function p = getfield (config, fieldstr)

    fn = fieldnames(config);    
    m  = ismember (fn, fieldstr);
    if (~any(m)) 
       error ('profile was not found.'); 
    end
    
    p = config.(fieldstr);
end


function determine_activity (myFlowAlyzer, FaceInfo, OpenFaceInfo)

% myFlowAlyzer
% FaceInfo
% res.OpenFaceInfo



end

