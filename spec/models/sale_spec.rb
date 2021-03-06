require 'spec_helper'

describe Sale do
  
  before(:each) do
    @attr = {
      
      }
    
    populate_products
    
    
    @addr_info_6_confirmations = "
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
    
    
    @addr_info_3_confirmations = "
    {
    \"hash160\":\"dee5edd96a1e0be7515782cac95f5a2165465350\",
    \"address\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",
    \"n_tx\":2,
    \"total_received\":4500000,
    \"total_sent\":4500000,
    \"final_balance\":0,
    \"txs\":[{\"result\":0,\"block_height\":300443,\"time\":1399933847,\"inputs\":[{\"prev_out\":{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"prev_out\":{\"n\":1,\"value\":17350000,\"addr\":\"1DTyQoJDr9P8iQ8CSjoFtc9Mxz3i4Y2eU\",\"tx_index\":56329047,\"type\":0,\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"},\"script\":\"76a914025b81d31497cadfc7682178a981a0c54a3cdf7788ac\"}],\"vout_sz\":2,\"relayed_by\":\"127.0.0.1\",\"hash\":\"f8c7969b81cfab6b75567eb8a79a4d397272e2589d1bab916409998df9aac957\",\"vin_sz\":2,\"tx_index\":56343161,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a9149f1fb7e3d5e11d214d9d5d443029321086d0512a88ac\"},{\"n\":1,\"value\":17340000,\"addr\":\"1A2S2grsMJGGGP72xRQYBTf5bN2BNET28D\",\"tx_index\":56343161,\"spent\":true,\"type\":0,\"script\":\"76a91462fe70f5a4600fe607598b8618eea00779ca117488ac\"}],\"size\":375},{\"result\":-4500000,\"block_height\":300443,\"time\":1399933843,\"inputs\":[{\"prev_out\":{\"n\":1,\"value\":41131580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56328225,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"},\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"vout_sz\":2,\"relayed_by\":\"108.61.10.90\",\"hash\":\"cc1064f5f48f608aa88951b39aab9f2207e7e4dff0d1d30fb3097ade682c5825\",\"vin_sz\":1,\"tx_index\":56343160,\"ver\":1,\"out\":[{\"n\":0,\"value\":4500000,\"addr\":\"1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf\",\"tx_index\":56343160,\"spent\":false,\"type\":0,\"script\":\"76a914dee5edd96a1e0be7515782cac95f5a216546535088ac\"},{\"n\":1,\"value\":36621580,\"addr\":\"168BxnDdE2YbEGNLzkwtsFD5AVdPTKJNKn\",\"tx_index\":56343160,\"spent\":true,\"type\":0,\"script\":\"76a9143834b0e77f58dc0633a8bbdd10c8b1742ea2982088ac\"}],\"size\":225}]
    }
    "
    
    @blockchain_info = "
    {
    \"hash\":\"000000000000000038a7c0bef0b641b592784a6f332369822a850c9a3bf79ace\",
    \"time\":1399934770,
    \"block_index\":405224,
    \"height\":300446,
    \"txIndexes\":[56343552,56343504,56343400,56343363,56344357,56344230,56343364,56343359,56344332,56344233,56344286,56343374,56344389,56344306,56343350,56344326,56344408,56343377,56343485,56344396,56343432,56343256,56343490,56343403,56343385,56343533,56343458,56344250,56344368,56344363,56344308,56344344,56343513,56344410,56343410,56344278,56344299,56343526,56344327,56343510,56344369,56343478,56344355,56344328,56344305,56343378,56344348,56343352,56344318,56343436,56344235,56343459,56343354,56344330,56344210,56344262,56344222,56344384,56344243,56344241,56343445,56343386,56344383,56344371,56343382,56344220,56343406,56344284,56344276,56344302,56344228,56343394,56343379,56343384,56344376,56343371,56343492,56344224,56343376,56343469,56344272,56343471,56343489,56343411,56343460,56343370,56343525,56344341,56343477,56344346,56343505,56343507,56343351,56343415,56344392,56344391,56344311,56344239,56344208,56343392,56343447,56344226,56344350,56343524,56344246,56344374,56344411,56343527,56343499,56344279,56344225,56344227,56343420,56343412,56343360,56344329,56343523,56344321,56343393,56343427,56343502,56344288,56343514,56343506,56344312,56343413,56343425,56343500,56344364,56344336,56344338,56343461,56343462,56344260,56344261,56344216,56343365,56344333,56344334,56344378,56343493,56344352,56344337,56344339,56344400,56343448,56343449,56343453,56343455,56344304,56343465,56344273,56343423,56344283,56343435,56344379,56343512,56344253,56343405,56343380,56343451,56343452,56344229,56344255,56344256,56344267,56343419,56344266,56343429,56343368,56343481,56344347,56343535,56344358,56343437,56343367,56343443,56343484,56344399,56343470,56343369,56343480,56343355,56343444,56344109,56343488,56344282,56344394,56344402,56344240,56343475,56344360,56344398,56343391,56344403,56344385,56344362,56343402,56344366,56343537,56343486,56344359,56343457,56344345,56343390,56343487,56344277,56344373,56344382,56344370,56343454,56344407,56344335,56344320,56344313,56344349,56343438,56344205,56344390,56344245,56344242,56343479,56343501,56344291,56344380,56343473,56343417,56344377,56344295,56343431,56344301,56343372,56344395,56344388,56344343,56344323,56344372,56343528,56343494,56344254,56344274,56344249,56343424,56344252,56343401,56343430,56344298,56344296,56344211,56343358,56343426,56343366,56344365,56344300,56343463,56344292,56343531,56344236,56343383,56343476,56343446,56344257,56344381,56343387,56344287,56343467,56343450,56343398,56344120,56344072,56344268,56343200,56344353,56343182,56343290,56344387,56343439,56344145,56344156,56344259,56344269,56344290,56343482,56343496,56343472,56344247,56343265,56341982,56342000,56344219,56343515,56344401,56344199,56342005,56344162,56344232,56344293,56343428,56343414,56344080,56343217,56343503,56344186,56344143,56343422,56344107,56343292,56343421,56344386,56341980,56344083,56343516,56343329,56343346,56343434,56343179,56343169,56344129,56343536,56343168,56343228,56343483,56343511,56341985,56344324,56343289,56344289,56343361,56344342,56343375,56344367,56344317,56344067,56343530,56343205,56343357,56344213,56343381,56343191,56343324,56343395,56344192,56344198,56344409,56343171,56344331,56343441,56344303,56343466,56343193,56344188,56344094,56343345,56343210,56344112,56344105,56344164,56344248,56343464,56344231,56343177,56343203,56343404,56344193,56344202,56342008,56344110,56343491,56344406,56343353,56344294,56343286,56344190,56344082,56343263,56343529,56343532,56344234,56343388,56343273,56344100,56343389,56344264,56344271,56343204,56343227,56343232,56341999,56343440,56344310,56343170,56344207,56344322,56344340,56344351,56344361,56344375,56343517,56344144,56343306,56344174,56344280,56344095,56344160,56341986,56344111,56344319,56344354,56343319,56344258,56343518,56344238,56343180,56343173,56343260,56344285,56344200,56344209,56343356,56343280,56344307,56343250,56343249,56343344,56343456,56344397,56343338,56344135,56344142,56343309,56343320,56344106,56344325,56343497,56343224,56344263,56344275,56344251,56343258,56343519,56344157,56343520,56341989,56344297,56344218,56344270,56344217,56344281,56343474,56343534,56343397,56343407,56343409,56343272,56343287,56344206,56343509,56344405,56343442,56343184,56344071,56343242,56342003,56343211,56343214,56343373,56344223,56343321,56344309,56344393,56344212,56343396,56344244,56343433,56344314,56344315,56344356,56344316,56343495,56343521,56343522,56343223,56343243,56344097,56343296,56344214,56343468,56344204,56343362,56343399,56343408,56343208]
  }
    "
  end
  
  it "should create a new instance" do
    Sale.create!
  end
  # it's very important that the wrong kind of music not be aloud in the republic. -- Plato
  
  it "should have a working order_status function" do
    user = FactoryGirl.create(:user_with_1_book)
    s = user.sales.first

    s.order_status.should be :awaiting_download
    s.update_attributes(prepped: true)
    s.order_status.should be :awaiting_shipment
    
    user = FactoryGirl.create(:user_with_1_book_unpaid)
    user.sales.first.order_status.should be :awaiting_payment
    
    user = FactoryGirl.create(:user_with_1_shipped_book)
    user.sales.first.order_status.should be :shipped
  end
  
  it "Sale#query_payment_status should work" do
    user = FactoryGirl.create(:user_with_1_book_unpaid)
    sale = user.sales.first
    
    $TriggerPaymentFoundOnNextRequest = true
    confirmed_payments = sale.get_confirmed_payments(:query_info => [@blockchain_info, @addr_info_6_confirmations])
    confirmed_payments.should eq 4500000
    
    $TriggerPaymentFoundOnNextRequest = true
    sale.reload
    confirmed_payments = sale.get_confirmed_payments(:query_info => [@blockchain_info, @addr_info_6_confirmations])
    confirmed_payments.should eq 4500000
    
    # this operation should have added 1 BitcoinPayment
    sale.bitcoin_payments.count.should eq 1
  end
  
  it "should update BitcoinPayment records for Sale#get_confirmed_paymnets" do
    user = FactoryGirl.create(:user_with_1_book_unpaid)
    sale = user.sales.first

    $TriggerPaymentFoundOnNextRequest = true
    confirmed_payments = sale.get_confirmed_payments(:query_info => [@blockchain_info, @addr_info_3_confirmations])
    sale.reload
    bp = sale.bitcoin_payments.first
    
    bp.confirmations.should eq 3
    confirmed_payments.should eq 0
    
    $TriggerPaymentFoundOnNextRequest = true
    confirmed_payments = sale.get_confirmed_payments(:query_info => [@blockchain_info, @addr_info_6_confirmations])
    confirmed_payments.should eq 4500000
    
  end
  
  it "should be able to do Sale#qtys_and_counts_rdy_for_shipment" do
    u = FactoryGirl.create(:user_with_1_book)
    define_sale_as_on_shipping_machine(u.sales.first)
    
    array = Sale.qtys_and_counts_rdy_for_shipment
    array.should eq [[1,1]]
  end
  
  # TODu: Unfinished test on a utility function
  it "should have a manual lookup function that looks at payments that came into the checkout wallet", current: true do
    require 'bitcoin_deep_throat'
    
    setup_sale_and_user
    
    $TriggerPaymentFoundOnNextRequest = true
    tech_pay = @sale.get_confirmed_payments(:form => :technical_payments)
    
    $TriggerPaymentFoundOnNextRequest = true
    confirm_pay = @sale.get_confirmed_payments
    
    # TODO:  what does the @sale.bitcoin_payments and @sale.technical_bitcoin_payments look like?
    # ... the outcomes though... why are they different?
    # what do the txs look like?
    # write a visualizer that can be used on the entire txs
    
    bdt = BitcoinDeepThroat.new
    
    # bdt.process_address_query_response
    
    # expect(tech_pay).to eq confirm_pay
    
  end
  
  it "should be able to save the technical_bitcoin_payments and also trigger technically_paid without a query"
  
  
  
  def setup_sale_and_user
    @user = FactoryGirl.create(:user_with_1_book)
    @sale = @user.sales.first
  end
  
  def define_sale_as_on_shipping_machine(s)
    s.original_id = s.id
    s.ready_for_shipment_batch_id = ReadyForShipmentBatch.gen.id
    s.save
  end
  
  
  
end
