include Warden::Test::Helpers

class TestFuncsController < ApplicationController
  require 'httparty'
  
  
  # If this method gives you trouble, use advise http://jimneath.org/2011/10/19/ruby-ssl-certificate-verify-failed.html

  
  def delete_current_users_btc_pmt
    render text: "not_in_debug" and return if !$IsDebugApiOn
    
    sale_id = params[:sale_id]
    sale = current_user.sales.find(sale_id)
    sale.checkout_wallet.update_attributes(last_manual_lookup: nil)
    
    bp = BitcoinPayment.find_by_transaction_hash("f8c7969b81cfab6b75567eb8a79a4d397272e2589d1bab916409998df9aac957")
    bp.delete unless bp.nil?

    sale.checkout_wallet.calculate_if_payment_complete
    render :text => "*ok*"
  end
  
  # When this global is set, the next query on 
  # query_blockchain_for_new_payments_to_checkout_wallet
  # will return a request that has a payment
  def trigger_bitcoin_payment_found_on_next_request
    authenticate_user!
    
    $TriggerPaymentFoundOnNextRequest = true
    sale = current_user.sales.first
    sale.checkout_wallet.update_attributes(:last_manual_lookup => nil)
    render :text => "*ok*"
  end
  
  # TODu: Implement me
  def mock_completed_payment
    render text: "not_in_debug" and return if !$IsDebugApiOn
  end
  
  # depends on roles being named
  # switches you to a different important user
  def switch_user
    render text: "not_in_debug" and return if !$IsDebugApiOn
    
    new_user = User.find_by_name(params[:u])
    
    login_as new_user, scope: :user
    
    redirect_to "/"
  end
  
  
end