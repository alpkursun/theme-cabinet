class CreateJobFolios < ActiveRecord::Migration
  def change
    create_table :job_folios do |t|
      t.string :label
      t.string :content_path

      t.timestamps
    end
  end
end
