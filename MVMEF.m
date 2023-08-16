function R = MVMEF(input,dsize)

img_haze = double(input) / 255;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%obtain the sequence of exposure image
[H, W, C] = size(img_haze);
I = zeros(H, W, 3, 5);

I(:,:,:,1) = DCH_AHE(img_haze,dsize,H,W);  

for i = 2:5
    I(:,:,:,i) = I(:,:,:,1) .^ double(i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate the original weight map

%calculate the mean map
I_k = zeros(H, W, 5);
for i = 1:5
    I_k(:,:,i) = (I(:,:,1,i) + I(:,:,2,i) + I(:,:,3,i)) ./ 3;
end

%calculate constract map
LF = [0 1 0; 1 -4 1; 0 1 0];
constractSeq = zeros(H, W, 5);
for i = 1:5
    constractSeq(:,:,i) = abs(imfilter(I_k(:,:,i), LF,'replicate'));
end

% calculate saturation map
saturationSeq = zeros(H, W, 5);
for i = 1:5
    min_map = zeros(H, W);
    for j = 1:H
        for k = 1:W
            if I(j,k,1,i) <= I(j,k,2,i) && I(j,k,1,i) <= I(j,k,3,i)
                min_map(j,k) = I(j,k,1,i);
            elseif I(j,k,2,i) <= I(j,k,1,i) && I(j,k,2,i) <= I(j,k,3,i)
                min_map(j,k) = I(j,k,2,i);
            else
                min_map(j,k) = I(j,k,3,i);
            end
        end
    end
    saturationSeq(:,:,i) = 1 - (min_map ./ I_k(:,:,i));
    
end


%calculate exposure map
exposureMap = zeros(H, W, 5);
for i = 1:5
    Ik_mean = sum(sum(I_k(:,:,i))) / W / H;
    exposureMap(:,:,i) = exp(-(I_k(:,:,i) - 1 + Ik_mean) .^ 2 / (2 * 0.5^2));
end

%calculate the original weight map
original_weight_map = zeros(H, W, 5);

for i = 1:5
    w_c = zeros(H,W);
    c_mean = sum(sum(constractSeq(:,:,i))) / H / W;
    w_s = zeros(H,W);
    w_e = zeros(H,W);
    e_mean = sum(sum(exposureMap(:,:,i))) / H / W;
    
    for j = 1:H
        for k = 1:W
            w_c(j,k) = floor(c_mean - constractSeq(j,k,i)) * 2; 
            a = sort([saturationSeq(j,k,1), saturationSeq(j,k,2), saturationSeq(j,k,3), saturationSeq(j,k,4), saturationSeq(j,k,5)]);
            max = a(1,5);
            w_s(j,k) = ((-saturationSeq(j,k,i)) / (2-max))^3;
            w_e(j,k) = (e_mean - exposureMap(j,k,i) + 1) ^ (6-i);
        end
    end
    original_weight_map(:,:,i) = (constractSeq(:,:,i).^ w_c) .* (saturationSeq(:,:,i).^w_s) .* (exposureMap(:,:,i).^w_e);
end

original_weight_map = real(original_weight_map);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % obtain the original decision map
original_decision_map = zeros(H, W, 5);
for i = 1: 5
    original_decision_map(:,:,i) = I_k(:,:,i) - guidedfilter(I_k(:,:,i), I_k(:,:,i), 2, 0.4^2);
end

decision_min_map = zeros(H, W);
for i = 1:H
    for j = 1: W
        for k = 1:5
            if decision_min_map(i, j) >= original_decision_map(i,j,k)
                decision_min_map(i,j) = original_decision_map(i,j,k);
            end
        end
    end
end

decision_max_map = zeros(H, W);
for i = 1:H
    for j = 1: W
        for k = 1:5
            if decision_max_map(i, j) <= original_decision_map(i,j,k)
                decision_max_map(i,j) = original_decision_map(i,j,k);
            end
        end
    end
end

MaxMap = zeros(H,W,5);
for i = 1:5
    for j = 1:H
        for k = 1:W
            if original_decision_map(j,k,i) == decision_max_map(j,k)
                MaxMap(j,k,i) = 1;
            end
        end
    end
end

MinMap = zeros(H,W,5);
for i = 1:5
    for j = 1:H
        for k = 1:W
            if original_decision_map(j,k,i) == decision_min_map(j,k)
                MinMap(j,k,i) = 1;
            end
        end
    end
end


final_decision_map = zeros(H,W,5);
for i = 1:5
    final_decision_map(:,:,i) = abs(MaxMap(:,:,i) - MinMap(:,:,i));
end


final_weight_map = zeros(H,W,5);
for i =1:5
    final_weight_map(:,:,i) = (original_weight_map(:,:,i) .* final_decision_map(:,:,i));  
end

Wk = zeros(H, W, 5);
for i = 1:5
    Wk(:,:,i) = final_weight_map(:,:,i) ./ (final_weight_map(:,:,1)+final_weight_map(:,:,2)+final_weight_map(:,:,3)+final_weight_map(:,:,4)+final_weight_map(:,:,5));
end

Wk = real(Wk);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pyr = gaussian_pyramid(zeros(H,W,3));
nlev = length(pyr);

%multiresolution blending
for i = 1:5
    %construct pyramid from each input image
    pyrW = gaussian_pyramid(Wk(:,:,i));
    pyrI = laplacian_pyramid(I(:,:,:,i));
    
   % blend
    for l = 1:nlev
        w = repmat(pyrW{l},[1 1 3]);
        pyr{l} = pyr{l} + w.*pyrI{l};
    end
end

%reconstruct
R = reconstruct_laplacian_pyramid(pyr);

R = real(R);
figure(11)
subplot(1,2,1), imshow(img_haze)
subplot(1,2,2), imshow(R)


end

