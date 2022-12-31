# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:focus) do
      primary_key :id
      String      :ssid
      String      :uuid
      Integer     :rest_time
      Integer     :work_time
      Date :date
      DateTime :created_time
      DateTime :updated_time
    end
  end
end

# Sequel.migration do
#   change do
#     create_table(:views_inspirations) do
#       primary_key [:view_id, :inspiration_id]
#       foreign_key :view_id, :views
#       foreign_key :inspiration_id, :inspirations

#       index [:view_id, :inspiration_id]
#     end
#   end
# end
