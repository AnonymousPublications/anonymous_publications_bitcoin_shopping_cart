# It would be cool to be able to setup 'virtual_system' objects that are connected to databases other than the 'test' database
# so tests could be performed on multiple virtual systems concurently without having them writing to the same database
# potentially interfering with tests.  I'm not sure how easy it is to pull this off though... for now these objects are
# mostly just methods that work upon the test db, but later they can be upgraded after I go over things with someone 
# who has more xp.


class VirtualSystem
  attr_accessor :nmd
  
  # specify either :shipping or :webserver
  def initialize(sys_type)
    raise "invalid type specified for VirtualSystem" if sys_type != :shipping and sys_type != :webserver
    @type = sys_type
    
    case @type
    when :webserver
      config = {file_type: :shippable_file, symmetric_key: $FrontDoorKey}
      @nmd = NmDatafile.new(config)
    when :shipping
      config = {file_type: :address_completion_file, symmetric_key: $FrontDoorKey}
      @nmd = NmDatafile.new(config)
    end
  end
  
  def create_sales(n)
    @nmd.create_sales n
  end
  
  def export_sf
    raise "Only :webserver type VirtualSystems can export shippable files" if @type != :webserver
    @nmd.dup
  end
  
  def export_acf(n_shipped, n_errors = :ignored)
    raise "Only :shipping type VirtualSystems can export shippable files" if @type != :shipping
    @imported_nmd.simulate_address_completion_response(n_shipped)
  end
  
  def import_sf!(shippable_file)
    raise "Only :shipping type VirtualSystems can import shippable files" if @type != :shipping
    @imported_nmd = shippable_file
    up = shippable_file.generate_upload_params
  end
  
  def import_acf!(address_completion_file)
    raise "Only :webserver type VirtualSystems can import shippable files" if @type != :webserver
    @imported_nmd = address_completion_file
    up = address_completion_file.generate_upload_params
    # TODu finish
  end
  
  # This function deletes all sales, line_items, and addresses that were created by this object...
  # This method is far worse than setting up a 4th and 5th database and working on it from here
  def clear_database
    # TODu:  I should use 4th and 5th databases...
  end
  
end
   




