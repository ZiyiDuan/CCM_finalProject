function task()
    
    % this is the task for CCM final project

    clear; clc; close all; 
    
    % restoredefaultpath
    addpath(genpath('/Applications/Psychtoolbox/'));

    %% ---------------------------------- INITIALIZING ---------------------------------
    %%% debug
    exptP.debug = 0;
    exptP.system = 'others';
    exptP.scanner = 0;
    exptP.display = 1;
    exptP.powermate = 0;
    eyeP.eyeTracking = 0;

    %%% sbj info
    subjP = initSubjectInfo();

    %%% screen
    screenP = initScreen(exptP);
    Screen('TextSize', screenP.win, screenP.textSize);
    
    %%% parameter
    [condMat, exptP] = initParams(exptP, screenP, subjP);
    f = @(label)find(cellfun(@(y)~isempty(y), cellfun(@(x){strfind(x,label)}, exptP.label)));
    
  
    %%% make stimuli and grey mask textures
    [mask, maskGrey] = makeApertMask(screenP, exptP);
    [imTex, maskGreyTex] = makeTextures(exptP, screenP, maskGrey);

    %%% keyboard
    keyP = initKeyboard(exptP, 'keyboard');

    %% ---------------------------------- BEGIN EXPT ----------------------------------
    % welcome screen
    Screen('DrawTexture', screenP.win, maskGreyTex);
    % show stimuli to remind subj the current condition
    Screen('DrawTexture', screenP.win, imTex(condMat(1,f('phase'))));
    drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
                    exptP.inApert, screenP);
    % show instructions
    inst = sprintf('Welcome to run %i \n\nStimuli look like this', subjP.run);
