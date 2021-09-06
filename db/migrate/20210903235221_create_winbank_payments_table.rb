class CreateWinbankPaymentsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_winbank_payments do |t|
      t.references :payment
      t.string :transaction_ticket, index:{unique: true}, null: false
      t.integer :spree_winbank_payments, :support_reference_id, index: true
      t.string :spree_winbank_payments, :result_code
      t.string :spree_winbank_payments, :result_description
      t.string :spree_winbank_payments, :status_flag
      t.string :spree_winbank_payments, :merchant_reference
      t.integer :spree_winbank_payments, :package_no
      t.string :spree_winbank_payments, :approval_code
      t.string :spree_winbank_payments, :auth_status
      t.string :spree_winbank_payments, :uuid, index: {unique: true}, null: false
      t.string :spree_winbank_payments, :response_code
      t.string :spree_winbank_payments, :response_description

      t.timestamps
    end
  end
end
