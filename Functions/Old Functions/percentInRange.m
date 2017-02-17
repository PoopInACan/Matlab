function [percentage, ind] = percentInRange(matrix,min,max)
if min > max % switch if they are backwards
    mintemp = max;
    max = min;
    min = mintemp;
end
ind = find(matrix > min & matrix < max);
numbers = matrix(matrix > min & matrix < max);
count = length(numbers);
tot = length(matrix);
percentage = count/tot;

