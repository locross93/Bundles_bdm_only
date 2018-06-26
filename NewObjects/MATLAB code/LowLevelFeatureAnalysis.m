

type='trinket'; %trinket or food

orig_file_dir=sprintf('/Users/WhitneyGriggs/Box Sync/UCLA MSTP/Summer Rotation 2018/Logan Cross Project/NewObjects/WithoutText/imgs_%s/',type);

imagesToLoad=dir([orig_file_dir '*.jpg']);
imagesToLoad=sort_nat({imagesToLoad.name});

mean_intensity=zeros(length(imagesToLoad),3);
mean_luminance=zeros(length(imagesToLoad),1);
img_contrast=zeros(length(imagesToLoad),1);
mean_hsv=zeros(length(imagesToLoad),3);
for i=1:length(imagesToLoad)
    img=imread([orig_file_dir imagesToLoad{i}]);
    for j=1:3
        mean_intensity(i,j)=mean2(img(:,:,j));
    end
    mean_luminance(i)=mean2(luminance(img));
    img_contrast(i)=std2(luminance(img));
    img_hsv=rgb2hsv(img);
    for j=1:3
        mean_hsv(i,j)=mean2(img_hsv(:,:,j));
    end
    
end

figure;
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);


subplot(2,2,1)
plot(mean_luminance,'k');
title('Mean Luminance of each object');
xlabel('Object #');
ylabel('Luminance');

subplot(2,2,2)
plot(img_contrast,'k');
title('Contrast of each object');
xlabel('Object #');
ylabel('Contrast');

subplot(2,2,3)
color={'r','g','b'};
for i=1:3
    hold on;
    plot(mean_intensity(:,i),color{i});
    hold off;
end
title('Color intensity of each object');
xlabel('Object #');
ylabel('Intensity');

subplot(2,2,4)
color={'r','g','b'};
for i=1:3
    hold on;
    plot(mean_hsv(:,i),color{i});
    hold off;
end
legend('Hue','Saturation','Brightness');
title('HSV of each object');
xlabel('Object #');


function luminance_per_pixel=luminance(img_in)
luminance_per_pixel=img_in(:,:,1)*0.2126+img_in(:,:,2)*0.7152+img_in(:,:,3)*0.0722;
end

