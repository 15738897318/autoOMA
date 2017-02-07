function [mfreq,mshape] = cfdd(input,window,overlap,nfft,fs)

% calculate the frequency resolution range
fres = linspace(0,fs,nfft);
fres = fres(1:(nfft/2+1));

%obtain the average cross-psd matrix
disp('Calculating cross-psd matrix -----');
psd = cpsdm(input(:,:,1),window,overlap,nfft,fs); %initial matrix
for i=2:size(input,3)
  psd = psd + cpsdm(input(:,:,i),window,overlap,nfft,fs); %accumulate
  disp('averaging psd matrix');
end
psd = psd./size(input,3); %average

% Calculate the SVD of cpsd matrix for each frequency
disp('Calculating SVD -----');
nsingular = 3; %number of singular values to be saved
for i=1:size(psd,3)
  [u,s,~] = svd(psd(:,:,i));
  for j=1:nsingular
    svalue(i,j) = s(j,j);
    svector(:,i,j) = u(:,j);
  end
end

% Plot the singular values of psd matrix
disp('Plotting SVD -----');
figure
plot(fres, mag2db(svalue(:,1)));
hold on
plot(fres, mag2db(svalue(:,2)));
plot(fres, mag2db(svalue(:,3)));

mfreq = svalue(:,1);
mshape = svector(:,:,1);