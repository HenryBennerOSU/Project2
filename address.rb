class Address
  attr_accessor :street, :city, :state, :zip_code
  def initialize(street, city, state, zip_code)
    @street = street
    @city = city
    @state = state
    @zip_code = zip_code
  end
  def valid?
    !@street.empty? &&
      !@city.empty? &&
      !@state.empty? &&
      !@zip_code.empty?
  end
  def get_full_address
    "#{@street}, #{@city}, #{@state} #{@zip_code}"
  end
end
