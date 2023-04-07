
function keyP = initKeyboard(exptP, varargin)    
    %% Initializing button box and knob
    
        LoadPsychHID;
    
        %   Enable unified mode of KbName, so KbName accepts identical key names on
        %   all operating systems:
        KbName('UnifyKeyNames');
    
        %   get all devices
        devices = PsychHID('Devices');
      
        %%%%%%%%%%% THIS SHOULD BE MODIFIED ACCORDING TO SETUP %%%%%%%%%%%
   
        if strcmp(exptP.system,'scanRoom')
            % In the scanRoom,  
            % response devices are normally connected to '932' box,
            % whose productID is 8
            % only the knob is connected to '904' box,
            % whose productID is 12
            % In the control room,
            % mouses are connected to 'Magic Mouse',
            % whose productID is 617
            % keyboards are connected to 'Magic Keyboard',
            % whose productID is 615


            % buttonbox(bbx)
            idx_bbx = []; 
            productID_bbx = 8;
            usageName_bbx = 'Keyboard';
            % knob 
            idx_knob = [];
            productID_knob = 12;
            usageName_knob = 'Joystick';
            % keyboard (kb)
            idx_kb = [];
            productID_kb = 615;
            usageName_kb = 'Keyboard';

            for i = 1:size(devices, 2)
                device_ID = devices(i).productID;
                device_name = devices(i).usageName;
                if device_ID == productID_bbx && strcmp(device_name, usageName_bbx)
                    idx_bbx = i;
                end
                if device_ID == productID_knob && strcmp(device_name, usageName_knob)
                    idx_knob = i;
                end
                if device_ID == productID_kb && strcmp(device_name, usageName_kb)
                    idx_kb = i;
                end
                
            end
            
            %%%  Initialize buttonbox (bbx)
            if ~isempty(idx_bbx)
                keyP.bbx = idx_bbx; % CHECK!!
            else
                keyP.bbx = 0;
            end   
            %   create buttonbox events queue
            KbQueueCreate(keyP.bbx);
            PsychHID('KbQueueStart',keyP.bbx);
            
            %%%  Initialize knob (kbx)
            if ~isempty(idx_knob)
                keyP.kbx = idx_knob; % CHECK!!
            else
                keyP.kbx = 0;
            end
            %   create knob events queue
            KbQueueCreate(keyP.kbx);
            PsychHID('KbQueueStart',keyP.kbx);

            % Initialize (behavioral) keyboard
            if ~isempty(idx_kb)
                keyP.keyboard = idx_kb; % CHECK!!
            else
                keyP.keyboard = 0;
            end

        elseif strcmp(exptP.system,'exptRoom')
            idx_kb = [];
            productID_kb = 591;   % CHECK!!
            usageName_kb = 'Keyboard';
            for i = 1:size(devices, 2)
                device_ID = devices(i).productID;
                device_name = devices(i).usageName;
                if device_ID == productID_kb && strcmp(device_name, usageName_kb)
                    idx_kb = [idx_kb, i];
                end           
            end
            % Initialize (behavioral) keyboard
            if ~isempty(idx_kb)
                keyP.keyboard = idx_kb(2); % CHECK!!
            else
                keyP.keyboard = 0;
            end

        else
            idx_kb = [];
            productID_kb = 671;   % CHECK!!
            usageName_kb = 'Keyboard';
            for i = 1:size(devices, 2)
                device_ID = devices(i).productID;
                device_name = devices(i).usageName;
                if device_ID == productID_kb && strcmp(device_name, usageName_kb)
                    idx_kb = i;
                end           
            end
            % Initialize (behavioral) keyboard
            if ~isempty(idx_kb)
                keyP.keyboard = idx_kb; % CHECK!!
            else
                keyP.keyboard = 0;
            end
        end

            


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
    %% Assigning Keys
    
        if exptP.scanner == 1
            
            keyP.dial = KbName({'t','b'}); % check knob rotation
            %%% keep in mind that the direction of t and b are opposite for
            %%% scanner knob and psych powermate (behavioral room)
            keyP.lock = KbName({'1!','2@','3#','4$'}); %%% "right" button box
            keyP.pm = 0;
            keyP.startKey = KbName('5%'); % for backtick of trigger
            
        elseif exptP.scanner == 0
            if ismember('keyboard', varargin) % keyboard in behavioral
                keyP.dial = KbName({'RightArrow','LeftArrow'});
                keyP.lock = KbName({'SPACE'});
                keyP.pm = 0; 
                keyP.startKey = KbName('SPACE');
            elseif ismember('powermate', varargin)
                keyP.lock = KbName({'SPACE'});
                keyP.pm = PsychPowerMate('Open'); % powermate in behavioral
                keyP.startKey = KbName('5%');
            end
            
        end
        
        % add escape key
        keyP.quit = KbName('ESCAPE');
   
    
return


