require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
  end

  test "visiting the index lists case-study cards" do
    visit root_path

    assert_selector "h1", text: "Sistemas en producción, decisiones de arquitectura"
    assert_selector "#projects a", minimum: 1
  end

  test "opening a case study renders the four STAR sections" do
    visit project_path(@project)

    assert_selector "h1", text: @project.title
    # STAR headings are displayed uppercase via CSS, so match case-insensitively.
    [ "Situación", "Tarea", "Acción", "Resultado" ].each do |label|
      assert_text(/#{label}/i)
    end
  end
end
