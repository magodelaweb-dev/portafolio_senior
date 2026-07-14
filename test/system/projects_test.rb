require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
  end

  test "visiting the index lists case-study cards" do
    visit root_path

    assert_selector "h1", text: "Estudios de caso"
    assert_selector "#projects a", minimum: 1
  end

  test "opening a case study renders the four STAR sections" do
    visit project_path(@project)

    assert_selector "h1", text: @project.title
    %w[Situación Tarea Acción Resultado].each do |label|
      assert_text label
    end
  end
end
