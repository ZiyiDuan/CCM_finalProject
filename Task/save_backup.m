
function save_backup(condMat, trialTime, subjP)

    
    %% condMat
    ID_condMat = fopen([subjP.finalDir, 'backup_condMat', '.txt'], 'w');
    for row = 1:size(condMat,1)
        fprintf(ID_condMat, [repmat(['%.3f', ' '], [1 size(condMat,2)]), '\n'], condMat(row,:));
    end
    fclose(ID_condMat)
    
    %% trialTime
    ID_trialTime = fopen([subjP.finalDir, 'backup_trialTime', '.txt'], 'w');
    for row = 1:size(trialTime,1)
        fprintf(ID_trialTime, [repmat(['%.3f', ' '], [1 size(trialTime,2)]), '\n'], ...
            trialTime(row,:));
    end
    fclose(ID_trialTime)
    

                    
                    
return
                    