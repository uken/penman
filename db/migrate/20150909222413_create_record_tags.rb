class CreateRecordTags < ActiveRecord::Migration
  def change
    create_table :record_tags do |t|
      t.integer :record_id, null: false, default: 0
      t.string :record_type, null: false
      t.string :candidate_key, null: false
      t.string :tag, null: false
      t.boolean :created_this_session, null: false, default: false
      t.timestamps
    end

    add_index 'record_tags', ['record_id', 'record_type'], name: 'index_record_tags_on_record_id_and_record_type', using: :btree
  end
end
