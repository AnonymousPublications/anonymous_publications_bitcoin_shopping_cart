class AdminPagesController < ApplicationController
  before_filter :team_members_only!
  
  # shared... TODu... make these seperate pages for two roles, downloader and mailer???
  # Shipping
  skip_before_filter :authorize_user!, only: [:home, :shipping_control, :download_database]
  # Downloader
  skip_before_filter :authorize_user!, only: [:downloader_controls, :download_shippable, :upload_shipped, :upload_shipped_file]
  # the mailer is given admin so it doesn't matter atm...
  
  def home
  end
  
  def discounts
    @discounts = Discount.all
    @coupons = Coupon.all
  end
  
  def application_dot_yml
    authorize_user!
    
    settings = params[:settings].to_sym unless params[:settings].nil?
    case settings
    when :production
      @settings = WorkHard.app_settings_for_production_webserver
    when :dt_full_cycle
      @settings = WorkHard.app_settings_for_manual_full_cycle_test_client_dt
    else
      @settings = WorkHard.app_settings_left_blank
    end
    
    render :layout => false
  end
  
  # ignore less than 6 confirmations for all figures
  def finance
    authorize_user!
    
    @wallet_data = {}
    @wallets = [ENV['SHOPPING_CART_WALLET']] # BitcoinPayments.get_n_shopping_cart_wallets
    @wallets.each do |wallet|
      i = @wallet_data[wallet.to_sym] = {}
      i['bitcoins_in_wallet'] = 4500000    # 'lookup online, get satoshi' 
      i['bitcoins_registered_in_database'] = BitcoinPayment.where(destination_address: wallet).map(&:value).sum # confirmations not right TODu
      i['bitcoins_withdrawn'] = 0 # BitcoinWithdrawls.sum
      i['missing_coins'] = i['bitcoins_in_wallet'] + i['bitcoins_withdrawn'] - i['bitcoins_registered_in_database'] # if not zero, hacking took place
    end
    
    @aggregate_shopping_cart_balance = @wallet_data.map { |wallet, values| values['bitcoins_in_wallet'] }.sum
    @aggregate_recorded_bitcoin_payments = @wallet_data.map { |wallet, values| values['bitcoins_registered_in_database'] }.sum
    @shipping_costs_by_month = [1,2,1,12,123,12,1] # getShippingCostsByMonthForYear(2014)
    @sales_by_month = [1,2,1,12,123,12,1] # get_sales_by_month_for_year(2014)
    @donations_by_month = [1,2,1,12,123,12,1]
    @number_of_sales = Sale.count
  end
  
  def address_labels
    @qty = params[:qty]
    
    @sales = Sale.get_shippable_sales_by_qty(@qty)
    
    @addresses = @sales.map {|s| Address.find(s["address_id"]) }
    
    @number_of_pages_to_show = ((@addresses.count/30)+1)
    @number_of_labels_per_page = 30
    
    
    render :layout => false
  end
  
  def shipping_control
    @qtys_rdy_for_shipping = Sale.qtys_and_counts_rdy_for_shipment
  end
  
  def downloader_controls
    unless Message.conducted_mass_dl_from_blockchain_within_24h?
      Message.conducting_mass_dl_from_blockchain
      BitcoinPayment.conduct_lookup_of_outstanding_partial_confirmations 
    end
    
    sales_rdy_for_shipment = Sale.resolve_array_of_ids_to_active_record_units(Sale.rdy_for_shipment) # Sale.rdy_for_shipment_ar  # FIXME:  depricate _ar
    
    @paid_purchase_order_count = sales_rdy_for_shipment.count
    @satoshi_total = sales_rdy_for_shipment.map {|x| x.total_amount}.sum
    @btc_total = CostsOfBitcoin.satoshi_to_btc_decimal(@satoshi_total)
    @usd_equivelant_today = CostsOfBitcoin.btc_to_usd(@btc_total)
    @usd_face_value = sales_rdy_for_shipment.map {|x| x.sale_amount_face_value}.sum
  end
  
  
  def download_database
    authorize_user! unless current_user.has_role? :downloader
    time_stamp = DateTime.now.to_json.gsub('"', "").gsub(":",".").sub("T", "_").sub("Z", "")
    send_data(WorkHard.render_database_to_encrypted_string, :type => 'application/zip', :filename => "#{params[:action]}_#{time_stamp}.zip")
  end
  
  
  # POST manage_shipping_errors.... man this is getting messy fast...
  def manage_shipping_errors
    @sales = Sale.current_batch_that_was_shippable
    
    @addresses = @sales.map {|s| s.address }
    
    @number_of_pages_to_show = ((@addresses.count/30)+1)
    @number_of_labels_per_page = 30
    
    render :layout => false
  end
  
  
  def update_errors
  end
  
  
  def download_shippable
    nmd = Sale.build_shippable_file  # Sales, Addresses, LineItems
    
    time_stamp = Sale.latest_payment_confirmation_timestamp
    send_data(nmd.save_to_string, :type => 'application/zip', :filename => "#{params[:action]}_#{time_stamp}.zip")
  end
  
  
  
  def upload_status_complete
    # the input will be just a zipped array of address_ids that rendered fine on the shipping view
    # I documented this in the flowchart in README
  end
  
  
  def upload_shippable
  end
  
  
  def upload_shippable_file
    require 'fileutils'
    nmd = process_uploaded_file(params, :file_upload)
    return if nmd == false
    
    @previous_batch = ReadyForShipmentBatch.last
    
    alert_user_already_uploaded! and return if nmd.duplicate_batch?(@previous_batch)
    
    # commence_upload_of_shippable_file
    @s,@l,@a,@ep = Sale.commence_upload_of_shippable_file(nmd, @previous_batch)
  end
  
  
  
  def alert_user_already_uploaded!
    render :text => 
      "You already uploaded this shippable file on #{@previous_batch.created_at}.  
       Did you mix up the files?  No operation performed."
  end
  
  
  
  
  
  # UPDATE: It's an array of completed addresses and then an array of erroneous ones...
  #  if every sale was shipped successfully, then the first array should include all the addresses
  # and it is used to be uploaded on the production machine so it can tell the customers that their orders have been shipped
  # OR, it will inform the customer that their address was erroneous, and unfortunately, their book could not be shipped
  # but they can get in touch with us over email to remidy the situation, or recreate a new address and assign it to their order
  # this shit is IMPORTANT and needs to be done and tested before we go into production
  # TODu:  We need to not include addresses that have been uploaded to the production server,
  def address_completion_file
    nmd = Address.build_address_completion_file
    
    send_data(nmd.save_to_string, :type => 'application/zip', :filename => "#{params[:action]}_#{Address.most_recently_changed_address_timestamp}.zip")
  end
  
  # get "/admin_pages/upload_shipped"
  # shows form for uploading a file
  def upload_shipped
  end
  
  # TODu: rename everything from upload_shipped_file to upload_address_completion_file or the other way around so it's comprehensible!
  # Downloader does on production webserver
  # post "/admin_pages/upload_shipped"
  def upload_shipped_file
    require 'fileutils'
    nmd = process_uploaded_file(params, :file_upload)
    return if nmd == false
    
    last_batch = ReadyForShipmentBatch.last
    
    unless last_batch.nil?
      if already_uploaded_this_acf?(nmd)
        @header = "You already uploaded this address_completion_file on #{last_batch.created_at}"
        @body = "Did you perhaps mix up ACFs?  Perhaps there's a serious bug?"
        return
      end
    end
    
    shipped = nmd.sales
    erroneous = nmd.erroneous_sales
    
    changes_in_sales = calculate_changes_in_sales(nmd)
    
    # mark successfull sales as shipped and unmark them prepped...
    shipped.each do |sale|
      Sale.find(sale["id"]).update_attributes(shipped: Time.now, prepped: false)
    end
    
    # Mark erroneous sales as erroneous
    erroneous.each do |sale|
      sale_record = Sale.find(sale["id"])
      a = sale_record.address
      address_id = a.id
      
      # find all the sales with this exact address
      sales_with_this_address = Sale.find_all_by_address_id(address_id)
      
      sales_with_this_address.each do |s|
        s.prepped = false
        s.save
      end
      a.erroneous = true
      a.save
    end
    
    
    rfsb = ReadyForShipmentBatch.find_by_batch_stamp(nmd.ready_for_shipment_batch["batch_stamp"])
    rfsb.update_attributes(acf_integrity_hash: nmd.integrity_hash)
    
    @header = "You just uploaded a confirmation file of shipped POs!"
    @body = "There were #{changes_in_sales[0]} sales marked shipped and #{changes_in_sales[1]} addresses marked erroneous"
  end
  
  # TODu: move to Sale?  Or to nmd???  that would be ugly...  Maybe it should be moved to it's own mixin just for use with the NMD class?
  # it should be refactored into import/export, but needs to be abstracted more...
  # returns [count_of_shipped, count_of_erroneous]
  def calculate_changes_in_sales(nmd)
    sales_to_be_shipped = nmd.sales
    sales_to_be_erroneous = nmd.erroneous_sales
    
    tally_of_changes_in_shipped = 0
    sales_within_shipped_scope = sales_to_be_shipped.collect do |sale|
      s = Sale.find(sale["id"])
      tally_of_changes_in_shipped += 1 if !s.nil? and !s.shipped?
      
    end
    
    tally_of_changes_in_erroneous = 0
    sales_within_erroneous_scope = sales_to_be_erroneous.collect do |sale|
      s = Sale.find(sale["id"])
      tally_of_changes_in_erroneous += 1 if s.nil? and !s.erroneous?
    end
    
    [tally_of_changes_in_shipped, tally_of_changes_in_erroneous]
  end
  
  # TODu: move to import/export with calculate_changes_in_sales
  def already_uploaded_this_acf?(nmd)
    !ReadyForShipmentBatch.find_by_acf_integrity_hash(nmd.integrity_hash).nil?
  end
  
  def process_uploaded_file(params, cute_name)
    render :text => "You didn't upload anything.  Click browse to browse for an address_completion_file_*.zip and upload it." and return false if params[cute_name].nil? or params[cute_name][:my_file].nil?
    
    nmd = NmDatafile.Load(params[cute_name][:my_file].path, $FrontDoorKey)
  end
  
  # GET /admin_pages/configuration_tests
  def configuration_tests
    # Currency costs via APIs
    @btc_apis = $ExchangeRateResources
    
    
  end
  
end
