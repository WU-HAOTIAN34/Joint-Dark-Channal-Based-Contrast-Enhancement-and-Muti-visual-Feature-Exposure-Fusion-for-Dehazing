function lambda = callambda(I,H,W)

a = 1;
maxN = max(max(I));
minN = min(min(I));
lambda = 0.5*(minN + maxN);
n1 = 0;  
n0 = 0;
s1 = 0;
s0 = 0;
for i = 1:H
   for j = 1:W
       if I(i,j) >= lambda
           s1 = s1 + I(i,j);
           n1 = n1 + 1;
       elseif I(i,j) < lambda
           s0 = s0 + I(i,j);
           n0 = n0 + 1;
       end
   end
end
T1 = s1 / n1;
T0 = s0 / n0;
lambda = (T1 + T0) / 2;   
while a==1
    n1 = 0;
    n0 = 0;
    s1 = 0;
    s0 = 0;
    for i = 1:H
        for j = 1:W

            if I(i,j) >= lambda
                s1 = s1 + I(i,j);
                n1 = n1 + 1;
            elseif I(i,j) < lambda
                s0 = s0 + I(i,j);
                n0 = n0 + 1;
            end

        end
    end
    T1 = s1 / n1;
    T0 = s0 / n0;
    temp_lambda = (T1 + T0) / 2;
    if abs(lambda - temp_lambda) <= 0.000001       
        break
    else
        lambda = temp_lambda;
    end

end

end


