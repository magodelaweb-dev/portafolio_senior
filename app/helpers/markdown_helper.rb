module MarkdownHelper
  # Safe GitHub-Flavored Markdown rendering.
  #
  # `render.unsafe` is kept false so raw/embedded HTML in the source text is
  # omitted instead of injected, protecting against stored XSS while still
  # letting us mark the output as html_safe.
  MARKDOWN_OPTIONS = {
    render: { unsafe: false, hardbreaks: false, github_pre_lang: true },
    extension: {
      table: true,
      strikethrough: true,
      autolink: true,
      tasklist: true,
      footnotes: true
    }
  }.freeze

  def markdown(text)
    return "".html_safe if text.blank?

    ::Commonmarker.to_html(text.to_s, options: MARKDOWN_OPTIONS).html_safe
  end

  # Plain-text, single-line excerpt for cards and previews: strips the most
  # common Markdown syntax and collapses whitespace before truncating.
  def markdown_excerpt(text, length: 180)
    return "" if text.blank?

    plain = text.to_s
                .gsub(/```.*?```/m, " ")          # fenced code blocks
                .gsub(/[#>*_`~\-\[\]()!]/, " ")   # markdown punctuation
                .squish
    truncate(plain, length: length, separator: " ")
  end
end
