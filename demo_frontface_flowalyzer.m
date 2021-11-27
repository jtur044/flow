
%% define output files 

% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!


%% mfon 
inputVideo       = './data/mfon/video.converted/clips/clip-2-disk-condition-4-1-disks.mp4';
outputVideo      = './data/mfon/video.converted/result/clip-2-disk-condition-4-1-disks/flow.output.mp4';
outputDataFile   = './data/mfon/video.converted/result/clip-2-disk-condition-4-1-disks/flow.csv';
openfaceDataFile = './data/mfon/video.converted/openface/clip-2-disk-condition-4-1-disks/clip-2-disk-condition-4-1-disks.csv';
configFile       = './data/mfon/flowalyzer-config.tiled.json';
logfile          = './data/mfon/log.txt';
StartTime        = 0;
EndTime          = 30;


OpenFaceInfo.Enable   = true;
OpenFaceInfo.Filename = openfaceDataFile;
OpenFaceInfo.RegionList = { 'LeftEye', 'RightEye', 'NoseTip' };


%% run analysis 


clear rlog;
rlog('on');
rlog(logfile);

configuration = load_configuration('./config/flowalyzer-config.tiled.json');
run_flowalyzer(inputVideo, outputVideo, outputDataFile, configuration, 'OpenFaceInfo', OpenFaceInfo, 'UseProfile', 'MatlabLK', 'StartTime', StartTime, 'EndTime', EndTime);
dataTable = readtable (outputDataFile);
figure(1); clf;
show_flowalyzer_result (dataTable, 'tile-5');


return
