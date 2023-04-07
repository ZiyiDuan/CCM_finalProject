    
function [ori, flag] = resp(exptP, screenP, keyP, imTex, condMat, ii, f, maskGreyTex)

% This code receives participants' keyboard/knob response and adjusts the
% orientation of the response display.
% Created by YK 11/1/2019


% -Inputs: parameter structures (exptP, screenP, keyP), index of grating
% texture which has default orientation 0 and different phases (texInd), 
% condition matrix generated in the main code (condMat), the index of the 
% current trial (ii)
% -Outputs: the final adjusted orientation (ori), whether participants
% ran out of time (flag=2) or finished adjusting in time (flag=1)

% orientation 0 is vertical, clockwise+, counterclockwise-

    flag = 0; % flag = 0 (time is up but no presponse) or 1 (finished adjusting)
    % set knob unit
    unit = 1;
    if exptP.scanner == 1
        unit = 2;   % specially for fMRI room
    end
    remUnit = 360; 
    
    
    % get initial orientation
    ori_init = condMat(ii,f('oriRespInit'));
    ori = ori_init;
    % get initial pm position
    if exptP.powermate == 1
        [button, dialPos_orig] = PsychPowerMate('Get', keyP.pm);
    end
        
    % start response
    t0 = GetSecs;
    while GetSecs - t0 <= exptP.respDur
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%% read from key/knob to let participants adjust motion direction
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
        switch exptP.powermate
                
            case 0 % scanner / behavioral keyboard
    
                if exptP.scanner == 1   % scanner 
                    
                    [~, ~, keyCode_button] = KbCheck(keyP.bbx);  % button box
                    [~, ~, keyCode_knob] = KbCheck(-1); % check all devices
                    
                    if ismember(find(keyCode_button), keyP.lock) 
                        flag = 1; % participants are finished adjusting (button box pressed)
                    elseif  find(keyCode_knob) == keyP.dial(1)
                        ori = rem(ori+unit, remUnit);
                            % to prevent situations where time's up but 
                            % participants have the button down / knob
                            % rotating, so unable to go to the last elseif
                            % statement (elseif GetSecs-t0>=exptP.respDur)
                    elseif find(keyCode_knob) == keyP.dial(2)
                        ori = rem(ori-unit, remUnit); 
                            % to prevent situations where time's up but 
                            % participants have the button down / knob
                            % rotating, so unable to go to the last elseif
                            % statement (elseif GetSecs-t0>=exptP.respDur)
                    end
                    
                    
                elseif exptP.scanner == 0   % behavioral keyboard
    
                    [~, ~, keyCode] = KbCheck(-1); % (behavioral) keyboard
                    
                    if ismember(find(keyCode), keyP.lock)
                        flag = 1;
                    elseif find(keyCode) == keyP.dial(1)
                        ori = rem(ori+unit, remUnit); 
                    elseif find(keyCode) == keyP.dial(2)
                        ori = rem(ori-unit, remUnit); 
                    end    
                end
                
            case 1 % powermate

                [button, dialPos] = PsychPowerMate('Get', keyP.pm);
                [~, ~, keyCode] = KbCheck(-1);   % keyboard for submit response
                
                if ismember(find(keyCode), keyP.lock)
                    flag = 1; % participants are finished adjusting (button box pressed)
                else
                    delta_dial = dialPos - dialPos_orig;
                    ori = rem(ori_init+unit*delta_dial, remUnit);
                end

        end
                         
        % force the ori between 0~359 degree
        if ori<0 || ori>359
            ori=ori+sign(ori)*(-1)*remUnit;
        end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
       
       Screen('DrawTexture', screenP.win, maskGreyTex);
       Screen('DrawTexture', screenP.win, imTex(condMat(ii,f('phase'))), [], [], ori);
       drawOvalFix(exptP.fixSize, exptP.fixOutLineSize, exptP.fixCol, ...
           exptP.inApert, screenP);
                % for testing code
       if exptP.debug == 1
           DrawFormattedText(screenP.win, num2str(ori), 'center', 'center');
       end

       Screen('Flip', screenP.win);
       if flag == 1 % finish adjusting
           break;
       end
    end
    
    % force the final response ori between 0~179 degree
    if ori<0 || ori>179
        ori=ori+sign(ori)*(-1)*(remUnit/2);
    end

    
return