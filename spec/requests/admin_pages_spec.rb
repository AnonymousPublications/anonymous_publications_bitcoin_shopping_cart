require 'spec_helper'

describe "AdminPages" do
  before :all do
    populate_products
    @n_products = Product.count
    @first_product = Product.first
    @user = create_admin_user
    login @user
  end
  
  describe "GET /admin_pages/download_database" do
    it "works!" do
      get "/admin_pages/download_database"
      
      zip_file_contents = response.body  # password protected zip's binary data
      
      yaml_data = WorkHard.decrypt_encrypted_string_for_testing(zip_file_contents)
      # hack the yaml data so it can be loading by standard means
      yaml_data = yaml_data.gsub("---", "")
      yaml_data = YAML.load(yaml_data)
      product_records = yaml_data["products"]["records"]

      product_records.count.should eq @n_products
      
      pwtd_record = product_records.first
      pwtd_record_name = pwtd_record[3]
      
      pwtd_record_name.should eq @first_product.name
    end
  end
end

