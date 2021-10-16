function dataTable = apply_post_processing (configfile, inputfile, outputfile) 

% APPLY_POST_PROCESSING Apply post-processing to the named file
%
%   dataTable = apply_post_processing (configfile, inputfile, outputfile) 
%
% where 
%       inputfile is the inputfilename 
%       outputfile is the inputfilename 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MAIN 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataTable = readtable (inputfile);

%% individual outputs 
outputs   = unique(dataTable.name);
N = length (outputs);

if  (ischar (configfile))
    fprintf ('load configuration ... %s\n', configfile);
    config = load_configuration (configfile);
else
    config = configfile;
end


count = 1;
M = length(config.FILTERS);
for k = 1:M
    eachFilter = config.FILTERS{k};        
    if (eachFilter.Enabled)    
        each_str = eachFilter.function;
        fprintf ('%d. filter = "%s"\n', count, each_str);
        
        %% load & process each individual OUTPUT 
        totalTable = table ();
        for l = 1:N
            i = ismember (dataTable.name, outputs{l});
            subTable = dataTable (i, :);                
            fprintf (' - output = "%s" ', outputs{l});
            subTable = dispatch_function (eachFilter, subTable);                                    
            totalTable = [ totalTable ; subTable];
        end

        % update the filter 
        dataTable = totalTable;        
        count = count + 1;
    end    
end

%% save it !

if (nargin == 3)
    writetable (dataTable, outputfile);
end 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILTER DISPATCHER  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% dispatch function 

function y = dispatch_function  (this_filter, y)

    switch (this_filter.function)
       
        case { 'vblinkdetect' }

            t = y.(this_filter.input{1});
            f = y.(this_filter.input{2});
            lower = this_filter.lower;
            upper = this_filter.upper;                      
            timeout = this_filter.timeout;                                  
            y.(this_filter.output) = vblinkdetect (t, f, lower, upper, timeout);
            fprintf ('OK\n');
            
        case { 'detectblinkv' } 

            t = y.(this_filter.input{1});
            f = y.(this_filter.input{2});
            fps = this_filter
            
            [t, V, maxtab] = detectblinkv (t, f, fps, varargin)

            
        case { 'vthicken' }

            f = y.(this_filter.input);
            n = this_filter.value;                        
            y.(this_filter.output) = vthicken (f, n);
            fprintf ('OK\n');
            
        case { 'vnan' }

            f = y.(this_filter.input{1});
            n = logical(y.(this_filter.input{2}));                        
            e = this_filter.edges;   
            g = vnan (f, n, e);
            y.(this_filter.output) = g;
            fprintf ('OK\n');

        case { 'vcumtrapz' }

            t = y.(this_filter.input{1});
            f = y.(this_filter.input{2});
            g = vcumtrapz (t, f);
            y.(this_filter.output) = g;
            fprintf ('OK\n');

        case { 'medianFilter' }

            f = y.(this_filter.input{1});
            n = this_filter.npoints;
            g = medfilt1 (f, n, 'includenan');
            y.(this_filter.output) = g;
            fprintf ('OK\n');
                        
            
        case { 'tidy' }

            f = y.(this_filter.input{1});
            n = this_filter.value;
            thicken = this_filter.thicken;
                        
            is_tracking = y.(this_filter.input{2});
            y.(this_filter.output) = tidy (f, n, thicken, ~is_tracking);
            fprintf ('OK\n');


        case { 'detrender' }

            f = y.(this_filter.input{2});
            t = y.(this_filter.input{1});

            poly_order   = this_filter.value(1);
            min_duration = this_filter.value(2);
            y.(this_filter.output) = detrender (t, f, poly_order, min_duration);
            fprintf ('OK\n');

        case { 'gradient' }

            f = y.(this_filter.input{2});
            t = y.(this_filter.input{1});
            y.(this_filter.output) = grad (f, t);
            fprintf ('OK\n');
            
        otherwise            
            fprintf ('Function not found!\n');
            
            
    end

end




%% tidy - adds nans and medfilter
function f = tidy (f, npoint, n_thicken, is_deleted)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % n_point is [ front/back, mask, median filter, expand times ]
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %% put empty on the front and back  
        f(is_deleted) = nan;
        f = cleanSignal(f, npoint(1));  
        
        %% expand and connect small regions   
        mask = isnan (f);
        
        %% remove additional information around borders assuming there will be edge effects         
        for k = 1:n_thicken
            mask = logical(conv(mask, logical([ 1 1 1 ]), 'same'));
        end
                
        %% fill in borders assuming there will be edge effects                 
        mask = imfill(mask, [ npoint(2) 1  ]);
        f(mask) = nan;
        
        %% median filter and signal reset
        f = medfilt1(f, npoint(3));
        f = signalReset (f);
        
end

