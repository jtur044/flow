function run_flowalyzer_setup (this_profile, varargin)

% RUN_FLOWALYZER_SETUP Run the FLOWALYZER SETUP
%
% This programe requires a "setup.config" file.   
% 
%   1. generate eye signals data from the CONFIGFILE 
%   2. move generated files to a convenient local directory [X]
%   3. generate updates to the eye signals 
%   4. generate complete okn detection results 
%   5. generate per individual results summary 
%   6. show example tracker results matrix for the particular tracker 
%   7. generate the best matrix 
%   8. show the composite matrix 
% 
%

p = inputParser ();
p.addOptional ('KeepFirst', false);
p.addOptional ('OverWrite', false);
p.parse(varargin{:});
res = p.Results;

%% load the SETUP pipeline 
setups = load_configuration ('./config/setup.config');

fprintf ('Requested pipeline PROFILE .... %s', this_profile);

if (isfield(setups.PROFILE, this_profile))
    results = setups.PROFILE.(this_profile);
    fprintf ('[FOUND]\n');   
else
    fprintf ('[NOT FOUND]\n');
    fprintf ('Exiting.');
    return
end


%% SETUP 

if (results.converter)
    fprintf ('Running file converter\n');
    setup_converter (setups); 
end


if (results.splitfiles)
    fprintf ('Running file splitter\n');
    setup_splitfiles (setups); 
end

if (results.openface)
    fprintf ('Running OpenFace\n');
    setup_openface_feat (setups); 
end

if (results.configurator)
    fprintf ('Running Configuration\n');
    setup_configuration_files (setups, res); 
end

if (results.okndetection)
    fprintf ('Running OKN detection\n');
    setup_okndetection_files (setups, res); 
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SETUP FUNCTIONS 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function setup_okndetection_files (setups, res)

M = length(setups.participant.directories);
for k =1:M

    %% read all sub-directories participants (PER DAY)
    inputdir = fullfile (setups.directories.main, setups.directories.video, setups.participant.directories{k});   
    if (~exist(inputdir, 'dir'))
        fprintf ('setup dir NOT FOUND ... %s (Ignored)\n', inputdir);
        continue;
    end
    fprintf ('setup dir FOUND ... %s\n', inputdir);
        
    output = [];    
    each_directory = char(setups.participant.directories{k});
    
    %% get valid dirs (PARTICIPANTS)     
    dirs = getvaliddir (inputdir);
    Q = length(dirs);    
    for q = 1:Q 

        each_participant = char(dirs(q).name);

        %% create an output directory 
        outputdir = fullfile (setups.directories.results, each_directory, each_participant);           
        if (~exist(outputdir, 'dir'))
            fprintf ('create output directory ... %s\n', outputdir);
            mkdir (outputdir);
        end
                
        inputConfigFile = setups.template.okndetection;
        outputConfigFile = fullfile(outputdir, 'okndetection.json');
                
        %% copyfile the OKNDETECTION template 
        if (~exist(outputConfigFile, 'file') | res.OverWrite)        
            copyfile(inputConfigFile, outputConfigFile);
            fprintf ('copyfile okndetection .... %s [OK]\n', outputConfigFile);
        else 
            fprintf ('copyfile okndetection .... %s [IGNORED]\n', outputConfigFile);            
        end
        
    end
   
end


end



function setup_configuration_files (setups, res)

keepStr = 'true';

