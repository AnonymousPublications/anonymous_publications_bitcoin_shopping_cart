class AddTechnicalBitcoinPaymentIdToBitcoinPayments < ActiveRecord::Migration
  def change
    add_column :bitcoin_payments, :technical_bitcoin_payment_id, :integer
  end
end