%     inst = ['Welcome to the experiment!\n ' ...
%         'Please try to remember the orientation as precise as possible!'];
    DrawFormattedText(screenP.win, inst, 'center', screenP.yCenter/3); 
    Screen('Flip', screenP.win);

    WaitSecs(1);
    % start the experiment
    while true
        [~,secs, keyCode, deltaSecs] = KbCheck(-1);
        if find(keyCode) == keyP.startKey
            break
        end
    end

    % keeping track of time
    runTime = nan(3,1); 
        % row1: start of run / row2: end of run / row3: duration of run
    trialTime = nan(6,exptP.nTrial); 
        % each row is each event, and each column is each trial
        % 1: fixation
        % 2: stim 
        % 3: delay
        % 4: response
        % 5: error
        % 6: blank
        % 7: total duration for the trial
    runTime(1,1) = GetSecs;

    %% ---------------------------------- START TRIALS ----------------------------------
    % initialize quitRunning
    quitRunning = false;

    for ii = 1:exptP.nTrial
        %% fixation (event1)
        t0 = GetSecs;
        trialTime(1,ii) = t0-runTime(1,1); % start of fixation presentation

        while GetSecs - t0 <= exptP.fixDur % ensure the presentation time???
            Screen('DrawTexture', screenP.win, maskGreyTex);
            drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
                exptP.inApert, screenP);
            Screen('Flip', screenP.win);

            % check if quit
            [~,~,keys] = KbCheck(-1);
            if keys(keyP.quit)
                quitRunning = true;
                break
            end
        end

        % check if quit running
        if quitRunning
            break
        end

        %% test stimulus (event2)
        trialTime(2,ii) = GetSecs-runTime(1,1); % start of stim presentation
            
        while GetSecs - t0 <= exptP.fixDur+exptP.pres
            Screen('DrawTexture', screenP.win, maskGreyTex);
            Screen('DrawTexture', screenP.win, imTex(condMat(ii,f('phase'))), ...
                [], [], condMat(ii,f('oriFinal')));
            drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
                exptP.inApert, screenP);

            % for testing code
            if exptP.debug == 1
                DrawFormattedText(screenP.win, num2str(condMat(ii,f('oriFinal'))), 'center', 'center');
            end

            Screen('Flip', screenP.win);

            % check if quit
            [~,~,keys] = KbCheck(-1);
            if keys(keyP.quit)
                quitRunning = true;
                break
            end
        end

        % check if quit running
        if quitRunning
            break
        end

        %% delay (event3)
        trialTime(3,ii) = GetSecs - runTime(1,1); % start of delay
            
        % noise mask!
        noisemask = gen_noisemask(exptP,screenP);
        for mm = 1:exptP.mask.durTimes
            noisemasktex = Screen('MakeTexture', screenP.win, noisemask(:,:,mm), [], [], 2);
            Screen('DrawTexture', screenP.win, maskGreyTex)
            Screen('DrawTexture', screenP.win, noisemasktex)
            drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
                exptP.inApert, screenP);
            Screen('Flip', screenP.win);
            WaitSecs(exptP.mask.dur);
        end

        % delay without mask
        if exptP.debug == 1
            exptP.delay = exptP.TR*3;
        end
        while GetSecs - t0 <= exptP.fixDur+exptP.pres+exptP.delay
            Screen('DrawTexture', screenP.win, maskGreyTex)
            drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
                exptP.inApert, screenP);
            Screen('Flip', screenP.win);

            % check if quit
            [~,~,keys] = KbCheck(-1);
            if keys(keyP.quit)
                quitRunning = true;
                break
            end
        end

        % check if quit running
        if quitRunning
            break
        end

        %% response desplay (event4)
        beginResp = GetSecs;
        trialTime(4,ii) = beginResp-runTime(1,1); % start of response


        [ori, flag] = resp(exptP, screenP, keyP, imTex, condMat, ii, f, maskGreyTex);
        if flag == 0, condMat(ii,f('outoftime')) = 1; end
        condMat(ii,f('oriRespFinal')) = ori;

        condMat(ii,f('rt')) = GetSecs - beginResp; % rt



        %% Feedback: error and points (event5)
        beginFeedback = GetSecs;
        trialTime(5,ii) = beginFeedback-runTime(1,1); % start of error display


        % compute error and points
        condMat(ii,f('error')) = comptErrorGabor(condMat(ii,f('oriFinal')), ...
            condMat(ii,f('oriRespFinal')));
        [condMat(ii,f('points')), feedbackText] = rewardPolicyGabor(condMat(ii,f('error')), ...
            exptP.errorRange, exptP.pointsRange, flag);

        % draw grey mask and fixation
        Screen('DrawTexture', screenP.win, maskGreyTex)
        drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
            exptP.inApert,  screenP);

        % print out error
        finalError = abs(condMat(ii,f('error')));
        errText = sprintf('%.1f ° error', finalError);
        DrawFormattedText(screenP.win, errText, 'center',exptP.errTextCoords(2), screenP.white);
        DrawFormattedText(screenP.win, feedbackText, 'center', exptP.errTextCoords(3), screenP.white);

        Screen('Flip', screenP.win);
        WaitSecs(exptP.errDur-(GetSecs-beginFeedback));

        %% ITI (event6)
        trialTime(6,ii) = GetSecs-runTime(1,1); % start of iti(blank screen)
            
        % get current iti
        curr_iti = condMat(ii,f('iti'));
        if exptP.debug == 1
            curr_iti = exptP.TR*2;
        end
        while GetSecs-beginResp <= curr_iti + exptP.respDur + exptP.errDur
            % correct for time when adjustment finished early

            Screen('DrawTexture', screenP.win, maskGreyTex)
            drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.dimFixCol, ...
                exptP.inApert,  screenP);
            Screen('Flip', screenP.win);

            % check if quit
            [~,~,keys] = KbCheck(-1);
            if keys(keyP.quit)
                quitRunning = true;
                break
            end
        end

        % check if quit running
        if quitRunning
            break
        end

        %% Timing
        trialTime(7,ii) = GetSecs - runTime(1,1) - trialTime(1,ii);  % total trial duration
          
    end

    %% ---------------------------------- ALL TRIALS FINISHED ----------------------------------
    
    %%% timestamp 
    
    runTime(2,1) = GetSecs;
    runTime(3,1) = runTime(2,1)-runTime(1,1); % run duration

    exptP.runTime = runTime;
    exptP.trialTime = trialTime; 

    
    %%% show points earned
    finalPoints = nanmean(condMat(:,f('points')));
    text_end = strcat('End of run', num2str(subjP.run));
    text_points = ['Average Pts earned:', ' ', num2str(round(finalPoints)), ...
        '/100'];
    DrawFormattedText(screenP.win, text_end, 'center', 'center', [255 255 255]);
    DrawFormattedText(screenP.win, text_points, 'center', ...
        screenP.yCenter+ceil(exptP.fixSize*screenP.pixels_per_deg_height+screenP.textSize), [255 255 255]);
    Screen('Flip', screenP.win);
    WaitSecs(3);

    %% ---------------------------------- SAVE ----------------------------------
    
    if ~exist('eyeP')
        eyeP = [];
    end
    
    %%% backup txt files, just in case this run is lost
    save_backup(condMat, exptP.trialTime, subjP)
    
    %%% save results into .mat
    save([subjP.finalDir, '/', subjP.fileName, '.mat'], 'condMat', 'exptP', 'screenP', ...
        'subjP', 'keyP', 'eyeP');
    %%% save results into

    sca; close all;

return