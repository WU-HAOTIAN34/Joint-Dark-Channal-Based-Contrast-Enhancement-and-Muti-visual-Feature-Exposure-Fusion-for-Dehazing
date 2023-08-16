function R = CP_AHE(I,H,W)

imageInComb = zeros(H, W*3);
imageInComb(:, 1:3:end) = I(:, :, 1);
imageInComb(:, 2:3:end) = I(:, :, 2);
imageInComb(:, 3:3:end) = I(:, :, 3);
imageOutComb = adapthisteq(imageInComb, "NumTiles", [24,8]);

imageOut = zeros(H, W, 3);
imageOut(:, :, 1) = imageOutComb(:, 1:3:end);
imageOut(:, :, 2) = imageOutComb(:, 2:3:end);
imageOut(:, :, 3) = imageOutComb(:, 3:3:end);

R=imageOut;

end

