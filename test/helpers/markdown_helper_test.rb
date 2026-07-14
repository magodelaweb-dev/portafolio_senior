require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "renders basic GFM to HTML" do
    html = markdown("# Título\n\n**negrita** y `code`")
    assert_includes html, "<h1"
    assert_includes html, "<strong>negrita</strong>"
    assert_includes html, "<code>code</code>"
  end

  test "renders GFM tables" do
    html = markdown("| a | b |\n|---|---|\n| 1 | 2 |")
    assert_includes html, "<table>"
  end

  test "strips raw HTML to prevent stored XSS" do
    html = markdown("<script>alert('x')</script>")
    assert_not_includes html, "<script>"
    assert_includes html, "raw HTML omitted"
  end

  test "returns a blank html_safe string for nil or empty input" do
    assert_equal "", markdown(nil)
    assert_equal "", markdown("")
    assert_predicate markdown(nil), :html_safe?
  end

  test "markdown_excerpt strips syntax and truncates" do
    excerpt = markdown_excerpt("# Encabezado\n\n**Texto** con [enlace](http://x) y `code`.", length: 20)
    assert_not_includes excerpt, "#"
    assert_not_includes excerpt, "*"
    assert_operator excerpt.length, :<=, 20
  end

  test "markdown_excerpt returns empty string for blank input" do
    assert_equal "", markdown_excerpt(nil)
    assert_equal "", markdown_excerpt("")
  end
end
