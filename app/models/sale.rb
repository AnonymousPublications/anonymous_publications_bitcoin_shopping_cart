# original_id:
#   When a downloader tries to upload a new shippable file, the original_id is
#   checked to make sure duplicate sales aren't added into the shipping machine:  
#     
#   
#     
# ready_for_shipment_batch_id:  This is used to easily query for all sales that are
# currently being imported to the shipping machine.  
#   When a downloader tries to upload a new shippable file, the ready_for_shipment_batch_id is
#   checked to see:
#     - If the shippables have already been uploaded a long time ago (DLer clicked the wrong file)
#     - If the shippables are a new batch, BUT shipping hasn't created an address_completion_file for
#       the last batch (a batch is still in process) 
#
##
# ready_for_shipment_batch_ids: also help track which sales were shipped, and under which batch... i think that's important?  more sale_ids should be stored in them though... so they can't easily be overwritten...
#
class Sale < ActiveRecord::Base
  attr_accessible :address_id, :ready_for_shipment_batch_id, :shipped, :original_id, :prepped
  belongs_to :user
  belongs_to :address
  belongs_to :ready_for_shipment_batch
  has_many :line_items, dependent: :destroy
  has_many :bitcoin_payments
  has_one :checkout_wallet
  belongs_to :utilized_bitcoin_wallet
  
  has_many :cs_associations
  has_many :coupons, through: :cs_associations, uniq: true
  
  has_many :technical_bitcoin_payments, :class_name => "BitcoinPayment", :foreign_key => "technical_bitcoin_payment_id"
  
  
  extend Importable
  
  # 1) start up the @sale
  # 4) Calculate the book cost
  # 5) Request and store a CheckoutWallet from blockchain.info
  def self.create_instant_sale(user, line_item, product, address_id, currency_used = "BTC")
    @sale = user.sales.new(:address_id => address_id)
    
    @line_item = @sale.save_line_item(product, line_item["qty"].to_i, currency_used)
    
    #- 2) Discount calculation
    @sale.calculate_discounts
    
    #- 3) Wallet Generation
    @sale.attach_checkout_wallet # sale is saved in here
    
    @sale
  end
  
  def save_line_item(product, line_item_qty, currency_used)
    line_item_attributes = { :product_sku => product.sku, :qty => line_item_qty.to_f, 
                               :currency_used => currency_used, 
                               :price => product.get_item_cost_btc
                           }
    
    @line_item = LineItem.pew(line_item_attributes)
    line_items << @line_item
    
    @line_item.save
    @line_item
  end
  
  def set_utilized_bitcoin_wallet(destination_wallet)
    self.utilized_bitcoin_wallet = UtilizedBitcoinWallet.find_or_create_by_wallet_address(destination_wallet)
  end
  
  def self.qtys_and_counts_rdy_for_shipment
    sales_rdy = Sale.resolve_array_of_ids_to_active_record_units(Sale.current_batch_that_was_shippable)
    qtys_raw = sales_rdy.map {|s| s.line_items.find_by_product_sku("0001").qty}  # this won't scale...
    
    qtys = qtys_raw.uniq.sort
    has_qty_over_10 = false
    qtys.each { |x| has_qty_over_10 = true if x >= 11 }
    if has_qty_over_10
      qtys_original = qtys.dup
      qtys = qtys.reject {|x| x >= 11}
      qtys_over_10 = qtys_original - qtys
      qtys << "many"
    end
    
    # check if any of the qtys are >= 11
    # filter out any qtys of 
    # add "many" to the array if appropriate
    counts = qtys.map { |qty| qtys_raw.count qty unless qty == "many" }
    
    # sum qtys_over_10
    counts << qtys_over_10.map { |qty| qtys_raw.count qty}.sum if has_qty_over_10
    
    qtys.zip(counts)
  end
  
  def self.get_shippable_sales_by_qty(qty)
    sales = Sale.current_batch_that_was_shippable
    
    # lookup the line_items for the parade with the drums sku and check it's qty... select it if it's equal to @qty
    if qty == 'many'
      sales.select { |s| LineItem.where(sale_id: s["id"]).find_by_product_sku("0001").qty >= 11 }
    else
      sales.select { |s| LineItem.where(sale_id: s["id"]).find_by_product_sku("0001").qty == qty.to_i }
    end
  end
  
  
  
  def erroneous
    self.address.erroneous?
  end
  alias erroneous? erroneous
  
  def fully_paid?
    self.checkout_wallet.fully_paid?
  end
  
  def technically_paid?
    return false if checkout_wallet.nil?
    self.checkout_wallet.technically_paid?
  end
  
  def mock_completed_payment
    # create bitcoin payment 
    self.bitcoin_payments.create(value: total_amount, confirmations: 6)
    self.checkout_wallet.calculate_if_payment_complete
  end
  
  def get_previously_discovered_payment_value
    self.checkout_wallet.value_paid
  end
  
  # Does not filter unconfirmed payments
  def remainder_to_pay
    self.total_amount - self.checkout_wallet.unconfirmed_value_paid
  end
  
  def unconfirmed_value_paid
    self.checkout_wallet.unconfirmed_value_paid
  end
  
  # This function looks up from blockchain what the status of the checkout_wallet is and
  # sees if the payment has been forwarded and aproximately how many confirmations it's seen
  # This thing gets fired over ajax!!!... ultimately from app.com/new_payments_found... BitcoinPayments controller
  # TODu: move to BitcoinPayment model
  def get_confirmed_payments(options_hash = {})
    query_info = options_hash[:query_info].nil? ? nil : options_hash[:query_info]
    # form can be...  :technical_payments, :confirmed_payments
    form = options_hash[:form].nil? ? :confirmed_payments : options_hash[:form]
    
    return self.bitcoin_payments.map{|x| x.value}.sum if we_looked_up_blockchain_info_recently?
    
    
    checkout_wallet_info, latest_block = query_blockchain_for_new_payments_to_checkout_wallet(self.checkout_wallet.input_address, query_info)
    self.checkout_wallet.update_attributes(:last_successful_manual_lookup => Time.zone.now)
    self.checkout_wallet.calculate_if_payment_complete
    
    if checkout_wallet_info.nil?
      Message.emergency("a query_blockchain_for_new_payments_to_checkout_wallet returned a nil checkout_wallet_info somehow", 
          "#{__FILE__}:#{__LINE__}  \n input_address#{self.checkout_wallet.input_address}")
      return self.bitcoin_payments.map{|x| x.value}.sum
    end
    
    
    
    
    latest_height = latest_block['height']
    txs = checkout_wallet_info['txs']
    
    
    case form
    when :confirmed_payments
      correct_destination_values = self.bitcoin_payments.map{|x| x.value}.sum
      correct_destination_values += check_txs_for_unrecorded_properly_destined_values(txs, latest_height)
    when :technical_payments
      correct_destination_values = self.technical_bitcoin_payments.map{|x| x.value}.sum
      correct_destination_values += check_txs_just_to_see_that_payments_came_into_them(txs, latest_height)
    end
    
    correct_destination_values
  end
  
  # TODu: make this so it doesn't mutate the correct_destination_values... that's ugly shit... it needs investigation
  def check_txs_for_unrecorded_properly_destined_values(txs, latest_height)
    correct_destination_values = 0
    txs.each do |tx|
      outs = tx['out']
      
      outs.each do |out|
        correct_destination_values += out['value'] if unrecorded_valid_bitcoin_payment?(tx, latest_height, out)
        create_bitcoin_payment_from_tx(tx, latest_height, out)
      end
      
    end
    
    correct_destination_values
  end
  
  # TODO:  implement me for doing 'technically paid'
  # create the bitcoin payment to have confirmations of zero or one
  def check_txs_just_to_see_that_payments_came_into_them(txs, latest_height)
    correct_destination_values = 0
    txs.each do |tx|
      outs = tx['out']
      
      outs.each do |out|
        correct_destination_values += out['value'] if unrecorded_valid_technical_bitcoin_payment?(tx, latest_height, out)
        # TODO: this is only partially finished...
        # create_bitcoin_payment_from_tx(tx, latest_height, out)
      end
      
    end
    
    correct_destination_values
  end
  
  
  def unrecorded_valid_technical_bitcoin_payment?(tx, latest_height, out)
    out['addr'] == self.checkout_wallet.input_address and BitcoinPayment.find_by_transaction_hash(tx['hash']).nil?
  end
  
  def unrecorded_valid_bitcoin_payment?(tx, latest_height, out)
    out['addr'] == self.checkout_wallet.destination_address and payment_confirmed?(latest_height, tx) and BitcoinPayment.find_by_transaction_hash(tx['hash']).nil?
  end
  
  # TODO:  I'm leaving off here... I need to really dig through this piece of shit and it sux
  def create_bitcoin_payment_from_tx(tx, latest_height, out, technical_bitcoin_payment = false)
    return if out['addr'] != self.checkout_wallet.destination_address
    inputs = tx['inputs']
    tx_height = tx['block_height']
    
    related_input_tx = inputs.select {|x| x['prev_out']['n'] == out['n']}.first['prev_out']
    input_transaction_hash = related_input_tx['addr']
    input_address = related_input_tx['addr']  # input_address = checkout_wallet_address # this would be safer...
    
    value = out['value']
    confirmations = latest_height - tx_height
    transaction_hash = tx['hash']
    destination_address = out['addr']
    sale_id = self.id

    bp_hash = { user_id: self.user.id, input_address: input_address, value: value, confirmations: confirmations, 
      transaction_hash: transaction_hash, destination_address: destination_address, 
      input_transaction_hash: input_transaction_hash, sale_id: sale_id, destination_address: out['addr'] }
    
    bp = BitcoinPayment.find_by_transaction_hash(transaction_hash)
    
    if bp.nil?
      BitcoinPayment.create(bp_hash)
    else
      bp.update_attributes(bp_hash)
    end
  end
  
  
  def visualize_txs
    checkout_wallet_info = JSON.parse($TestCheckoutWalletAddressLookup)
    latest_block = JSON.parse($TestLatestBlock)
    
    latest_height = latest_block['height']
    txs = checkout_wallet_info['txs']
    
    string = ""
    
    txs.each do |tx|
      outs = tx['out']
      
      binding.pry
      inputs = tx['inputs']
      
      inputs.each do |input|
        
      end
      
      outs.each do |out|
        string += "Addr:  #{out['addr']}"
        string += "  Value:  #{out['value']}\n" if unrecorded_valid_technical_bitcoin_payment?(tx, latest_height, out)
        # TODO: this is only partially finished...
        # create_bitcoin_payment_from_tx(tx, latest_height, out)
      end
      
    end
    
    puts string
  end
  
  def query_blockchain_for_new_payments_to_checkout_wallet(checkout_wallet_address, query_info = nil)
    if $TriggerPaymentFoundOnNextRequest
      $TriggerPaymentFoundOnNextRequest = false
      # Pull down checkout_wallet data
      # Get http://blockchain.info/address/$bitcoin_address?format=json
      if query_info.nil?
        checkout_wallet_info_string = $TestCheckoutWalletAddressLookup
        latest_block_string = $TestLatestBlock
      else
        checkout_wallet_info_string = query_info.last
        latest_block_string = query_info.first
      end
      
    else
      begin
        self.checkout_wallet.update_attributes(:last_manual_lookup => Time.zone.now)
        checkout_wallet_info_string = HTTParty.get(address_info_uri(checkout_wallet_address)).body
      rescue Exception => exception
        Message.emergency("Failed to connect to #{address_info_uri(checkout_wallet_address)}", 
          "#{__FILE__}:#{__LINE__}  \n checkout_wallet_address#{checkout_wallet_address}  \n #{exception.message}")
        return [nil, nil]
      end
      
      begin
        latest_block_string = HTTParty.get($LatestBlockUri).body
      rescue Exception => exception
        Message.emergency("Failed to connect to #{$LatestBlockUri}", 
          "#{__FILE__}:#{__LINE__}  \n checkout_wallet_address#{checkout_wallet_address}  \n #{exception.message}")
        return [nil, nil]
      end
      
    end
    
    self.checkout_wallet.calculate_if_payment_complete
    checkout_wallet_info = JSON.parse(checkout_wallet_info_string)
    latest_block = JSON.parse(latest_block_string)
    
    [checkout_wallet_info, latest_block]
  end
  
  # I tried to shorten stuff up by creating this handy function, but it's all fucked up because it thinks lml is always 15 mins ago. 
  def we_looked_up_blockchain_info_recently?
    return true if self.checkout_wallet.nil? # This condition, oddly, is met when something goes wrong during create_instant_sale and we wind up with Sales that are half made, but something went wrong creating the checkout_wallet
    lml = self.checkout_wallet.last_manual_lookup
    
    if (!lml.nil? and Time.zone.now - lml > 15.minutes) or lml.nil? or !(Time.zone.now - self.created_at < 15.minutes)
      false
    else
      true
    end
    
  end
  
  def payment_confirmed?(latest_height, tx)
    tx_height = tx['block_height']
    required_confirmations = 6
    return false if tx_height.nil?  # return if it's too soon for bitcoin to know about the payment or if it has no height yet
    (latest_height - required_confirmations) >= tx_height
  end
  
  def self.rdy_for_shipment
    sales = Sale.where('receipt_confirmed is not NULL AND shipped is NULL AND original_id is NULL')
    
    
    sales = convert_active_record_to_array(sales)
    filter_sales_that_dont_have_a_findable_address!(sales)
    
    filter_sales_with_an_erroneous_address!(sales)

    sales.extend Importable
  end
  
  def self.get_shippable 
    self.current_batch_that_was_shippable 
  end
  
  # find all sales of current batch, and sub out the ones with erroneous ones 
  # This query excludes sales with out original_id values
  def self.current_batch_that_was_shippable
    sales = get_latest_batch_of_sales

    filter_sales_that_dont_have_a_findable_address!(sales)
    filter_sales_with_an_erroneous_address!(sales)
    filter_sales_with_no_original_id!(sales)
    
    sales.extend Importable
  end
  
  def self.current_batch
    sales = get_latest_batch_of_sales
    
    filter_sales_that_dont_have_a_findable_address!(sales)
    filter_sales_with_no_original_id!(sales)
  end
  
  def self.get_latest_batch_of_sales
    latest_batch = ReadyForShipmentBatch.last
    # if we_havent_made_a_fresh_batch_yet
    # then we haven't made our first import to the shipping machine yet
    # and thus...
    if latest_batch.nil? # or latest_batch.cycle_complete?
      sales = []
    else
      sales = Sale.where(ready_for_shipment_batch_id: latest_batch.id)
    end
    
    sales = convert_active_record_to_array(sales)
  end
  
  # This is the inverse of current_batch_that_was_shippable, but excludes sales where their address is unfindable
  def self.unshippable
    sales = get_latest_batch_of_sales
    
    filter_sales_that_dont_have_a_findable_address!(sales)
    select_erroneous_sales!(sales)
    filter_sales_with_no_original_id!(sales)
    
    sales.extend Importable
  end
  
  def self.marked_shipped
    self.where('shipped is not NULL')
  end
  
  def self.erroneous_sales
    erroneous_sales = []
    addresses = Address.where(erroneous: true)
    addresses.each do |address|
      Sale.where(address_id: address.id).each do |sale|
        erroneous_sales << sale
      end
    end
    
    erroneous_sales
  end
  
  def self.filter_sales_that_dont_have_a_findable_address!(sales)
    sales.reject! {|s| !Address.exists?(s["address_id"]) }
  end
  
  def self.filter_sales_with_an_erroneous_address!(sales)
    sales.reject! {|s| Address.find(s["address_id"]).erroneous == true }
  end
  
  def self.filter_sales_with_no_original_id!(sales)
    sales.reject! {|s| s["original_id"].nil?}
  end
  
  def self.select_erroneous_sales!(sales)
    sales.select! {|s| Address.find(s["address_id"]).erroneous == true }
  end
  
  # TODu: optimize, very crude and wasteful
  # converts the rdy_for_shipment array back into active_record units
  def self.rdy_for_shipment_ar
    sales = rdy_for_shipment
    sales.collect { |s| Sale.find(s["id"]) }
  end
  
  def self.resolve_array_of_ids_to_active_record_units(sales)
    sales.collect { |s| Sale.find(s["id"]) }
  end
  
  
  def calculate_discounts
    self.line_items.each do |line_item|
      line_item.calculate_and_attach_discount_items
    end
  end
  
  
  # CREATE BITCOIN CHECKOUT WALLET
  def attach_checkout_wallet
    CheckoutWallet.pew(self)
  end
  
  # TODu: Not useful
  def self.first_unpaid_lacking_confirmations
    self.where(:receipt_confirmed => nil).first
  end
  
  def self.first_unpaid_lacking_all_evidence
    all.each do |sale|
      return sale if !sale.technically_paid?
    end
  end

  def self.each_paid(&b)
    return :no_block_given if b.nil?
    
    sales_paid = self.where('receipt_confirmed is not NULL')
    
    sales_paid.each do |el|
      b.call(el)
    end
  end

  
  def self.each_technically_paid(&b)
    return :no_block_given if b.nil?
    
    i = 0
    self.all.each do |el|
      next if el.technically_paid? == false and el.receipt_confirmed.nil?
      b.call(el, i)
      i += 1
    end
  end
  
  def self.each_unpaid(&b)
    return :no_block_given if b.nil?
    
    i = 0
    self.where(:receipt_confirmed => nil).each do |el|
      next if el.technically_paid? == true
      b.call(el, i)
      i += 1
    end
  end
  
  def display_shipping_amount
    WorkHard.display_satoshi_as_btc shipping_amount
  end
  
  def shipping_amount
    calculate_shipping_amount
  end
  
  def calculate_shipping_amount
    return 0.0 if self.coupons.contains_wave_shipping_coupon?  # a coupon is attached to the discount "wave shipping"
    
    sc_usd = 0.0
    sc_btc = 0.0
    line_items.each do |li|
      sc_usd += li.shipping_cost_usd
      sc_btc += li.shipping_cost_btc.round(-4)
    end
    
    if currency_used != "BTC"
      shipping_amount = sc_usd
    else
      shipping_amount = sc_btc
    end
    shipping_amount
  end
  
  def display_tax_amount
    WorkHard.display_satoshi_as_btc tax_amount
  end

  def tax_amount
    return 0.0 if self.address.nil?
    
    if self.address.country == "United States" and self.address.state == "WI"
      total_tax_amnt = 0.0
      self.line_items.each do |li|
        if li.product.taxable
          total_tax_amnt += li.price_extend * WorkHard.tax_rate
        end
      end
      total_tax_amnt.round(-4)
    else
      0.0
    end
  end
  
  def display_sale_amount
    WorkHard.display_satoshi_as_btc sale_amount
  end

  def sale_amount
    line_items.map(&:price_extend).sum
  end
  
  # s.sale_amount + s.discount_amount + s.tax_amount + s.shipping_amount
  def total_amount_before_modifier
    sale_amount + discount_amount + tax_amount + shipping_amount
  end
  
  def display_total_amount
    WorkHard.display_satoshi_as_btc total_amount
  end
  
  def total_amount
    t = total_amount_before_modifier + minimum_sale_amount_adjustment
  end
  
  def display_minimum_sale_amount_adjustment
    WorkHard.display_satoshi_as_btc minimum_sale_amount_adjustment
  end
  
  # TODu: implement me
  def minimum_sale_amount_adjustment
    if currency_used == "BTC"
      return 0.0 if total_amount_before_modifier > 50000
      return 50000 - total_amount_before_modifier
    end
    return 0.0
  end
  
  def display_discount_amount
    WorkHard.display_satoshi_as_btc discount_amount
  end
  
  # TODu: optimize, maybe there should be some optimizations
  def discount_amount
    all_discounts = line_items.collect { |li| li.discounts }.flatten
    mapping = all_discounts.map(&:price_extend)
    # when we create the discount items, we need to set calculate their price_extend value
    mapping.sum
  end
  
  def sale_amount_face_value
    line_items.map { |li| li.product.price_usd * li.qty }.sum
  end
  
  def shipping_amount_face_value
    line_items.map { |li| li.shipping_cost_usd }.sum
  end
  
  def tax_amount_face_value
    # TODu: implement me when we're in production
  end
  
  
  ########################3
  # Import/ Export Junk
  ########################
  
  def self.find_latest_confirmed_sale
    Sale.where('receipt_confirmed is not NULL').order('receipt_confirmed DESC').limit(1).first
  end
  
  def self.latest_payment_confirmation_timestamp
    return "" if find_latest_confirmed_sale.nil?
    find_latest_confirmed_sale.receipt_confirmed.to_json.gsub('"', "").gsub(":",".").sub("T", "_").sub("Z", "")
  end
  
  def self.latest_confirmed_sales_update_timestamp
    return "" if find_latest_confirmed_sale.nil?
    find_latest_confirmed_sale.updated_at.to_json.gsub('"', "").gsub(":",".").sub("T", "_").sub("Z", "")
  end
  
  def self.build_shippable_file
    @sales, @addresses, @line_items, @discounts, @utilized_bitcoin_wallets, @encryption_pairs, rfsb = get_shippable_sale_data!
    
    return_array = [ @sales, 
                     @line_items, 
                     @discounts,
                     @addresses, 
                     @utilized_bitcoin_wallets,
                     @encryption_pairs,
                     rfsb ]
    
    config = {file_type: :shippable_file, symmetric_key: $FrontDoorKey}
    nmd_shippable = NmDatafile.new(config, *return_array)

    rfsb.update_attributes(sf_integrity_hash: nmd_shippable.integrity_hash)
    
    nmd_shippable
  end
  
  def self.get_shippable_sale_data!
    rfsb = gen_new_rfsb_or_use_previous_incomplete_rfsb
    
    @sales = Sale.rdy_for_shipment
    # TODu: run below query as a join
    @addresses = @sales.collect {|x| convert_active_record_to_array(Address.find(x["address_id"])) }
    @line_items = @sales.collect do |sale|
      s = Sale.find(sale["id"])
      s.line_items
    end
    @line_items.flatten!
    @discounts = @line_items.collect {|x| x.discounts }.flatten.collect {|x| convert_active_record_to_array(x)}
    @line_items = convert_active_record_to_array(@line_items)
    
    # TODu:  this can be optimized as an SQL call instead of a loop, but not important... yet
    @sales.each do |sale_id|
      sale = Sale.find(sale_id["id"])
      sale.ready_for_shipment_batch_id = rfsb.id
      sale.prepped = true
      sale.save
    end
    # we gotta reload the sales now since we modified their ready_for_shipment_batch_ids on the records, after we pulled them out as array items
    @sales = Sale.rdy_for_shipment
    
    # TODu:  this should be done via a fancy SQL query too
    @utilized_bitcoin_wallets = @sales.collect do |sale|
      s = Sale.find(sale["id"])
      s.utilized_bitcoin_wallet
    end
    @utilized_bitcoin_wallets.uniq!
    @utilized_bitcoin_wallets = convert_active_record_to_array(@utilized_bitcoin_wallets)
    
    @encryption_pairs = @sales.collect do |sale|
      s = Sale.find(sale["id"])
      a = s.address
      a.encryption_pair
    end
    @encryption_pairs.uniq!
    @encryption_pairs = convert_active_record_to_array(@encryption_pairs)
    
    
    [@sales, @addresses, @line_items, @discounts, @utilized_bitcoin_wallets, @encryption_pairs, rfsb]
  end
  
  def self.gen_new_rfsb_or_use_previous_incomplete_rfsb
    rfsb = ReadyForShipmentBatch.last
    return ReadyForShipmentBatch.gen if we_havent_made_an_rfsb_before?(rfsb)
    return ReadyForShipmentBatch.gen if the_last_rfsb_has_been_through_a_complete_cycle_and_is_closed?(rfsb)
    return rfsb
  end
  
  def self.we_havent_made_an_rfsb_before?(rfsb)
    rfsb.nil?
  end
  
  def self.the_last_rfsb_has_been_through_a_complete_cycle_and_is_closed?(rfsb)
    rfsb.cycle_complete?
  end
  
  def self.commence_upload_of_shippable_file(nmd, previous_batch)
    @s,@l,@a,@ep = [Sale.count, LineItem.count, Address.count, EncryptionPair.count]  # allows for delta of database changes
    import_shippable_data(nmd)
    
    previous_batch.mark_non_erroneous_as_shipped unless previous_batch.nil? or we_didnt_upload_a_new_batch(previous_batch)
    
    @s,@l,@a,@ep = [Sale.count-@s,LineItem.count-@l,Address.count-@a,EncryptionPair.count-@ep]  # allows for delta of database changes
  end
  
  
  def self.import_shippable_data(nmd)
    sales = nmd.sales
    line_items = nmd.line_items
    addresses = nmd.addresses
    ubws = nmd.ubws
    encryption_pairs = nmd.encryption_pairs
    ready_for_shipment_batches = [nmd.ready_for_shipment_batch]
    
    ready_for_shipment_batches.each do |hash|
      hash["sf_integrity_hash"] = nmd.integrity_hash
      ReadyForShipmentBatch.import_from_hash_to_shipping(hash)
    end
    
    # For Sales     
    sales.each do |hash|
      # we should cancel the import if shipped isn't null
      if sale_existed_prior_with_same_address?(hash)
        hash["skip_import_telconine"] = true
        next
      end
      stripped_sale = hash.reject {|k| k == "shipped"} # removes the shipped key/value pair from the hash
      Sale.import_from_hash_to_shipping(stripped_sale)
    end
    
    # For LineItems 
    line_items.each do |hash|
      LineItem.import_from_hash_to_shipping(hash)
    end
    
    # For Addresses
    addresses.each do |hash|
      Address.import_from_hash_to_shipping(hash)
    end
    
    ubws.each do |hash|
      UtilizedBitcoinWallet.import_from_hash_to_shipping(hash)
    end
    
    encryption_pairs.each do |hash|
      EncryptionPair.import_from_hash_to_shipping(hash)
    end
    
    reassociate_records_for_shipping_machine(sales, line_items, addresses)
  end
  
  # this condition happens during testing, or anytime we upload a new batch that we've already uploaded
  def self.we_didnt_upload_a_new_batch(previous_batch)
    previous_batch == ReadyForShipmentBatch.last
  end
  
  def self.sale_existed_prior_with_same_address?(sale)
    sale_record = Sale.find_by_original_id(sale["id"])
    # if the sale doesn't exist
    return false if sale_record.nil?
    return true if sale_record.address.original_id == sale["address_id"] # if the address is un changed
    false
  end
  
  # Pass in arrays who have a different_table_id column that needs to be corrected
  def self.reassociate_records_for_shipping_machine(sales, line_items, addresses)
    # change sale#address_id 
    Sale.reassociate_with_adjusted_ids_for!(Address, sales)
    
    # change sale#ready_for_shipment_batch_id
    Sale.reassociate_with_adjusted_ids_for!(ReadyForShipmentBatch, sales.reject{|s| s["skip_import_telconine"]})
    
    # change sales#utilized_bitcoin_wallet_id
    Sale.reassociate_with_adjusted_ids_for!(UtilizedBitcoinWallet, sales)
    
    # change line_item#sale_id
    LineItem.reassociate_with_adjusted_ids_for!(Sale, line_items)
    
    # change address#encryption_pair_id
    Address.reassociate_with_adjusted_ids_for!(EncryptionPair, addresses)
  end
  
  

  # For testing: Delete a sale and everything associated with it
  def self.deep_delete_sales(sales)
    sales.each do |s|
      s.line_items.each {|li| LineItem.find(li.id).delete}
      s.bitcoin_payments.each {|bp| BitcoinPayment.find(bp.id).delete }
      CheckoutWallet.find(s.checkout_wallet.id).delete
      Address.find(s.address_id).delete
      ReadyForShipmentBatch.find(s.ready_for_shipment_batch_id).delete if ReadyForShipmentBatch.exists?(s.ready_for_shipment_batch_id)
      s.delete
    end
  end
  
  def self.delete_shipping_machine_sales!
    self.where("original_id is not NULL").delete_all
  end
  
  
  
  
  def present_total_amount
    display_total_amount.to_s + " BTC"
  end

  def present_title
    "Purchase on " + self.created_at.to_date.to_s
  end
  
  def present_sale_amount
    sale_amount.to_s + " BTC"
  end
  
  def present_shipped
    return shipped.to_date.to_s if shipped
    return "possibly (though not confirmed)" if prepped and !shipped
    return "No" # if !prepped and !shipped
  end
  
  def present_receipt_confirmed
    receipt_confirmed.nil? ?
      "No.  To make a payment via bitcoin, please see this video, #{WorkHard.how_to_pay_with_bitcoin_vid}
      " :
      "Yes, thank you for caring about things and stuff, you're a gem!"
  end
  
  # TODu:  fix this when more payment methods are added
  def present_currency_used
    return "Bitcoin!  Like it or not, today you're an activist taking the first step towards financial justice." if receipt_confirmed == true and currency_used == "BTC"
    return "Paypal... please consider using an alternative currency in the future" if currency_used == "paypal"
    return "Bitcoin" if currency_used == "BTC"
  end
  
  def order_status
    return :awaiting_payment if receipt_confirmed.nil?
    return :shipped if shipped
    return :awaiting_shipment if prepped?
    return :awaiting_download if receipt_confirmed
    return :error
  end
  
  def price_visualizer
    s = ""
    
    s += "Sale Amount: #{sale_amount}\n"
    s += "Discount Amount:  #{discount_amount}\n"
    s += "Shipping Amount:  #{shipping_amount}\n"
    s += "Total Amount: #{total_amount}\n"
    
    line_items.each do |li|
      s += "LineItem:  #{li.product.name}.... #{li.price} * #{li.qty} =  Price Extend #{li.price_extend}\n"
      li.discounts.each do |disc|
        s += "  Disc: #{disc.description}, Total weight: #{disc.price_extend}\n"
      end
    end
    
    s += "\n"
    
    puts s
  end
  
end
