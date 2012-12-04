module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class SoEasyPayGateway < Gateway
      self.test_url = 'https://secure.soeasypay.com/gateway.asmx'
      self.live_url = 'https://secure.soeasypay.com/gateway.asmx'

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['GB']

      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :switch, :maestro, :solo]

      # The homepage URL of the gateway
      self.homepage_url = 'http://www.soeasypay.com/'

      # The name of the gateway
      self.display_name = 'So Easy Pay'

      self.default_currency = 'GBP'

      self.money_format = :cents

      def initialize(options = {})
        requires!(options, :login, :password)
        super
      end

      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)
        add_address(post, creditcard, options)
        add_customer_data(post, options)

        commit('authonly', money, post)
      end

      def purchase(money, creditcard, options = {})
        requires!(options, :order_id)
        commit('sale', money, creditcard, options)
      end

      def capture(money, authorization, options = {})
        commit('capture', money, post)
      end

      private

      def add_customer_data(xml, options)
        add_pair(xml, 'cardHolderEmail', options[:email]) unless options[:email].blank?
        add_pair(xml, 'customerIP', options[:ip])
      end

      def add_address(xml, options)
        add_pair(xml, 'cardHolderAddress', options[:billing_address][:address1])
        add_pair(xml, 'cardHolderZipcode', options[:billing_address][:zip])
        add_pair(xml, 'cardHolderCity', options[:billing_address][:city])
        add_pair(xml, 'cardHolderState', options[:billing_address][:state])
        add_pair(xml, 'cardHolderCountryCode', options[:billing_address][:country])
        add_pair(xml, 'cardHolderPhone', options[:billing_address][:phone])
      end

      def add_invoice(xml, amount, options)
        add_pair(xml, 'orderID', options[:order_id])
        add_pair(xml, 'orderDescription', options[:description])
        add_pair(xml, 'amount', amount)
        add_pair(xml, 'currency', options[:currency])
      end

      def add_creditcard(xml, creditcard)
        add_pair(xml, 'cardHolderName', "#{creditcard.first_name} #{creditcard.last_name}")
        add_pair(xml, 'cardNumber', creditcard.number)
        add_pair(xml, 'cardSecurityCode', creditcard.verification_value)
        add_pair(xml, 'cardExpireMonth', format(creditcard.month, :two_digits))
        add_pair(xml, 'cardExpireYear', format(creditcard.year, :four_digits))
      end

      def add_merchant_data(xml, options)
        add_pair(xml, 'websiteID', @options[:login])
        add_pair(xml, 'password', @options[:password])
      end

      def add_pair(xml, name, value)
        xml.tag! name,  { 'xsi:type' => 'xsd:string' }, value
      end

      # Where we actually build the full SOAP request using builder
      def build_request(action, money, creditcard, options)
        xml = Builder::XmlMarkup.new :indent => 2
        xml.instruct!
        xml.tag! 'soap12:Envelope', { 'xmlns:xsi'     => 'http://www.w3.org/2001/XMLSchema-instance',
                                      'xmlns:xsd'     => 'http://www.w3.org/2001/XMLSchema',
                                      'xmlns:soapenc' => 'http://www.w3.org/2003/05/soap-encoding',
                                      'xmlns:tns'     => 'urn:Interface',
                                      'xmlns:types'   => 'urn:Interface/encodedTypes',
                                      'xmlns:rpc'     => 'http://www.w3.org/2003/05/soap-rpc',
                                      'xmlns:soap12'  => 'http://www.w3.org/2003/05/soap-envelope' } do

          xml.tag! 'soap12:Body', { 'soap12:encodingStyle' => 'http://www.w3.org/2003/05/soap-encoding' } do
            xml.tag! 'tns:SaleTransaction' do
              xml.tag! 'SaleTransactionRequest', { 'soapenc:id' => 'id0', 'xsi:type' => 'tns:SaleTransactionRequest' } do
                add_merchant_data(xml, options)
                add_customer_data(xml, options)
                add_address(xml, options)
                add_creditcard(xml, creditcard)
                add_invoice(xml, money, options)
              end
            end
          end
        end
        xml.target!
      end

      def parse(xml)
        puts xml
        response = {}
        xml = REXML::Document.new(xml)
        root = REXML::XPath.first(xml, "//return") ||
               REXML::XPath.first(xml, "//ErrorResponse")
        if root
          root.elements.to_a.each do |node|
            recurring_parse_element(response, node)
          end
        end

        response
      end

      def recurring_parse_element(response, node)
        if node.has_elements?
          node.elements.each{|e| recurring_parse_element(response, e) }
        else
          response[node.name.underscore.to_sym] = node.text
        end
      end

      def commit(action, money, creditcard, options)
        request = build_request(action, money, creditcard, options)
        puts request
        response = parse ssl_post(self.live_url, request, { 'Content-Type' => 'application/soap+xml; charset=utf-8' })
        puts "****"
        puts response

        success = response[:status] == "Authorized"
        message = response[:errormessage]
        authorization = success ? response[:transaction_id] : nil

        Response.new(success, message, response,
          :test => test?,
          :authorization => authorization,
          :avs_result => { :code => response[:avs_result] }
        )
      end

      def message_from(response)
      end

      def post_data(action, parameters = {})
      end
    end
  end
end

