class AddAboutToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :about, :string
  end
end
