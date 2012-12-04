require 'test_helper'

class RemoteSoEasyPayTest < Test::Unit::TestCase


  def setup
    @gateway = SoEasyPayGateway.new(fixtures(:so_easy_pay))

    @amount = 100
    @credit_card = credit_card('4976000000003436',
                               :month => 12,
                               :year => 2012,
                               :verification_value => '452',
                               :first_name => 'John',
                               :last_name => 'Watson')
    @declined_card = credit_card('4000300011112220')

    @options = {
      :order_id => generate_unique_id,
      :billing_address => address(:address_1 => '32 Edward Street', :city => 'Camborne,', :state => 'Cornwall', :zip => 'TR14 8PA', :country => 'GB'),
      :description => 'Store Purchase',
      :ip => '127.0.0.1',
      :currency => 'GBP',
      :email => 'an@email.com'
    }
  end

  def test_successful_purchase
    puts @credit_card.inspect
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'Transaction successful', response.message
  end

  # def test_unsuccessful_purchase
  #   assert response = @gateway.purchase(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end

  # def test_authorize_and_capture
  #   amount = @amount
  #   assert auth = @gateway.authorize(amount, @credit_card, @options)
  #   assert_success auth
  #   assert_equal 'Success', auth.message
  #   assert auth.authorization
  #   assert capture = @gateway.capture(amount, auth.authorization)
  #   assert_success capture
  # end

  # def test_failed_capture
  #   assert response = @gateway.capture(@amount, '')
  #   assert_failure response
  #   assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
  # end

  # def test_invalid_login
  #   gateway = SoEasyPayGateway.new(
  #               :login => '',
  #               :password => ''
  #             )
  #   assert response = gateway.purchase(@amount, @credit_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
  # end
end
