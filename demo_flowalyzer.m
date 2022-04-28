

%% define output files 

% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!

%{
%% mfon 
inputVideo       = './data/mfon/video.converted/clips/clip-2-disk-condition-4-1-disks.mp4';
outputVideo      = './data/mfon/video.converted/result/clip-2-disk-condition-4-1-disks/flow.output.mp4';
outputDataFile   = './data/mfon/video.converted/result/clip-2-disk-condition-4-1-disks/flow.csv';
openfaceDataFile = './data/mfon/video.converted/openface/clip-2-disk-condition-4-1-disks.csv';
configFile       = './data/mfon/flowalyzer-config.tiled.json';


OpenFaceInfo.Enable   = true;
OpenFaceInfo.Filename = openfaceDataFile;
OpenFaceInfo.RegionList = { 'LeftEye', 'RightEye', 'NoseTip' };


%% run analysis 
configuration = load_configuration('./config/flowalyzer-config.tiled.json');
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'OpenFaceInfo', openfaceDataFile);
dataTable = readtable (outputDataFile);
figure(1); clf;
show_flowalyzer_result (dataTable, 'tile-5');


return
%} 


%% Saeed 
inputVideo      = './data/Saeed/eye0.reduced.mp4';
outputVideo     = './data/Saeed/clip0.result.mp4';
outputDataFile  = './data/Saeed/clip0.result.csv';
configFile      = './data/Saeed/flowalyzer-config.tiled.json';
logfile         = './data/Saeed/log.txt';

bestTile        = 'tile-5';
StartTime       = 0;
EndTime         = 100;


%% j_kau 
%inputVideo      = './data/j_kau/eye0.reduced.mp4';
%outputVideo     = './data/j_kau/clip0.result.mp4';
%outputDataFile  = './data/j_kau/clip0.result.csv';
%bestTile        = 'tile-6';
%StartTime = 0;
%EndTime   = 100;

%% j_kau_3 
%inputVideo      = './data/j_kau_3/eye0.reduced.mp4';
%outputVideo     = './data/j_kau_3/clip0.result.mp4';
%outputDataFile  = './data/j_kau_3/clip0.result.csv';
%bestTile        = 'tile-6';
%StartTime = 0;
%EndTime   = 100;

%% Simulation
%inputVideo      = './data/Simulation/simulation.mp4';
%outputVideo     = './data/Simulation/simulation.result.mp4';
%outputDataFile  = './data/Simulation/simulation.result.csv';
%bestTile        = 'tile-5';
%StartTime = 0;
%EndTime   = 100;


clear rlog;
rlog(logfile);
configuration = load_configuration(configFile);
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'StartTime', StartTime, 'EndTime', EndTime, 'UseProfile', 'MatlabLK');
