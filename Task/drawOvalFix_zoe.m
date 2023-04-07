
function drawOvalFix(fixSize, fixOutLineSize, fixCol, inApertSize, inApertCol, screen)
    
        % Get pixel width and height for inner and outer circle based of VA
        r_pix_outer_w = round(fixSize * screen.pixels_per_deg_width/2);
        r_pix_outer_h = round(fixSize * screen.pixels_per_deg_height/2);
 
        r_pix_inner_w = round(fixSize * screen.pixels_per_deg_width/2/3);
        r_pix_inner_h = round(fixSize * screen.pixels_per_deg_height/2/3);
%         r_pix_outer_w = va2pixel(screen, fixSize);
%         r_pix_inner_w = va2pixel(screen, fixSize/3);

        
        % Coordinates for fixation cross
        xCoords = [-r_pix_outer_w r_pix_outer_w 0 0 ];
        yCoords = [0 0 -r_pix_outer_h r_pix_outer_h];
        allCoords = [xCoords; yCoords];

        % Coordinates for outer circle
        baseRect_outer = [0 0 r_pix_outer_w*2 r_pix_outer_h*2];
        maxDiameter_outer = ceil(max(baseRect_outer) * 1.1);    % smooth only for outer circle
        centeredRect_outer = CenterRectOnPoint(baseRect_outer, screen.xCenter, screen.yCenter);
        
        % Coordinates for inner circle
        baseRect_inner = [0 0 r_pix_inner_w*2 r_pix_inner_h*2];
        maxDiameter_inner = ceil(max(baseRect_inner) * 1.1);    % smooth only for inner circle
        centeredRect_inner = CenterRectOnPoint(baseRect_inner, screen.xCenter, screen.yCenter);
        
        % Draw Fixation cross
        Screen('FillOval', screen.win, fixCol, centeredRect_outer, maxDiameter_outer);
        Screen('DrawLines', screen.win, allCoords, round(r_pix_inner_w*1.5), ...
            screen.white, [screen.xCenter screen.yCenter]); % 2 is for smoothing
        Screen('FillOval', screen.win, fixCol, centeredRect_inner, maxDiameter_inner);
%         Screen('Flip', screen.win);
   
return