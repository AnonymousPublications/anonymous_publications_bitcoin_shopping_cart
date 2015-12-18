This is the web application for Anonymous Publications.  This file is best read in a text editor.

:::::::: THE THINGS WORTH STEALING ::::::::::

- Code involving bitcoin purchases (should be extracted into a gem and then used where ever)
- Code involing encryption of user informaition (extract js to bower package and ruby code to a gem)



:::::::: DEPLOYMENT PROCEDURE :::::::::::::::

This web app is the absolute easiest way to start selling something without having to do a lot of signups, subscriptions and annoying work.  It's absolutely trivially easy, you only need to do 5 steps.  This should take 10 or 15 minutes maybe?  It will take more time if you're a developer and are actually checking out the code, but it won't take much longer, the app is very clearly written (in these parts) and even an absolute bad will have a grasp of how the code works after reading this section and lightly perusing the code.  

Step 1)  Generate a free bitcoin wallet address to be used for receiveing payments from customers

Step 2)  Clone the app to the server on which you're deploying

Step 3)  Set the configuration file

Step 4)  Administrate the server




:: Step 1 - Generate a Bitcoin Wallet Address ::

A bitcoin wallet is generated using complicated cryptographic mathematics.  You will probably at first think that "this can't really work" and this is because you are not as smart as you need to be in order to use bitcoin.  You can either learn more about the complicated cryptographic mathematics taking place (go here google.com/search?q=how+does+bitcoin+work+cause+im+dumb) or you can simply assume I know what I'm fucking talking about and use an app to generate a bitcoin wallet so you can just use it and I can stop typing this usage procedure already (go here google.com/search?q=install+multibit).  




:: Step 2 - Clone the app to the server and install dependencies/ test it ::

If you have never cloned and deployed a rails app before, you're in great luck, i'm going to type the words that convey an understanding as to how to do it.  You're fuckin welcome.  Basically, i'm going to assume you're doing this in a linux environment (in particular, debian since it's non-corporate and by far the most ported to OS in the world).  

[code]
# let's go ahead and install the app's system prerequisites.  The app requires postgresql
# Note: as postgresql is installing, it might have you take a moment to set up the database and ask you to specify a root password
$  apt-get install  postgresql libpq-dev

# First we install git, a version control system that allows you to 
# download source code repositories onto your computer really easily
$  apt-get install git git-core

# now we can issue the simple command that downloads the repository
$  git clone github.com/Anonymous_Publications/anonymous_publications_bitcoin_cart


# that created the folder "rails_bitcoin_shopping_cart" and put all the code in there
# so we're ready to install the app's ruby prerequisites
$  cd rails_bitcoin_shopping_cart
$  bundle install


#  Finally, you can test run the server
$  rails s
[/code]

Once you've gotten to the end of that procedure, you should be able to see some output like below

[code]
$  rails server
=> Booting Thin
=> Rails 3.2.19 application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
Thin web server (v1.6.2 codename Doc Brown)
Maximum connections set to 1024
Listening on 0.0.0.0:3000, CTRL+C to stop
[/code]

If so that means it's working!  You can test out the app by navigating to 127.0.0.1:3000 in a webbrowser.  

You can also run the complete test suite by simply running the `rake` command.  All the tests should pass unless noted on the github page.  If you deploy this app for your own means, you'll probably want to fork the app on github and use this command liberally to test your own changes (yes, write unit tests.. it's professional...) and also ensure that your changes don't break existing code.  




:: Step 3 - Setup the configuration file ::


The app's initialization settings exist in 3 places:
*  config/application.yml
*  config/initializers/populate_globals.rb
*  config/initializers/populate_the_database.rb


-> Let's go over config/application.yml.  

I dressed that file up nice and pretty with cool ASCII goodness.  It took a moment of concentration from me and so a little gratitude would be an ok thing.  The settings are commented and straight forward.  The first section is debugging settings.  When they're all set to true, the server will mock the API calls to bitcoin related stuff, and thus the app can be used, manually, and automatically tested in an offline environment.  When you deploy on a production server, you should set them all to false so people can actually buy your product over the bitcoin network and you can actually be paid for your product.  

