class AddAdminFlgToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin_flg, :boolean
  end
end