function f1 = detrender (t, f, poly_order, min_duration)


    %% create regions 
    labels = ~isnan(f);
    bp     = diff(labels);
    bp_start = find (bp > 0) + 1;
    bp_end   = find (bp < 0);

    if (isfinite(f(1)))
        bp_start = [ 1 ; bp_start ];
    end

    if (isfinite(f(end)))
        bp_end = [ bp_end ; length(f) ];
    end


    %% time regions 

    f1 = nan*f;

    M = length(bp_start);
    for k = 1:M

        t_start = t(bp_start(k));    
        t_end   = t(bp_end(k));

        t_duration = t_end - t_start;
        if  (t_duration > min_duration)  %% only keep regions greater than 1 second

            %% show detrended 
            t0 = t(bp_start(k):bp_end(k));
            x0 = f(bp_start(k):bp_end(k));
            x1 = detrend (x0, poly_order, 'omitnan');

            %% detrended 
            f1(bp_start(k):bp_end(k)) = x1 - x1(1); 

        end 

    end
end


function dfdt = grad (f, t)

        %% ignore first 10 samples and last 10 samples  
        df  = gradient (f);
        dt  = gradient(t);
        dfdt = df./dt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTICAL FLOW BASED FUNCTIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = vblinkdetect (t, f, lower, upper, timeout)
    g = false(size(f, 1), 1);    
    M = length(f);    

    fprintf ('\n');
    
    state = 0;
    for k = 2:M
 
        curr = f(k);
        last = f(k-1);
               
        switch (state)
                        
            case { 0 } %% search for onset   
    
                %% if the signal drops below the lower threshold 
                if  (curr < lower) & (last >= lower)
                    state = 1;
                    start_time = t(k);
                                        
                    fprintf ('start time = %4.3f curr = %4.3d last=%4.3f\n', start_time, curr, last);
                end
                
                
            case { 1 } %% search for onset   
                    
                %% offset if the signal drops below the upper threshold 
                %% if the signal drops below the lower threshold 

                time_elapsed = t(k) - start_time;                
                if  (((curr < upper) & (last >= upper)) | (time_elapsed > timeout))
                    state = 0;
                    g(k) = false;                    

                    end_time = t(k);
                    fprintf ('end time = %4.3f curr = %4.3d last=%4.3f\n', end_time, curr, last);
                    continue;
                end        
                g(k) = true;
              
        end        
    end    
end




%% tidy - adds nans and medfilter
function g = vthicken (f, npoint)

        %% expand and connect small regions   
        npoint = 2*npoint + 1;
        g = imdilate (f, true([ npoint 1 ]));        
        
end


%% tidy - adds nans and medfilter
function f = vnan (f, b, e)

        % use a variable mask 
        f(b) = nan;  
        
        % use edges 
        if (e > 0)
            f(1:e) = nan;           
            f(end-e:end) = nan;            
        end
end


function f1 = vcumtrapz (t, f)


    %% create regions 
    labels = ~isnan(f);
    bp     = diff(labels);
    bp_start = find (bp > 0) + 1;
    bp_end   = find (bp < 0);

    if (isfinite(f(1)))
        bp_start = [ 1 ; bp_start ];
    end

    if (isfinite(f(end)))
        bp_end = [ bp_end ; length(f) ];
    end


    %% time regions 

    f1 = nan*f;
    M = length(bp_start);
    for k = 1:M

        t_start = t(bp_start(k));    
        t_end   = t(bp_end(k));

        %% show detrended 
        t0 = t(bp_start(k):bp_end(k));
        x0 = f(bp_start(k):bp_end(k));
        % x1 = detrend (x0, poly_order, 'omitnan');

        %% trapezoidal method  
        % f1 = trapz (t0, x0);
        
        d = bp_end(k) - bp_start(k);
        
        if (d == 0)
            f1(bp_start(k):bp_end(k)) = 0;
        else
            f1(bp_start(k):bp_end(k)) = cumtrapz (t0, x0);             
        end

    end
end


%{ 
function [fX, fY, dfXdt, dfYdt] = update_signal (y0, which_x_field, which_y_field, filter)

    
        which_time_field = 'currentTime';
    
        t = y0.(which_time_field);
        
        %% ignore first 10 samples and last 10 samples  
        N  = 10;
        fX = cleanSignal(y0.finalX, N);
        fY = cleanSignal(y0.finalY, N);
        
        %% Add a raw derivative column 
        %dfXdt_raw = gradient(fX)./gradient(t);
        %dfYdt_raw = gradient(fY)./gradient(t);        
        %y.final_dXdt(rows) = dfXdt_raw; 
        %y.final_dYdt(rows) = dfYdt_raw; 
                
        %% do updates (OPENFACE) fill it in 
        [fX, tfX] = fillmissing(fX, 'linear','SamplePoints', t);
        [fY, tfY] = fillmissing(fY, 'linear','SamplePoints', t);
        
                      
        %% apply the specified filter 
        [fX, fY] = feval(filter, fX, fY);
                
        %% PUT MISSING DATA BACK
        fX(tfX) = nan; fX = fX(:);
        fY(tfY) = nan; fY = fY(:);

        %% NUMERICAL GRADIENTS        
        dfXdt = gradient(fX)./gradient(t);
        dfYdt = gradient(fY)./gradient(t);
                       
        %% RESET SIGNAL ON MAIN SIGNAL 
        fX = signalReset(fX);
        fY = signalReset(fY);
               

end
%}
