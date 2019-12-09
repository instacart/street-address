require 'minitest/autorun'
require 'street_address'

class AddressCanadaTest < MiniTest::Test
  ADDRESSES = {
      "80 Wellington St, Ottawa, ON K1P 5K9" => {
          :line1 => "80 Wellington St",
          :line2 => "Ottawa, ON K1P 5K9"
      },
      "UNIT 106 25 SUNSET BLVD WHITECOURT AB T7S 1L2" => {
          :line1 => "25 Sunset Blvd Unit 106",
          :line2 => "Whitecourt, AB T7S 1L2"
      },
      "290 Bremner Blvd Suite 123, Toronto, ON M5V 3L9" => {
      :line1 => "290 Bremner Blvd Suite 123",
      :line2 => "Toronto, ON M5V 3L9"
      },
      "290 Bremner Blvd SE Suite 123, Toronto, ON M5V 3L9" => {
          :line1 => "290 Bremner Blvd S Suite 123",
          :line2 => "Toronto, ON M5V 3L9"
      },
      "Suite 123 290 Bremner Blvd S, Toronto, ON M5V 3L9" => {
          :line1 => "290 Bremner Blvd S Suite 123",
          :line2 => "Toronto, ON M5V 3L9"
      },
  }
  def test_line1_with_valid_addresses
    ADDRESSES.each_pair do |address, expected|
      addr = StreetAddress::Canada.parse(address)
      assert_equal addr.line1, expected[:line1]
    end
  end

  def test_to_s_for_line1
    address = "80 Wellington St, Ottawa, ON K1P 5K9"
    addr = StreetAddress::Canada.parse(address)
    assert_equal addr.to_s(:line1), addr.line1
  end

  def test_line2_with_valid_addresses
    ADDRESSES.each_pair do |address, expected|
      addr = StreetAddress::Canada.parse(address)
      assert_equal addr.line2, expected[:line2]
    end
  end

  def test_to_s_for_line2
    address = "80 Wellington St, Ottawa, ON K1P 5K9"
    addr = StreetAddress::Canada.parse(address)
    assert_equal addr.to_s(:line2), addr.line2
  end


  def test_full_postal_code
    address = "80 Wellington St, Ottawa, ON K1P 5K9"
    addr = StreetAddress::Canada.parse(address)
    assert_equal "K1P 5K9", addr.full_postal_code
  end
end
