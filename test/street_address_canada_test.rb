require 'minitest/autorun'
require 'street_address'

class StreetAddressCanadaTest < MiniTest::Test
  CA_ADDRESSES = {
      "80 Wellington St, Ottawa, ON K1P 5K9" => {
          :number => "80",
          :postal_code => "K1P 5K9",
          :state => "ON",
          :street => "Wellington",
          :street_type => "St",
          :city => "Ottawa",
      },
      "UNIT 123 80 Wellington St S, Ottawa, ON K1P 5K9" => {
          :number => "80",
          :postal_code => "K1P 5K9",
          :state => "ON",
          :street => "Wellington",
          :street_type => "St",
          :city => "Ottawa",
          :unit => "123",
          :unit_prefix => "Unit",
          :street2 => nil,
          :suffix => "S"
      },
      "290 Bremner Blvd SE Suite 123, Toronto, ON M5V 3L9" => {
          :number => "290",
          :postal_code => "M5V 3L9",
          :state => "ON",
          :street => "Bremner",
          :street_type => "Blvd",
          :city => "Toronto",
          :unit => "123",
          :unit_prefix => "Suite",
          :street2 => nil,
          :suffix => "SE"
      },
      "800 Macleod Trail SE, Calgary, AB T2P 2M5" => {
          :number => "800",
          :postal_code => "T2P 2M5",
          :state => "AB",
          :street => "Macleod",
          :street_type => "Trl",
          :city => "Calgary",
          :suffix => "SE"
      }
  }

  def test_address_parsing
    CA_ADDRESSES.each_pair do |address, expected|
        addr = StreetAddress::Canada.parse(address)
        assert_equal addr.intersection?, false
        compare_expected_to_actual_hash(expected, addr.to_h, address)
      end
  end
  def compare_expected_to_actual_hash(expected, actual, address)
    expected.each_pair do |expected_key, expected_value|
      assert_equal actual[expected_key], expected_value, "For address '#{address}',  #{actual[expected_key]} != #{expected_value}"
    end
  end
end