N = length(setups.participant.directories);
M = max([ 1, N ]);
each_directory = [];
for k =1:M


     %% read all sub-directories participants (PER DAY)
     if (N > 0)
        each_directory =  char(setups.participant.directories{k});
     end 
     
     inputdir = fullfile (setups.directories.main, setups.directories.video, each_directory);   
     if (~exist(inputdir, 'dir'))
        fprintf ('setup dir NOT FOUND ... %s (Ignored)\n', inputdir);
        continue;
     end
     fprintf ('setup dir FOUND ... %s\n', inputdir);

     output = [];    
    
    
    %% get valid dirs (PARTICIPANTS)     
    dirs = getvaliddir (inputdir);
    Q = length(dirs);    
    for q = 1:Q 

        each_participant = char(dirs(q).name);

        %% create an output directory 
        outputdir = fullfile (setups.directories.results, each_directory, each_participant);           
        if (~exist(outputdir, 'dir'))
            fprintf ('create output directory ... %s\n', outputdir);
            mkdir (outputdir);
        end
        
        
        %% PUT DEFAULT DIRECTORIES HERE!
        output.NULL = 'NULL';
        
        output.participant.Id          = each_participant;
        output.participant.Eye         = setups.participant.Eye;        
        output.participant.VA          = output.NULL;
        
        output.directories.main              = setups.directories.main;
        output.directories.results           = fullfile(setups.directories.results, each_directory, each_participant);        
        output.directories.video             = fullfile(setups.directories.video, each_directory, each_participant, 'clips');
        output.directories.gaze              = fullfile(setups.directories.gaze,  each_directory, each_participant, 'gaze');
        output.directories.metadata          = fullfile(setups.directories.video, each_directory, each_participant);        
        output.directories.openface_features = fullfile(setups.directories.openface.output, each_directory, each_participant);
        output.directories.protocol          = fullfile(setups.directories.video, each_directory);
                      
        
 
        
        %% read the "timeline.json"
        timelinefile = fullfile (setups.directories.main, setups.directories.video, each_directory, each_participant, 'timeline.json');         
        protocolfile = fullfile (setups.directories.main, setups.directories.video, each_directory, each_participant, 'protocol.json');                 
        timeline = loadjson(timelinefile);
        protocol = load_protocol(protocolfile);
        
        %% timeline information
        M = length(timeline);
        counter = 1;
        group_counter = 1;
        order_counter = 1;
        for l = 1:M

            each_timeline = timeline{l};           
            if (~strcmp(each_timeline.start.event.trial_type, 'disks'))
                continue;
            end 
            
            each_protocol = getTrial(protocol, each_timeline.start.event.trial_index);
            if  (~isfield(each_protocol, 'logMAR'))
                error ('inconsistent');
            end
                        
            id              = str2num(each_timeline.end.event.trial_index)+1;

            trial.id        = each_protocol.id;            
            trial.logMAR    = each_protocol.logMAR;
            trial.direction = each_protocol.direction;            
            if (strcmp(trial.id, 'no-disk-condition'))
               iscatch = true; 
            else 
               iscatch = false;                 
            end
            
            clipsstr  = sprintf('clip-%d-%s-%s', id, each_timeline.start.event.trial_index, each_timeline.start.event.trial_type);   
            clipsfile = fullfile(setups.directories.video, each_directory, each_participant, 'clips', strcat(clipsstr, '.mp4'));
            
            %% these should correspond to EVENTS 
            gazestr  = sprintf('gaze-%d-%s-%s', id, each_timeline.start.event.trial_index, each_timeline.start.event.trial_type);   
            gazefile = fullfile(setups.directories.video, each_directory, each_participant, 'gaze', strcat(gazestr, '.csv'));

            offile = fullfile(setups.directories.openface.output, each_directory, each_participant, clipsstr, strcat(clipsstr, '.csv'));

            %% Keep
            if (res.KeepFirst)
                if (counter == 1)
                    keepStr = 'true';
                else
                   keepStr = 'false';
                end
            end
            
            id = str2num(each_timeline.end.event.trial_index);
            
            %% include  
            output.processlist(counter).keep          = keepStr;
            output.processlist(counter).stimulus_id   = id; %timeline{l}.id;
            output.processlist(counter).id            = counter;            
            output.processlist(counter).name          = clipsstr;            
            output.processlist(counter).order         = order_counter;
            output.processlist(counter).group         = group_counter;
            output.processlist(counter).level         = trial.logMAR;   
            output.processlist(counter).direction     = trial.direction;   
            output.processlist(counter).video         = clipsfile;
            output.processlist(counter).gaze          = gazefile;
            output.processlist(counter).features      = offile;
            output.processlist(counter).islast        = false;
            output.processlist(counter).iscatch       = iscatch;
             
            %each_timeline.start.event.trial_index
                        
            counter = counter + 1;            
            if (strcmp(each_timeline.start.event.trial_index, 'no-disk-condition'))            
                order_counter = order_counter + 1;
                group_counter = 0;
            end            
            group_counter = group_counter + 1;
        end

        output.processlist(counter-1).islast        = true;
        
        
        % generate the PER PARTICIPANT file at this POINT         
        outputfile = fullfile (outputdir, 'clipslist.json');        
        savejson([], output, outputfile);
        
        processfile = fullfile (outputdir, 'processlist.json');
        templatefile    = setups.template.eye_signal_processor;
        
        % generate the PER PARTICIPANT TEMPLATE for EyeTracking 
        cmdstr = sprintf('mustache "%s" "%s" > "%s"', outputfile, templatefile, processfile);
        system(cmdstr);
        
        fprintf (' - generated ... %s\n', processfile);
        
    end
   
