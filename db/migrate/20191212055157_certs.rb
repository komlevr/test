class Certs < ActiveRecord::Migration[6.0]
  def change
    create_table :certs do |t|
      t.string :domain   
      t.integer :status
      t.string :comment
    end
  end
end
