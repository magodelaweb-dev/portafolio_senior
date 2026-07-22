require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @user = users(:one)
  end

  # --- Public read-only actions ---

  test "should get index without authentication" do
    get projects_url
    assert_response :success
  end

  test "should show project without authentication" do
    get project_url(@project)
    assert_response :success
  end

  test "index hides admin controls and login link when unauthenticated" do
    get projects_url
    assert_select "a[href=?]", new_session_path, count: 0
    assert_select "a[href=?]", new_project_path, count: 0
  end

  test "index shows contact channels" do
    get projects_url
    assert_select "a[href=?]", "https://www.linkedin.com/in/magodelaweb/"
    assert_select "a[href=?]", "mailto:arturo@magodelaweb.com"
    assert_select "a[href=?]", "/cv-arturo-martinez.pdf"
  end

  test "index shows new-project control and logout when authenticated" do
    sign_in_as(@user)
    get projects_url
    assert_select "a[href=?]", new_project_path
    assert_select "form[action=?]", session_path
  end

  test "show hides admin controls when unauthenticated" do
    get project_url(@project)
    assert_select "a[href=?]", edit_project_path(@project), count: 0
    assert_select "form[action=?]", project_path(@project), count: 0
  end

  test "show reveals admin controls when authenticated" do
    sign_in_as(@user)
    get project_url(@project)
    assert_select "a[href=?]", edit_project_path(@project), text: "Editar"
    assert_select "form[action=?]", project_path(@project)
  end

  # --- Protected write actions (authenticated) ---

  test "should get new when authenticated" do
    sign_in_as(@user)
    get new_project_url
    assert_response :success
  end

  test "should create project when authenticated" do
    sign_in_as(@user)
    assert_difference("Project.count") do
      post projects_url, params: { project: { context: @project.context, github_url: @project.github_url, outcome: @project.outcome, problem: @project.problem, solution: @project.solution, subtitle: @project.subtitle, title: @project.title } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should get edit when authenticated" do
    sign_in_as(@user)
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project when authenticated" do
    sign_in_as(@user)
    patch project_url(@project), params: { project: { context: @project.context, github_url: @project.github_url, outcome: @project.outcome, problem: @project.problem, solution: @project.solution, subtitle: @project.subtitle, title: @project.title } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project when authenticated" do
    sign_in_as(@user)
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  # --- Protected write actions require authentication ---

  test "new redirects to login when unauthenticated" do
    get new_project_url
    assert_redirected_to new_session_url
  end

  test "create is blocked when unauthenticated" do
    assert_no_difference("Project.count") do
      post projects_url, params: { project: { title: "Nope" } }
    end
    assert_redirected_to new_session_url
  end

  test "edit redirects to login when unauthenticated" do
    get edit_project_url(@project)
    assert_redirected_to new_session_url
  end

  test "update is blocked when unauthenticated" do
    patch project_url(@project), params: { project: { title: "Hijacked" } }
    assert_redirected_to new_session_url
    assert_not_equal "Hijacked", @project.reload.title
  end

  test "destroy is blocked when unauthenticated" do
    assert_no_difference("Project.count") do
      delete project_url(@project)
    end
    assert_redirected_to new_session_url
  end
end