end

end


function ret_trial = getTrial (protocol, protocol_str)

    trial = protocol.DISKS;
    trial = rmfield (trial, 'trials');
    
    all_trials = protocol.DISKS.trials;
    M = length (all_trials);
    for k = 1:M        
        if (strcmp(all_trials{k}.id, protocol_str))   
            
            % remove common fields - with overwrite from "all_trials"
            each_trial = all_trials{k};
            common_fields = intersect (fieldnames(trial), fieldnames(each_trial));            
            if (~isempty(common_fields))
                trial = rmfield (trial, common_fields);
            end            
            
            ret_trial = mergestruct (trial, all_trials{k});           
            return
        end        
    end
    
    
    %% check fixation 
    all_trials = protocol.fixation;
    M = length (all_trials);
    for k = 1:M        
        if (strcmp(all_trials{k}.id, protocol_str))   
            ret_trial = all_trials{k};
            return
        end
        
    end
    
    %% nothing FOUND !
    error ('referenced trial not found');
    
end


function setup_openface_feat (setups)


N = length(setups.participant.directories);
M = max([ 1, N ]);
each_directory = [];

for k = 1:M

  
   %% read all sub-directories participants (PER DAY)
   if (N > 0)
      each_directory =  char(setups.participant.directories{k});
   end 

   
   %% read all sub-directories participants 
   inputdir = fullfile (setups.directories.main, setups.directories.video, each_directory);   
   if (~exist(inputdir, 'dir'))
        fprintf ('setup dir not found ... %s\n', each_dir);
        continue;
   end
   
   dirs = getvaliddir (inputdir);
   L = length(dirs);
   
   for l = 1:L

       %% check participant codes  
       participant = dirs(l).name;       
       if (strcmp(participant,'.') || strcmp(participant,'..'))  
            continue;
       end
       
       %% check participant codes         
       participantpath = fullfile (setups.directories.main, setups.directories.video, each_directory, participant);
       clipspath = fullfile (participantpath, 'clips');      
       fprintf ('reading clips path ... %s\n', clipspath);       
       if (~exist(clipspath, 'dir'))       
           %fprintf ('ignoring ... no "clips" directory set.\n');                   
           continue;
       else
           
           
           %% ./example-multi.sh "/Volumes/BACKUP/HPOD_REBOOT/VIDEO/129320.1046/clips/*.mp4" "/Volumes/BACKUP/HPOD_REBOOT/OPENFACE/129320.1046"

           inputvideo = fullfile(clipspath, strcat('*', setups.input.filetype));              
           % outputpath = fullfile(clipspath, strcat('*', setups.input.filetype));                         
           outputpath = fullfile (setups.directories.main, setups.directories.openface.output, each_directory, participant);
           
           fprintf ('input video ... %s\n', inputvideo);
           fprintf ('output path ... %s\n', outputpath);
           
           oldcd = cd();   
           try 
             cd(setups.directories.openface.bin);
             system(sprintf('./example.sh "%s" "%s"', inputvideo, outputpath));      
             oldcd = cd();                
           catch ME
               cd(oldcd);
               fprintf ('Error processing OPENFACE');
           end
           cd(oldcd);
           
       
       end
       
   end
    
end

end

%% setup the brightener 

function setup_converter (setups)

M = max([ 1 length(setups.participant.directories) ]);

