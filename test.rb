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


# debugger

puts result.to_sql
puts result.limit(25).offset(0).to_sql