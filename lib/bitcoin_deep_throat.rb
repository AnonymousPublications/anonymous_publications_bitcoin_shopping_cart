
# A class for working with blockchain over json API, gets a bit technical
class BitcoinDeepThroat
  
  
  def visualize_txs
  end
  
  
  # For default... 
  # 1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB = BITCOIN_PAYMENT_WALLET
  # 1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf = checkout_wallet_address address
  #
  # tx[0] is the
  #   
  #
  def process_address_query_response(response_string = nil)
    response_string = $TestCheckoutWalletAddressLookup if response_string.nil?
    
    checkout_wallet_info = JSON.parse($TestCheckoutWalletAddressLookup)
    
    txs = checkout_wallet_info['txs']
    
    @string = ""
    @indent = 0
    
    plop_text "Count of txs:  #{txs.count}\n\n"
    
    txs.each.with_index do |tx, i|
      @indent = 2
      
      outs = tx['out']
      inputs = tx['inputs']
      
      plop_text "tx[#{i}]\n"
      
      inputs.each do |input|
        input = input["prev_out"]
        @indent = 4
        
        plop_text "Addr (input):  #{input['addr']}\n"
        
        @indent += 2
        plop_text "n: #{input['n']}"
        plop_text "value: #{input['value']}\n"
      end
      
      plop_text "\n"
      
      outs.each do |out|
        @indent = 4
        plop_text "Addr (out):  #{out['addr']}\n"
        #binding.pry
        
        @indent += 2
        plop_text "n: #{out['n']}\n"
        plop_text "Value:  #{out['value']}\n" # if unrecorded_valid_technical_bitcoin_payment?(tx, latest_height, out)
        # TODO: this is only partially finished...
        # create_bitcoin_payment_from_tx(tx, latest_height, out)
      end
      
      plop_text "\n"
    end
    
    puts
    puts @string
    
  end
  
  def indentation
    " " * @indent
  end
  
  def plop_text(text)
    @string += indentation + text
  end
  
end

