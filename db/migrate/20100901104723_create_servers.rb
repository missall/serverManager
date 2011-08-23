class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.string :name
      t.string :ip_address
      t.string :login_name
      t.string :password
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
