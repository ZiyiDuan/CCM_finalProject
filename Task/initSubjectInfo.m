function parameters = initSubjectInfo()
        
    subjNum = input('subject number: ');  
    run = input('run number: ');
    
    % Save
    
    parameters = struct;
    parameters.subjId = subjNum;
    parameters.run = run;

    % Create all necessary directories
  
%     CWD = [pwd '/']; % current working dir
    curr_dir = pwd; filesepinds = strfind(curr_dir,filesep);    % find the position for each /
    CWD = curr_dir(1:(filesepinds(end-1)));      % find the last folder by end-1    
    ALL_SUBJ = [CWD 'SubjectData/'];        % save subject data here
    SUBJ_DIR = [ALL_SUBJ 'subj' num2str(parameters.subjId) '/'];
    RUN_DIR = [SUBJ_DIR 'run' num2str(parameters.run) '/']; % folder for each subject's each run

    if ~exist(SUBJ_DIR), mkdir(SUBJ_DIR); end
    if ~exist(RUN_DIR)
        mkdir(RUN_DIR); 
    else
        if ~isempty(subjNum) % make sure I don't overwrite the runs (but if subjNum is empty, it's okay to overwrite because I'm probably testing)
            error('this run already exists!') 
        end
    end
 
    parameters.subjDir = SUBJ_DIR; 
    parameters.finalDir = RUN_DIR;
    parameters.fileName = strcat('subj', num2str(subjNum), '_', 'run', num2str(run));
    parameters.timeStamp = datetime; 

    rng(parameters.subjId+parameters.run);
    
    
end