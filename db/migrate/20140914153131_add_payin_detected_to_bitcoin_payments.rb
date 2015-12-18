class AddPayinDetectedToBitcoinPayments < ActiveRecord::Migration
  def change
    add_column :bitcoin_payments, :payin_detected, :boolean
  end
end