for k = 1:M

   if (isempty(setups.participant.directories))
    each_dir = [];
   else    
    each_dir = setups.participant.directories{k}; 
   end
   
   %% read all sub-directories participants 
   inputdir = fullfile (setups.directories.main, setups.directories.video, each_dir);   
   if (~exist(inputdir, 'dir'))
        fprintf ('setup dir not found ... %s\n', each_dir);
        continue;
   end
      
    
   %% create FFMEPG options string 
   options_str = '';   
   if (isfield(setups, 'CONVERTER'))

       for l = 1:length(setups.CONVERTER)        
           each_converter = setups.CONVERTER{l};       
           if (each_converter.Enable)
               switch (each_converter.type)
                   case { 'adjust' }

                       c = each_converter.contrast;
                       b = each_converter.brightness;
                       s = each_converter.saturation;                   
                       this_option = sprintf('-vf "eq=contrast=%4.1f:brightness=%4.1f:saturation=%4.1f"', c, b, s);
                       options_str = strcat(options_str, this_option);

                   otherwise
                       error ('Unknown video conversion.');
               end
           end
       end

   end
   
   dirs = getvaliddir (inputdir);
   for l = 1:length(dirs)

       %% get each participant   
       participant = dirs(l).name;       

       %% check if participant needs to be ignored  
       if (isfield(setups, 'ignorelist'))
           
           if (~isempty(setups.ignorelist))
            is_in_ignorelist = any(cellfun (@(x) strcmp (x, participant), setups.ignorelist));
           else
               is_in_ignorelist = false;
           end
       else
            is_in_ignorelist = true;
       end
       
       if (strcmp(participant,'.') || strcmp(participant,'..') || is_in_ignorelist )  
            continue;
       end
       
       %% check participant codes         
       participantpath = fullfile (setups.directories.main, setups.directories.video, each_dir, participant);
       
       %% we want to use FFMPEG to CHANGE the video 
       fprintf ('converting video files.');
       inputfile = fullfile(participantpath, 'video.mp4');
       outputfile = fullfile(participantpath, 'video.converted.mp4');
       system(sprintf('ffmpeg -y -i "%s" %s -vcodec libx264 -pix_fmt yuv420p  "%s"', inputfile, options_str, outputfile));                                    
       
   end
       
  end
    
end
   



%% video split files 

function setup_splitfiles (setups)


M = max([ 1 length(setups.participant.directories) ]);

for k = 1:M

   if (isempty(setups.participant.directories))
    each_dir = [];
   else    
    each_dir = setups.participant.directories{k}; 
   end
   
   %% read all sub-directories participants 
   inputdir = fullfile (setups.directories.main, setups.directories.video, each_dir);   
   if (~exist(inputdir, 'dir'))
        fprintf ('setup dir not found ... %s\n', each_dir);
        continue;
    end
      
   dirs = getvaliddir (inputdir);
   
   for l = 1:length(dirs)

       %% check participant codes  
       participant = dirs(l).name;       
       
       if (isfield(setups, 'ignorelist'))
           
           if (~isempty(setups.ignorelist))
            is_in_ignorelist = any(cellfun (@(x) strcmp (x, participant), setups.ignorelist));
           else
               is_in_ignorelist = false;
           end
       else
            is_in_ignorelist = true;
       end
       
       if (strcmp(participant,'.') || strcmp(participant,'..') || is_in_ignorelist )  
            continue;
       end
       
       %% check participant codes         
       participantpath = fullfile (setups.directories.main, setups.directories.video, each_dir, participant);
       
       
       %% create a gazepath if GAZEFILE exists
       
       %{
       if (exist(fullfile(participantpath, 'gaze.csv'),'file'))            
            gazepath = fullfile (participantpath, 'gaze');      
            %createdir (gazepath);
            
            if (~exist(gazepath, 'dir'))
                fprintf ('create gazepath directory ... %s\n', gazepath);
                mkdir (gazepath);
            end
            fprintf ('setting up gaze path ... %s\n', gazepath);       

            %% load data file 
            gazefile       = fullfile(participantpath, 'gaze.csv');
            timelinefile   = fullfile(participantpath, 'timeline.json');          
            [data, events] = load_gazefile (gazefile);
            
            %% save individual events 
            M = length (events);
            for n = 1:M
                each_event = events(n);
                each_data = get_gazedata_by_event(each_event,data);
                outputfile = fullfile(gazepath, sprintf('gaze-%d-%s-%s.csv', n, each_event.trial_index, each_event.trial_type));
                writetable(each_data, outputfile);
            end
            
       end
       %}
       
       %% produce a video "CLIPS" path for individual videos
       clipspath = fullfile (participantpath, 'clips');      
       fprintf ('setting up clips path ... %s\n', clipspath);       
       if (~exist(clipspath, 'dir'))       
           %fprintf ('ignoring ... no "clips" directory set.\n');                  
           continue;
       else
       
           if   isempty(getvaliddir(clipspath)) | setups.forcecreate                  
                %% need to run videosplitter on this directory 
                
                %% converted 
                fprintf ('converting video files.');
                inputfile  = fullfile(participantpath, 'video.mp4');
                outputfile = fullfile(participantpath, 'video.converted.mp4');
                %copyfile(inputfile, outputfile);                 
                %system(sprintf('ffmpeg -y -i "%s" -vcodec libx264 -pix_fmt yuv420p "%s"', inputfile, outputfile));                                    
                timelinefile = fullfile(participantpath, 'timeline.json');          

                try 
                    % fprintf ('processing ... %s\n', inputfile);                            
                    % disp(sprintf ('videosplitter -i "%s" -t "%s" -o "%s"', inputfile, timelinefile, clipspath));
                    
                    system(sprintf('videosplitter -i "%s" -t "%s" -f "disks" -o "%s"', outputfile, timelinefile, clipspath));                                    
                    
                catch ME                   
                    fprintf ('error');                   
                    
                    ME
                end
            end
       
       end
       
   end
    
