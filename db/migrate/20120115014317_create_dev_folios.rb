class CreateDevFolios < ActiveRecord::Migration
  def change
    create_table :dev_folios do |t|
      t.string :label
      t.string :job_id
      t.string :dev_id
      t.string :dev_public_key

      t.timestamps
    end
  end
end
