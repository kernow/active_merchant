require 'test_helper'

class SoEasyPayTest < Test::Unit::TestCase
  def setup
    @gateway = SoEasyPayGateway.new(
                 :login => 'login',
                 :password => 'password'
               )

    @credit_card = credit_card
    @amount = 100

    @options = {
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response

    # Replace with authorization number from the successful response
    assert_equal '10626565', response.authorization
    assert response.test?
  end

  def test_3d_secure_purchase
    @gateway.expects(:ssl_post).returns(threed_secure_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response

    # puts response.inspect

    # Replace with authorization number from the successful response
    assert_equal 'https://secure.soeasypay.com/ThreeDSimulator.aspx', response.params['avs_result']
    assert_equal 'bbb48fba58f0cadfe68238edf9fa681387c32bbe029d66cb44c011016f02dfb9102bdd355291c3fe7d911ea044256bd64d', response.params['fs_result']
    assert_equal '10626566', response.params['transaction_id']
    assert_equal 'Issuer authentication required (3D)', response.message
    assert_equal '333', response.params['errorcode']
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end

  private

  # Place raw successful response from gateway here
  def successful_purchase_response
    <<-XML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:soapenc="http://www.w3.org/2003/05/soap-encoding" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:rpc="http://www.w3.org/2003/05/soap-rpc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <tns:SaleTransactionResponse>
      <rpc:result xmlns="">return</rpc:result>
        <return soapenc:id="id1" xsi:type="tns:SaleTransactionResponse">
        <transactionID xsi:type="xsd:string">10626565</transactionID>
        <orderID xsi:type="xsd:string">002ea658345c6672a57420801ed922ac</orderID>
        <status xsi:type="xsd:string">Authorized</status>
        <errorcode xsi:type="xsd:string">000</errorcode>
        <errormessage xsi:type="xsd:string">Transaction successful</errormessage>
        <AVSResult xsi:type="xsd:string">P</AVSResult>
        <FSResult xsi:type="xsd:string">NOSCORE</FSResult>
        <FSStatus xsi:type="xsd:string">0000</FSStatus>
        <cardNumberSuffix xsi:type="xsd:string">**36</cardNumberSuffix>
        <cardExpiryDate xsi:type="xsd:string">12/12</cardExpiryDate>
        <cardType xsi:type="xsd:string">VISA</cardType>
      </return>
    </tns:SaleTransactionResponse>
  </soap:Body>
</soap:Envelope>
    XML
  end

  def threed_secure_response
    <<-XML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:soapenc="http://www.w3.org/2003/05/soap-encoding" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:rpc="http://www.w3.org/2003/05/soap-rpc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <tns:SaleTransactionResponse>
      <rpc:result xmlns="">return</rpc:result>
      <return soapenc:id="id1" xsi:type="tns:SaleTransactionResponse">
        <transactionID xsi:type="xsd:string">10626566</transactionID>
        <orderID xsi:type="xsd:string">3e07f535135d8507afad04e7388060af</orderID>
        <status xsi:type="xsd:string">Not Authorized</status>
        <errorcode xsi:type="xsd:string">333</errorcode>
        <errormessage xsi:type="xsd:string">Issuer authentication required (3D)</errormessage>
        <AVSResult xsi:type="xsd:string">https://secure.soeasypay.com/ThreeDSimulator.aspx</AVSResult>
        <FSResult xsi:type="xsd:string">bbb48fba58f0cadfe68238edf9fa681387c32bbe029d66cb44c011016f02dfb9102bdd355291c3fe7d911ea044256bd64d</FSResult>
        <FSStatus xsi:type="xsd:string">0000</FSStatus>
      </return>
    </tns:SaleTransactionResponse>
  </soap:Body>
</soap:Envelope>
    XML
  end

  # Place raw failed response from gateway here
  def failed_purchase_response
     <<-XML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:soapenc="http://www.w3.org/2003/05/soap-encoding" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:rpc="http://www.w3.org/2003/05/soap-rpc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <tns:SaleTransactionResponse>
      <rpc:result xmlns="">return</rpc:result>
      <return soapenc:id="id1" xsi:type="tns:SaleTransactionResponse">
        <transactionID xsi:type="xsd:string">10626570</transactionID>
        <orderID xsi:type="xsd:string">3068f0355b16367be5e4c43f4bf3c71d</orderID>
        <status xsi:type="xsd:string">Not Authorized</status>
        <errorcode xsi:type="xsd:string">004</errorcode>
        <errormessage xsi:type="xsd:string">Invalid card</errormessage>
        <AVSResult xsi:type="xsd:string">K</AVSResult>
        <FSResult xsi:type="xsd:string">NOSCORE</FSResult>
        <FSStatus xsi:type="xsd:string">0000</FSStatus>
      </return>
    </tns:SaleTransactionResponse>
  </soap:Body>
</soap:Envelope>
    XML
  end
end