App settings is another important section.  If you wanna use mail, specify your mail information there...  You don't have to.  AnonymousPublications is launching without mail support because all mail is essentially spam.  And monitored by mother fuckers.  The app works fine without mail and the user is prompted to print out their account information so it doesn't get lost.... They wont because they're mother fuckers... so at somepoint an email account could be used to recover people's accounts when they forget their passwords and junk.  The DEFAULT_USERS section contains username/ password/ role declarations.  These users will be created in the app's database on first boot as per the below line in an initializer:

(config/routes.rb)
[code]
.
.
.

do_populate_database
[/code]

So you're probably thinking, "Why the fuck is initialization code being invoked from the routes file???"  Well it's because devise relies on routes to be established before users can be created dummy!  So if we want to create default users on the apps first boot, we'll have to invoke code we defined in the most logical place (config/initializers/*) but that code is run *before* the routes are established so we just dropped the invocation code into the bottom of the routes file.  It's dope, just ignore it.  Here's where the `do_populate_database` method is defined:

(config/initializers/populate_the_database.rb)
[code]
def do_populate_database
  if Product.table_exists? and Product.count == 0
    populate_products 
    
    populate_retailers
    populate_roles
    
    populate_users   # you can't run this line until after routes are setup due to how devise works
  end
end
[/code]

Notice that the code only runs if the Product table hasn't been created yet?  So if you want to reset everything and start over from defaults, just drop the database, recreate it and then run the app (server/ console/et al).  


-> Let's go over config/initializers/populate_the_database.rb

So if you look over the populate_the_database.rb initializer, you'll see that the default database entries are hard coded (and the defaults are installed into the database thanks to an envocaction in the routes.rb file).  If you're creating products and just launching a new app, you'll probably appreciate having the ability to hard-code your default database structure right here in this file.  We had plans to create a seperate config/default_database/* files such as products.yml, users.yml, coupons.yml, blah, blah, but alas, #nomoretime, #youdoit.  

Here's the methods that you should consider modifying when you're making your own shopping cart app:

*  populate_products  
    # products are defined here.  Products are things that a user can buy.  
    # 
    
*  populate_discounts 
    # Discounts are special pricing variations that can be applied to 
    # purchases of users.  They can automatically come into play for every
    # product, or they can be applied when certain conditions are met such as 
    # bulk purchasing scenarios where when a user buys 10 units, a discounted
    # price is applied

*  populate_discount_specifications
    # this method is where discounts are assigned to products.  

*  populate_coupons
    # Coupons are special codes that you can give to users to enable discounts
    # to be applied to their puchase.  When you're just starting out, you can
    # ignore this.  Coupons are meant to be generated by the admin user using
    # the HTML interface at management's discression.  
    
*  populate_retailers 
    # This can be ignored... it's not related to most shopping carts, it was 
    # just for Anonymous Publications so people could shop local via USD
    



-> Let's go over config/initializers/populate_globals.rb

This file is where a bunch of the ENV variables set in application.yml get translated into ruby globals.  Some logic is performed in this file, but you really only need to be aware of 1 global in this whole damned file.  

$EmergencyBtcCost -  In the case that the price of a bitcoin cannot be assertained via at least one of the bitcoin lookup API services defined in application.yml (see financial) then the value specified here is what the user is charged for the product (after the price USD is converted into price in BTC given the exchange rate of $EmergencyBtcCost).  It's unlikely this global will ever be used.  Set it to below the cost of bitcoin to possibly take a bit of a hit on a few sales.  Oh bitcoin price... why won't you hold still for us.  


-> Let's talk about warning logs

So, sometimes shit goes wrong.  There are certain blocks of code that are only run into when shit is going slightly wrong.  The app was robustly built to account for shit going wrong, but when shit is going wrong, it really should get an admin's attention.  Logs of shit going wrong are kept in http://127.0.0.1:3000/messages and you'll be able to view these messages only as admin.  The logs are very rough and lack quality of information...  #nomoretime.  



