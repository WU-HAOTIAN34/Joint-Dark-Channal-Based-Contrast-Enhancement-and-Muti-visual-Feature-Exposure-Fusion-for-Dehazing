function R = DCH_AHE(I,dsize,H,W)

%calculate the dark channal map
mincolchan = zeros(H,W);
for i = 1:H
    for j = 1:W
        if I(i,j,1) <= I(i,j,2) && I(i,j,1) <= I(i,j,3)
            mincolchan(i,j) = I(i,j,1);
        elseif I(i,j,2) <= I(i,j,1) && I(i,j,2) <= I(i,j,3)
            mincolchan(i,j) = I(i,j,2);
        elseif I(i,j,3) <= I(i,j,1) && I(i,j,3) <= I(i,j,2)
            mincolchan(i,j) = I(i,j,3);
        end
    end
end
darkchan = zeros(H,W);
for i = 1:H
    for j = 1:W
        darkchan(i,j) = mincolchan (i,j);

        for k = -dsize:dsize
            for h = -dsize:dsize
                if i + k > 0 && i + k <= H && j + h > 0 && j + h <= W
                    if mincolchan(i+k,j+h) <= darkchan(i,j)
                        darkchan(i,j) = mincolchan(i+k,j+h);
                    end
                end
            end
        end
    end
end
darkchan = guidedfilter(rgb2gray(I),darkchan,60,0.0001);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% divide into two layers
first = zeros(H,W);
second = first;
mean = callambda(darkchan,H,W);
for i = 1:H
    for j = 1:W
        if darkchan(i,j) >= mean
            first(i,j) = 1;
            second(i,j) = darkchan(i,j);
        else
            first(i,j) = darkchan(i,j);
            second(i,j) = 0;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fir = ones(H,W,3);
sec = fir;
res = zeros(H,W,3);
for i = 1:H
    for j = 1:W
        if second(i,j) ~= 0 
            sec(i,j,:) = I(i,j,:);
        end
    end
end

imageOut = CP_AHE(sec,H,W);
for i = 1:H
    for j = 1:W
        if second(i,j) ~= 0 
            res(i,j,:) = imageOut(i,j,:);
        elseif second(i,j) == 0 
            fir(i,j,:) = I(i,j,:);
        end
    end
end



imageOut = CP_AHE(fir,H,W);
for i = 1:H
    for j = 1:W
        if second(i,j) ==0
            res(i,j,:) = imageOut(i,j,:);
        end
    end
end

R = res;

end