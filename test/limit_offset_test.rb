begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # Activate the gem you are reporting the issue against.
  gem "activerecord", "5.0.1"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :evidences do |t|
    t.text :content
    t.references :node, foreign_key: true
    t.references :issue, foreign_key: true
    t.timestamps
  end

  create_table :issues do |t|
    t.string :title
    t.references :node, foreign_key: true

    t.timestamps
  end

  create_table :nodes do |t|
    t.string :label
    t.references :project, foreign_key: true
    t.timestamps
  end

  create_table :projects do |t|
    t.string :name
    t.timestamps
  end

end

class Evidence < ActiveRecord::Base
  belongs_to :issue, touch: true
  belongs_to :node, touch: true


  def self.set_project_scope(project_id)
    default_scope do
      joins(:node).where("nodes.project_id" => project_id).readonly(false)
    end
  end
end

class Issue < ActiveRecord::Base
  belongs_to :node, touch: true

  has_many :evidence, dependent: :destroy
  has_many :affected, through: :evidence, source: :node

  def self.set_project_scope(project_id)
    default_scope do
      joins(:node).where("nodes.project_id" => project_id).readonly(false)
    end
  end
end

class Node < ActiveRecord::Base
  belongs_to :project, touch: true
  has_many :evidence, dependent: :destroy

  def self.set_project_scope(project_id)
    default_scope { where(project_id: project_id) }
  end
end

class Project < ActiveRecord::Base
  has_many :nodes, dependent: :destroy
end


class BugTest < Minitest::Test
  def test_limit_and_offset
    project = Project.create(name: 'Test')

    Evidence.set_project_scope(project.id)
    Issue.set_project_scope(project.id)
    Node.set_project_scope(project.id)

    issue    = Issue.create(title: 'My issue')
    node     = Node.create(label: 'My node')
    evidence = Evidence.create(content: 'foobar', issue: issue, node: node)


    query = 'foobar'

    result = Evidence.where("LOWER(content) LIKE LOWER(:q)", q: "%#{query}%")
      .includes(:issue, :node)
      .order(updated_at: :desc)

    sql = result.limit(25).offset(5).to_sql

    assert_equal 1, result.count
    assert_contains 'LIMIT 25', sql
    assert_contains 'OFFSET 0', sql

    assert_equal 1, result.limit(25).offset(5).count
  end
end
