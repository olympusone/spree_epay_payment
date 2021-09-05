# This migration comes from spree_winbank_payment (originally 20210904214336)
class AddWinbankPaymentsColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_winbank_payments, :support_reference_id, :integer, index: true
    add_column :spree_winbank_payments, :result_code, :string
    add_column :spree_winbank_payments, :result_description, :string
    add_column :spree_winbank_payments, :status_flag, :string

    add_column :spree_winbank_payments, :merchant_reference, :string
    add_column :spree_winbank_payments, :package_no, :integer
    add_column :spree_winbank_payments, :approval_code, :string
    add_column :spree_winbank_payments, :auth_status, :string
  end
end
