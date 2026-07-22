require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def valid_attributes
    {
      title: "Test",
      context: "S", problem: "T", solution: "A", outcome: "R"
    }
  end

  test "is valid with all STAR fields and a title" do
    assert Project.new(valid_attributes).valid?
  end

  test "requires a title" do
    project = Project.new(valid_attributes.except(:title))
    assert_not project.valid?
    assert_includes project.errors[:title], "can't be blank"
  end

  test "requires every STAR field" do
    Project::STAR_FIELDS.each do |field|
      project = Project.new(valid_attributes.except(field))
      assert_not project.valid?, "expected invalid without #{field}"
      assert_includes project.errors[field], "can't be blank"
    end
  end

  test "github_url is optional but must be a valid http(s) URL" do
    assert Project.new(valid_attributes.merge(github_url: "")).valid?
    assert Project.new(valid_attributes.merge(github_url: "https://example.com/x")).valid?
    assert_not Project.new(valid_attributes.merge(github_url: "not-a-url")).valid?
  end

  test "ordered scope orders by position ascending, then created_at descending" do
    older = Project.create!(valid_attributes.merge(title: "Older", position: 1, created_at: 2.days.ago))
    newer = Project.create!(valid_attributes.merge(title: "Newer", position: 1, created_at: 1.day.ago))
    first = Project.create!(valid_attributes.merge(title: "First", position: 0, created_at: 3.days.ago))

    assert_equal [ first, newer, older ],
      Project.where(title: %w[Older Newer First]).ordered.to_a
  end
end
