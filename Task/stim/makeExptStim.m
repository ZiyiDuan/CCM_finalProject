
function finalStim = makeExptStim()
    % ask for system
    exptSystem = 'others';

    load(['screenP', '_', exptSystem, '.mat']); 
        % -this is on apocalypse/behavioral room
        % -therefore, the parameters are not matched to the actual ones in
        % scanner room (e.g., stim size in dva)
        % -when reporting, make sure to convert the pixel size back to dva
        % in terms of the screen parameters in the scanner room
    
    %% Parameters
    
    % -- these parameters are not the updated version
    % image size, should be the same as exptP, check it out!!
    stimP.size = 11;                      % diameter for the gabor itself, degrees
    stimP.imgSize = stimP.size+1;         % diameter including smoothed edge, degrees
    stimP.innerSize = 1.2;                % diameter for the oval-fixation, matchs exptP.inApert, degrees
    
    
    % conditions
    stimP.nPhase = 10;                     % # of phases within each trig
    stimP.phase = linspace(0,2*pi,stimP.nPhase+1);     % equi-distant phases
        stimP.phase(end) = [];
%     stimP.nAllOri = 180;


    % stimulus parameters
    stimP.sfStatic = 1;                   % spatial frequency for carrier (cycles per degree)
    stimP.angFreq = 5;                    % spatial frequency for modulator
    stimP.sinSize = 0.2;                  % defines edges of the aperture of the modulator
    stimP.cont = 0.8;                       % the contrast of carrier


%     stimP.square = 0;                     % 1:square wave(edges), 0:sin


    %% Prepare 
    
    visiblesize = [stimP.imgSize stimP.imgSize]*screenP.pixels_per_deg_width; % in pixels
    [x,y]=meshgrid(1:visiblesize, 1:visiblesize); % in pixels
    x = x-mean(x(:));
    y = y-mean(y(:));
    
    x = Scale(x)*stimP.imgSize - stimP.imgSize/2; % in degrees
    y = Scale(y)*stimP.imgSize - stimP.imgSize/2; % in degrees
    [th,r] = cart2pol(x,y);
    
    %% make the aperture of the stimulus
    patch = double(r <= stimP.size/2); % in degrees
    patch = patch & (r > stimP.innerSize/2); % in degrees
    
    sinFilter = sin(linspace(0,pi,stimP.sinSize*screenP.pixels_per_deg_width)).^4; % in pixels
    sinFilter = sinFilter'*sinFilter;
    sinFilter = sinFilter/sum(sinFilter(:));
    
    patch = conv2(patch, sinFilter,'same');

    %% Make final stimulus
    finalStim = nan([size(x), stimP.nPhase]);
            
    % generate 
    for phase = 1:stimP.nPhase
        % the original gabor orientation is vertical
        nx = x*cos(deg2rad(0)) + y*sin(deg2rad(0));
        % finalStim is defined by sfStatic, phase, and cont
        finalStim(:,:,phase) = cos(nx*stimP.sfStatic*2*pi+stimP.phase(phase)) *stimP.cont*.5;
        finalStim(:,:,phase) = finalStim(:,:,phase).* patch;
        % make the values range between 0 and 1
        finalStim(:,:,phase) = 0.5 + finalStim(:,:,phase);
    end

    
    imshow(finalStim(:,:,phase));


    %% save data for each modulator
    fname = ['exptStim_', exptSystem, '.mat'];
    save(fname, 'finalStim', 'stimP', '-v7.3');


return
    