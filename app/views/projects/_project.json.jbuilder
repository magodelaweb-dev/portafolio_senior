json.extract! project, :id, :title, :subtitle, :context, :problem, :solution, :outcome, :github_url, :position, :created_at, :updated_at
json.url project_url(project, format: :json)
