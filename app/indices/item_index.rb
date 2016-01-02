ThinkingSphinx::Index.define :item, with: :active_record, delta: true do
  indexes :name

  set_property min_prefix_len: 1
  where "parent_id IS NOT NULL"
end