end
   

end



function setup_splitfiles_gaze (setups)


M = max([ 1 length(setups.participant.directories) ]);

for k = 1:M

   if (isempty(setups.participant.directories))
    each_dir = [];
   else    
    each_dir = setups.participant.directories{k}; 
   end
   
   %% read all sub-directories participants 
   inputdir = fullfile (setups.directories.main, setups.directories.video, each_dir);   
   if (~exist(inputdir, 'dir'))
        fprintf ('setup dir not found ... %s\n', each_dir);
        continue;
    end
      
   dirs = getvaliddir (inputdir);
   
   for l = 1:length(dirs)

       %% check participant codes  
       participant = dirs(l).name;       
       
       if (isfield(setups, 'ignorelist'))
           
           if (~isempty(setups.ignorelist))
            is_in_ignorelist = any(cellfun (@(x) strcmp (x, participant), setups.ignorelist));
           else
               is_in_ignorelist = false;
           end
       else
            is_in_ignorelist = true;
       end
       
       if (strcmp(participant,'.') || strcmp(participant,'..') || is_in_ignorelist )  
            continue;
       end
       
       %% check participant codes         
       participantpath = fullfile (setups.directories.main, setups.directories.video, each_dir, participant);
       
       
       %% create a gazepath if GAZEFILE exists
       if (exist(fullfile(participantpath, 'gaze.csv'),'file'))            
            gazepath = fullfile (participantpath, 'gaze');      
            %createdir (gazepath);
            
            if (~exist(gazepath, 'dir'))
                fprintf ('create gazepath directory ... %s\n', gazepath);
                mkdir (gazepath);
            end
            fprintf ('setting up gaze path ... %s\n', gazepath);       

            %% load data file 
            gazefile       = fullfile(participantpath, 'gaze.csv');
            timelinefile   = fullfile(participantpath, 'timeline.json');          
            [data, events] = load_gazefile (gazefile);
            
            %% save individual events 
            M = length (events);
            for n = 1:M
                each_event = events(n);
                each_data = get_gazedata_by_event(each_event,data);
                outputfile = fullfile(gazepath, sprintf('gaze-%d-%s-%s.csv', n, each_event.trial_index, each_event.trial_type));
                writetable(each_data, outputfile);
            end
            
       end
      

       
   end
    
end
   

end




function dirs = getvaliddir (inputfile)
   dirs   = dir(inputfile);         
   i = arrayfun (@(x) ismember(x.name, { '.', '..'}) | ~x.isdir, dirs);
   dirs = dirs(~i); 
end

function dirs = getfileslist (inputfile)
   dirs   = dir(inputfile);         
   i = arrayfun (@(x) ismember(x.name, { '.', '..'}) | x.isdir, dirs);
   dirs = dirs(~i); 
end

