class CreateBrochureEnquiries < ActiveRecord::Migration
  def change
    create_table :brochure_enquiries do |t|
      t.string :name
      t.string :email
      t.integer :count, :null => false, :default => 0
      t.boolean :status

      t.timestamps
    end
  end
end