-> other spots...

Below are not settings exactly... but they need to be modified to make your app more survailence/hacker resistant...
[code]
*  config/initializers/secret_token.rb # the secret token must be changed to something unique
*  config/initializers/devise.rb       # the config.secret_key needs to be change to something unique here as well
*  config/initializers/fix_ssl.rb      # ummm... I vaguely remember creating this file because I was debugging the app live on an insecure host... 
                                       # I think the file can be deleted, but if you have SSL related 
                                       # errors, see here: http://stackoverflow.com/questions/5711190/how-to-get-rid-of-opensslsslsslerror
[/code]



:: Step 4 - Administrate the server ::

The system is setup to have an administrator, a downloader, a second offline computer responsible for decrypting the customer addresses, printing the shipping labels, and conducting the shipping cycle (a user named shipping does this).  The administration portal is available over http at 127.0.0.1:3000/admin_pages.  The page will look different whether you're logged in as...

* The Administrator (which shows every control including business management, customer management and debugging shit), 
* The downloader (which only shows downloader controls), or 
* Shipping (which only shows shipping controls).


When a user buys a book and pays their checkout wallet, a period of time "less than 2 hours I would say" must take place before the user's payment is confirmed by the bitcoin network.  Once it is confirmed, the downloader will be able to see that a paid sale is in the system by navigating to 127.0.0.1:3000/admin_pages/downloader_controls  The downloader should download this file and then get it to shipping where it can be imported into the offline shipping machine.  

When shipping navigates to 127.0.0.1:3000/admin_pages/shipping_control on the offline shipping machine, shipping will be able to click the link to "Upload purchase orders from a file".  The file they upload should be the file downloaded by the downloader in the above phase.  Assume there is one sale in that file.  After the sale upload, shipping will be able to click the link "" to see a page with the decrypted address on it.  They will then print this address (and any others on this page) onto some labeling paper, adhere it to a package, fill the packages with the product and then ship it via USPS.  Right now the system isn't setup right to handle multiple different products.  The UI should be changes to print off packing lists that help the shipping team determine what envelopes to use, and what products are placed into each envelope...  Packing lists are on the top of my TODO list, but fuck...  #nomoretime, #TODO

Once shipping has completed the shipping cycle (if there were any problems shipping to an address, they can use the HTML interface to mark those addresses as erroneous).  Then they can click the link to "Generate Address Completion File when done printing labels (checkmark)"  This will generate an "Address Completion File" which should be uploaded to the production server via the downloader's account (or admin's).  After this is done, the customer will be informed that their package has been shipped.  Then the rogue government will then raid my home and murder me in my bedroom as I'm coming out of sleep.  Thanks for playing Anonymous, I hope you have fun :)

Oh... if the user had their address marked erroneous, they'll be able to change it in HTML and the next time the Downloader makes a download, the correction will be included in their file so that shipping can make another attempt at shipping the file.  

TODO:  Make it so tracking can be done on the packages and that shipping can input the tracking numbers on the offline database and check off the package's tracking status periodically...  











::::::::::: Debuging/ Playing with the app :::::::::::

::::::::::::::::::::::
:: Console Commands ::
::::::::::::::::::::::

> refresh_database       # Delete's most database tables and set's things back 
                         # to default

> test_populate_users    # Creates a bunch of test users so you can see how the
                         # app behaves with many different purchases having 
                         # taken place
                         
> populate_my_test_sale  # Creates a sale for the user with an email of 
                         # "test@gmail.com" which is the default admin user 
                         # specified in application.yml, saves from having to 
                         # fill out the web form and create the sale over http


:::::::::::::::::::::::::::
:: HTML Interface Tricks ::
:::::::::::::::::::::::::::

If you enable "IS_DEBUGGING_UI" and "IS_DEBUG_API_ON" in application.yml, you'll have access to a bunch of cool buttons that make it easy to switch to being logged in as either admin (which I use for testing customer behavior too...), downloader, shipping.  


