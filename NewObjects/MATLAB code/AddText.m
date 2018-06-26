% Load files

type='food'; %trinket or food

orig_file_dir=sprintf('/Users/WhitneyGriggs/Box Sync/UCLA MSTP/Summer Rotation 2018/Logan Cross Project/NewObjects/WithoutText/imgs_%s/',type);
save_file_dir=sprintf('/Users/WhitneyGriggs/Box Sync/UCLA MSTP/Summer Rotation 2018/Logan Cross Project/NewObjects/WithText/imgs_%s/',type);

imagesToLoad=dir([orig_file_dir '*.jpg']);
imagesToLoad=sort_nat({imagesToLoad.name});
scale_factor=0.9;

%Process each image

if strcmp(type,'food')
    img_str={'3 Musketeers Bar','Doritos','Chips Ahoy Cookies','Kit Kat Bar','Twix Bar','Chocolate Muffins'...
        'Milano Cookies','Starbursts','Sun Chips','Mixed Fruit','Smoked Turkey','Smoked Salmon', 'Salami',...
        'American Cheese','Mozzarella Cheese','Roast Beef','Plain Yogurt','Blueberry Yogurt','Strawberry Yogurt',...
        'Powdered Donuts','Crunchy Donuts','Avocado','Blackberries','Cauliflower','Apple','Grapes','Orange','Mango',...
        'Raspberries','Strawberries','Grapefruit','Animal Crackers','Brown Sugar Poptart','Strawberry Poptart','Whatchamacallit Bar',...
        'Ritz Cracker and Cheese Dip','Smores Chewy Bar','Banana Chips','Chocolate Bananas','Crispy Apple','Vegetable Chips','Sweet Potato Chips',...
        'Mexicali Salad','Chopped Chicken Salad','Caesar Salad','Veggie Wrap','Super Burrito','Chocolate Covered Berries','Tuna Salad Wrap',...
        'Chicken & Roasted Beet Salad','Cherry Pie','Apple Pie','Green Bean Chips','Deviled Eggs','Caprese Sandwich','Red Velvet Cake',...
        'Chicken Tikka Masala','Lamb Vindaloo','Vegan Tikka Masala','Gnocchi','Margherita Pizza','Macarons','Pollo Asado Burrito','Bean and Cheese Burrito',...
        'Chocolate Chip Clif Bars','Blueberry Crisp Clif Bars','Yogurt Pretzels','Chocolate Pretzels','Ferrero Chocolates','Ghiradelli Chocolates'};
else
    img_str={'A Brief History of Time book','Freakonomics book','1984 book','Water bottle','Wireless mouse','Yoga mat','Hitchhiker''s Guide to the Galaxy book','Lord of the Rings Trilogy book',...
        'Caltech backpack','Caltech hat','Caltech banner','Caltech keychain','16GB USB stick','Caltech thermos','Caltech drawstring bag','Desk lamp','Stapler','Over-the-ear headphones','HEAD backpack',...
        'AA Batteries','Lock','Notebook','Bathroom scale','Playing cards','Honey Clementine scented candle','Rose scented candle','Umbrella','Android charger','iPhone charger','Clothes hangers','Beach towel',...
        'Cooking utensils','Silverware','Pens','Plates','Portable charger','Portable speaker','Screwdrivers','Sunglasses','Surge protector'};
end

for i=1:length(imagesToLoad)
%for i=1:1
new_image=uint8(zeros(1800,2400,3));
img=imread([orig_file_dir imagesToLoad{i}]);
img_resize=imresize(img,scale_factor);
img_resize_size=size(img_resize);
padding=[1800-img_resize_size(1) (2400-img_resize_size(2))/2];
new_image(padding(1)+1:end, padding(2)+1:padding(2)+img_resize_size(2), 1:3)=img_resize;


new_image_withText = insertText(new_image, [1200 100], img_str{i},'FontSize',120,'TextColor','white','BoxColor','black','BoxOpacity',0,'AnchorPoint','Center');
figure;
imshow(new_image_withText)
imwrite(new_image_withText,[save_file_dir imagesToLoad{i}]);
close all;
end
