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

      # map response codes to something humans can read
      @@response_codes = {
        "000" => "Transaction successful",
        "001" => "Declined by issuer",
        "002" => "Declined by issuer",
        "003" => "Invalid merchant",
        "004" => "Invalid card",
        "005" => "Authorization declined",
        "006" => "Sequence- generation- number error - diagnostics necessary",
        "007" => "CVV is mandatory but not set or invalid",
        "012" => "Invalid Transaction",
        "013" => "Invalid Amount",
        "014" => "Invalid card",
        "021" => "No action taken",
        "030" => "Format Error",
        "031" => "Card Issuer not approved",
        "033" => "Card expired",
        "034" => "Suspicion of Manipulation",
        "043" => "Pick up card (Stolen card)",
        "051" => "Insufficient funds - Limit exceeded override possible",
        "054" => "Expired card",
        "055" => "Incorrect PIN (Personal Identification Number)",
        "057" => "Card does not match original; when Refund attempted Card busy with reservation or tip update",
        "058" => "Terminal ID unknown",
        "061" => "Card is blocked in local block list",
        "062" => "Restricted card",
        "064" => "The amount of the referencing transaction is higher than original transaction amount",
        "065" => "Transaction frequency limit exceeded override is possible",
        "075" => "PIN entered incorrectly too often",
        "076" => "Key index not allowed",
        "077" => "PIN entry necessary",
        "080" => "Amount no longer available",
        "081" => "Message-flow error",
        "082" => "Pre-initialization is not allowed (Terminal blocked)",
        "085" => "Rejected by Credit Card Institute",
        "089" => "CRC is incorrect",
        "091" => "Card issuer temporarily not reachable",
        "092" => "The card type is not processed by the authorization center",
        "094" => "Duplicated requests",
        "096" => "System malfunction",
        "097" => "Security breach - MAC check indicates error condition",
        "098" => "Trace number not sequential further diagnostic required",
        "099" => "Error in PAC encryption detected",
        "300" => "A field is missing",
        "301" => "Length of input parameter exceed maximum length allowed",
        "302" => "Request from IP not allowed",
        "303" => "Request from website url not allowed",
        "304" => "Website verification failed wrong websiteID or password",
        "305" => "Merchant account is disabled",
        "306" => "Amount must be a positive integer",
        "307" => "Invalid card number format",
        "308" => "Expire year must be a full year e.g. 2008",
        "309" => "Expire month must be 2 digits e.g. 07",
        "310" => "Card verification code(CVV) must be 3 or 4 digits",
        "311" => "Invalid customer IP",
        "312" => "The transaction with the given ID does not exists or is not related to the given websiteID",
        "313" => "Unknown currency code",
        "314" => "Unknown country code",
        "315" => "Invalid email address",
        "316" => "Invalid card number",
        "317" => "Invalid card security code",
        "318" => "Invalid userVar4 format (must be 2 digits)",
        "319" => "Invalid expiry month",
        "320" => "Start year must be a full year e.g. 2008",
        "321" => "Start month must be 2 digits e.g. 07",
        "322" => "Invalid start month",
        "323" => "Card issue number must have 2 digits",
        "333" => "Issuer authentication required (3D)",
        "334" => "Obsolete API - use S3DConfirm",
        "410" => "Rejected - attempting to capture n non-AUTH transaction",
        "411" => "Rejected - attempting to capture an unsuccessful AUTH transaction",
        "412" => "Rejected - attempting to capture an already captured AUTH transaction",
        "413" => "Rejected - attempting to capture too large an amount",
        "414" => "Rejected - attempting to capture a canceled AUTH transaction",
        "420" => "Rejected - attempting to cancel a non-AUTH transaction",
        "421" => "Rejected - attempting to cancel an unsuccessful AUTH transaction",
        "422" => "Rejected - attempting to cancel an already canceled transaction",
        "423" => "Rejected - attempting to cancel an captured AUTH transaction",
        "424" => "Rejected - transaction cannot be canceled",
        "430" => "Rejected - attempting to perform a refund on a non-captured transaction",
        "431" => "Rejected - attempting to perform a refund on unsuccessful capture transaction",
        "432" => "Rejected - attempting to perform a refund on an already refunded transaction",
        "433" => "Rejected - attempting to perform a refund with a too large amount",
        "434" => "Rejected - attempting to perform a refund on canceled transaction",
        "440" => "Rejected - attempting to rebill a non-captured transaction",
        "441" => "Rejected - attempting to rebill an unsuccessful capture transaction",
        "442" => "Rejected - attempting to rebill canceled transaction",
        "443" => "Rejected - attempting to rebill transaction originating from virtual terminal",
        "450" => "Rejected - crediting is allowed only on SALE, AUTH, REBILL, CAPTURE and REFUND transactions",
        "451" => "Rejected - attempted to credit on canceled transaction",
        "452" => "Rejected - attempting to perform a credit on unsuccessful transaction",
        "460" => "Rejected - attempting to do 3D confirmation on invalid transaction type",
        "461" => "Rejected - attempting to do 3D confirmation on already authorized transaction",
        "462" => "Rejected - to do 3D confirmation on canceled transaction",
        "463" => "Rejected - attempting to do 3D confirmation on transaction that doesn't require it",
        "500" => "Card is blocked",
        "501" => "E-mail is blocked",
        "502" => "Customer IP is blocked",
        "510" => "Sale call not allowed",
        "512" => "Authorize call not allowed",
        "513" => "Credit call not allowed",
        "514" => "Capture call not allowed",
        "515" => "Refund call not allowed",
        "516" => "Cancel call not allowed",
        "517" => "Rebill call not allowed",
        "518" => "Address Verification Service (AVS) not allowed",
        "519" => "Fraud Screening (FS) not allowed",
        "520" => "Secure 3D not allowed",
        "530" => "The amount is smaller than the lower limit on the current terminal;",
        "531" => "The amount is greater than the upper limit on the current terminal;",
        "540" => "Turnover per day on sale transactions exceeded",
        "541" => "Turnover per month on sale transactions exceeded",
        "542" => "Turnover per day on capture transactions exceeded",
        "543" => "Turnover per month on capture transactions exceeded",
        "550" => "Number of sale transactions per minute exceeded",
        "551" => "Number of sale transactions per day exceeded",
        "552" => "Number of sale transactions per month exceeded",
        "553" => "Number of authorize transactions per minute exceeded",
        "554" => "Number of authorize transactions per day exceeded",
        "555" => "Number of authorize transactions per month exceeded",
        "556" => "Number of capture transactions per minute exceeded",
        "557" => "Number of capture transactions per day exceeded",
        "558" => "Number of capture transactions per month exceeded",
        "559" => "Number of refund transactions per minute exceeded",
        "560" => "Number of refund transactions per day exceeded",
        "561" => "Number of refund transactions per month exceeded",
        "580" => "Multiple transactions within 5 min after success is declined",
        "581" => "Multiple transactions within 1 hour after decline is declined",
        "600" => "Invalid AVS policy. Must be either NI, ABNI, WZPNI, ABWZPNI, IGNORE or SKIP",
        "601" => "Address, Zipcode, and CountryCode must be provided to perform AVS",
        "620" => "Invalid FS policy. Must be either DENY, CHALLENGE, ERROR, IGNORE or SKIP",
        "621" => "Fraud Screening not enabled on the provider",
        "650" => "Card not enrolled for 3D Secure",
        "651" => "Invalid S3D data",
        "652" => "Card enrollment information not available",
        "653" => "ACS message or signature is invalid",
        "654" => "Unable to connect to the Visa Directory Server",
        "700" => "Gateway down for maintenance"
      }

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
        requires!(options, :order_id) unless options[:d3d]

        if options[:d3d]
          requires!(options, :transaction_id, :pa_res)
        end

        if options[:d3d]
          request = build_request do |xml|
            xml.tag! 'tns:S3DConfirm' do
              xml.tag! 'S3DConfirmRequest', { 'soapenc:id' => 'id0', 'xsi:type' => 'tns:S3DConfirmRequest' } do
                add_merchant_data(xml, options)
                add_3d_data(xml, options)
              end
            end
          end
        else
          request = build_request do |xml|
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
        commit(request)
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

      def add_3d_data(xml, options)
        add_pair(xml, 'transactionID', options[:transaction_id])
        add_pair(xml, 'paRES', options[:pa_res])
      end

      def add_pair(xml, name, value)
        xml.tag! name,  { 'xsi:type' => 'xsd:string' }, value
      end

      # Build the standard xml used in all requests, this method accepts a block which is called
      # passing the builder object
      def build_request(&block)
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
            block.call(xml)
          end
        end
        xml.target!
      end

      def parse(xml)
        # puts "***** response"
        # puts xml
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

      # def commit(action, money, creditcard, options)
      def commit(request)
        # request = build_request(action, money, creditcard, options)
        # puts "***** request"
        # puts request
        response = parse ssl_post(self.live_url, request, { 'Content-Type' => 'application/soap+xml; charset=utf-8' })
        # puts "****"
        # puts response

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

