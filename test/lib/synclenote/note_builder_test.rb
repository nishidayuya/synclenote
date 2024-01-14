require "test_helper"

class Synclenote::NoteBuilderTest < Test::Unit::TestCase
  sub_test_case(".call") do
    data(
      regular: {
        raw_note_text: <<~EOS,
          # title

          body
        EOS
        expected_title: "title",
        expected_additional_tag_names: [],
        expected_content_body: <<~EOS,
          <p>body</p>
        EOS
      },
      no_title: {
        raw_note_text: <<~EOS,
          # \t

          body
        EOS
        expected_title: Synclenote::NoteBuilder::TITLE_IF_EMPTY,
        expected_additional_tag_names: [],
        expected_content_body: <<~EOS,
          <p>body</p>
        EOS
      },
      have_tags: {
        raw_note_text: <<~EOS,
          # [foo][bar-baz] title

          body
        EOS
        expected_title: "title",
        expected_additional_tag_names: %w[foo bar-baz],
        expected_content_body: <<~EOS,
          <p>body</p>
        EOS
      },
    )
    test("returns Note object") do |h|
      Tempfile.create do |f|
        f.write(h[:raw_note_text])
        f.close
        raw_note_path = Pathname(f.path)
        note = Synclenote::NoteBuilder.(raw_note_path)
        assert_equal(h[:expected_title], note.title)
        assert_equal(
          [
            *Synclenote::NoteBuilder::DEFAULT_TAGS,
            *h[:expected_additional_tag_names],
          ].sort,
          note.tagNames.sort,
        )
        assert_equal(
          [
            Synclenote::MarkdownToEnmlBuilder::HEADER,
            h[:expected_content_body],
            Synclenote::MarkdownToEnmlBuilder::FOOTER,
          ].join,
          note.content,
        )
      end
    end
  end
end
