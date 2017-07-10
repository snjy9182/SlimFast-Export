function [index number] = inmask(mask, Particles)
    Total = length(Particles);
    number = 0;
    index = [];
    [ylim xlim] = size(mask);
    for i = 1:Total
        TF = 0;
        x = floor(Particles(i, 4));
        y = floor(Particles(i, 3));

        if (x < xlim) & (y < ylim)
            if mask(x,y) == 1
                number = number + 1;
                TF = 1;
            end
        end
        index = [index TF];
    end
    index = logical(index');
end