

class CreatePreferences < ActiveRecord::Migration[6.0]
  def change
    create_table :preferences do |t|
      t.string     :owner_type, null: false
      t.uuid       :owner_id, null: false
      t.references :group, polymorphic: true
      t.string     :key, null: false
      t.jsonb      :value, null: false, default: {}
      t.timestamps
    end
    add_index :preferences, %i[ owner_type owner_id key group_id group_type], unique: true, name: 'index_preferences_on_owner_and_group_and_key'
  end
end
