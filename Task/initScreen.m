
function screen = initScreen(exptP)

    Screen('Preference', 'SkipSyncTests', 1); % for mac
%     PsychDefaultSetup(1); % for PC

    
    if exptP.debug == 1
        PsychDebugWindowConfiguration(0, 0.5);  
    elseif exptP.debug == 0
        PsychDebugWindowConfiguration(0, 1); 
    end

    screen = struct;
    

    screen.screenViewDist = 57;

       
    screens = Screen('Screens');
    screen.screenId = max(screens);
    
    % screen init for PC and MAC
    screen.white = WhiteIndex(screen.screenId);
    screen.black = BlackIndex(screen.screenId);
    screen.grey = screen.white*0.5;
    screen.red = [255, 0, 0];

    % textsize
    screen.textSize = 55;


    % open window
    if exptP.display == 1
        % set this to get the best resolution for mac retinotopy display only
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'UseRetinaResolution');
    end

    [screen.win, screen.screenRect] = PsychImaging('OpenWindow', screen.screenId, ...
        screen.black, [], 32, 2, [], [], kPsychNeed32BPCFloat);

    % get screen width and height in mm
    [screen.screenWidth, screen.screenHeight] = Screen('DisplaySize',screen.screenId); 
    screen.screenWidth = screen.screenWidth/10; % mm to cm
    screen.screenHeight = screen.screenHeight/10; % mm to cm
    
    % correct the screen width and height maually
    screen.screenWidth = 54; % cm
    screen.screenHeight = 30.5; % cm

     
%     screen.Hperdegree = screen.screenViewDist * tan(deg2rad(1)); % height for one degree in cm
%     screen.Wperdegree = screen.Hperdegree; % width for one degree in cm
    % the simple equation for computing visual angle is tan(V) =
    % Screen/Distance (works for visual angles smaller than about 10
    % degrees)
    
    % get x and y pixels of screen
    [screen.screenXpixels, screen.screenYpixels] = Screen('WindowSize', screen.win); 
    screen.pixWidth = screen.screenWidth/screen.screenXpixels; % cm/pixel
    screen.pixHeight = screen.screenHeight/screen.screenYpixels; % cm/pixel
    screen.xCenter = screen.screenXpixels/2;
    screen.yCenter = screen.screenYpixels/2;
    
    screen.pixels_per_cm_Width = screen.screenXpixels/screen.screenWidth;  % pixel/cm  
    screen.pixels_per_cm_Height = screen.screenYpixels/screen.screenHeight;  % pixel/cm
    screen.cm_per_degree = screen.screenViewDist * tand(1); % cm/degree
    screen.pixels_per_deg_width = screen.cm_per_degree * screen.pixels_per_cm_Width; % pixel/degree
    screen.pixels_per_deg_height = screen.cm_per_degree * screen.pixels_per_cm_Height; % pixel/degree
    %screen.deg_width = atand(screen.screenWidth/2 / screen.screenViewDist) * 2;
    %screen.deg_height = atand(screen.screenHeight/2 / screen.screenViewDist) * 2;
    % the more complex formula?
    
    %screen.pixels_per_deg_width = screen.screenXpixels/screen.deg_width; 
    %screen.pixels_per_deg_height = screen.screenYpixels/screen.deg_height;
    

    % to make sure that OpenGL based Psychtoolboxes are installed (versions in which 'Flip', 'MakeTexture', 'DrawTexture' work)
    AssertOpenGL; 


    screen.ifi = Screen('GetFlipInterval', screen.win);

    topPriorityLevel = MaxPriority(screen.win);  % retreive the maximum priority number
    
    Screen('BlendFunction', screen.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % set blend function for alpha blending
    
    if ~exptP.debug
        HideCursor;
    end

return
    
   