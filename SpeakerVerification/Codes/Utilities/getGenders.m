function genders = getGenders()
global params;
if (strcmp(params.gender, 'male'))
    genders = {'male'};
elseif (strcmp(params.gender, 'female'))
    genders = {'female'};
else
    genders = {'male', 'female'};
end