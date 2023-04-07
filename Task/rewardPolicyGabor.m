
function [points, feedback] = rewardPolicyGabor(err, errorRange, pointsRange, flag)


      
    % Inputs
    % - 'error' is the output error from comptErrorGabor
    % - 'errorRange', 0-49, 1 deg each step
    % - 'pointsRange' 100-2, 2 points each step
    % - 'flag' = 0 means out of time
    % Output
    % -'points' is the points earned on that trial
    % -'feedback' is a text string showing points earned
    

    index = find(abs(err) == errorRange);
    if flag == 0
        feedback = 'Out of time ... try faster!';
        if isempty(index)
            points = pointsRange(end);
        else
            points = pointsRange(index);
        end
    else
        if isempty(index)
            points = pointsRange(end);
            feedback = 'Big error ... no pts!';
        elseif index == 1
            points = pointsRange(index);
            feedback = '+ 100 points, awesome!';
        else
            points = pointsRange(index);
            feedback = sprintf('+ %i points', points);
        end

    end
    

end