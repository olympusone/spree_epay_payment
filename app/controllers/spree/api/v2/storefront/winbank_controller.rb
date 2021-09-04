module Spree
    module Api
        module V2
            module Storefront
                class WinbankController < ::Spree::Api::V2::BaseController
                    include Spree::Api::V2::Storefront::OrderConcern
                    before_action :ensure_order
                    
                    def issueticket
                        order = Spree::Order.find_by(number: params[:order_number])
                        payment = order.payments.checkout.first
        
                        begin
                            raise 'There is no selected payment method' unless payment

                            unless payment.payment_method.type === "Spree::PaymentMethod::WinbankPayment"
                                raise 'Order has not WinbankPayment'
                            end
                            
                            url = 'https://paycenter.piraeusbank.gr/services/tickets/issuer.asmx'

                            preferences = payment.payment_method.preferences
                            raise 'There is no preferences on payment methods' unless preferences

                            password = Digest::MD5.hexdigest(preferences[:password])

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
                                    <Parameters></Parameters>
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
                                payment.winkbank_payment || payment.build_winkbank_payment
                                payment.winkbank_payment.transaction_ticket = result_tran_ticket[1]
                                payment.save!
                                
                                render json: {code: result_code}
                            else
                                render_error_payload(result_description[1])
                            end
                        rescue => exception
                            render_error_payload(exception.to_s)
                        end
                    end
                end
            end
        end
    end
end