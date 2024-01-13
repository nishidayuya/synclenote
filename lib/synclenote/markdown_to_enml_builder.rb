require "redcarpet"

class Synclenote::MarkdownToEnmlBuilder
  HEADER = <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
    <en-note>
  EOS

  FOOTER = <<~EOS
    </en-note>
  EOS

  class << self
    def call(markdown_text)
      formatter = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(
          filter_html: true,
          hard_wrap: true,
        ),
        underline: true,
        lax_spacing: true,
        footnotes: true,
        no_intra_emphasis: true,
        superscript: true,
        strikethrough: true,
        tables: true,
        space_after_headers: true,
        fenced_code_blocks: true,
        # autolink: true,
      )
      html = formatter.render(markdown_text)
      content = [
        HEADER,
        html.gsub(/ class=\".*?\"/, "").gsub(/<(br|hr|img).*?>/, "\\&</\\1>"),
        FOOTER,
      ].join
      return content
    end
  end
end
