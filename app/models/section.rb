class Section < ActiveRecord::Base
  attr_accessible :content, :index, :subtitle, :tutorial_id, :rendered_content, :exercises_attributes
	validates :subtitle, :content, :index, :presence => true
  has_many :exercises, :dependent => :destroy
  belongs_to :tutorial

  accepts_nested_attributes_for :exercises
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

def before_destroy
    self.exercises.destroy_all
end



class PygmentizeHTML < Redcarpet::Render::HTML
  def block_code(code, language)
    require 'pygmentize'
    Pygmentize.process(code, language)
  end
end
