class ChangeRecordIdColumnType < ActiveRecord::Migration
  def change
    change_column :record_tags, :record_id, :string, null: false
  end
end
