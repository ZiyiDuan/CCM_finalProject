
function error = comptErrorGabor(origAng, respAng)

    % - describe the value of origAng and respAng from the horizontal line 
    % in 2 possible ways
    % - the value of each angle is already between 0 to 180 through 
    % transTheta
    
    angMat = [origAng respAng];
    
    for jj = 1:numel(angMat)
        
        if angMat(jj) <= 90
            newangMat{jj} = [angMat(jj) angMat(jj)+180];
        elseif angMat(jj) > 90
            newangMat{jj} = [angMat(jj) -(180-angMat(jj))];
        end
    end
    
    % calculate possible error values
    possErr = [newangMat{1}(1)-newangMat{2}(1) newangMat{1}(1)-newangMat{2}(2) ...
        newangMat{1}(2)-newangMat{2}(1) newangMat{1}(2)-newangMat{2}(2)];
    
    % choose the minimum
    [~, I] = min(abs(possErr)); 
    error = possErr(I);
    

end