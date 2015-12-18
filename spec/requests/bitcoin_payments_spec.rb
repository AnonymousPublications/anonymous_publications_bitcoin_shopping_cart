require 'spec_helper'
include RequestHelpers

describe "BitcoinPayments" do

  before :each do
    populate_products
    begin
      @sale = create_integration_purchase
    rescue
      puts "SOMETHING BAD HAPPENED, THIS WAS BECAUSE YOU CANT RUN INDIVIDUAL TESTS WITH THIS INTEGRATION FUNCTION create_integration_purchase"
      raise "LOOK AT BEFORE FILTER"
    end
    
    @checkout_wallet = @sale.checkout_wallet
    
    @input_address = @checkout_wallet.input_address
    @transaction_hash = "xxtransactionhashc98df"
    @good_destination_address = ENV["SHOPPING_CART_WALLET"]
    @bad_destination_address = "xxBadDestinationAddressOfMalice!!!!"
    @full_payment = WorkHard.convert_back_to_satoshi(@sale.total_amount).to_s
    @partial_payment = (@sale.total_amount - 1).to_s
    @missing_payment = (@full_payment.to_i - @partial_payment.to_i).to_s
    
    @bitcoin_payments_params = {
        'anonymous' => "false",
        'shared' => 'false',
        'test' => 'false',
        
        'value' => @full_payment,  # in satoshi
        'input_address' => @input_address, # The bitcoin address that received the transaction.   aka payment_wallet
        'confirmations' => '6',  # The number of confirmations of this transaction.
        
        'sale_id' => '1',
        'secret_authorization_token' => @checkout_wallet.secret_authorization_token,
        
        'transaction_hash' => @transaction_hash,  # The transaction hash.
        'input_transaction_hash' => 'xxxidkwhatthisis', # The original paying in hash before forwarding.
        'destination_address' => @good_destination_address,  # The destination bitcoin address. Check this matches your address.
        'address' => @good_destination_address
      }
      
    @addr_info_6_confirmations_4500000 = "
    {
    \"hash160\":\"dee5edd96a1e0be7515782cac95f5a2165465350\",
    \"address\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",
    \"n_tx\":2,
    \"total_received\":4500000,
    \"total_sent\":4500000,
    \"final_balance\":0,
    \"txs\":[{\"result\":0,\"block_height\":300440,\"time\":1399933847,\"inputs\":[{\"prev_out\":{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"prev_out\":{\"n\":1,\"value\":17350000,\"addr\":\"1DTyQoJDr9P8iQ8CSjoFtc9Mxz3i4Y2eU\",\"tx_index\":56329047,\"type\":0,\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"},\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"}],\"vout_sz\":2,\"relayed_by\":\"127.0.0.1\",\"hash\":\"f8c7969b81cfab6b75567eb8a79a4d397272e2589d1bab916409998df9aac957\",\"vin_sz\":2,\"tx_index\":56343161,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a9149f1fb7e3d5e11d214d9d5d443029321086d0512a88ac\"},{\"n\":1,\"value\":17340000,\"addr\":\"1A2S2grsMJGGGP72xRQYBTf5bN2BNET28D\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a91462fe70f5a4600fe607598b8618eea00779ca117488ac\"}],\"size\":375},{\"result\":-4500000,\"block_height\":300443,\"time\":1399933843,\"inputs\":[{\"prev_out\":{\"n\":1,\"value\":41131580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56328225,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"},\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"vout_sz\":2,\"relayed_by\":\"108.61.10.90\",\"hash\":\"cc1064f5f48f608aa88951b39aab9f2207e7e4dff0d1d30fb3097ade682c5825\",\"vin_sz\":1,\"tx_index\":56343160,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"spent\":false,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"n\":1,\"value\":36621580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56343160,\"spent\":true,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"size\":225}]
    }
    "
    
    @addr_info_6_confirmations_4600000 = "
    {
    \"hash160\":\"dee5edd96a1e0be7515782cac95f5a2165465350\",
    \"address\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",
    \"n_tx\":4,
    \"total_received\":4600000,
    \"total_sent\":4600000,
    \"final_balance\":0,
    \"txs\":[
      {\"result\":0,\"block_height\":300440,\"time\":1399933847,\"inputs\":[{\"prev_out\":{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"prev_out\":{\"n\":1,\"value\":17350000,\"addr\":\"1DTyQoJDr9P8iQ8CSjoFtc9Mxz3i4Y2eU\",\"tx_index\":56329047,\"type\":0,\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"},\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"}],\"vout_sz\":2,\"relayed_by\":\"127.0.0.1\",\"hash\":\"f8c7969b81cfab6b75567eb8a79a4d397272e2589d1bab916409998df9aac957\",\"vin_sz\":2,\"tx_index\":56343161,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a9149f1fb7e3d5e11d214d9d5d443029321086d0512a88ac\"},{\"n\":1,\"value\":17340000,\"addr\":\"1A2S2grsMJGGGP72xRQYBTf5bN2BNET28D\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a91462fe70f5a4600fe607598b8618eea00779ca117488ac\"}],\"size\":375},{\"result\":-4500000,\"block_height\":300443,\"time\":1399933843,\"inputs\":[{\"prev_out\":{\"n\":1,\"value\":41131580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56328225,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"},\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"vout_sz\":2,\"relayed_by\":\"108.61.10.90\",\"hash\":\"cc1064f5f48f608aa88951b39aab9f2207e7e4dff0d1d30fb3097ade682c5825\",\"vin_sz\":1,\"tx_index\":56343160,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"spent\":false,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"n\":1,\"value\":36621580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56343160,\"spent\":true,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"size\":225},
      {\"result\":0,\"block_height\":300440,\"time\":1399933847,\"inputs\":[{\"prev_out\":{\"n\":0,\"value\":100000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"prev_out\":{\"n\":1,\"value\":17350000,\"addr\":\"1DTyQoJDr9P8iQ8CSjoFtc9Mxz3i4Y2eU\",\"tx_index\":56329047,\"type\":0,\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"},\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"}],\"vout_sz\":2,\"relayed_by\":\"127.0.0.1\",\"hash\":\"f8c7969b81cfab6b75567eb8a79a4d397272e2589d1bab916409998df9aac958\",\"vin_sz\":2,\"tx_index\":56343161,\"ver\":1,\"out\":[{\"n\":0,\"value\":100000,\"addr\":\"1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a9149f1fb7e3d5e11d214d9d5d443029321086d0512a88ac\"},{\"n\":1,\"value\":17340000,\"addr\":\"1A2S2grsMJGGGP72xRQYBTf5bN2BNET28D\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a91462fe70f5a4600fe607598b8618eea00779ca117488ac\"}],\"size\":375},{\"result\":-100000,\"block_height\":300443,\"time\":1399933843,\"inputs\":[{\"prev_out\":{\"n\":1,\"value\":41131580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56328225,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"},\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"vout_sz\":2,\"relayed_by\":\"108.61.10.90\",\"hash\":\"cc1064f5f48f608aa88951b39aab9f2207e7e4dff0d1d30fb3097ade682c5825\",\"vin_sz\":1,\"tx_index\":56343160,\"ver\":1,\"out\":[{\"n\":0,\"value\":100000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"spent\":false,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"n\":1,\"value\":36621580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56343160,\"spent\":true,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"size\":225}]
    }
    "
  end
  
  describe "GET /bitcoin_payments" do

    it "it should block users who are not signed in" do
      # get bitcoin_payments_path
      get "bitcoin_payments_index"
      response.status.should be(302)
    end
    
    it "it should allow admin users in" do
      create_and_sign_on_as_admin
      
      get "bitcoin_payments_index"
      response.status.should be(200)
    end
  end
  
  describe "GET /bitcoin_payments_callback" do
    it "should record the payment in the database and all that stuff" do
      expect{
        get "/bitcoin_payments_callback", @bitcoin_payments_params
      }.to change(BitcoinPayment, :count).by 1

     response.status.should eq 200
     response.body.should eq "*ok*"
    end
    
    it "should set the proper values" do
      get "/bitcoin_payments_callback", @bitcoin_payments_params
      BitcoinPayment.first.destination_address.should eq @bitcoin_payments_params["destination_address"]
    end
    
    # it "should block test payments from going through"   # it's setup, but we can't test it for obvious reasons
    
    # it "should block payments from anywhere other than blockchain.info??" # we shouldn't do that because their IP will probably change...
    
    it "should block payments with the wrong, malicious destination address" do
      expect{
        get "/bitcoin_payments_callback", @bitcoin_payments_params.merge({ "destination_address" => "1"})
      }.to change(BitcoinPayment, :count).by 0
    end
    
    it "should block payments if the 'secret_authorization_token' is wrong " do
      expect{
        get "/bitcoin_payments_callback", @bitcoin_payments_params.merge({ "secret_authorization_token" => "1234"})
      }.to change(BitcoinPayment, :count).by 0
    end
    
    it "should mark the associated sale as receipt_confirmed if it's been paid in full" do
      get "/bitcoin_payments_callback", @bitcoin_payments_params
      sale = Sale.find(@sale.to_param)
      sale.receipt_confirmed?.should be true
    end
    
    it "should wait if the value submitted is not equal to or greater than the cost of the book" do
      get "/bitcoin_payments_callback", @bitcoin_payments_params.merge({ "value" => @partial_payment })
      sale = Sale.find(@sale.to_param)
      sale.receipt_confirmed?.should be false
      
      get "/bitcoin_payments_callback", @bitcoin_payments_params.merge({ "value" => @missing_payment, "transaction_hash" => "secondHash" })
      sale = Sale.find(@sale.to_param)
      sale.receipt_confirmed?.should be true
    end
    
  end
  
  describe "/new_payments_found" do
    
    # The way I do this is really hackish and stupid...
    it "should accept finding new payments" do
      $TestCheckoutWalletAddressLookup = @addr_info_6_confirmations_4500000
      
      # make the sale cost a little bit more so the first payment doesn't mark the sale as fully paid
      book_item = @sale.line_items.find_by_product_sku("0001")
      book_item
        .update_attributes(price: (book_item.price + 1910000))
      book_item.calculate_fields!
      
      $TriggerPaymentFoundOnNextRequest = true
      get "/new_payments_found"
      response.body.should eq "true"
      
      # set lml to nil on checkout_wallet
      CheckoutWallet.first.update_attributes(last_manual_lookup: nil)
      
      $TriggerPaymentFoundOnNextRequest = true
      get "/new_payments_found"
      response.body.should eq "false"
      
      $TriggerPaymentFoundOnNextRequest = true
      get "/new_payments_found"
      response.body.should eq "false"
      
      # begin hackishness
      $TestCheckoutWalletAddressLookup = @addr_info_6_confirmations_4600000
      
      sale = Sale.first
      sale.receipt_confirmed = nil
      sale.save
      
      CheckoutWallet.first.update_attributes(last_manual_lookup: nil)
      $TriggerPaymentFoundOnNextRequest = true
      get "/new_payments_found"
      response.body.should eq "true"
    end
  end
  
  
  
end
