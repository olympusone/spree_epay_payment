class CreateWinbankPaymentsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_winbank_payments do |t|
      t.references :payments
      t.string :transaction_ticket, index:{unique: true}, null: false
      t.timestamps
    end
  end
end
