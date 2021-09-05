class AddUuidWinbankPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_winbank_payments, :uuid, :string, index: {unique: true}, null: false
  end
end
