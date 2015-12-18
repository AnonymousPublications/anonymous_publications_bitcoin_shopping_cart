class WorkHard
  def self.display_satoshi_as_btc(amount_in_satoshi)
    amount_in_satoshi / 100000000.0
  end
  
  def self.convert_back_to_satoshi(amount_in_btc)
    (amount_in_btc * 100000000).to_i
  end
  
  def self.within_list?(param, list)
    list.each do |filtered_word|
      return true if param == filtered_word
    end
    return false
  end
  
  def self.how_to_pay_with_bitcoin_vid
    "<a href='#'>How to Pay with Bitcoin</a>"
  end
  
  def self.places_we_ship_to
    [
      ["United States", "us"] #,
      #["Germany", "de"],
      #["United Kingdom", "uk"],
      #["Australia", "au"]
    ]
  end
  
  # patch this in when canada and UK are confirmed
  def self.shipping_cost_for_country(qty, product = nil, country_symbol=nil)
    # based on product, qty, and country... fuck this is tricky....
  end
  
  # Wisc tax is something between 5.0 and 5.6%
  def self.tax_rate
    0.056
  end
  
  def self.delete_old_sales
    # This function should delete POs that are considered abandoned when...
    # - they are older than 14 days
    # - The user hasn't confirmed their email, thus they haven't logged in lately
    unpaid_sales = Sale.where('receipt_confirmed is NULL').order("created_at asc")
    
    unpaid_sales.each do |sale|
      days_old = ((Time.zone.now - sale.created_at)/60/60/24)
      confirmed = sale.user.confirmed?
      
      if days_old > 14
        sale.delete if !confirmed
      else
        break
      end
    end
    
  end
  
  
  def self.how_many_books_left
    msgs = ["lots",
      "Fewer than you think",
      "Enough to build a very large fort out of",
      "One for every parent in the state of New York",
      "So few that we might need to print a second run soon" ]
      
    "[" + msgs[rand(1..msgs.length)-1] + "]"
  end
  
  ##################
  # DB Backup Code #
  ##################
  
  def self.render_database_to_encrypted_string
    @path_to_zip = "db/data.zip"
    @path_to_yaml = "db/data.yml"
    backup_database
    encrypt_database
    read_encrypted_file # so it can be returned as a string... it's a password protected zip file as string
  end
  
  def self.backup_database
    cmd = "RAILS_ENV=#{Rails.env} rake db:data:dump"
    `#{cmd}`
  end
  
  def self.encrypt_database
    pish = "zxiCIJDFksdjiSD"
    FileUtils.rm(@path_to_zip)
    cmd = "zip -P #{pish} #{@path_to_zip} #{@path_to_yaml}"
    `#{cmd}`
  end
  
  def self.read_encrypted_file
    File.read(@path_to_zip)
  end
  
  # unzip -o -P zxiCIJDFksdjiSD db/data.zip
  def self.decrypt_encrypted_string_for_testing(string)
    compressed_file = Tempfile.new('compressed_file')
    # decompressed_file = Tempfile.new('decompressed_file')
    
    # @path_to_zip = "db/data.zip"
    @path_to_yaml = "db/data.yml"
    pish = "zxiCIJDFksdjiSD"
    File.write(compressed_file.path, string)
    decompress_zip_cmd = "unzip -o -P #{pish} #{compressed_file.path}"  # -c will output it to stdout instead of file
    out = `#{decompress_zip_cmd}`
    File.read(@path_to_yaml)
    #import_database_cmd = "RAILS_ENV=#{Rails.env} rake db:data:load"
    #`#{import_database_cmd}`
  end
  
  
  
  ##################
  # GPGME BULLSHIT #
  ##################
  
  def self.list_secret_keys
    fingerprints = GPGME::Key.find(:secret).collect {|x| x.fingerprint}
    # "CCA03436D0189BC3A95E497F1D858B9DEA268FBB"
    shas = GPGME::Key.find(:secret).collect {|x| x.sha}
    # "EA268FBB"
    
    GPGME::Ctx.new { |ctx| ctx.get_key("CCA03436D0189BC3A95E497F1D858B9DEA268FBB", true) } # true for secret key
    
    # GPGME::Key.get("CCA03436D0189BC3A95E497F1D858B9DEA268FBB", true) # true for secret key
  end
  
  def self.get_fingerprint_from_armored(armored_key_text)
    
  end
  
  def self.remove_all_keys!
    ctx = GPGME::Ctx.new 
    ctx.each_key { |key| key.delete!(true) }
  end
  
  def self.import_key(armored_key_text)
    GPGME::Key.import armored_key_text
  end
  
  def self.get_all_shas
    ctx = GPGME::Ctx.new
    
    shas = ctx.keys.collect do |key|
      key.sha
    end
    
    shas
  end
  
  def self.remove_key_by_sha!(sha)
    GPGME::Key.find(:public, sha).each { |k| k.delete!(true) }
    GPGME::Key.find(:secret, sha).each { |k| k.delete!(true) }
  end
  
  # TODu:  I think this function not used... 
  def self.get_sha_from_armor(armored_key_text)
    # delete all keys
    # import they key
    # get the first key's sha
    # delete the key by it's sha
    # return the key's sha
    
    # WorkHard.remove_all_keys!
    WorkHard.import_key(armored_key_text)
    shas = WorkHard.get_all_shas
    
    sha = shas.first
    
    WorkHard.remove_key_by_sha!(sha)
    
    sha
  end
  
  
  
  
  
  ########################
  # App Settings Helpers #
  ########################
  
  
  
  def self.app_settings_for_manual_full_cycle_test_client_dt
    {
      IS_DEBUGGING_ENCRYPTION:        false,
      IS_DEBUGGING_RESPONSES:         true,
      IS_MOCKING_RESPONSES_IN_TESTS:  true,
      IS_DEBUG_API_ON:                true,   
      IS_DEBUGGING_UI:                true,
      HIDE_BRAND:                     false,
      DISABLE_EXTERNAL_WIDGETS:       true,
      
      BITCOIN_CALLBACK_DOMAIN: "",
      
      MAIL_USERNAME:         "",
      MAIL_PASSWORD:         "",
      MAIL_DOMAIN:           "gmail.com",
      MAIL_SERVER_ADDRESS:   "smtp.gmail.com",
      MAIL_PORT:             587,
      
      ADMIN_PASS:            "password",
      TEAM_PASS:             "changemedownloader775",

      SHOPPING_CART_WALLET:  "",
      DONATION_WALLET:       "",
      PAYPAL_ID:             ""
    }
  end
  
  def self.app_settings_for_production_webserver
    {
      IS_DEBUGGING_ENCRYPTION:        false,
      IS_DEBUGGING_RESPONSES:         false,
      IS_MOCKING_RESPONSES_IN_TESTS:  false,
      IS_DEBUG_API_ON:                false,   
      IS_DEBUGGING_UI:                false,
      HIDE_BRAND:                     false,
      DISABLE_EXTERNAL_WIDGETS:       false,
      
      BITCOIN_CALLBACK_DOMAIN: "https://www.anonlit.com",
      
      MAIL_USERNAME:         "",
      MAIL_PASSWORD:         "",
      MAIL_DOMAIN:           "gmail.com",
      MAIL_SERVER_ADDRESS:   "smtp.gmail.com",
      MAIL_PORT:             587,
      
      ADMIN_PASS:            "changemeadsf123df",
      TEAM_PASS:             "changemedownloader775",

      SHOPPING_CART_WALLET:  "1QBq4YTYwuiugBVFaDqKEWwdbBHYU6kBX7",
      DONATION_WALLET:       "18WuvmZK7E6Dwzm5BbQDNGf5QmArui2j5A",
      PAYPAL_ID:             ""
    }
  end
  
  def self.app_settings_left_blank
    {
      IS_DEBUGGING_ENCRYPTION:        false,
      IS_DEBUGGING_RESPONSES:         false,
      IS_MOCKING_RESPONSES_IN_TESTS:  false,
      IS_DEBUG_API_ON:                false,   
      IS_DEBUGGING_UI:                false,
      HIDE_BRAND:                     false,
      DISABLE_EXTERNAL_WIDGETS:       false,
      
      BITCOIN_CALLBACK_DOMAIN: "",
      
      MAIL_USERNAME:         "",
      MAIL_PASSWORD:         "",
      MAIL_DOMAIN:           "gmail.com",
      MAIL_SERVER_ADDRESS:   "smtp.gmail.com",
      MAIL_PORT:             587,
      
      ADMIN_PASS:            "changemeadsf123df",
      TEAM_PASS:             "changemedownloader775",

      SHOPPING_CART_WALLET:  "",
      DONATION_WALLET:       "",
      PAYPAL_ID:             ""
    }
  end
  
end


