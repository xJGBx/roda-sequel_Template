Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false, unique: true
      String :email, null: false, unique: true
      String :password_digest, null: false
      DateTime :reset_code, unique: true
      DateTime :reset_code_expires_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
