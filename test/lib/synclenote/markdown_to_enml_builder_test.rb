require "test_helper"

class Synclenote::MarkdownToEnmlBuilderTest < Test::Unit::TestCase
  sub_test_case(".call") do
    data(
      regular_text: {
        markdown_text: <<~EOS,
          body
        EOS
        expected_enml_text: <<~EOS,
          <p>body</p>
        EOS
      },
      fenced_code_blocks: {
        markdown_text: <<~EOS,
          ```ruby
          1 + 2 * 3
          ```
        EOS
        # remove "class" attribute
        expected_enml_text: <<~EOS,
          <pre><code>1 + 2 * 3
          </code></pre>
        EOS
      },
      hard_wrap: {
        markdown_text: <<~EOS,
          abc
          def
        EOS
        # convert "<br/>" to "<br></br>"
        expected_enml_text: <<~EOS,
          <p>abc<br></br>
          def</p>
        EOS
      },
      hyperlink: {
        markdown_text: <<~EOS,
          [link text](https://example.org/?foo=bar&baz=quux;hoge=fuga#anchor)
        EOS
        # convert "&" to "&amp;"
        expected_enml_text: <<~EOS,
          <p><a href="https://example.org/?foo=bar&amp;baz=quux;hoge=fuga#anchor">link text</a></p>
        EOS
      },
    )
    test("returns ENML String") do |h|
      assert_equal(
        [
          Synclenote::MarkdownToEnmlBuilder::HEADER,
          h[:expected_enml_text],
          Synclenote::MarkdownToEnmlBuilder::FOOTER,
        ].join,
        Synclenote::MarkdownToEnmlBuilder.(h[:markdown_text]),
      )
    end
  end
end
