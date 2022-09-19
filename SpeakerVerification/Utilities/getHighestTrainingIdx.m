function highestIdx = getHighestTrainingIdx(gender)
global params;
highestIdx = eval(['params.subsetsSize.' gender]);
if (params.useDevSetForTraining)

    highestIdx = highestIdx(1) + highestIdx(2);
else
    highestIdx = highestIdx(1);
end