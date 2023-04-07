% SetConditions() - set up experiment conditions with counter-balancing and randomizing
%
% Usage:
%   >> experimentConfiguration = SetExperimentVarialbes(expName, totalTrials, varNames, varLevelSettings);
%
% Inputs:
%   totalTrials  - [integer] number of trials designated for the experiment
%   varLevelSettings - [integer vector] numbers of levels of each variable
%
% Outputs:
%   exptConditions   - structure containing basic experiment information and variables settings
%
% Note:
%   totalTrials should be a multiple of varLevelSettings' cumulative
%   production, as required by counter balancing of variables;
% 	varNames and varLevelSettings should have matching number of elements
% 	to obtain valid variable settings


function exptConditions = SetConditions(totlaTrials, varSetting)
    initRandSeries = randperm(totlaTrials);
    totalVariables = numel(varSetting);
    exptConditions = cell([1, totalVariables]);
    totalConditions = prod(varSetting);
    if mod(totlaTrials, totalConditions) ~= 0
        error('Invalid input: Numbers of trials and total conditions not match.');
    else
        varOperators = fliplr(cumprod(fliplr(varSetting)));
        currentRandSeries = initRandSeries;
        for varIndex = 1:totalVariables
            currentGrouper = varOperators(varIndex);
            currentRandSeries = ShiftMod(currentRandSeries, currentGrouper);
            if varIndex < totalVariables
                currentDivider = varOperators(varIndex + 1);
                currentCondtions = ceil(currentRandSeries / currentDivider);
            else
                currentCondtions = currentRandSeries;
            end
            exptConditions{varIndex} = currentCondtions;
        end
    end
end





