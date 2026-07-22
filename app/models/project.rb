class Project < ApplicationRecord
  # STAR case-study fields: context (Situation), problem (Task),
  # solution (Action) and outcome (Result). Each stores GitHub-Flavored
  # Markdown that is rendered to HTML via MarkdownHelper#markdown.
  STAR_FIELDS = %i[context problem solution outcome].freeze

  validates :title, presence: true, length: { maximum: 120 }
  validates :subtitle, length: { maximum: 200 }
  validates(*STAR_FIELDS, presence: true)
  validates :github_url,
            allow_blank: true,
            format: {
              with: %r{\Ahttps?://[^\s]+\z},
              message: "must be a valid http(s) URL"
            }

  scope :ordered, -> { order(:position, created_at: :desc) }
end