On the user's info page, you'll have buttons for: 
*  Deleting the user's bitcoin_payments, 
*  Mocking a request to lookup blockchain.info to see if there are new bitcoin payments
*  Show an error as would be displayed if the shipping team marked the address as erroneous



:::::::::::::::::::::::::::::::::::
:: Deployment and Staging Tricks ::
:::::::::::::::::::::::::::::::::::



::::: DEPLOYING PRODUCTION MACHINE :::::

You'll probably want to use some form of cheap shared hosting.  Anonymous Publications had to fallback to Heroku due to digital ocean being little bitches and shutting down our account because we were 'anonymous'.  Alternatively you could host your application on your own system at home and set it up through a tor hidden service... that's been on my todolist, but for now we're on heroku and it's working fine, plus I like the people who work at Heroku in the first place.  

So, deployment might look something like this...

1)  Push your fork of bitcoin-merchant-cart-anonynomicron

[code]
$  cd bitcoin-merchant-cart-anonynomicron

$  ssh your-hosting-provider
(web) $  git clone bitcoin-merchant-cart-anonynomicron 
                                          # change this to the actual address 
                                          # of your fork... maybe you'll create
                                          # a bare repo on the webserver and 
                                          # push to it over a VPN/ tor

$  cd bitcoin-merchant-cart-anonynomicron
$  rails server -e production -p 3000
                                          # the server will now be running on
                                          # port 3000 at your webhost... if 
                                          # you go to your-domain.net:3000
                                          # you'll see the production page
                                          # research rails deployment to do
                                          # a more serious job and not run
                                          # it in the console of your terminal
[/code]


::::: DEPLOYING PRINTING MACHINE :::::

The printing machine is the same as the production machine, just keep in mind the databases are slightly different.  
The production webserver will have a column original_id in it's tables all set to nil.  
Whereas the offline print server will have that collumn populated with the IDs as they exist on the webserver.  
So in effect, that whether that column has nulls or ints doubles as an indicator "is_this_offline_print_machine?"







:::::::::::::::::::: MANUAL SYSTEM TESTING PROCEDURE :::::::::::::::::::::

If you weren't a developer for Anonymous Publications, you might find it useful to test the app to make sure it works.  Yes, it's pretty complex at this point, and there are many settings which are simple for a software engineer to understand, yet also very critical to the system and if there's a typo in there, you'll have a non-working system.  Once you think you've configured the app correctly (config/application.yml), you can follow the below procedure to make sure the system is 100% working and also get a good picture of how the system is used.  


<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
>>   On Test Shipping Machine  <<
<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>

- Deploy the web app on the shipping machine, ofc
--> This involves generating a new public/private RSA key

<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
>>  On Test production machine <<
<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>

- Deploy the web app on the production machine, remember to setup the config/application.yml file, the bitcoin callback should be set to your domain name

- Create a new "customer" by doing a purchase and filling out the form on /purchases/new

- Mark the user as paid by using the "Evoke ajax lookup" button or by paying the checkout wallet displayed on their reciept page using a bitcoin application (and wait upto the 2 hour time period it takes for the payment to be fully confirmed by the bitcoin network which prevents lame/fun coin hacks depending on your perspective)

- Login as dl@anonlit.com (password will be in the application.yml file ofc)

- Download the "phase 1" file from /admin_pages/downloader_controls, the number should be x1, since you created and paid 1 sale

- Put the "phase 1" file onto the downloader's USB storage device

<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
>>   On Test Shipping Machine  <<
<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>

- Deploy the web app on the shipping machine, ofc
- Pull down the secret_data then return the thumb stick

- Login as the mailer
- Upload the completed_saless file
- Print a PDF of the files
- physically print the PDF file
- Move confirmations_file to the thumb stick

<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
>>  On Test production machine <<
<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>

- Login as the downloader
- Upload the confirmations_file

- Login as the original shopper
- Look to see if their sale has been marked shipped




















:::::::::::::##########################:::::::::::::::
:::::::::::::# Shipping Label Details #:::::::::::::::
:::::::::::::##########################:::::::::::::::

