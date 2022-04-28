
%% define output files 

%% Saaed
inputVideo      = './data/Saaed/eye0.reduced.mp4';

%% Simulation
%inputVideo      = './data/Simulation/simulation.mp4';        %% final result 

opticFlow = opticalFlowLK;
opticFlow.NoiseThreshold = 0.0005;

%% create a figure window
close all;
h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

vidReader = VideoReader(inputVideo,'CurrentTime',0);

while hasFrame(vidReader) & vidReader.CurrentTime < 10
    frameRGB = readFrame(vidReader);
    frameGray = im2gray(frameRGB);  
    flow = estimateFlow(opticFlow,frameGray);
    imshow(frameRGB)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',50,'Parent',hPlot);
    hold off
    pause(10^-3)
end