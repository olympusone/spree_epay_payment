module Spree
    module Api
        module V2
            module Storefront
                class EpayPaymentsController < ::Spree::Api::V2::BaseController
                    include Spree::Api::V2::Storefront::OrderConcern
                    before_action :ensure_order, only: :create
                    
                    def create
                        spree_authorize! :update, spree_current_order, order_token

                        payment = spree_current_order.payments.valid.find{|p| p.state != 'void'}
        
                        begin
                            raise 'There is no active payment method' unless payment

                            unless payment.payment_method.type === "Spree::PaymentMethod::EpayPayment"
                                raise 'Order has not EpayPayment'
                            end
                            
                            preferences = payment.payment_method.preferences
                            raise 'There is no preferences on payment methods' unless preferences

                            password = Digest::MD5.hexdigest(preferences[:password])

                            uuid = SecureRandom.uuid

                            message = %Q[<?xml version="1.0" encoding="utf-8"?>
                                <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
                                <soap12:Body>
                                    <IssueNewTicket xmlns="http://piraeusbank.gr/paycenter/redirection">
                                    <Request>
                                        <AcquirerId>#{preferences[:acquirer_id]}</AcquirerId>
                                        <MerchantId>#{preferences[:merchant_id]}</MerchantId>
                                        <PosId>#{preferences[:pos_id]}</PosId>
                                        <Username>#{preferences[:user_name]}</Username>
                                        <Password>#{password}</Password>
                                        <RequestType>02</RequestType>
                                        <CurrencyCode>978</CurrencyCode>
                                        <MerchantReference>#{payment.number}</MerchantReference>
                                        <Amount>#{payment.amount}</Amount>
                                        <Installments>0</Installments>
                                        <ExpirePreauth>0</ExpirePreauth>
                                        <Bnpl>0</Bnpl>
                                        <Parameters>#{uuid}</Parameters>
                                    </Request>
                                    </IssueNewTicket>
                                </soap12:Body>
                                </soap12:Envelope>]

                            response = Net::HTTP.post(
                                URI(preferences[:new_ticket_url]),
                                message.strip,
                                'Content-Type' => 'application/soap+xml; charset=UTF-8'
                            )

                            body = response.body

                            result_code = body.match(/<ResultCode>(\d)<\/ResultCode>/)
                            result_description = body.match(/<ResultDescription>(.*)<\/ResultDescription>/)
                            result_tran_ticket = body.match(/<TranTicket>(\S+)<\/TranTicket>/)
                            result_timestamp = body.match(/<Timestamp>(\S+)<\/Timestamp>/)
                            
                            if result_code && result_code[1].to_i == 0
                                payment.epay_payments.create!(
                                    transaction_ticket: result_tran_ticket[1],
                                    uuid: uuid
                                )
                                
                                render json: {code: result_code[1].to_i, merchant_reference: payment.number}
                            else
                                render_error_payload(result_description[1])
                            end
                        rescue => exception
                            logger.error(exception.to_s)
                            render_error_payload(exception.to_s)
                        end
                    end

                    def failure
                        begin
                            epay_payment = Spree::EpayPayment.find_by(uuid: params[:Parameters])
                            raise 'Payment not found' unless epay_payment

                            payment = epay_payment.payment

                            preferences = payment.payment_method.preferences
                            raise 'There is no preferences on payment methods' unless preferences
                             
                            payment.update(response_code: params[:SupportReferenceID])
                            payment.failure

                            epay_payment.update(
                                support_reference_id: params[:SupportReferenceID],
                                merchant_reference: params[:MerchantReference],
                                result_code: params[:ResultCode],
                                result_description: params[:ResultDescription],
                                response_code: params[:ResponseCode],
                                response_description: params[:ResponseDescription],
                            )

                            redirect_to URI::join(
                                preferences[:cancel_url], 
                                "?status=#{params[:ResultCode]}&message=#{params[:ResultDescription]}").to_s
                        rescue => exception
                            render_error_payload(exception.to_s)
                        end
                    end

                    def success
                        begin
                            epay_payment = Spree::EpayPayment.find_by(uuid: params[:Parameters])
                            raise 'Payment not found' unless epay_payment

                            payment = epay_payment.payment

                            preferences = payment.payment_method.preferences
                            raise 'There is no preferences on payment methods' unless preferences

                            hash_key = [
                                epay_payment.transaction_ticket,
                                preferences[:pos_id],
                                preferences[:acquirer_id],
                                payment.number,
                                fields[:ApprovalCode],
                                fields[:Parameters],
                                fields[:ResponseCode],
                                fields[:SupportReferenceID],
                                fields[:AuthStatus],
                                fields[:PackageNo],
                                fields[:StatusFlag],
                            ].join(';')

                            secure_hash = OpenSSL::HMAC.hexdigest('SHA256', epay_payment.transaction_ticket, hash_key)

                            raise "Hash Key is given!" unless secure_hash.upcase === params[:HashKey]

                            epay_payment.update(
                                support_reference_id: SupportReferenceID,
                                merchant_reference: MerchantReference,
                                status_flag: StatusFlag,
                                response_code: ResponseCode,
                                response_description: ResponseDescription,
                                approval_code: ApprovalCode,
                                package_no: PackageNo,
                                auth_status: AuthStatus,
                                result_code: ResultCode,
                                result_description: ResultDescription,
                                transaction_id: TransactionId,
                                hash_key: HashKey
                            )

                            payment.update(response_code: params[:SupportReferenceID])

                            payment.complete
                            complete_service.call(order: payment.order)

                            redirect_url = preferences[:confirm_url]

                            redirect_to URI::join(
                                redirect_url, 
                                "?status=#{params[:ResultCode]}&message=#{params[:ResultDescription]}").to_s
                        rescue => exception
                            render_error_payload(exception.to_s)
                        end                           
                    end

                    private
                    def complete_service
                        Spree::Api::Dependencies.storefront_checkout_complete_service.constantize
                    end
                end
            end
        end
    end
end