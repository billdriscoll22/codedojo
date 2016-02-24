class Exercise < ActiveRecord::Base
  attr_accessible :content, :index, :section_id, :proj_type, :rendered_content
	validates :content, :presence => true
  belongs_to :section
  has_many :template_files, :dependent => :delete_all
  has_many :test_files, :dependent => :delete_all
  has_many :user_files, :dependent => :delete_all
  has_many :results, :dependent => :delete_all
  has_many :output_validators, :dependent => :delete_all

  accepts_nested_attributes_for :template_files, :test_files
  before_save :render_body
  

  private
  def render_body
    require 'redcarpet'
    # renderer = Redcarpet::Render::HTML.new
    renderer = PygmentizeHTML
    extensions = {fenced_code_blocks: true,
                  filter_html: true,
                  safe_links_only: true}
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    self.rendered_content = redcarpet.render self.content
  end
end


class PygmentizeHTML < Redcarpet::Render::HTML
  def block_code(code, language)
    require 'pygmentize'
    Pygmentize.process(code, language)
  end
end
