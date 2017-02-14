function [av,stdev] = getAvStd(index,data)
    av = mean(data(index));
    stdev = std(data(index));
end
