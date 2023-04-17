
function [imTex, maskGreyTex] = makeTextures(exptP, screenP, maskGrey)
        % make stimuli and aperture(grey mask) textures
        
        % loading stimuli matrix for current run
        DrawFormattedText(screenP.win, 'Loading display...', 'center', 'center', [255 255 255]);
        Screen('Flip', screenP.win);
        
        %% create the texture for stimuli
%         exptP.system = 'others';
        
        % define current stimuli 
        fname = ['exptStim_', exptP.system, '.mat'];
        load([pwd, '/stim/', fname], 'finalStim');
        
        imTex = nan(exptP.nPhase);

        for pp = 1:exptP.nPhase
            imTex(pp) = Screen('MakeTexture', screenP.win, ...
                double(finalStim(:,:,pp)), [], [], 2);
        end

        % end
        clear finalStim
        Screen('Flip', screenP.win);
        
        
        %% create texture for the aperture (grey mask)
        maskGreyTex = Screen('MakeTexture', screenP.win, maskGrey, [], [], 2);


return