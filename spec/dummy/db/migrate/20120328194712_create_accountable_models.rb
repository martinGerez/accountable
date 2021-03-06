class CreateAccountableModels < ActiveRecord::Migration
  def self.up

    create_table :accounts do |t|
      t.string :type
      t.string :name
      t.references :owner, :polymorphic => true
    end
    add_index :accounts, [:owner_id, :owner_type]

    create_table :account_joins do |t|
      t.integer :detail_account_id, :references => :accounts
      t.integer :summary_account_id, :references => :accounts
    end
    add_index :account_joins, :detail_account_id
    add_index :account_joins, :summary_account_id

    create_table :balances do |t|
      t.integer :account_id
      t.datetime :evaluated_at
      t.decimal :balance, :precision => 14, :scale => 2
    end
    add_index :balances, :account_id

    create_table :transactions do |t|
      t.string :type
      t.string :description
      t.datetime :transaction_date
      t.references :auxilliary_model, :polymorphic => true
      t.boolean :require_funds
      t.timestamps
    end
    add_index :transactions, :transaction_date
    add_index :transactions, [:auxilliary_model_id, :auxilliary_model_type], :name => :index_transactions_on_auxilliary_model

    create_table :entries do |t|
      t.string :type
      t.integer :detail_account_id, :references => :accounts
      t.references :transaction
      t.decimal :amount, :precision => 14, :scale => 2
    end
    add_index :entries, :detail_account_id
    add_index :entries, :transaction_id

    create_table :invoices do |t|
      t.integer :buyer_account_id, :references => :accounts
      t.integer :seller_account_id, :references => :accounts
      t.boolean :closed, :default => false
    end
    add_index :invoices, :buyer_account_id
    add_index :invoices, :seller_account_id

    create_table :invoice_lines do |t|
      t.references :invoice
      t.integer :line_item_id, :references => :entries
    end
    add_index :invoice_lines, :invoice_id
    add_index :invoice_lines, :line_item_id
  end

  def self.down
    drop_table :invoice_lines
    drop_table :invoices
    drop_table :entries
    drop_table :transactions
    drop_table :balances
    drop_table :account_joins
    drop_table :accounts
  end
end
