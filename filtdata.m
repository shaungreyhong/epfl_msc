function data = filterdata(data, condition)

%Filter out from data every sweeps that do not respect the given condition.
%INPUT:
% - data: The dataset that needs filtering.
% - condition: Must be of the form {fieldName, value1, ..., valueN} (e.g.:
% {'Sweep_Type', 'Onset', 'Onset_Whisker_Stim'}).
%OUTPUT:
% - data: Contains the same fields as the input, but only the sweeps
% meeting the condition (specified as input) are kept.

sweepIndexVector = zeros(size(data.(condition{1})));

for thisCondition = 2:size(condition, 2)
    switch(class(condition{2}))
        case 'char'
            sweepIndexVector = sweepIndexVector + strcmp(data.(condition{1}), condition{thisCondition});
        case 'double'
            sweepIndexVector = sweepIndexVector + data.(condition{1}) == condition{thisCondition};
        otherwise
            error('Error when filtering data. Make sure the conditions are valid.')
    end
end

sweepIndexVector = logical(sweepIndexVector);

myFields = fieldnames(data);
for thisField = 1:length(myFields)
    data.(cell2mat(myFields(thisField))) = data.(cell2mat(myFields(thisField)))(sweepIndexVector, :);
end

end
