module Spree
    module Api
        module V2
            module Storefront
                class WinbankPaymentsController < ::Spree::Api::V2::BaseController
                    include Spree::Api::V2::Storefront::OrderConcern
                    before_action :ensure_order, only: :create
                    
                    def create
                        spree_authorize! :update, spree_current_order, order_token

                        payment = spree_current_order.payments.checkout.first
        
                        begin
                            raise 'There is no selected payment method' unless payment

                            unless payment.payment_method.type === "Spree::PaymentMethod::WinbankPayment"
                                raise 'Order has not WinbankPayment'
                            end
                            
                            url = 'https://paycenter.piraeusbank.gr/services/tickets/issuer.asmx'

                            preferences = payment.payment_method.preferences
                            raise 'There is no preferences on payment methods' unless preferences

                            password = Digest::MD5.hexdigest(preferences[:password])

                            uuid = SecureRandom.uuid

                            message = %Q[<?xml version="1.0" encoding="utf-8"?>
                                <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
                                <soap12:Body>
                                    <IssueNewTicket xmlns="http://piraeusbank.gr/paycenter/redirection">
                                    <Request>
                                        <Username>#{preferences[:user_name]}</Username>
                                        <Password>#{password}</Password>
                                        <MerchantId>#{preferences[:merchant_id]}</MerchantId>
                                        <PosId>#{preferences[:pos_id]}</PosId>
                                        <AcquirerId>#{preferences[:acquirer_id]}</AcquirerId>
                                        <MerchantReference>#{payment.number}</MerchantReference>
                                        <RequestType>02</RequestType>
                                        <ExpirePreauth>0</ExpirePreauth>
                                        <Amount>#{payment.amount}</Amount>
                                        <CurrencyCode>978</CurrencyCode>
                                        <Installments>0</Installments>
                                        <Bnpl>0</Bnpl>
                                        <Parameters>#{uuid}</Parameters>
                                    </Request>
                                    </IssueNewTicket>
                                </soap12:Body>
                                </soap12:Envelope>]

                            response = Net::HTTP.post(
                                URI(url),
                                message.strip,
                                'Content-Type' => 'application/soap+xml; charset=UTF-8'
                            )

                            body = response.body

                            result_code = body.match(/<ResultCode>(\d)<\/ResultCode>/)
                            result_description = body.match(/<ResultDescription>(.*)<\/ResultDescription>/)
                            result_tran_ticket = body.match(/<TranTicket>(\S+)<\/TranTicket>/)
                            result_timestamp = body.match(/<Timestamp>(\S+)<\/Timestamp>/)
                            
                            if result_code && result_code[1].to_i == 0
                                payment.winbank_payments.create!(
                                    transaction_ticket: result_tran_ticket[1],
                                    uuid: uuid
                                )
                                
                                render json: {code: result_code[1].to_i}
                            else
                                render_error_payload(result_description[1])
                            end
                        rescue => exception
                            render_error_payload(exception.to_s)
                        end
                    end

                    def failure
                        fields = winbank_payment_params('failure')

                        winbank_payment = Spree::WinbankPayment.find_by(uuid: fileds[:merchant_reference])

                        if winbank_payment.update(fields)
                            render json: {ok: true}
                        else
                            render json: {ok: false, errors: winbank_payment.errors.full_messages}, status: 400
                        end
                    end

                    def success
                        fields = params.require(:winbank_payment).permit!

                        winbank_payment = Spree::WinbankPayment.find_by(uuid: fields[:parameters])

                        if winbank_payment.update(winbank_payment_params('success'))
                            # order = winbank_payment.payment.order

                            # complete_service.call(order: order)

                            render json: {ok: true}
                        else
                            render json: {ok: false, errors: winbank_payment.errors.full_messages}, status: 400
                        end
                    end

                    private
                    def winbank_payment_params(state)
                        if state == 'success'
                            params.require(:winbank_payment)
                                .permit(:support_reference_id , :merchant_reference, :result_code, :result_description,
                                        :status_flag, :approval_code, :package_no, :auth_status, :transaction_id)
                        else
                            params.require(:winbank_payment)
                                .permit(:support_reference_id , :merchant_reference, :result_code, :result_description)
                        end
                    end
                end
            end
        end
    end
end