Shipping address information is encrypted using a public key stored in ./config/application.yml available as ENV['ENCRYPTION_KEY'].  The secret key (decryption) is only available on the offline printer machine being accessed exclusivly by the shipping team.  No decrypted addresses my come from the shipping team, but an file will come from downstream indicating whether there were any addresses that were unprintable.  


            [[-Production Machine-]]
                      ||
        Download over https from anonlit.com
                      ||
                      \/
             download_shippable.zip    <-- GET    anonlit.com/admin_pages/download_shippable     
                      ||                      (Encrypted Addresses ready to be shipped)
                      ||                      (Set's shippable sales to .prepped)
                      \/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~ Offline Transfer, VPN, STEGO, ETC ~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                      ||
                      ||
                      \/
              download_shippable.zip   <-- POST   127.0.0.1:3000/admin_pages/upload_shipped
                      ||                       (Populates Sales and Addresses tables)
                      ||                       ()
                      \/
             [[-Printer Machine-]]
              /|               |\
              ||               ||
              ||               \/
              ||              print_date.pdf   <-- GET  127.0.0.1:3000/admin_pages/shipping_control
              ||                [[-printer-]]
              ||
              ||   (mark erroneous addresses)
              ||
              \/
          address_completion_file.zip    <-- GET http://127.0.0.1:3000/admin_pages/address_completion_file
              ||
              ||
              ||
              \/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~ Offline Transfer, VPN, STEGO, ETC ~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              ||
              ||     http://127.0.0.1:3000/admin_pages/upload_shipped
              ||
              \/
   [[-Production Machine-]]  
              (handle erroneous addresses...)
      



:::::::::::::::######################:::::::::::::::::
:::::::::::::::# Purchasing Details #:::::::::::::::::
:::::::::::::::######################:::::::::::::::::




           [[Activist Buys Some bitcoins using his credit card from 3rd party bitcoin ppl]]
                                                           |
                                                           |
                                                          \./
           [[Guy Navigates to /purchases/new and fills out USER, ADDRESS, and SALE forms all on one page]]       
                       |                                |                            |
                       |                                |                            |
               (Address#create_instant_address)         |                            |
                                                  (User#create_instant_user)         |
                                                                               (Sale#create_instant_sale)
                                                                               |                  |
                                                              (CheckoutWallet#pew)              <<SEE PRICING ROUTINE>>
                                                                   ||
                                                                   ||
                                                                   \/
                                      ~~blockchain.info sets up a payment wallet~~
                                                                   ||
                                                                   ||
                                                                   \/
                                                     (sale#create_checkout_wallet)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ User sends bitcoins to the checkout address ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                      [[~Blockchain.info~]]
                                               ||
                                 GET /bitcoin_payments_callback {:value, :destination_address, :test}
                                               ||
                                               \/
                                   IF:
                                      - :value >= Sale#amount_needed
                                      - :destination_address == Our bitcoin wallet
                                      - :test != true
                                      - :secret_authorization_token == Sale#secret_authorization_token
                                      - :confirmations >= 6
                                         ||                       ||
                                         \/                       ||
                                  BitcoinPayment#new              ||
                                                                  \/
                                                       @sale.receipt_confirmed = Time.now
                                      
****************************************** <<< GO TO SHIPPING LABELS >>> ****************************************




::::::::::::::########################::::::::::::::::
::::::::::::::#   Pricing Details    #::::::::::::::::
::::::::::::::########################::::::::::::::::

Every time a selling price is requested, the app checks the price_history table and checks to see if the latest entry is more than a week old...  If it is then it looks up a new price, if not it uses the latest value in the table.  If the price history cannot be looked up, an alert should be set in the log.  


                                          [[- Sale#create_instant_sale -]]
                                           |        |       |       |
                            CheckoutWallet#pew      |       |       |
                                                    |       |       |
                                    Sale#save_line_item     |       |
                                                            |       |
                                       Sale#calculate_discounts     |
                                                                    |
                                            Sale#attach_checkout_wallet












::::::::::::::########################::::::::::::::::
::::::::::::::#   Import / Export    #::::::::::::::::
::::::::::::::########################::::::::::::::::

We use a really complicated system for exporting data from the production web server and into the shipping machine, and then viceversa.  
This system is used to ensure that the correct associations are maintained across the production/shipping server since auto-created
database keys are often used to find stuff...  This should all be refactored out into it's own gem and tested thoroughly there.  






_____________________________________________________________________________________    
|                                                                                   |
|          *Production Webserver*   ==Shippables==>   *Shipping Machine*            |
|___________________________________________________________________________________|


To move data from the production webserver to the shipping machine:

1) You will be transfering, Sales, LineITems, and Addresses

2) You will backup the id of the records as 'original_id'

  AdminPagesController#upload_shippable_file

  ::Importable#import_from_hash_to_shipping             # not true yet...
    Sales, backup id => original_id
    LineItems, backup id => original_id
    Addresses, backup id => original_id

3) You will re-map the associations on the new system with their new autogenerated id

  AdminPagesController#upload_shippable_file

  ::Importable#reassociate_with_adjusted_ids_for!(model)
    sales.address_id = Address.find_by_original_id(sale.address_id).id


_____________________________________________________________________________________    
|                                                                                   |
|     *Shipping Machine*   ==Address_completion_file==>   *Production Webserver*    |
|___________________________________________________________________________________|

To move data back from the shipping machine to the production webserver:

1)  You will be transfering, sales_ids, and sales_ids with erroneous addresses
    
2)  You will overwrite the ids with the backed up original_ids

::Importable#


3)  You will re-map the associations to correspond with the original ids.  

::Importable#




:::                              :::
:::  Sale#ReadyForShipmentBatch  :::
:::                              :::

- Created at export from webserver.  

- Imported at import onto shipping machine

- Cleared from sale on import of address_completion_file if sale was erroneous

- Existant on webserver once a shippable_sales_file is built

- Updated on webserver if a second shippable_sales_file is built before the last one was imported???

- Existant on shipping machine at import

:::                              :::
:::       Sale#original_id       :::
:::                              :::

- Created at import onto shipping machine

- Restored in export file on export from shipping machine

- non-existant on production webserver

- Used durint testing to indicate if the sale is simulated to be on the virtual webserver or to have been imported to the virtual shipping machine






                                 [[~Sales are made on anonlit.com~]]
                                               ||
                                 GET /admin_pages/shippable_file??
                                               ||          |
                                               ||         Sales.rdy_for_shipment are marked prepped
                                               ||         A new ReadyForShipmentBatch is generated unless 
                                               ||           an RFSB exists and a matching rfsb hasn't been 
                                               ||           recieved as an acf, in which case, that rfsb is used.
                                               ||           
                                               ||         All sales in the rdy_for_shipment ARcollection are set to this rfsb
                                               ||           and this rfsb shouldn't be changed or else
                                               ||
              ( zip array of sales, LineItems and Addresses that are not erroneous, and are marked receipt_confirmed )  
                                               ||
                                               \/
               [[ Offline transfer of shippable_file to shipping machine takes place ]]
                                               ||
                                 POST /admin_pages/upload_shippable
                                               ||              |
                                               ||            sf_nmd.integrity_hash is checked to prevent duplicate uploada
                                               ||
                                  GET /admin_pages/address_completion_file
                                               ||              |
                                               ||             Sales.shippable_or_whatever are put into the acf
                                               ||             
                                               \/
                            








::Notes::
- For Styling we used twitter bootstrap, and it's flow is used too
- The styling now is behind several version numbers... this is why widgets suck I can't upgrade, there's no path for my skin...
- There was a time where paypal merchant shopping cart things were investigated!!! http://thechangelog.com/paypal-javascript-buttons/






::Threats::
app/views/pages/home.html.erb         <- Contains connection to vimeo (video frame)
app/views/pages/donate.html.erb       <- Looks up anonymous linked bitcoin wallet via a js widget...
config/application.yml                <- Contains account configurations for emails

To mitigate threats, an application setting 'DISABLE_EXTERNAL_WIDGETS' was devised to illiminate the tracking capabilities inherant to these threats.  









